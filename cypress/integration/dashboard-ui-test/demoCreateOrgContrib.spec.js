describe("demo organization contributions", () => {
    before(() => {
        cy.generateDemo();
    });

    beforeEach(() => {
        cy.initContrib();
        cy.selectOrg();
    });

    afterEach(() => {
        cy.contribSubmit();
    });

    it("can create a Sole Proprietorship Check contribution", () => {
        cy.selectEntityType("Solep");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });

    it("can create a Sole Proprietorship Credit contribution", () => {
        cy.selectEntityType("Solep");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });
    it("can create a Sole Proprietorship Cash contribution", () => {
        cy.selectEntityType("Solep");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Sole Proprietorship In-kind contribution", () => {
        cy.selectEntityType("Solep");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Partnership Check contribution", () => {
        cy.selectEntityType("Part");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Partnership Credit contribution", () => {
        cy.selectEntityType("Part");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Partnership Cash contribution", () => {
        cy.selectEntityType("Part");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Partnership In-kind contribution", () => {
        cy.selectEntityType("Part");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Corporation Check contribution", () => {
        cy.selectEntityType("Corp");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Corporation Credit contribution", () => {
        cy.selectEntityType("Corp");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Corporation Cash contribution", () => {
        cy.selectEntityType("Corp");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Corporation In-kind contribution", () => {
        cy.selectEntityType("Corp");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Union Check contribution", () => {
        cy.selectEntityType("Union");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Union Credit contribution", () => {
        cy.selectEntityType("Union");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Union Cash contribution", () => {
        cy.selectEntityType("Union");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Union In-kind contribution", () => {
        cy.selectEntityType("Union");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Association Check contribution", () => {
        cy.selectEntityType("Assoc");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Association Credit contribution", () => {
        cy.selectEntityType("Assoc");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });
    it("can create a Association Cash contribution", () => {
        cy.selectEntityType("Assoc");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Association In-kind contribution", () => {
        cy.selectEntityType("Assoc");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a LLC Check contribution", () => {
        cy.selectEntityType("Llc");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a LLC Credit contribution", () => {
        cy.selectEntityType("Llc");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a LLC Cash contribution", () => {
        cy.selectEntityType("Llc");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a LLC In-kind contribution", () => {
        cy.selectEntityType("Llc");
        cy.fillContribOwnersForm();
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Political Action Committee Check contribution", () => {
        cy.selectEntityType("Pac");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Political Action Committee Credit contribution", () => {
        cy.selectEntityType("Pac");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Political Action Committee Cash contribution", () => {
        cy.selectEntityType("Pac");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Political Action Committee In-kind contribution", () => {
        cy.selectEntityType("Pac");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Political Committee Check contribution", () => {
        cy.selectEntityType("Plc");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Political Committee Credit contribution", () => {
        cy.selectEntityType("Plc");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Political Committee Cash contribution", () => {
        cy.selectEntityType("Plc");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Political Committee In-kind contribution", () => {
        cy.selectEntityType("Plc");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });

    it("can create a Other Check contribution", () => {
        cy.selectEntityType("Oth");
        cy.fillContribOrgPii();
        cy.fillCheck();
    });
    it("can create a Other Credit contribution", () => {
        cy.selectEntityType("Oth");
        cy.fillContribOrgPii();
        cy.fillCCForm();
    });

    it("can create a Other Cash contribution", () => {
        cy.selectEntityType("Oth");
        cy.fillContribOrgPii();
        cy.fillCash();
    });

    it("can create a Other In-kind contribution", () => {
        cy.selectEntityType("Oth");
        cy.fillContribOrgPii();
        cy.fillInKind();
    });
});
