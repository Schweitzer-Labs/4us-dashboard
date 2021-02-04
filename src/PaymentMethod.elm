module PaymentMethod exposing (PaymentMethod(..), init, paymentMethodToText, toDisplayString)

import Html exposing (Html, div, text)


type PaymentMethod
    = ACH ACHModel
    | Wire WireModel
    | Check CheckModel


toDisplayString : String -> String
toDisplayString src =
    case src of
        "ach" ->
            "ACH"

        "wire" ->
            "Wire"

        "check" ->
            "Check"

        "credit" ->
            "Credit"

        _ ->
            ""


init : String -> Maybe PaymentMethod
init str =
    case str of
        "check" ->
            Just
                (Check
                    { checkNumber = ""
                    , entityName = ""
                    , date = ""
                    }
                )

        _ ->
            Nothing


type alias CheckModel =
    { checkNumber : String
    , entityName : String
    , date : String
    }


type alias WireModel =
    { bankName : String
    , bankAddress1 : String
    , bankAddress2 : String
    , bankCity : String
    , bankState : String
    , bankPostalCode : String
    , routingNumber : String
    , accountNumber : String
    }


type alias ACHModel =
    { bankName : String
    , routingNumber : String
    , accountNumber : String
    , accountType : AccountType
    }


type AccountType
    = Checking
    | Saving


form : PaymentMethod -> msg -> Html msg
form paymentMethod submit =
    case paymentMethod of
        Check model ->
            div [] [ text "checking form" ]

        _ ->
            div [] [ text "other forms" ]


paymentMethodToText : PaymentMethod -> String
paymentMethodToText method =
    case method of
        Check a ->
            "Check"

        ACH a ->
            "ACH"

        Wire a ->
            "Wire"
