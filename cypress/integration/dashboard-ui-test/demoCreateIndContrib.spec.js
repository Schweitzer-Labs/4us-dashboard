

describe('demo individual contributions',()=>{
    before(()=> {
        cy.generateDemo()
    })

    beforeEach(()=> {
        cy.initContrib()
        cy.selectInd()
        cy.fillContribFormInd()

    })

    afterEach(()=>{
        cy.contribSubmit()
    })

    it('can create check contributions', ()=>{

        cy.contains('Check').click()
        cy.get('#check-number').type('123')
    })

    it('can create  credit card contribution', ()=>{
        cy.contains('Credit').click()
        cy.fillCCForm()
    })

    it('can create cash contribution', ()=>{
        cy.contains('Cash').click()
    })

    it('can create in-kind contributions', ()=>{

        cy.contains('In-Kind').click()
        cy.contains('Service/Facilities Provided').click()
        cy.get('[data-cy=createContribDescription]').type('Pizza Party')

    })
})
