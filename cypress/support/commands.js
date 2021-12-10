const faker = require("faker")
// Demo Setup

let donor = {
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

Cypress.Commands.add('generateAmendDisbDemo', () => {
    cy.createDemo()
    cy.get('.col-12 > a').then((e)=>{
        cy.visit(e.text())
    })
})

Cypress.Commands.add('contribSubmit', ()=> {
    cy.get('button').contains('Submit').click()
    cy.wait(1800)
})

Cypress.Commands.add('disbSubmit', ()=> {
    cy.get(':nth-child(6) > .modal > .elm-bootstrap-modal > .modal-content > .modal-footer > .container-fluid > .row > :nth-child(2) > .btn')
        .click()
})


// Generic Form Commands

Cypress.Commands.add('fillCheck',()=>{
    cy.get('[data-cy=payMethod-check]').click()
    cy.get('[data-cy=createDisbCheck]').type('123')
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

    cy.get(':nth-child(2) > :nth-child(1) > .form-group > [data-cy=paymentAmount]').type(donor.amount)
    cy.get(':nth-child(2) > :nth-child(2) > .form-group > [data-cy=paymentDate]').type(donor.paymentDate)
})

Cypress.Commands.add('selectOrg', ()=>{
    cy.contains('Organization').click()
})

Cypress.Commands.add('fillContribOrgPii',()=>{

    cy.get('[data-cy=contribOwnerName]').type(donor.organizationName)
    cy.get('[data-cy=createContribEmail]').type(donor.email)
    cy.get('[data-cy=createContribPhoneNumber]').type(donor.phoneNumber)
    cy.get('[data-cy=createContribFirstName]').type(faker.name.firstName())
    cy.get('[data-cy=createContribLastName]').type(faker.name.lastName())
    cy.get('[data-cy=createContribaddressLine1]').type(faker.address.streetAddress())
    cy.get('[data-cy=createContribaddressLine2]').type('Apartment 5')
    cy.get('[data-cy=createContribcity]').type(faker.address.city())
    cy.get('[data-cy=createContribstate]').select(faker.address.state())
    cy.get('[data-cy=createContribpostalCode]').type(faker.address.zipCode().substring(0, 5))

})

Cypress.Commands.add('fillContribOwnersForm', ()=>{
    cy.get('[data-cy=addOwner]').click()
    cy.get('[data-cy=createOwnerFirstName]').type(faker.name.firstName())
    cy.get('[data-cy=createOwnerLastName]').type(faker.name.lastName())
    cy.get('[data-cy=createOwneraddressLine1]').type(faker.address.streetAddress())
    cy.get('[data-cy=createOwneraddressLine2]').type('Apartment 5')
    cy.get('[data-cy=createOwnercity]').type(faker.address.city())
    cy.get('[data-cy=createOwnerstate]').select(faker.address.state())
    cy.get('[data-cy=createOwnerpostalCode]').type(faker.address.zipCode().substring(0, 5))
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

    cy.get('[data-cy=createContribEmail]').type(faker.internet.email())
    cy.get('[data-cy=createContribPhoneNumber]').type(donor.phoneNumber)
    cy.get('[data-cy=createContribFirstName]').type(faker.name.firstName())
    cy.get('[data-cy=createContribLastName]').type(faker.name.lastName())
    cy.get('[data-cy=createContribaddressLine1]').type(faker.address.streetAddress())
    cy.get('[data-cy=createContribaddressLine2]').type('Apartment 5')
    cy.get('[data-cy=createContribcity]').type(faker.address.city())
    cy.get('[data-cy=createContribstate]').select(faker.address.state())
    cy.get('[data-cy=createContribpostalCode]').type(faker.address.zipCode().substring(0, 5))

    cy.get('.col-8 > form > .form-group > :nth-child(4) > .custom-control-label').click()

})

// Disbursement Commands

Cypress.Commands.add ('initDisb',()=>{

    cy.get('#actions-dropdown').click()
    cy.get('button').contains('Create Disbursement').click()

})

Cypress.Commands.add('fillDisbForm', ()=>{
    cy.get('[data-cy=createDisbrecipientName]')
        .type(`${faker.name.firstName()} ${faker.name.lastName()}`)
    cy.get('[data-cy=createDisbaddressLine1]').first().type(faker.address.streetAddress())
    cy.get('[data-cy=createDisbaddressLine2]').first().type('Apartment 5')
    cy.get('[data-cy=createDisbcity]').first().type(faker.address.city())
    cy.get('[data-cy=createDisbstate]').first().select(faker.address.state())
    cy.get('[data-cy=createDisbpostalCode]').first().type(faker.address.zipCode().substring(0, 5))

    cy.get('[data-cy=createDisbpurposeCode]').first().select("LITER")

    cy.get('[data-cy=createDisbisSubcontractedyes]').click()
    cy.get('[data-cy=createDisbisPartialPaymentno]').click()
    cy.get('[data-cy=createDisbisExistingLiabilityno]').click()
    cy.get('[data-cy=createDisbisInKindno]').click()

    cy.get('[data-cy=paymentAmountcreateDisb]').first().type(faker.datatype.number({
            min: 10,
            max: 100,
        }))
    cy.get('[data-cy=paymentDatecreateDisb]').first()
        .type('2021-09-17')
    

})
