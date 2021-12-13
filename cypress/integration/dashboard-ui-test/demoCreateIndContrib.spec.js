describe("demo individual contributions", () => {
    before(() => {
        cy.generateDemo();
    });

    beforeEach(() => {
        cy.initContrib();
        cy.selectInd();
        cy.fillContribFormInd();
    });

    afterEach(() => {
        cy.contribSubmit();
    });

    it("can create check contributions", () => {
        cy.fillCheck();
    });

    it("can create  credit card contribution", () => {
        cy.contains("Credit").click();
        cy.fillCCForm();
    });

    it("can create cash contribution", () => {
        cy.fillCash();
    });

    it("can create in-kind contributions", () => {
        cy.fillInKind();
    });
});
