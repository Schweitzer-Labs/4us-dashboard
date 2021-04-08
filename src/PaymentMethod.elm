module PaymentMethod exposing (PaymentMethod(..), toDataString, toDisplayString)

import Html exposing (Html, div, text)


type PaymentMethod
    = ACH
    | Wire
    | Check
    | Credit
    | InKind


toDataString : PaymentMethod -> String
toDataString method =
    case method of
        ACH ->
            "ach"

        Wire ->
            "wire"

        Check ->
            "check"

        Credit ->
            "credit"

        InKind ->
            "in-kind"


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

        "debit" ->
            "Debit"

        "transfer" ->
            "Transfer"

        "in-kind" ->
            "In-kind"

        _ ->
            ""


type AccountType
    = Checking
    | Saving
