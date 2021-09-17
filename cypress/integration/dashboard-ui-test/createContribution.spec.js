it('should visit 4us dashboard page',  () => {
    cy.visit('http://localhost:3000/committee/nelson-lopez')
    cy.get('#actions-dropdown').click()
    cy.get('button').contains('Create Contribution').click()

    cy.get('#amount').type('10')
    cy.get('#date').type('2021-09-17')

    cy.get('#Individual').click()

    cy.get(':nth-child(5) > :nth-child(1) > .form-control').type('4us@gmail.com')
    cy.get(':nth-child(5) > :nth-child(2) > .form-control').type('2369860981')
    cy.get(':nth-child(4) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > :nth-child(6) > :nth-child(1) > .form-control')
        .type('John')
    cy.get(':nth-child(4) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > :nth-child(6) > :nth-child(2) > .form-control')
        .type('Doe')

    cy.get('#addressLine1').type('1234 Broadway')
    cy.get('#addressLine2').type('Apartment 5')
    cy.get('#city').type('Manhattan')
    cy.get('#State').select('New York')
    cy.get('#postalCode').type('10356')


    cy.get(':nth-child(5) > .custom-control-label').click()
    cy.get(':nth-child(11) > :nth-child(1) > .form-control').type('Toyota')
    cy.get(':nth-child(11) > :nth-child(2) > .form-control').type('Marketing')
    cy.get('.col-8 > form > .form-group > :nth-child(4) > .custom-control-label').click()

    cy.get(':nth-child(15) > .form-group > :nth-child(3) > .custom-control-label').click()

    cy.get('#card-number').type('4242424242424242')
    cy.get('#card-month').select('4 - Apr')
    cy.get('#card-year').select('2024')
    cy.get('#cvv').type('123')

    cy.get('button').contains('Submit').click()
});
