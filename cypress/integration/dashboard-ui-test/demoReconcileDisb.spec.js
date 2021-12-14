const faker = require("faker");
const { purposeCodes } = require("../../support/commands");
describe("Demo Disbursement Reconciliation", () => {
  before(() => {
    cy.createDemo();
    cy.get("[data-cy=seedMoneyOut]").click();
    cy.get(".col-12 > a").then((e) => {
      cy.visit(e.text());
    });
  });
  it("It can reconcile multiple disbursements", () => {
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.35");

    cy.get("tbody > :nth-child(1) > :nth-child(1)").click();
    cy.get('[type="checkbox"]').check();

    cy.get("[data-cy=disbRuleUnverifiedsubmitButton]").click();
  });
});
