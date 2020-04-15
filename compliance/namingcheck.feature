Feature: Azure resources follow naming convention
    As a cloud architect
    I want to ensure Azure resources follow naming convention
    In order to standardize naming in cloud environments

    Scenario Outline: Naming Standard on all available resources
        Given I have <resource_name> defined
        When it contains <name_key>
        Then its value must match the "<regex>" regex

        Examples:
            | resource_name                                | name_key | regex |
            | azurerm_resource_group                       | name     | aRG.* |
            | azurerm_virtual_network                      | name     | .*    |
            | azurerm_subnet                               | name     | .*    |
            | azurerm_public_ip                            | name     | .*    |
            | azurerm_bastion_host                         | name     | .*    |
            | azurerm_firewall                             | name     | .*    |
            | azurerm_network_interface                    | name     | .*    |
            | azurerm_windows_virtual_machine              | name     | .*    |
            | azurerm_route_table                          | name     | .*    |
            | azurerm_subnet_route_table_association       | name     | .*    |
            | azurerm_firewall_application_rule_collection | name     | .*    |
            | azurerm_windows_virtual_machine              | name     | .*    |
            | azurerm_windows_virtual_machine              | name     | .*    |