package io.syndesis.qe.pages.customizations.connectors.wizard;

import static com.codeborne.selenide.Condition.exist;
import static com.codeborne.selenide.Selenide.$;

import org.openqa.selenium.By;

import com.codeborne.selenide.SelenideElement;

import io.syndesis.qe.pages.WizardPageObject;
import io.syndesis.qe.pages.customizations.connectors.wizard.steps.ReviewEditConnectorDetails;
import io.syndesis.qe.pages.customizations.connectors.wizard.steps.ReviewActions;
import io.syndesis.qe.pages.customizations.connectors.wizard.steps.SpecifySecurity;
import io.syndesis.qe.pages.customizations.connectors.wizard.steps.UploadSwaggerSpecification;
import io.syndesis.qe.logic.common.wizard.WizardPhase;

public class ApiClientConnectorWizard extends WizardPageObject {


    private static final class Element {
        public static final By ROOT = By.cssSelector("syndesis-api-connectors-create");
    }

    public ApiClientConnectorWizard() {
        setSteps(new WizardPhase[] {new UploadSwaggerSpecification(), new ReviewActions(), new SpecifySecurity(), new ReviewEditConnectorDetails()});
    }

    @Override
    public SelenideElement getRootElement() {
        return $(Element.ROOT).should(exist);
    }

    @Override
    public boolean validate() {
        return getRootElement().exists();
    }
}
