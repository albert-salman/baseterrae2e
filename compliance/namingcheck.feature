Feature: Azure resources follow naming convention
    As a cloud architect
    I want to ensure Azure resources follow naming convention
    In order to standardize naming in cloud environments

    Scenario Outline: Naming Standard on all available resources
        Given I have <resource_name> defined
        When it contains <name_key>
        Then its value must match the "<regex>" regex

        Examples:
            | resource_name                   | name_key | regex                                                                    |
            | azurerm_resource_group          | name     | ^(PRD\|TST\|DEV)-RG-\\w\\w-.*                                            |
            | azurerm_virtual_network         | name     | ^(PRD\|TST\|DEV)-VN-\\w\\w-.*                                            |
            | azurerm_subnet                  | name     | ^(PRD\|TST\|DEV)-(SN-\\w\\w-.*\|AzureBastionSubnet\|AzureFirewallSubnet) |
            | azurerm_public_ip               | name     | ^(PRD\|TST\|DEV)-PI-\\w\\w-.*                                            |
            | azurerm_bastion_host            | name     | ^(PRD\|TST\|DEV)-BN-\\w\\w-.*                                            |
            | azurerm_firewall                | name     | ^(PRD\|TST\|DEV)-FW-\\w\\w-.*                                            |
            | azurerm_network_interface       | name     | .*-VMNIC\\d                                                              |
            | azurerm_windows_virtual_machine | name     | ^VM\\w\\w.*                                                              |
            | azurerm_route_table             | name     | ^(PRD\|TST\|DEV)-UR-\\w\\w-.*                                            |
