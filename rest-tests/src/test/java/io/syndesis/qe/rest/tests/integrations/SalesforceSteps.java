package io.syndesis.qe.rest.tests.integrations;

import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import cucumber.api.DataTable;
import cucumber.api.java.en.Given;
import io.syndesis.common.model.action.Action;
import io.syndesis.common.model.action.ConnectorDescriptor;
import io.syndesis.common.model.connection.Connection;
import io.syndesis.common.model.connection.Connector;
import io.syndesis.common.model.integration.Step;
import io.syndesis.common.model.integration.StepKind;
import io.syndesis.qe.bdd.AbstractStep;
import io.syndesis.qe.bdd.entities.StepDefinition;
import io.syndesis.qe.bdd.storage.StepsStorage;
import io.syndesis.qe.endpoints.ConnectionsEndpoint;
import io.syndesis.qe.endpoints.ConnectorsEndpoint;
import io.syndesis.qe.utils.RestConstants;
import io.syndesis.qe.utils.TestUtils;
import lombok.extern.slf4j.Slf4j;

/**
 * Jan 12, 2018 Red Hat
 *
 * @author tplevko@redhat.com
 */
@Slf4j
public class SalesforceSteps extends AbstractStep {

    @Autowired
    private StepsStorage steps;
    @Autowired
    private ConnectionsEndpoint connectionsEndpoint;
    @Autowired
    private ConnectorsEndpoint connectorsEndpoint;

    public SalesforceSteps() {
    }

    @Given("^create SF \"([^\"]*)\" action step on field: \"([^\"]*)\"$")
    public void createSfStepWithAction(String action, String field) {
        List<List<String>> rawTable = Arrays.asList(
                Arrays.asList("sObjectName", field)
        );
        createSfStepWithActionAndProperties(action, DataTable.create(rawTable));
    }

    @Given("^create SF \"([^\"]*)\" action step with properties$")
    public void createSfStepWithActionAndProperties(String action, DataTable props) {
        final Connector salesforceConnector = connectorsEndpoint.get("salesforce");
        final Connection salesforceConnection = connectionsEndpoint.get(RestConstants.SALESFORCE_CONNECTION_ID);
        final Action sfAction = TestUtils.findConnectorAction(salesforceConnector, action);

        Map<String, String> properties = props.asMap(String.class, String.class);

        final ConnectorDescriptor connectorDescriptor = getConnectorDescriptor(sfAction, properties, RestConstants.SALESFORCE_CONNECTION_ID);
        final Step salesforceStep = new Step.Builder()
                .stepKind(StepKind.endpoint)
                .id(UUID.randomUUID().toString())
                .connection(salesforceConnection)
                .action(generateStepAction(sfAction, connectorDescriptor))
                .configuredProperties(properties)
                .build();

        steps.getStepDefinitions().add(new StepDefinition(salesforceStep, connectorDescriptor));
    }
}
