module Purpose exposing (Purpose(..), purposeText, purposeToString)


type Purpose
    = CMAIL
    | CONSL
    | CONSV
    | CNTRB
    | FUNDR
    | LITER
    | OFFICE
    | OTHER
    | PETIT
    | INT
    | POLLS
    | POSTA
    | PRINT
    | PROFL
    | RADIO
    | REIMB
    | RDET
    | RENTO
    | TVADS
    | VOTER
    | WAGES
    | BKFEE
    | LWNSN
    | UTILS
    | PAYRL
    | MAILS
    | LOAN
    | CCDET
    | CCP
    | BKKP
    | CAR
    | CARSVC
    | CELL
    | EADS
    | GAS
    | LODG
    | MEALS
    | MLGE
    | MTG
    | PARK
    | TOLLS
    | XPORT
    | BLBD
    | WAGE
    | NPD



purposeText : List ( Purpose, String, String )
purposeText =
    [ ( CMAIL, "CMAIL", "Campaign Mailings" )
    , ( CONSL, "CONSL", "Campaign Consultant" )
    , ( CONSV, "CONSV", "Constituent Services" )
    , ( CNTRB, "CNTRB", "Political Contributions" )
    , ( FUNDR, "FUNDR", "Fundraising" )
    , ( LITER, "LITER", "Campaign Literature" )
    , ( OFFICE, "OFFICE", "Office Expenses" )
    , ( OTHER, "OTHER", "Other" )
    , ( PETIT, "PETIT", "Petition Expenses" )
    , ( INT, "INT", "Interest Expense" )
    , ( POLLS, "POLLS", "Polling Costs" )
    , ( POSTA, "POSTA", "Postage" )
    , ( PRINT, "PRINT", "Print Ads" )
    , ( PROFL, "PROFL", "Professional Services" )
    , ( RADIO, "RADIO", "Radio Ads" )
    , ( REIMB, "REIMB", "Reimbursement" )
    , ( RENTO, "RENTO", "Office Rent" )
    , ( RDET, "RDET", "Reimbursement Detail Item" )
    , ( TVADS, "TVADS", "Television Ads" )
    , ( VOTER, "VOTER", "Voter Reg. Material" )
    , ( WAGES, "WAGES", "Campaign Salaries" )
    , ( BKFEE, "BKFEE", "Bank Fees" )
    , ( LWNSN, "LWNSN", "Lawn Signs" )
    , ( UTILS, "UTILS", "Utilities" )
    , ( PAYRL, "PAYRL", "Payroll" )
    , ( MAILS, "MAILS", "Mailings" )
    , ( LOAN, "LOAN", "Loan" )
    , ( CCDET, "CC-DET", "Credit Card Itemization" )
    , ( CCP, "CCP", "Credit Card Payment" )
    , ( BKKP, "BKKP", "Bookkeeping" )
    , ( CAR, "CAR", "Car Rental, Payment, Etc." )
    , ( CARSVC, "CARSVC", "Taxi, Uber, Etc." )
    , ( CELL, "CELL", "Cell Phone" )
    , ( EADS, "EADS", "Online Ads" )
    , ( GAS, "EMAIL", "Gas" )
    , ( LODG, "LODG", "Lodging" )
    , ( MEALS, "MEALS", "Meals" )
    , ( MLGE, "MLGE", "Mileage" )
    , ( MTG, "MTG", "Meeting" )
    , ( PARK, "PARK", "Parking" )
    , ( TOLLS, "TOLLS", "Tolls" )
    , ( XPORT, "XPORT", "Transportation" )
    , ( BLBD, "BLBD", "Billboard" )
    , ( WAGE, "WAGE", "Wages" )
    , ( NPD, "NPD", "Non-Political Donations" )
    ]


purposeToString : Purpose -> String
purposeToString purpose =
    let
        maybePurpose =
            List.head <|
                List.filter (\( p, _, _ ) -> p == purpose) purposeText
    in
    case maybePurpose of
        Just ( _, val, _ ) ->
            val

        Nothing ->
            ""
