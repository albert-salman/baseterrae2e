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
            | azurerm_resource_group          | name     | ^(PRD\|TST\|DEV)-\\w\\w-RG-.*                                            |
            | azurerm_virtual_network         | name     | ^(PRD\|TST\|DEV)-\\w\\w-VN-.*                                            |
            | azurerm_subnet                  | name     | ^((PRD\|TST\|DEV)-\\w\\w-SN-.*\|AzureBastionSubnet\|AzureFirewallSubnet) |
            | azurerm_public_ip               | name     | ^(PRD\|TST\|DEV)-\\w\\w-PI-.*                                            |
            | azurerm_bastion_host            | name     | ^(PRD\|TST\|DEV)-\\w\\w-BN-.*                                            |
            | azurerm_firewall                | name     | ^(PRD\|TST\|DEV)-\\w\\w-FW-.*                                            |
            | azurerm_network_interface       | name     | .*-VMNIC\\d                                                              |
            | azurerm_windows_virtual_machine | name     | ^(PRD\|TST\|DEV)-\\w\\w-winVM.*                                          |
            | azurerm_linux_virtual_machine   | name     | ^(PRD\|TST\|DEV)-\\w\\w-nixVM.*                                          |
            | azurerm_route_table             | name     | ^(PRD\|TST\|DEV)-\\w\\w-UR-.*                                            |
