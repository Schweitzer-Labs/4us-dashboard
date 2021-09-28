

describe('demo individual contributions',()=>{
    before(()=> {
        cy.generateDemo()
    })

    beforeEach(()=> {
        cy.initContrib()
        cy.fillContribFormInd()
    })

    afterEach(()=>{
        cy.contribSubmit()
    })

    it('can create check contributions', ()=>{

        cy.get(':nth-child(15) > .form-group > :nth-child(2) > .custom-control-label').click()
        cy.get('#check-number').type('123')

    })
    it('can create  credit card contribution', ()=>{
        cy.get(':nth-child(15) > .form-group > :nth-child(3) > .custom-control-label').click()
        cy.get('#card-number').type('4242424242424242')
        cy.get('#card-month').select('4 - Apr')
        cy.get('#card-year').select('2024')
        cy.get('#cvv').type('123')


    })
    it('can create in-kind contributions', ()=>{
        cy.get(':nth-child(15) > .form-group > :nth-child(4) > .custom-control-label').click()
        cy.get('.fade-in > .col > form > .form-group > :nth-child(2) > .custom-control-label').click()
        cy.get(':nth-child(4) > .modal > .elm-bootstrap-modal > .modal-content > .modal-body > .container-fluid > .fade-in > .col > .form-control')
            .type('Pizza party')


    })
})
