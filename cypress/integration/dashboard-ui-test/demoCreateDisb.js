describe('demo individual disbursements',()=>{
    before(()=> {
        cy.generateDemo()
    })
    beforeEach(()=>{
        cy.initDisb()
        cy.fillDisbForm()
    })

    afterEach(()=>{
        cy.disbSubmit()
    })
    it( 'can create ACH disbursements',()=>{
        cy.get('#paymentMethod').select('ACH')
    })

    it( 'can create Wire disbursements',()=>{
        cy.get('#paymentMethod').select('Wire')
    })

    it( 'can create Cash disbursements',()=>{
        cy.get('#paymentMethod').select('Cash')
    })

    it( 'can create Check disbursements',()=>{

        cy.get('#paymentMethod').select('Check')
        cy.get(':nth-child(8) > .col > .form-control').type('123')
    })
    it( 'can create Credit disbursements',()=>{
        cy.get('#paymentMethod').select('Credit')
    })
    it( 'can create Debit disbursements',()=>{
        cy.get('#paymentMethod').select('Debit')
    })
    it( 'can create Transfer disbursements',()=>{
        cy.get('#paymentMethod').select('Transfer')
    })
})
