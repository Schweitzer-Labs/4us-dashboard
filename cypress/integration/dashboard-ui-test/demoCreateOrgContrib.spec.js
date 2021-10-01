describe('demo organization contributions',()=>{
    before(()=>{
        cy.generateDemo()
    })

    beforeEach(()=>{
        cy.initContrib()
        cy.selectOrg()
    })

    afterEach(()=>{
        cy.contribSubmit()
    })

    it('can create a Sole Proprietorship Check contribution',()=>{
        cy.fillContribOrgCheck('Solep')
        cy.fillContribOrgPii()

    })
    
    it('can create a Sole Proprietorship Credit contribution',()=>{
        cy.fillContribOrgCredit('Solep')
        cy.fillContribOrgPii()
    })
    it('can create a Sole Proprietorship Cash contribution',()=>{
        cy.fillContribOrgCash('Solep')
        cy.fillContribOrgPii()

    })

    it('can create a Sole Proprietorship In-kind contribution',()=>{
        cy.fillContribOrgInKind('Solep')
        cy.fillContribOrgPii()

    })

    it('can create a Partnership Check contribution',()=>{
        cy.fillContribOrgCheck('Part')
        cy.fillContribOrgPii()

    })
    it('can create a Partnership Credit contribution',()=>{
        cy.fillContribOrgCredit('Part')
        cy.fillContribOrgPii()

    })

    it('can create a Partnership Cash contribution',()=>{
        cy.fillContribOrgCash('Part')
        cy.fillContribOrgPii()

    })

    it('can create a Partnership In-kind contribution',()=>{
        cy.fillContribOrgInKind('Part')
        cy.fillContribOrgPii()

    })

    it('can create a Corporation Check contribution',()=>{
        cy.fillContribOrgCheck('Corp')
        cy.fillContribOrgPii()

    })
    it('can create a Corporation Credit contribution',()=>{
        cy.fillContribOrgCredit('Corp')
        cy.fillContribOrgPii()

    })

    it('can create a Corporation Cash contribution',()=>{
        cy.fillContribOrgCash('Corp')
        cy.fillContribOrgPii()

    })


    it('can create a Corporation In-kind contribution',()=>{
        cy.fillContribOrgInKind('Corp')
        cy.fillContribOrgPii()

    })

    it('can create a Union Check contribution',()=>{
        cy.fillContribOrgCheck('Union')
        cy.fillContribOrgPii()

    })
    it('can create a Union Credit contribution',()=>{
        cy.fillContribOrgCredit('Union')
        cy.fillContribOrgPii()

    })

    it('can create a Union Cash contribution',()=>{
        cy.fillContribOrgCash('Union')
        cy.fillContribOrgPii()

    })


    it('can create a Union In-kind contribution',()=>{
        cy.fillContribOrgInKind('Union')
        cy.fillContribOrgPii()

    })

    it('can create a Association Check contribution',()=>{
        cy.fillContribOrgCheck('Assoc')
        cy.fillContribOrgPii()

    })
    it('can create a Association Credit contribution',()=>{
        cy.fillContribOrgCredit('Assoc')
        cy.fillContribOrgPii()

    })
    it('can create a Association Cash contribution',()=>{
        cy.fillContribOrgCash('Assoc')
        cy.fillContribOrgPii()

    })

    it('can create a Association In-kind contribution',()=>{
        cy.fillContribOrgInKind('Assoc')
        cy.fillContribOrgPii()

    })

    it('can create a Political Action Committee Check contribution',()=>{
        cy.fillContribOrgCheck('Pac')
        cy.fillContribOrgPii()

    })
    it('can create a Political Action Committee Credit contribution',()=>{
        cy.fillContribOrgCredit('Pac')
        cy.fillContribOrgPii()

    })

    it('can create a Political Action Committee Cash contribution',()=>{
        cy.fillContribOrgCash('Pac')
        cy.fillContribOrgPii()

    })


    it('can create a Political Action Committee In-kind contribution',()=>{
        cy.fillContribOrgInKind('Pac')
        cy.fillContribOrgPii()

    })

    it('can create a Political Committee Check contribution',()=>{
        cy.fillContribOrgCheck('Plc')
        cy.fillContribOrgPii()

    })
    it('can create a Political Committee Credit contribution',()=>{
        cy.fillContribOrgCredit('Plc')
        cy.fillContribOrgPii()

    })

    it('can create a Political Committee Cash contribution',()=>{
        cy.fillContribOrgCash('Plc')
        cy.fillContribOrgPii()

    })


    it('can create a Political Committee In-kind contribution',()=>{
        cy.fillContribOrgInKind('Plc')
        cy.fillContribOrgPii()

    })

    it('can create a Other Check contribution',()=>{
        cy.fillContribOrgCheck('Oth')
        cy.fillContribOrgPii()

    })
    it('can create a Other Credit contribution',()=>{
        cy.fillContribOrgCredit('Oth')
        cy.fillContribOrgPii()

    })

    it('can create a Other Cash contribution',()=>{
        cy.fillContribOrgCash('Oth')
        cy.fillContribOrgPii()

    })


    it('can create a Other In-kind contribution',()=>{
        cy.fillContribOrgInKind('Oth')
        cy.fillContribOrgPii()

    })


})
