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
  client_secret="987c8e05-7a4c-4f5d-abd9-89ca0a13dc2b"
  features {}
}

resource "azurerm_resource_group" "__resourcegroupname__" {
  name     = "__resourcegroupname__"
  location = "__resourcelocation__"
}

resource "azurerm_virtual_network" "__vnetname__" {
  name                = "__vnetname__"
  address_space       = ["100.64.0.0/10"]
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name
}

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.127.255.0/24"
}

resource "azurerm_public_ip" "__bastionpublicipname__" {
  name                = "__bastionpublicipname__"
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "__bastionname__" {
  name                = "__bastionname__"
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.__bastionpublicipname__.id
  }
}

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.64.0.0/24"
}

resource "azurerm_public_ip" "__azfwpipname__" {
  name                = "__azfwpipname__"
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "__azfwname__" {
  name                = "__azfwname__"
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name

  ip_configuration {
    name                 = "__azfwipconfigname__"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.__azfwpipname__.id
  }
}

resource "azurerm_subnet" "__vmsubnetname__" {
  name                 = "__vmsubnetname__"
  resource_group_name  = azurerm_resource_group.__resourcegroupname__.name
  virtual_network_name = azurerm_virtual_network.__vnetname__.name
  address_prefix       = "100.64.1.0/24"
}

resource "azurerm_network_interface" "__vmname__-VMNIC1" {
  name                = "__vmname__-VMNIC1"
  location            = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.__vmsubnetname__.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "__vmname__" {
  name                = "__vmname__"
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name
  location            = azurerm_resource_group.__resourcegroupname__.location
  size                = "__vmsize__"
  admin_username      = "__vmadminusername__"
  admin_password      = "__vmadminuserpassword__"
  network_interface_ids = [
    azurerm_network_interface.__vmname__-VMNIC1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "__osdiskstoragetier__"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_route_table" "__udrname__" {
  name                          = "__udrname__"
  location                      = azurerm_resource_group.__resourcegroupname__.location
  resource_group_name           = azurerm_resource_group.__resourcegroupname__.name
  disable_bgp_route_propagation = false

  route {
    name                   = "route1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.__azfwname__.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "HUB"
  }
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.__vmsubnetname__.id
  route_table_id = azurerm_route_table.__udrname__.id
}

resource "azurerm_firewall_application_rule_collection" "FR-AllowAzurePortal" {
  name                = "FR-AllowPortal"
  azure_firewall_name = azurerm_firewall.__azfwname__.name
  resource_group_name = azurerm_resource_group.__resourcegroupname__.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "FR-AllowAzurePortal"

    source_addresses = [
      "100.64.0.0/10",
    ]

    target_fqdns = [
      "*.azure.com",
      "*.microsoftonline.com",
      "*.msauth.net",
      "*.msftauth.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
