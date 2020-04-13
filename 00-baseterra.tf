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