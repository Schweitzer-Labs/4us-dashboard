module PaymentMethod exposing (PaymentMethod(..), decoder, toDataString, toDisplayString)

import Json.Decode as Decode exposing (Decoder)


type PaymentMethod
    = ACH
    | Wire
    | Check
    | Credit
    | InKind
    | Debit
    | Transfer


toDataString : PaymentMethod -> String
toDataString method =
    case method of
        ACH ->
            "ach"

        Wire ->
            "wire"

        Check ->
            "check"

        Debit ->
            "debit"

        Credit ->
            "credit"

        InKind ->
            "in-kind"

        Transfer ->
            "transfer"


decoder : Decoder PaymentMethod
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "ach" ->
                        Decode.succeed ACH

                    "wire" ->
                        Decode.succeed Wire

                    "check" ->
                        Decode.succeed Check

                    "credit" ->
                        Decode.succeed Credit

                    "debit" ->
                        Decode.succeed Debit

                    "in-kind" ->
                        Decode.succeed InKind

                    "transfer" ->
                        Decode.succeed Transfer

                    badVal ->
                        Decode.fail <| "Unknown payment method: " ++ badVal
            )


toDisplayString : PaymentMethod -> String
toDisplayString src =
    case src of
        ACH ->
            "ACH"

        Wire ->
            "Wire"

        Check ->
            "Check"

        Credit ->
            "Credit"

        Debit ->
            "Debit"

        Transfer ->
            "Transfer"

        InKind ->
            "In-kind"


type AccountType
    = Checking
    | Saving
