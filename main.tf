locals {
  csp_resource_group_name   = upper(format("%s-%s", var.customer_code, var.csp_resource_group_name))
  nic_name                          = upper(format("%s-%s-%s", var.customer_code, var.nic_name, local.management_server_name))
  availability_name                 = upper(format("%s-%s-%s", var.customer_code, var.availability_name, var.management_server_name))
  management_server_name            = upper(format("%s-%s", var.customer_code, var.management_server_name))
  management_server_public_ip_name  = upper(format("%s-%s-%s", var.customer_code, var.management_server_public_ip, local.management_server_name))
  customer_core_resource_group_name = upper(format("%s-%s", var.customer_code, var.customer_core_resource_group_name))
  os_disk_name                      = upper(format("%s-%s", local.management_server_name, var.management_server_os_disk_name))
  tags                              = merge( var.standard_tags, var.additional_tags)
}


########## Create csp Resource Group ############################################
resource "azurerm_resource_group" "csp_resource_group" {
  count    = var.create_csp_resource_group ? 1 : 0
  name     = local.csp_resource_group_name
  location = var.csp_resource_group_location
  tags     = local.tags
}

data "azurerm_resource_group" "csp_resource_group" {
  count = var.create_csp_resource_group ? 0 : 1
  name  = var.existing_resource_group_name
}


resource "azurerm_availability_set" "management_vm_availability_set" {
  name                         = local.availability_name
  resource_group_name          = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].name : data.azurerm_resource_group.csp_resource_group[0].name
  location                     = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].location : data.azurerm_resource_group.csp_resource_group[0].location
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  tags                         = local.tags
  depends_on = [
    azurerm_resource_group.csp_resource_group
  ]
}

resource "azurerm_public_ip" "management_server_public_ip" {
  name                = local.management_server_public_ip_name
  resource_group_name = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].name : data.azurerm_resource_group.csp_resource_group[0].name
  location            = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].location : data.azurerm_resource_group.csp_resource_group[0].location
  allocation_method   = "Static"
  tags                = local.tags
  depends_on = [
    azurerm_resource_group.csp_resource_group
  ]
}

resource "azurerm_network_interface" "management_vm_nic" {
  name                = local.nic_name
  resource_group_name = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].name : data.azurerm_resource_group.csp_resource_group[0].name
  location            = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].location : data.azurerm_resource_group.csp_resource_group[0].location
  tags                = local.tags
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.csp_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.management_server_public_ip.id
  }
  depends_on = [
    azurerm_resource_group.csp_resource_group

  ]
}

resource "azurerm_windows_virtual_machine" "management_vm" {
  name                  = local.management_server_name
  resource_group_name   = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].name : data.azurerm_resource_group.csp_resource_group[0].name
  location              = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].location : data.azurerm_resource_group.csp_resource_group[0].location
  network_interface_ids = [azurerm_network_interface.management_vm_nic.id]
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  #availability_set_id   = azurerm_availability_set.management_vm_availability_set.id
  zone = null
  os_disk {
    name                 = local.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
  tags = merge(
    local.tags    
  )
  depends_on = [
    azurerm_resource_group.csp_resource_group
  ]
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  virtual_machine_id    = azurerm_windows_virtual_machine.management_vm.id
  location              = var.create_csp_resource_group ? azurerm_resource_group.csp_resource_group[0].location : data.azurerm_resource_group.csp_resource_group[0].location
  enabled               = true
  daily_recurrence_time = var.daily_shutdown_time
  timezone              = var.time_zone
  notification_settings {
    enabled = false
  }
}

########## csp internal subnet NSG rules for management server  #################
resource "azurerm_network_security_rule" "Allow_RDP_to_Jumpbox" {
  name                        = "Allow_RDP_to_Jumpbox"
  description                 = "Allow_RDP_to_Jumpbox"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = var.rdp_to_jumpbox_ips
  destination_address_prefix  = azurerm_network_interface.management_vm_nic.private_ip_address
  access                      = "allow"
  priority                    = 500
  direction                   = "inbound"
  resource_group_name         = local.customer_core_resource_group_name
  network_security_group_name = var.csp_subnet_nsg_name
}

resource "azurerm_network_security_rule" "outbound_connectivity_to_internet" {
  name                        = "outbound_connectivity_to_internet"
  description                 = "outbound_connectivity_to_internet"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = [80, 443]
  source_address_prefix       = azurerm_network_interface.management_vm_nic.private_ip_address
  destination_address_prefix  = "internet"
  access                      = "allow"
  priority                    = 600
  direction                   = "outbound"
  resource_group_name         = local.customer_core_resource_group_name
  network_security_group_name = var.csp_subnet_nsg_name
}

resource "azurerm_network_security_rule" "outbound_connectivity_to_customer_Subnets" {
  name                        = "outbound_connectivity_to_customer_Subnets"
  description                 = "outbound_connectivity_to_customer_Subnets"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = [3389, 22]
  source_address_prefix       = azurerm_network_interface.management_vm_nic.private_ip_address
  destination_address_prefix  = "VirtualNetwork"
  access                      = "allow"
  priority                    = 700
  direction                   = "outbound"
  resource_group_name         = local.customer_core_resource_group_name
  network_security_group_name = var.csp_subnet_nsg_name
}
