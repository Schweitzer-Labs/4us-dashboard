import { purposeCodes } from "../../support/commands";

const faker = require("faker");

describe("Demo Amending Disbursements", () => {
    before(() => {
        cy.generateDemo();
        cy.initDisb();
        cy.fillDisbForm();
        cy.get("[data-cy=createDisbpaymentMethod]").select("ACH");
        cy.disbSubmit();
    });

    afterEach(() => {
        cy.get(
            ":nth-child(8) > .modal > .elm-bootstrap-modal > .modal-content > .modal-header > .close"
        ).click();
    });

    it("allows a user to amend disbursement information", () => {
        const newName = `${faker.name.firstName()} ${faker.name.lastName()}`;

        const newAddressLine1 = faker.address.streetAddress();
        const newCity = faker.address.city();
        const newState = faker.address.state();
        const newPostalCode = faker.address.zipCode().substring(0, 5);
        const newPurposeCode = faker.random.arrayElement(purposeCodes);

        cy.get("tbody > .hover-pointer > :nth-child(1)").click();

        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedrecipientName]").clear().type(newName);
        cy.get("[data-cy=disbRuleVerifiedaddressLine1]")
            .clear()
            .type(newAddressLine1);
        cy.get("[data-cy=disbRuleVerifiedcity]").clear().type(newCity);
        cy.get("[data-cy=disbRuleVerifiedstate]").select(newState);
        cy.get("[data-cy=disbRuleVerifiedpostalCode]").clear().type(newPostalCode);
        cy.get("[data-cy=disbRuleVerifiedpurposeCode]").select(newPurposeCode);

        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiedplatformSucessOkBtn]").click();

        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedrecipientName]").should(
            "have.value",
            newName
        );
        cy.get("[data-cy=disbRuleVerifiedaddressLine1]").should(
            "have.value",
            newAddressLine1
        );
        cy.get("[data-cy=disbRuleVerifiedcity]").should("have.value", newCity);
        cy.get("[data-cy=disbRuleVerifiedstate] option:selected").should(
            "have.text",
            newState
        );
        cy.get("[data-cy=disbRuleVerifiedpostalCode]").should(
            "have.value",
            newPostalCode
        );
        cy.get("[data-cy=disbRuleVerifiedpurposeCode] option:selected").should(
            "have.value",
            newPurposeCode
        );
    });

    it("displays the correct entity name error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedrecipientName]").clear();
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "Entity name is missing."
        );
    });

    it("displays the correct street address error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedaddressLine1]").clear();
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "Address 1 is missing."
        );
    });

    it("displays the correct city error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedcity]").clear();
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "City is missing."
        );
    });

    it("displays the correct state error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedstate]").select("-- State --");
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "State is missing."
        );
    });

    it("displays the correct postal code error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedpostalCode]").clear();
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "Postal Code is missing."
        );
    });

    it("displays the correct purpose code error to the user", () => {
        cy.get("tbody > .hover-pointer > :nth-child(1)").click();
        cy.get("[data-cy=disbRuleVerifiededitIcon]").click();

        cy.get("[data-cy=disbRuleVerifiedpurposeCode]").select("-- Purpose --");
        cy.get("[data-cy=disbRuleVerifiedsubmitButton]").click();
        cy.get("[data-cy=disbRuleVerifiederrorRow]").should(
            "have.text",
            "Purpose Code is missing."
        );
    });
});
