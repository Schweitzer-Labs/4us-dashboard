const faker = require("faker");
describe("Demo Creating Owners Contribution", () => {
  before(() => {
    cy.generateDemo();
    cy.initContrib();
    cy.selectOrg();
    cy.selectEntityType("Llc");
  });
  it("should display the correct error message when ownership above 100%", () => {
    cy.fillContribOwnersForm("120");
    cy.get("[data-cy=ownersViewError]").should(
      "have.text",
      "Ownership percentage total must add up to 100%. You have 100% left to attribute."
    );
  });
  it("should display the correct error message when submitting ownership below 100%", () => {
    cy.get("[data-cy=createOwnerPercent]").clear().type("80");
    cy.get("[data-cy=addMember]").click();
    cy.fillContribOrgPii();
    cy.fillInKind();
    cy.get("[data-cy=createContribsubmitButton]").click();

    cy.get("[data-cy=createContriberrorRow]").should(
      "have.text",
      "Ownership percentage total must add up to 100%. Total is off by 20%."
    );
  });

  it("should allow you to create more than one owner", () => {
    cy.fillContribOwnersForm("20");

    cy.get("#owners-view")
      .children()
      .should("contain", "80")
      .and("contain", "20");
  });

  it("should allow you to delete an owner", () => {
    cy.get('[data-cy="20ownerDeleteBtn"]').click();
    cy.get("#owners-view").children().should("not.contain", "20");
  });

  it("should allow you to edit an owner", () => {
    const firstName = faker.name.firstName();

    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=createOwnerFirstName]").clear().type(firstName);

    cy.get(".col-2 > .btn").click();

    cy.get("#owners-view").children().should("contain", firstName);
  });

  it("should display the correct errors on editing pii info for an owner", () => {
    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=createOwnerFirstName]").clear();
    cy.get(".col-2 > .btn").click();
    cy.get("[data-cy=ownersViewError]").should(
      "contain.text",
      "Owner First name is missing."
    );
    cy.get(".col-4 > .btn").click();

    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=createOwnerLastName]").clear();
    cy.get(".col-2 > .btn").click();
    cy.get("[data-cy=ownersViewError]").should(
      "contain.text",
      "Owner Last name is missing."
    );
    cy.get(".col-4 > .btn").click();

    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=ownersViewaddressLine1]").clear();
    cy.get(".col-2 > .btn").click();
    cy.get("[data-cy=ownersViewError]").should(
      "contain.text",
      "Owner Address 1 is missing."
    );
    cy.get(".col-4 > .btn").click();

    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=ownersViewcity]").clear();
    cy.get(".col-2 > .btn").click();
    cy.get("[data-cy=ownersViewError]").should(
      "contain.text",
      "Owner City is missing."
    );
    cy.get(".col-4 > .btn").click();

    cy.get('[data-cy="80ownerEditBtn"]').click();
    cy.get("[data-cy=ownersViewpostalCode]").clear();
    cy.get(".col-2 > .btn").click();
    cy.get("[data-cy=ownersViewError]").should(
      "contain.text",
      "Owner Postal Code is missing."
    );
    cy.get(".col-4 > .btn").click();
  });

  it("should allow you to submit multiple owners", () => {
    cy.fillContribOwnersForm("10");
    cy.fillContribOwnersForm("10");
    cy.get("[data-cy=createContribsubmitButton]").click();
  });
});
