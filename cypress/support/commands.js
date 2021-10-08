// Demo Setup

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

const appUrl = 'http://localhost:3000/committee/nelson-lopez'
const demoPassword = 'f4jp1i'


Cypress.Commands.add('createDemo', ()=>{
    cy.visit(appUrl)
    cy.visit(`${appUrl}/demo`)

    cy.get('#password').type(demoPassword)
    cy.get('.btn').click()
    cy.wait(12000)

})

Cypress.Commands.add('generateDemo', () => {
    cy.createDemo()
    cy.get('.col-12 > a').then((e)=>{
        cy.visit(e.text())
    })
})

Cypress.Commands.add('generateReconcileDisbDemo', () => {
    cy.createDemo()
    cy.get('[data-cy=seedMoneyOut]').click()
    cy.get('.col-12 > a').then((e)=>{
        cy.visit(e.text())
    })
    cy.get('tbody > .hover-pointer > :nth-child(1)').click()
})

// Generic Form Commands

Cypress.Commands.add('fillCheck',()=>{
    cy.get('[data-cy=payMethod-check]').click()
    cy.get('#check-number').type('123')
})

Cypress.Commands.add('fillCCForm',()=>{
    cy.get('[data-cy=payMethod-credit]').click()
    cy.get('#card-number').type('4242424242424242')
    cy.get('#card-month').select('4 - Apr')
    cy.get('#card-year').select('2024')
    cy.get('#cvv').type('123')
})

Cypress.Commands.add('fillCash', ()=>{
    cy.get('[data-cy=payMethod-cash]').click()
})

Cypress.Commands.add('fillInKind', ()=> {

    cy.get('[data-cy=payMethod-inKind]').click()
    cy.contains('Service/Facilities Provided').click()
    cy.get('[data-cy=createContribDescription]')
        .type('Pizza Party')
})

// Contribution Commands
Cypress.Commands.add ('initContrib',()=>{

    cy.get('#actions-dropdown').click()
    cy.get('button').contains('Create Contribution').click()

    cy.get(':nth-child(2) > :nth-child(1) > .form-group > [data-cy=paymentAmount]').type(individual.amount)
    cy.get(':nth-child(2) > :nth-child(2) > .form-group > [data-cy=paymentDate]').type(individual.paymentDate)
})

Cypress.Commands.add('selectOrg', ()=>{
    cy.contains('Organization').click()
})

Cypress.Commands.add('fillContribOrgPii',()=>{

    cy.get('[data-cy=contribOwnerName]').type(individual.organizationName)
    cy.get('[data-cy=createContribEmail]').type(individual.email)
    cy.get('[data-cy=createContribPhoneNumber]').type(individual.phoneNumber)
    cy.get('[data-cy=createContribFirstName]').type(individual.firstName)
    cy.get('[data-cy=createContribLastName]').type(individual.lastName)
    cy.get('[data-cy=createContribaddressLine1]').type(individual.addressLine1)
    cy.get('[data-cy=createContribaddressLine2]').type(individual.addressLine2)
    cy.get('[data-cy=createContribcity]').type(individual.city)
    cy.get('[data-cy=createContribstate]').select(individual.state)
    cy.get('[data-cy=createContribpostalCode]').type(individual.postalCode)

})

Cypress.Commands.add('fillContribOwnersForm', ()=>{
    cy.get('[data-cy=addOwner]').click()
    cy.get('[data-cy=createOwnerFirstName]').type(individual.firstName)
    cy.get('[data-cy=createOwnerLastName]').type(individual.lastName)
    cy.get('[data-cy=createOwneraddressLine1]').type(individual.addressLine1)
    cy.get('[data-cy=createOwneraddressLine2]').type(individual.addressLine2)
    cy.get('[data-cy=createOwnercity]').type(individual.city)
    cy.get('[data-cy=createOwnerstate]').select(individual.state)
    cy.get('[data-cy=createOwnerpostalCode]').type(individual.postalCode)
    cy.get('[data-cy=createOwnerPercent]').type('100')
    cy.get('.col-3 > .btn').click()

})
Cypress.Commands.add('selectEntityType',(entityType)=>{
    cy.get('#entityType').select(entityType)
})




