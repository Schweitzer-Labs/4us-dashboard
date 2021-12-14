const faker = require("faker");

describe("Demo Amending Disbursements", () => {
  before(() => {
    cy.generateDemo();
    cy.initContrib();
    cy.selectInd();
    cy.fillContribFormInd();
    cy.get("[data-cy=payMethod-cash]").click();
    cy.contribSubmit();
  });

  afterEach(() => {
    cy.get(
      ":nth-child(10) > .modal > .elm-bootstrap-modal > .modal-content > .modal-header > .close"
    ).click();
  });

  it("allows a user to amend contribution information", () => {
    const firstName = faker.name.firstName();
    const lastName = faker.name.lastName();

    const newAddressLine1 = faker.address.streetAddress();
    const newCity = faker.address.city();
    const newState = faker.address.state();
    const newPostalCode = faker.address.zipCode().substring(0, 5);

    cy.get("tbody > .hover-pointer > :nth-child(1)").click();

    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedFirstName]").clear().type(firstName);
    cy.get("[data-cy=contribRuleVerifiedLastName]").clear().type(lastName);
    cy.get("[data-cy=contribRuleVerifiedaddressLine1]")
      .clear()
      .type(newAddressLine1);
    cy.get("[data-cy=contribRuleVerifiedcity]").clear().type(newCity);
    cy.get("[data-cy=contribRuleVerifiedstate]").select(newState);
    cy.get("[data-cy=contribRuleVerifiedpostalCode]")
      .clear()
      .type(newPostalCode);

    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiedplatformSucessOkBtn]").click();

    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedFirstName]").should(
      "have.value",
      firstName
    );
    cy.get("[data-cy=contribRuleVerifiedLastName]").should(
      "have.value",
      lastName
    );
    cy.get("[data-cy=contribRuleVerifiedaddressLine1]").should(
      "have.value",
      newAddressLine1
    );
    cy.get("[data-cy=contribRuleVerifiedcity]").should("have.value", newCity);
    cy.get("[data-cy=contribRuleVerifiedstate] option:selected").should(
      "have.text",
      newState
    );
    cy.get("[data-cy=contribRuleVerifiedpostalCode]").should(
      "have.value",
      newPostalCode
    );
  });

  it("displays the correct first name error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedFirstName]").clear();
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "First Name is missing."
    );
  });

  it("displays the correct last name error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedLastName]").clear();
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "Last Name is missing."
    );
  });

  it("displays the correct street address error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedaddressLine1]").clear();
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "Address 1 is missing."
    );
  });

  it("displays the correct city error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedcity]").clear();
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "City is missing."
    );
  });

  it("displays the correct state error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedstate]").select("-- State --");
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "State is missing."
    );
  });

  it("displays the correct postal code error to the user", () => {
    cy.get("tbody > .hover-pointer > :nth-child(1)").click();
    cy.get("[data-cy=contribRuleVerifiededitIcon]").click();

    cy.get("[data-cy=contribRuleVerifiedpostalCode]").clear();
    cy.get("[data-cy=contribRuleVerifiedsubmitButton]").click();
    cy.get("[data-cy=contribRuleVerifiederrorRow]").should(
      "have.text",
      "Postal Code is missing."
    );
  });
});
