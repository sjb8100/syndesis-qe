# @sustainer: mastepan@redhat.com

@integrations-twitter-to-salesforce
Feature: Integration - Twitter to Salesforce

  Background: Clean application state
    Given clean application state
    Given clean SF contacts related to TW account: "twitter_talky"
    Given clean all tweets in twitter_talky account
    Given log into the Syndesis
    Given created connections
      | Twitter    | Twitter Listener | Twitter Listener | SyndesisQE Twitter listener account |
      | Salesforce | QE Salesforce    | QE Salesforce    | SyndesisQE salesforce test          |

  Scenario: Create
    # create integration
    When navigate to the "Home" page
    And click on the "Create Integration" button to create a new integration.
    Then check visibility of visual integration editor
    And check that position of connection to fill is "Start"
    # select twitter connection
    When select the "Twitter Listener" connection
    And select "Mention" integration action
    Then check that position of connection to fill is "Finish"
    # select salesforce connection
    When select the "QE Salesforce" connection
    And select "Create or update record" integration action
    And select "Contact" from "sObjectName" dropdown
    And click on the "Next" button
    And select "TwitterScreenName" from "sObjectIdName" dropdown
    And click on the "Done" button
    Then check visibility of the "Add a Step" button

    # add data mapper step
    When click on the "Add a Step" button
    And select "Data Mapper" integration step
    Then check visibility of data mapper ui

    When create data mapper mappings
      | user.screenName | TwitterScreenName__c |
      | text            | Description          |
      | user.name       | FirstName; LastName  |

    And scroll "top" "right"
    And click on the "Done" button

    # add basic filter step
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When click on the "Add a step" link
    And select "Basic Filter" integration step
    Then check visibility of "Basic Filter" step configuration page
    And check that basic filter step path input options contains "text" option
    When fill in the configuration page for "Basic Filter" step with "ANY of the following, text, contains, #syndesis4ever" parameter
    And click on the "Done" button

     # add advanced filter step
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When click on the "Add a step" link
    And select "Advanced Filter" integration step
    Then check visibility of "Advanced Filter" step configuration page
    When fill in the configuration page for "Advanced Filter" step with "${body.text} contains '#e2e'" parameter
    And click on the "Done" button

    # finish and save integration
    And click on the "Save as Draft" button
    And set integration name "Twitter to Salesforce E2E"
    And click on the "Publish" button
    # assert integration is present in list
    Then check visibility of "Twitter to Salesforce E2E" integration details
    When navigate to the "Integrations" page
    And Integration "Twitter to Salesforce E2E" is present in integrations list
    # wait for integration to get in active state
    Then wait until integration "Twitter to Salesforce E2E" gets into "Running" state
    #And verify s2i build of integration "Twitter to Salesforce E2E" was finished in duration 1 min

    When tweet a message from twitter_talky to "Twitter Listener" with text "Red Hat #syndesis4ever"
    And sleep for "30000" ms
    Then check SF does not contain contact for tw account: "twitter_talky"

    When tweet a message from twitter_talky to "Twitter Listener" with text "Red Hat #e2e"
    And sleep for "30000" ms
    Then check SF does not contain contact for tw account: "twitter_talky"

    When tweet a message from twitter_talky to "Twitter Listener" with text "Red Hat #e2e #syndesis4ever"
    And sleep for "30000" ms
    Then check SF contains contact for tw account: "twitter_talky"
    And check that contact from SF with last name: "Talky" has description "Red Hat #e2e #syndesis4ever @syndesis_listen"
    # clean-up in salesforce
    When delete contact from SF with last name: "Talky"
