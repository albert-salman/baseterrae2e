Feature: Azure resources follow naming convention
    As a cloud architect
    I want to ensure Azure resources follow naming convention
    In order to standardize naming in cloud environments

    Scenario Outline: Naming Standard on all available resources
        Given I have <resource_name> defined
        When it contains <name_key>
        Then its value must match the "<regex>" regex

        Examples:
            | resource_name                   | name_key | regex      |
            | azurerm_resource_group          | name     | RG-\w\w-.* |
            | azurerm_virtual_network         | name     | VN-\w\w-.* |
            | azurerm_subnet                  | name     | SN-\w\w-.* |
            | azurerm_public_ip               | name     | PI-\w\w-.* |
            | azurerm_bastion_host            | name     | BN-\w\w-.* |
            | azurerm_firewall                | name     | FW-\w\w-.* |
            | azurerm_network_interface       | name     | .*-VMNIC\d |
            | azurerm_windows_virtual_machine | name     | VM\w\w.*   |
            | azurerm_route_table             | name     | UR-\w\w-.* |
