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
        cy.fillCCForm()
    })

    it('can create a Sole Proprietorship In-kind contribution',()=>{
        cy.fillContribOrgInKind('Solep')
        cy.fillContribOrgPii()

    })

    it('can create a Partnerhip Check contribution',()=>{
        cy.fillContribOrgCheck('Part')
        cy.fillContribOrgPii()

    })
    it('can create a Partnership Credit contribution',()=>{
        cy.fillContribOrgCredit('Part')
        cy.fillContribOrgPii()
        cy.fillCCForm()

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
        cy.fillCCForm()

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
        cy.fillCCForm()

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
        cy.fillCCForm()

    })

    it('can create a Association In-kind contribution',()=>{
        cy.fillContribOrgInKind('Assoc')
        cy.fillContribOrgPii()

    })

    it('can create a Political Action Committee Check contribution',()=>{
        cy.fillContribOrgCheck('Pac')
        cy.fillContribOrgPii()

    })
    it('can create a Political Action Committee contribution',()=>{
        cy.fillContribOrgCredit('Pac')
        cy.fillContribOrgPii()
        cy.fillCCForm()

    })

    it('can create a Political Action Committee In-kind contribution',()=>{
        cy.fillContribOrgInKind('Pac')
        cy.fillContribOrgPii()

    })

    it('can create a Political Committee Check contribution',()=>{
        cy.fillContribOrgCheck('Plc')
        cy.fillContribOrgPii()

    })
    it('can create a Political Committee contribution',()=>{
        cy.fillContribOrgCredit('Plc')
        cy.fillContribOrgPii()
        cy.fillCCForm()

    })

    it('can create a Political Committee In-kind contribution',()=>{
        cy.fillContribOrgInKind('Plc')
        cy.fillContribOrgPii()

    })

    it('can create a Other Check contribution',()=>{
        cy.fillContribOrgCheck('Oth')
        cy.fillContribOrgPii()

    })
    it('can create a Other contribution',()=>{
        cy.fillContribOrgCredit('Oth')
        cy.fillContribOrgPii()
        cy.fillCCForm()

    })

    it('can create a Other In-kind contribution',()=>{
        cy.fillContribOrgInKind('Oth')
        cy.fillContribOrgPii()

    })


})
