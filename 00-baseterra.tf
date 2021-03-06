terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "__terraformstorageaccount__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__storagekey__"
  }
}

provider "azurerm" {
  version = "=2.5.0"
  features {}
}

resource "azurerm_resource_group" "__resourcegroupname__" {
  name     = "__tagenvironment__-__regionprefix__-__resourcegroupname__"
  location = "__resourcelocation__"

  tags = {
    environment = "__tagenvironment__"
    application = "__tagapplication__"
  }
}

resource "azurerm_virtual_network" "__vnetname__" {
  name                = "__tagenvironment__-__regionprefix__-__vnetname__"
  address_space       = ["100.64.0.0/10"]
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name

  tags = {
    environment = "__tagenvironment__"
    application = "__tagapplication__"
  }
}

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.127.255.0/24"
}

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.64.0.0/24"
}

resource "azurerm_subnet" "__vmsubnetname__" {
  name                 = "__tagenvironment__-__regionprefix__-__vmsubnetname__"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.64.1.0/24"
}

# resource "azurerm_public_ip" "__bastionpublicipname__" {
#   name                = "__tagenvironment__-__regionprefix__-__bastionpublicipname__"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_bastion_host" "__bastionname__" {
#   name                = "__tagenvironment__-__regionprefix__-__bastionname__"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.AzureBastionSubnet.id
#     public_ip_address_id = azurerm_public_ip.__bastionpublicipname__.id
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_public_ip" "__azfwpipname__" {
#   name                = "__tagenvironment__-__regionprefix__-__azfwpipname__"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_firewall" "__azfwname__" {
#   name                = "__tagenvironment__-__regionprefix__-__azfwname__"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name

#   ip_configuration {
#     name                 = "__azfwipconfigname__"
#     subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
#     public_ip_address_id = azurerm_public_ip.__azfwpipname__.id
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_route_table" "__udrname__" {
#   name                          = "__tagenvironment__-__regionprefix__-__udrname__"
#   location                      = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name           = azurerm_resource_group.__resourcegroupname__.name
#   disable_bgp_route_propagation = false

#   route {
#     name                   = "route1"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = azurerm_firewall.__azfwname__.ip_configuration[0].private_ip_address
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = azurerm_subnet.__vmsubnetname__.id
#   route_table_id = azurerm_route_table.__udrname__.id
# }

# resource "azurerm_firewall_application_rule_collection" "FR-AllowAzurePortal" {
#   name                = "FR-AllowAzurePortal"
#   azure_firewall_name = azurerm_firewall.__azfwname__.name
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   priority            = 101
#   action              = "Allow"

#   rule {
#     name = "FR-AllowAzurePortal"

#     source_addresses = [
#       "100.64.0.0/10",
#     ]

#     target_fqdns = [
#       "*.azure.com",
#       "*.microsoftonline.com",
#       "*.msauth.net",
#       "*.msftauth.net"
#     ]

#     protocol {
#       port = "443"
#       type = "Https"
#     }
#   }
# }

# resource "azurerm_network_interface" "win__vmname__-VMNIC1" {
#   name                = "__tagenvironment__-__regionprefix__-win__vmname__-VMNIC1"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.__vmsubnetname__.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_windows_virtual_machine" "win__vmname__" {
#   name                = "__tagenvironment__-__regionprefix__-win__vmname__"
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   size                = "__vmsize__"
#   admin_username      = "__vmadminusername__"
#   admin_password      = "__vmadminuserpassword__"
#   zone                = "__vmzone__"
#   network_interface_ids = [
#     azurerm_network_interface.win__vmname__-VMNIC1.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "__osdiskstoragetier__"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_public_ip" "__nixvmpipname__" {
#   name                = "__tagenvironment__-__regionprefix__-__nixvmpipname__"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_network_interface" "nix__vmname__-VMNIC1" {
#   name                = "__tagenvironment__-__regionprefix__-nix__vmname__-VMNIC1"
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.__vmsubnetname__.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.__nixvmpipname__.id
#   }

#   tags = {
#     environment = "__tagenvironment__"
#     application = "__tagapplication__"
#   }
# }

# resource "azurerm_linux_virtual_machine" "nix__vmname__" {
#   name                = "__tagenvironment__-__regionprefix__-nix__vmname__"
#   resource_group_name = azurerm_resource_group.__resourcegroupname__.name
#   location            = azurerm_resource_group.__resourcegroupname__.location
#   size                = "__vmsize__"
#   admin_username      = "__vmadminusername__"
#   admin_password      = "__vmadminuserpassword__"
#   disable_password_authentication = "false"
#   network_interface_ids = [
#     azurerm_network_interface.nix__vmname__-VMNIC1.id,
#   ]

#   # admin_ssh_key {
#   #   username   = "adminuser"
#   #   public_key = file("~/.ssh/id_rsa.pub")
#   # }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "__osdiskstoragetier__"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }