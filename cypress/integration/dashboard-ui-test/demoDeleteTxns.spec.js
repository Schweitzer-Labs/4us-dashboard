describe("Demo deleting transactions", () => {
    before(() => {
        cy.generateDemo();
    });
    it("Can delete contributions", () => {
        cy.initContrib();
        cy.selectInd();
        cy.fillContribFormInd();
        cy.get("[data-cy=payMethod-cash]").click();
        cy.contribSubmit();

        cy.get("tbody > .hover-pointer > :nth-child(1)").click();

        cy.get("[data-cy=contribRuleVerifieddeleteButton]").click();
        cy.get("[data-cy=contribRuleVerifieddeleteButton]").click();
        cy.get("[data-cy=emptyTxnsText] > .text-center").should(
            "contain.text",
            "Awaiting Transactions."
        );
    });

    it("Can delete disbursements", () => {
        cy.initDisb();
        cy.fillDisbForm();
        cy.get("[data-cy=createDisbpaymentMethod]").select("ACH");
        cy.disbSubmit();

        cy.get("tbody > .hover-pointer > :nth-child(1)").click();

        cy.get("[data-cy=disbRuleVerifieddeleteButton]").click();
        cy.get("[data-cy=disbRuleVerifieddeleteButton]").click();
        cy.get("[data-cy=emptyTxnsText] > .text-center").should(
            "contain.text",
            "Awaiting Transactions."
        );
    });
});
