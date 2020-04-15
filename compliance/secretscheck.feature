Feature: Azure credentials must not be within the code
    As a security architect
    I want to eliminate hardcoded credentials in terraform templates
    In order to increase IaC security

    Scenario Outline: Azure Credentials should not be hardcoded
        Given I have azurerm provider configured
        When it contains <key>
        Then its value must not match the "<regex>" regex

        Examples:
            | key             | regex                                                        |
            | client_secret   | [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12} |
            | client_id       | [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12} |
            | subscription_id | [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12} |
            | tenant_id       | [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12} |