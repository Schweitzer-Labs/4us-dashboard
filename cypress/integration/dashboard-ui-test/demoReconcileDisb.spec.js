describe("Demo Disbursement Reconciliation", () => {
  it("It can reconcile multiple disbursements", () => {
    cy.createDemo();
    cy.get("[data-cy=seedMoneyOut]").click();
    cy.get(".col-12 > a").then((e) => {
      cy.visit(e.text());
    });
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.33");
    cy.fillReconcileDisb("83.35");

    cy.get("tbody > :nth-child(1) > :nth-child(1)").click();
    cy.get('[type="checkbox"]').check();

    cy.get("[data-cy=disbRuleUnverifiedsubmitButton]").click();

    cy.get("[data-cy=disbRuleUnverifiedplatformSucessMessage]").should(
      "have.text",
      " Reconciliation Successful!"
    );
  });

  it("It can reconcile multiple contributions", () => {
    cy.createDemo();
    cy.get("[data-cy=seedMoneyIn]").click();
    cy.get(".col-12 > a").then((e) => {
      cy.visit(e.text());
    });
    cy.fillReconcileContrib("200");
    cy.fillReconcileContrib("200");
    cy.fillReconcileContrib("200");
    cy.fillReconcileContrib("200");
    cy.fillReconcileContrib("200");
    cy.fillReconcileContrib("200");
    cy.get("tbody > :nth-child(1) > :nth-child(1)").click();
    cy.get('[type="checkbox"]').check();

    cy.get("[data-cy=contribRuleUnverifiedsubmitButton]").click();

    cy.get("[data-cy=contribRuleUnverifiedplatformSucessMessage]").should(
      "have.text",
      " Reconciliation Successful!"
    );
  });
});
