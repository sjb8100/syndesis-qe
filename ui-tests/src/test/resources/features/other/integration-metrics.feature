# @sustainer: mkralik@redhat.com

@integration-metrics
Feature: Metrics

  Background: Clean application state
    Given clean application state
    And reset content of "contact" table
    And log into the Syndesis

  @metrics
  Scenario: Check metrics
    When navigate to the "Home" page
    And click on the "Create Integration" button to create a new integration.
    Then check visibility of visual integration editor
    And check that position of connection to fill is "Start"

    When select the "Webhook" connection
    And select "Incoming Webhook" integration action
    And fill in values
      | Webhook Token | test-webhook |
    And click on the "Next" button
    And fill in values
      | Select Type | JSON Instance |
    #only available after type is selected
    And fill in values by element ID
      | specification | {"first_name":"John","company":"Red Hat"} |
    And click on the "Done" button

    # finish point
    Then check visibility of page "Choose a Finish Connection"
    When select the "PostgresDB" connection
    And select "Invoke SQL" integration action
    And fill in invoke query input with "INSERT INTO CONTACT(first_name, company) VALUES(:#first_name, :#company)" value
    And click on the "Done" button

    #add log
    And click on the "Add a Step" button
    And select "Log" integration step
    And fill in values
      | Message Context | false               |
      | Message Body    | true                |
      | Custom Text     | before basic filter |
    And click on the "Done" button

    #add basic filter step
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "2". "Add a step" link
    And select "Basic Filter" integration step
    Then check visibility of "Basic Filter" step configuration page
#    And check that basic filter step path input options contains "company" option TODO issue: https://github.com/syndesisio/syndesis/issues/4162
    When fill in the configuration page for "Basic Filter" step with "ANY of the following, company, contains, Red Hat" parameter
    And click on the "Done" button

    #add log
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "3". "Add a step" link
    And select "Log" integration step
    And fill in values
      | Message Context | false                  |
      | Message Body    | true                   |
      | Custom Text     | before advanced filter |
    And click on the "Done" button

    # add advanced filter step
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "4". "Add a step" link
    And select "Advanced Filter" integration step
    Then check visibility of "Advanced Filter" step configuration page
    When fill in the configuration page for "Advanced Filter" step with "${body.company} not contains 'incorrect'" parameter
    And click on the "Done" button

    # add log
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "5". "Add a step" link
    And select "Log" integration step
    And fill in values
      | Message Context | false                |
      | Message Body    | true                 |
      | Custom Text     | before mapper filter |
    And click on the "Done" button

    # add data mapper
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "6". "Add a step" link
    And select "Data Mapper" integration step
    Then check visibility of data mapper ui
    When create data mapper mappings
      | first_name | first_name |
      | company    | company    |
    And click on the "Done" button

    And click on the "Publish" button
    And set integration name "Webhook to DB"
    And click on the "Publish" button

    And navigate to the "Integrations" page
    And wait until integration "Webhook to DB" gets into "Running" state

    And select the "Webhook to DB" integration
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that number of valid messages is 0
    And check that number of error messages is 0
    And check that number of total messages is 0
#    Then check that up time is "2 hours 32 minutes" TODO

    When click on the "Details" tab
    And save time before request
    And invoke post request to webhook with body {"first_name":"John","company":"incorrect company"}
    And save time after request
    And sleep for "3000" ms
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that last processed date is valid
    And check that number of valid messages is 1
    And check that number of error messages is 0
    And check that number of total messages is 1

    When click on the "Details" tab
    And save time before request
    And invoke post request to webhook with body {"first_name":"John","company":"Red Hat still incorrect"}
    And save time after request
    And sleep for "3000" ms
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that last processed date is valid
    And check that number of valid messages is 2
    And check that number of error messages is 0
    And check that number of total messages is 2

    When click on the "Details" tab
    And save time before request
    And invoke post request to webhook with body {"first_name":"John","company":"Red Hat"}
    And save time after request
    And sleep for "3000" ms
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that last processed date is valid
    And check that number of valid messages is 3
    And check that number of error messages is 0
    And check that number of total messages is 3

  @metrics-error
  Scenario: Check error
    When navigate to the "Home" page
    And click on the "Create Integration" button to create a new integration.
    Then check visibility of visual integration editor
    And check that position of connection to fill is "Start"

    When select the "Webhook" connection
    And select "Incoming Webhook" integration action
    And fill in values
      | Webhook Token | test-webhook |
    And click on the "Next" button
    And fill in values
      | Select Type | JSON Instance |
    #only available after type is selected
    And fill in values by element ID
      | specification | {"first_name":"John","company":"Red Hat"} |
    And click on the "Done" button

    # finish point
    Then check visibility of page "Choose a Finish Connection"
    When select the "PostgresDB" connection
    And select "Invoke SQL" integration action
    And fill in invoke query input with "INSERT INTO CONTACT(first_name, company) VALUES(:#first_name, :#company)" value
    And click on the "Done" button

    And click on the "Add a Step" button
    And select "Log" integration step
    And fill in values
      | Message Context | false               |
      | Message Body    | true                |
      | Custom Text     | before basic filter |
    And click on the "Done" button

    # add advanced filter step
    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "2". "Add a step" link
    And select "Advanced Filter" integration step
    Then check visibility of "Advanced Filter" step configuration page
    When fill in the configuration page for "Advanced Filter" step with "${body.companyINCORRECT} not contains 'incorrect'" parameter
    And click on the "Done" button

    And click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    And clicks on the "3". "Add a step" link
    And select "Log" integration step
    And fill in values
      | Message Context | false             |
      | Message Body    | true              |
      | Custom Text     | before data maper |
    And click on the "Done" button

    # add data mapper
    When click on the "Add a Step" button
    Then check visibility of the "Add a step" link
    When clicks on the "4". "Add a step" link
    And select "Data Mapper" integration step
    Then check visibility of data mapper ui
    When create data mapper mappings
      | first_name | first_name |
      | company    | company    |
    And click on the "Done" button

    And click on the "Publish" button
    And set integration name "Webhook to DB with error"
    And click on the "Publish" button

    And navigate to the "Integrations" page
    And wait until integration "Webhook to DB with error" gets into "Running" state

    And select the "Webhook to DB with error" integration
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that number of valid messages is 0
    And check that number of error messages is 0
    And check that number of total messages is 0

    When click on the "Details" tab
    And save time before request
    And invoke post request to webhook with body {"first_name":"John","company":"Red Hat"}
    And save time after request
    And sleep for "3000" ms
    And click on the "Metrics" tab
    Then check that number of total error is 0
    And check that last processed date is valid
    And check that number of valid messages is 1
    And check that number of error messages is 0
    And check that number of total messages is 1