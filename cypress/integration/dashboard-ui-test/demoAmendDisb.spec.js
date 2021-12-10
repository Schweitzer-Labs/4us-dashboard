const faker = require("faker")



describe('Demo Amending Disbursements',()=>{
    before(()=>{
        cy.generateAmendDisbDemo()
        cy.initDisb()
        cy.fillDisbForm()
        cy.get('[data-cy=createDisbpaymentMethod]').select('ACH')
        cy.disbSubmit()
    })
    it('can amend a disbursements pii', ()=>{
        const newName  = `${faker.name.firstName()} ${faker.name.lastName()}`

        const newAddressLine1  = faker.address.streetAddress()
        const newCity = faker.address.city()
        const newState =  faker.address.state()
        const newPostalCode =  faker.address.zipCode().substring(0, 5)

        cy.get('tbody > .hover-pointer > :nth-child(1)').click()

        cy.get('[data-cy=disbRuleVerifiededitIcon]').click()

        cy.get('[data-cy=disbRuleVerifiedrecipientName]').clear()
        cy.get('[data-cy=disbRuleVerifiedrecipientName]').type(newName)

        cy.get('[data-cy=disbRuleVerifiedsubmitButton]').click()
        cy.get('[data-cy=disbRuleVerifiedplatformSucessOkBtn]').click()

        cy.get('tbody > .hover-pointer > :nth-child(1)').click()

        cy.get('[data-cy=disbRuleVerifiededitIcon]').click()
        cy.get('[data-cy=disbRuleVerifiedrecipientName]').should('have.value',newName)

    })

    it('can amend ')
})
