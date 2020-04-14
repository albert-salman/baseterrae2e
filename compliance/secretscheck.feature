Feature: Azure Credentials should not be within the code
    This feature will enforce to use Azure Credentials either via
    environment variables or via metadata endpoint

    Scenario Outline: Azure Credentials should not be hardcoded
        Given I have azurerm provider configured
        When it contains <key>
        Then its value must not match the "<regex>" regex

        Examples:
            | key        | regex                                                      |
            | client_secret | (?<![A-Z0-9])[A-Z0-9]{20}(?![A-Z0-9])                      |
            | adminpassword | (?<![A-Za-z0-9\/+=])[A-Za-z0-9\/+=]{40}(?![A-Za-z0-9\/+=]) |  