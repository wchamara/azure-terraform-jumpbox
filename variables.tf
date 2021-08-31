variable "customer_code" {
  type        = string
  description = "This is 3 letter customer code / org organization code. This can be found within Dynamics or from a PM/SDM/AE"
}
variable "interactive_resource_group_name" {
  type        = string
  default     = "RGP-INT01"
  description = "Name of the interactive management resource group without the customer code"
}
variable "interactive_resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Name of the interactive management resource group"
}
variable "management_server_name" {
  type        = string
  description = "This is the name of the management server without customer code"
  default     = "MGMTBOX01"
}
variable "admin_username" {
  type        = string
  default     = "IntAdmin1"
  description = "This is the local admin user name of the management server"
}
variable "admin_password" {
  type        = string
  description = "Password for the local admin user"
}
variable "management_server_os_disk_name" {
  type        = string
  default     = "DSK-OS01"
  description = "The name of the management server os disk"
}
variable "nic_name" {
  type        = string
  default     = "NIC"
  description = "The name of the management server NIC"
}
variable "management_server_public_ip" {
  type        = string
  default     = "VIP"
  description = "The name of the management server public IP"
}
variable "interactive_subnet_id" {
  type        = string
  description = "The ID of the interactive subnet. This can be referenced from the output of the vnet module"
}
variable "interactive_subnet_nsg_name" {
  type        = string
  description = "The name of the interactive subnet. This can be referenced from the output of the vnet module"
}
variable "rdp_to_jumpbox_ips" {
  type = list(any)
  default = ["49.255.131.66/32",
    "49.255.131.74/32",
    "49.255.227.66/32",
    "49.255.177.222/32",
    "49.255.7.94/32",
    "49.255.7.90/32",
    "49.255.156.22/32",
    "203.176.107.208/32",
    "203.161.148.30/32",
    "203.161.144.190",
    "150.207.158.229",
    "61.68.114.69",
    "120.147.137.58",
    "172.29.10.10",
    "182.23.214.17",
    "49.255.144.22",
    "203.176.100.51"
  ]
}
variable "size" {
  type        = string
  default     = "Standard_B2s"
  description = "Replace the vm size if non standard vm size required"
}

variable "time_zone" {
  type        = string
  default     = "AUS Eastern Standard Time"
  description = "This is the time zone for shutting down the management server. Update the time zone if the management server is deployed to different time zone"
}

variable "daily_shutdown_time" {
  type        = string
  default     = "2200"
  description = "This is the time for when the management serverver will be shutdown daily. It is based on the timezone defined in the <time_zone> variable."
}

variable "create_interactive_resource_group" {
  type        = bool
  default     = true
  description = "set this to false to use existing an existing Resource Group (e.g. a customer provided resource group), and provide the resource group name in the <existing_resource_group_name> variable."
}
variable "existing_resource_group_name" {
  type        = string
  description = "This will be where the management vm will be deployed if <create_interactive_resource_group> is set to false."
}
variable "customer_core_resource_group_name" {
  type        = string
  default     = "RGP-CORE01"
  description = "The name of Interactive's resource group without the prefix (var.customer_code) prepended"
}
variable "additional_tags" {
  description = "Standard tags will be applied. If you have additional tags, use the format key = value"
  type        = map(string)
  default = {
    # INTMonitored        = "true"
    # INTOSPatchGroup     = "None"
    # INTBackupIDataAgent = "False"
    # INTBackupImage      = "False"
    # INTAlerting         = "False"
    # INTAV               = "True"
  }
}
variable "availability_name" {
  type    = string
  default = "AVAIL"
}
variable "platform_fault_domain_count" {
  type    = string
  default = "2"
}
variable "platform_update_domain_count" {
  type    = string
  default = "5"
}
variable "source_image_reference" {
  type        = map(string)
  description = <<EOT
source_image_reference supports the following:
publisher - Specifies the publisher of the image used to create the virtual machines.
offer - Specifies the offer of the image used to create the virtual machines.
sku - Specifies the SKU of the image used to create the virtual machines.
version - Specifies the version of the image used to create the virtual machines.

Interactive's current standard is Windows Server 2016 as set as default values for this variable.
NOTE: The virtual machine is deployed as a Windows virtual machine and therefore will fail if a Linux source_image_reference is used
EOT
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
