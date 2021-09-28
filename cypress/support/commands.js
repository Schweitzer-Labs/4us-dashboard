
Cypress.Commands.add('generateDemo', () => {

    const appUrl = 'http://localhost:3000/committee/nelson-lopez'
    const demoPassword = 'f4jp1i'


    cy.visit(appUrl)
    cy.visit(`${appUrl}/demo`)

    cy.get('#password').type(demoPassword)
    cy.get('.btn').click()
    cy.wait(12000)
    cy.get('.col-12 > a').then((e)=>{
        cy.visit(e.text())
    })
})

Cypress.Commands.add ('initContrib',()=>{

    cy.get('#actions-dropdown').click()
    cy.get('button').contains('Create Contribution').click()

    cy.get('#amount').type('10')
    cy.get('#date').type('2021-09-17')
})

Cypress.Commands.add('fillContribFormInd', ()=>{

    cy.get('#Individual').click()

    cy.get(':nth-child(5) > :nth-child(1) > .form-control').type('4us@gmail.com')
    cy.get(':nth-child(5) > :nth-child(2) > .form-control').type('2369860981')
    cy.get(':nth-child(4) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > :nth-child(6) > :nth-child(1) > .form-control')
        .type('John')
    cy.get(':nth-child(4) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > :nth-child(6) > :nth-child(2) > .form-control')
        .type('Williams')

    cy.get('#addressLine1').type('1234 Broadway')
    cy.get('#addressLine2').type('Apartment 5')
    cy.get('#city').type('Manhattan')
    cy.get('#State').select('New York')
    cy.get('#postalCode').type('10356')


    cy.get(':nth-child(5) > .custom-control-label').click()
    cy.get(':nth-child(11) > :nth-child(1) > .form-control').type('Toyota')
    cy.get(':nth-child(11) > :nth-child(2) > .form-control').type('Marketing')
    cy.get('.col-8 > form > .form-group > :nth-child(4) > .custom-control-label').click()

})

Cypress.Commands.add('contribSubmit', ()=> {
    cy.get('button').contains('Submit').click()
    cy.wait(5000)
})
