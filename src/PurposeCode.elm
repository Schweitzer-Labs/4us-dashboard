module PurposeCode exposing (PurposeCode(..), fromMaybeToString, fromString, purposeCodeText, select, toString, toText)

import AppInput
import Bootstrap.Form as Form
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (attribute, class, for, value)


type PurposeCode
    = BKFEE
    | BKKP
    | BLBD
    | CAR
    | CARSVC
    | CCP
    | CELL
    | CMAIL
    | CNTRB
    | CONSL
    | CONSV
    | EADS
    | EMAIL
    | FUNDR
    | GAS
    | INT
    | LITER
    | LODG
    | LWNSN
    | MEALS
    | MLGE
    | MTG
    | NPD
    | OFFICE
    | OTHER
    | PARK
    | PETIT
    | PIDA
    | POLLS
    | POSTA
    | PRINT
    | PROFL
    | RADIO
    | REIMB
    | RENTO
    | TOLLS
    | TVADS
    | UTILS
    | VOTER
    | WAGE
    | WAGES
    | XPORT


purposeCodeText : List ( PurposeCode, String, String )
purposeCodeText =
    [ ( BKFEE, "BKFEE", "Bank Fees" )
    , ( BLBD, "BLBD", "Billboard" )
    , ( BKKP, "BKKP", "Bookkeeping" )
    , ( CONSL, "CONSL", "Campaign Consultant" )
    , ( LITER, "LITER", "Campaign Literature" )
    , ( CMAIL, "CMAIL", "Campaign Mailings" )
    , ( WAGES, "WAGES", "Campaign Salaries" )
    , ( CAR, "CAR", "Car Rental, Payment, Etc." )
    , ( CELL, "CELL", "Cell Phone" )
    , ( CONSV, "CONSV", "Constituent Services" )
    , ( CCP, "CCP", "Credit Card Payment" )
    , ( EMAIL, "EMAIL", "Email" )
    , ( FUNDR, "FUNDR", "Fundraising" )
    , ( GAS, "EMAIL", "Gas" )
    , ( INT, "INT", "Interest Expense" )
    , ( LWNSN, "LWNSN", "Lawn Signs" )
    , ( LODG, "LODG", "Lodging" )
    , ( MEALS, "MEALS", "Meals" )
    , ( MTG, "MTG", "Meeting" )
    , ( MLGE, "MLGE", "Mileage" )
    , ( NPD, "NPD", "Non-Political Donations" )
    , ( OFFICE, "OFFICE", "Office Expenses" )
    , ( RENTO, "RENTO", "Office Rent" )
    , ( EADS, "EADS", "Online Ads" )
    , ( OTHER, "OTHER", "Other" )
    , ( PIDA, "PIDA", "PIDA" )
    , ( PARK, "PARK", "Parking" )
    , ( PETIT, "PETIT", "Petition Expenses" )
    , ( CNTRB, "CNTRB", "Political Contributions" )
    , ( POLLS, "POLLS", "Polling Costs" )
    , ( POSTA, "POSTA", "Postage" )
    , ( PRINT, "PRINT", "Print Ads" )
    , ( PROFL, "PROFL", "Professional Services" )
    , ( RADIO, "RADIO", "Radio Ads" )
    , ( REIMB, "REIMB", "Reimbursement" )
    , ( CARSVC, "CARSVC", "Taxi, Uber, Etc." )
    , ( TVADS, "TVADS", "Television Ads" )
    , ( TOLLS, "TOLLS", "Tolls" )
    , ( XPORT, "XPORT", "Transportation" )
    , ( UTILS, "UTILS", "Utilities" )
    , ( VOTER, "VOTER", "Voter Reg. Material" )
    , ( WAGE, "WAGE", "Wages" )
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
    Maybe.withDefault "---" << Maybe.map toString


select : String -> Maybe PurposeCode -> (Maybe PurposeCode -> msg) -> Bool -> Html msg
select cyId maybePurposeCode updateMsg disabled =
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange (fromString >> updateMsg)
            , Select.attrs <|
                [ Attribute.value <| fromMaybeToString maybePurposeCode
                , class <| AppInput.inputStyle disabled
                , attribute "data-cy" (cyId ++ "purposeCode")
                ]
            , Select.disabled disabled
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (maybePurposeCode == Nothing)
                    , Attribute.value "---"
                    ]
                    [ text "-- Purpose --" ]
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


toText : Maybe PurposeCode -> String
toText purposeCode =
    case purposeCode of
        Just val ->
            let
                purpose =
                    List.head <|
                        List.filter (\( p, _, _ ) -> p == val) purposeCodeText
            in
            case purpose of
                Just ( _, _, str ) ->
                    str

                _ ->
                    "N/A"

        _ ->
            "N/A"
