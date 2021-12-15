describe("demo individual disbursements", () => {
  before(() => {
    cy.generateDemo();
  });
  beforeEach(() => {
    cy.initDisb();
    cy.fillDisbForm();
  });

  afterEach(() => {
    cy.disbSubmit();
  });
  it("can create ACH disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("ACH");
  });

  it("can create Wire disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Wire");
  });

  it("can create Cash disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Cash");
  });

  it("can create Check disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Check");
    cy.get("[data-cy=createDisbCheck]").type("123");
  });
  it("can create Credit disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Credit");
  });
  it("can create Debit disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Debit");
  });
  it("can create Transfer disbursements", () => {
    cy.get("[data-cy=createDisbpaymentMethod]").select("Transfer");
  });
});