Cypress.Commands.add('selectInd', ()=>{
    cy.get('#Individual').click()
})


Cypress.Commands.add('fillContribFormInd', ()=>{

    cy.get('[data-cy=createContribEmail]').type(individual.email)
    cy.get('[data-cy=createContribPhoneNumber]').type(individual.phoneNumber)
    cy.get('[data-cy=createContribFirstName]').type(individual.firstName)
    cy.get('[data-cy=createContribLastName]').type(individual.lastName)
    cy.get('[data-cy=createContribaddressLine1]').type(individual.addressLine1)
    cy.get('[data-cy=createContribaddressLine2]').type(individual.addressLine2)
    cy.get('[data-cy=createContribcity]').type(individual.city)
    cy.get('[data-cy=createContribstate]').select(individual.state)
    cy.get('[data-cy=createContribpostalCode]').type(individual.postalCode)

    cy.get('.col-8 > form > .form-group > :nth-child(4) > .custom-control-label').click()

})

// Disbursement Commands

Cypress.Commands.add ('initDisb',()=>{

    cy.get('#actions-dropdown').click()
    cy.get('button').contains('Create Disbursement').click()

})

Cypress.Commands.add('fillDisbForm', ()=>{
    cy.get('.container-fluid > .fade-in > .col > #recipient-name')
        .type(`${individual.firstName} ${individual.lastName}`)
    cy.get('[data-cy=createDisbaddressLine1]').first().type(individual.addressLine1)
    cy.get('[data-cy=createDisbaddressLine2]').first().type(individual.addressLine2)
    cy.get('[data-cy=createDisbcity]').first().type(individual.city)
    cy.get('[data-cy=createDisbstate]').first().select(individual.state)
    cy.get('[data-cy=createDisbpostalCode]').first().type(individual.postalCode)

    cy.get(':nth-child(4) > .col > .form-group > #purpose').select(individual.purposeCode)

    cy.get(':nth-child(5) > :nth-child(1) > form > .form-group').click()
    cy.get(':nth-child(5) > :nth-child(1) > form > .form-group > :nth-child(2) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(2) > form > .form-group > :nth-child(2) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(3) > form > .form-group > :nth-child(3) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(4) > form > .form-group > :nth-child(3) > .custom-control-label').click()

    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > .mt-3 > :nth-child(1) > .form-group > [data-cy=paymentAmount]')
        .type(individual.amount)
    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > .mt-3 > :nth-child(2) > .form-group > [data-cy=paymentDate]')
        .type(individual.paymentDate)


})

Cypress.Commands.add('fillDisbForm', ()=>{
    cy.get('.container-fluid > .fade-in > .col > #recipient-name')
        .type(`${individual.firstName} ${individual.lastName}`)
    cy.get('[data-cy=createDisbaddressLine1]').first().type(individual.addressLine1)
    cy.get('[data-cy=createDisbaddressLine2]').first().type(individual.addressLine2)
    cy.get('[data-cy=createDisbcity]').first().type(individual.city)
    cy.get('[data-cy=createDisbstate]').first().select(individual.state)
    cy.get('[data-cy=createDisbpostalCode]').first().type(individual.postalCode)

    cy.get(':nth-child(4) > .col > .form-group > #purpose').select(individual.purposeCode)

    cy.get(':nth-child(5) > :nth-child(1) > form > .form-group').click()
    cy.get(':nth-child(5) > :nth-child(1) > form > .form-group > :nth-child(2) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(2) > form > .form-group > :nth-child(2) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(3) > form > .form-group > :nth-child(3) > .custom-control-label').click()
    cy.get(':nth-child(5) > :nth-child(4) > form > .form-group > :nth-child(3) > .custom-control-label').click()

    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > .mt-3 > :nth-child(1) > .form-group > [data-cy=paymentAmount]')
        .type(individual.amount)
    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > .mt-3 > :nth-child(2) > .form-group > [data-cy=paymentDate]')
        .type(individual.paymentDate)


})

Cypress.Commands.add('contribSubmit', ()=> {
    cy.get('button').contains('Submit').click()
    cy.wait(1000)
})

Cypress.Commands.add('disbSubmit', ()=> {
    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-footer > .container-fluid > .row > :nth-child(2) > .btn')
        .click()
})
