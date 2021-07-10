module PurposeCode exposing (PurposeCode(..), fromMaybeToString, fromString, purposeCodeText, select, toString)

import Bootstrap.Form as Form
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (for, value)


type PurposeCode
    = LITER
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
    | CMAIL
    | CONSL
    | CONSV
    | CNTRB
    | FUNDR
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


purposeCodeText : List ( PurposeCode, String, String )
purposeCodeText =
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


fromString : String -> Maybe PurposeCode
fromString str =
    let
        maybePurpose =
            List.head <|
                List.filter (\( _, p, _ ) -> p == str) purposeCodeText
    in
    case maybePurpose of
        Just ( val, _, _ ) ->
            Just val

        Nothing ->
            Nothing


toString : PurposeCode -> String
toString purpose =
    let
        maybePurpose =
            List.head <|
                List.filter (\( p, _, _ ) -> p == purpose) purposeCodeText
    in
    case maybePurpose of
        Just ( _, val, _ ) ->
            val

        Nothing ->
            ""


fromMaybeToString : Maybe PurposeCode -> String
fromMaybeToString =
    Maybe.withDefault "" << Maybe.map toString


select : Maybe PurposeCode -> (Maybe PurposeCode -> msg) -> Html msg
select maybePurposeCode updateMsg =
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange (fromString >> updateMsg)
            , Select.attrs <| [ Attribute.value <| fromMaybeToString maybePurposeCode ]
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (maybePurposeCode == Nothing)
                    , Attribute.value ""
                    ]
                    [ text "---" ]
                ]
            <|
                List.map
                    (\( _, codeText, purposeText ) ->
                        Select.item
                            [ Attribute.selected (codeText == fromMaybeToString maybePurposeCode)
                            , Attribute.value codeText
                            ]
                            [ text <| purposeText ]
                    )
                    purposeCodeText
        ]
