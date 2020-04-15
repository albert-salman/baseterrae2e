Feature: Azure resources have tags
    As a cloud architect
    I want to ensure Azure resources have tags
    In order to ensure metadata-based management automation

    Scenario Outline: Tags on all available resources
        Given I have resource that supports tags defined
        When it contains tags
        Then it must contain <tags>
        And its value must match the "<value>" regex

        Examples:
            | tags        | value              |
            | application | .+                 |
            | environment | ^(prod\|uat\|dev)$ |