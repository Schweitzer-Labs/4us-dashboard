describe('Demo Disbursement Reconciliation',()=>{
    before(()=>{
        cy.generateReconcileDisbDemo()
    })

    const individual = {
        firstName : 'John',
        lastName: 'Williams',
        amount: '10',
        paymentDate: '2021-09-17',
        email: '4us@gmail.com',
        phoneNumber: '2369860981',
        addressLine1 :'1234 Broadway',
        addressLine2: 'Apartment 5',
        city : 'Manhattan',
        state: 'New York',
        postalCode: '10356',
        company: 'Toyota',
        job: 'Marketing',
        purposeCode: 'LITER',
        organizationName: 'PDT Co'
    }

    it( 'can add a Disbursement',()=>{
        cy.get('[data-cy=addDisbBtn]').click()
        cy.get(':nth-child(1) > .container-fluid > .fade-in > .col > [data-cy=recipientName]')
            .type(`${individual.firstName} ${individual.lastName}`)
        cy.get(':nth-child(4) > :nth-child(1) > .form-group > [data-cy=createDisbaddressLine1]')
            .type(individual.addressLine1)

        cy.get(':nth-child(5) > .col-lg-6 > .form-group > [data-cy=createDisbcity]')
            .type(individual.city)

        cy.get(':nth-child(5) > :nth-child(2) > .form-group > [data-cy=createDisbstate]')
            .select(individual.state)

        cy.get(':nth-child(5) > :nth-child(3) > .form-group > [data-cy=createDisbpostalCode]')
            .type(individual.postalCode)

        cy.get(':nth-child(6) > .col > .form-group > #purpose')
            .select(individual.purposeCode)

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
