const faker = require("faker")
// Demo Setup

const donor = {
    firstName : faker.name.firstName(),
    lastName: faker.name.lastName(),
    amount: faker.datatype.number({
        min: 10,
        max: 100,
    }),
    paymentDate: '2021-09-17',
    email: faker.internet.email(),
    phoneNumber: '2369860981',
    addressLine1 :faker.address.streetAddress(),
    addressLine2: 'Apartment 5',
    city : faker.address.city(),
    state: faker.address.state(),
    postalCode: faker.address.zipCode().substring(0, 5),
    company: 'Toyota',
    job: 'Marketing',
    purposeCode: 'LITER',
    organizationName: 'PDT Co'
}



describe('Demo Disbursement Reconciliation',()=>{
    before(()=>{
        cy.generateReconcileDisbDemo()
    })


    it( 'can add a Disbursement',()=>{
        cy.get('[data-cy=addDisbBtn]').click()
        cy.get(':nth-child(1) > .container-fluid > .fade-in > .col > [data-cy=recipientName]')
            .type(`${donor.firstName} ${donor.lastName}`)
        cy.get(':nth-child(4) > :nth-child(1) > .form-group > [data-cy=createDisbaddressLine1]')
            .type(donor.addressLine1)

        cy.get(':nth-child(5) > .col-lg-6 > .form-group > [data-cy=createDisbcity]')
            .type(donor.city)

        cy.get(':nth-child(5) > :nth-child(2) > .form-group > [data-cy=createDisbstate]')
            .select(donor.state)

        cy.get(':nth-child(5) > :nth-child(3) > .form-group > [data-cy=createDisbpostalCode]')
            .type(donor.postalCode)

        cy.get(':nth-child(6) > .col > .form-group > #purpose')
            .select(donor.purposeCode)

        cy.get(':nth-child(7) > :nth-child(1) > form > .form-group > :nth-child(3) > .custom-control-label').click()
        cy.get(':nth-child(7) > :nth-child(2) > form > .form-group > :nth-child(3) > .custom-control-label').click()
        cy.get(':nth-child(7) > :nth-child(3) > form > .form-group > :nth-child(3) > .custom-control-label').click()
        cy.get(':nth-child(7) > :nth-child(4) > form > .form-group > :nth-child(3) > .custom-control-label').click()
        cy.get(':nth-child(1) > .container-fluid > .justify-content-between > :nth-child(2) > .btn').click()
    })
    it('can reconcile a Disbursement', ()=>{
        cy.get('button').contains('Reconcile').click()
        cy.get('.modal-body > .p-3 > .text-green').should('have.text', ' Reconciliation Successful!')
    })

})
