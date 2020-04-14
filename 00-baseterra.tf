provider "azurerm" {
  version = "=2.5.0"
  features {}
}

resource "azurerm_resource_group" "RG-WE-Common-Network" {
  name     = "RG-WE-Common-Network"
  location = "West Europe"
}

resource "azurerm_virtual_network" "VN-WE-HubVNET" {
  name                = "VN-WE-HubVNET"
  address_space       = ["100.64.0.0/10"]
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name
}

resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.RG-WE-Common-Network.name
  virtual_network_name = azurerm_virtual_network.VN-WE-HubVNET.name
  address_prefix       = "100.127.255.0/24"
}

resource "azurerm_public_ip" "PI-WE-BastionPIP" {
  name                = "PI-WE-BastionPIP"
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "BN-WE-Bastion" {
  name                = "BN-WE-Bastion"
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.AzureBastionSubnet.id
    public_ip_address_id = azurerm_public_ip.PI-WE-BastionPIP.id
  }
}

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.RG-WE-Common-Network.name
  virtual_network_name = azurerm_virtual_network.VN-WE-HubVNET.name
  address_prefix       = "100.64.0.0/24"
}

resource "azurerm_public_ip" "PI-WE-AzFwPIP" {
  name                = "PI-WE-AzFwPIP"
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "FW-WE-AzFw01" {
  name                = "FW-WE-AzFw01"
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name

  ip_configuration {
    name                 = "IP-WE-AzFwIPConfig"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id
    public_ip_address_id = azurerm_public_ip.PI-WE-AzFwPIP.id
  }
}

resource "azurerm_subnet" "SN-WE-HUB-Internal" {
  name                 = "SN-WE-HUB-Internal"
  resource_group_name  = azurerm_resource_group.RG-WE-Common-Network.name
  virtual_network_name = azurerm_virtual_network.VN-WE-HubVNET.name
  address_prefix       = "100.64.1.0/24"
}

resource "azurerm_network_interface" "VMWEHUB01-VMNIC1" {
  name                = "VMWEHUB01-VMNIC1"
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SN-WE-HUB-Internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VMWEHUB01" {
  name                = "VMWEHUB01"
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name
  location            = azurerm_resource_group.RG-WE-Common-Network.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "!QAZ2wsx"
  network_interface_ids = [
    azurerm_network_interface.VMWEHUB01-VMNIC1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_route_table" "UR-WE-Default" {
  name                          = "UR-WE-Default"
  location                      = azurerm_resource_group.RG-WE-Common-Network.location
  resource_group_name           = azurerm_resource_group.RG-WE-Common-Network.name
  disable_bgp_route_propagation = false

  route {
    name                   = "route1"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.FW-WE-AzFw01.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "HUB"
  }
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.SN-WE-HUB-Internal.id
  route_table_id = azurerm_route_table.UR-WE-Default.id
}

resource "azurerm_firewall_application_rule_collection" "FR-WE-AllowAzurePortal" {
  name                = "FR-WE-AllowPortal"
  azure_firewall_name = azurerm_firewall.FW-WE-AzFw01.name
  resource_group_name = azurerm_resource_group.RG-WE-Common-Network.name
  priority            = 101
  action              = "Allow"

  rule {
    name = "FR-WE-AllowAzure"

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
