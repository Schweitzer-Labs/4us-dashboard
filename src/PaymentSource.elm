module PaymentSource exposing (..)

import Json.Decode as Decode exposing (Decoder)


type Model
    = ActBlue
    | Stripe
    | Dashboard
    | DonateForm
    | Finicity
    | Other


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "ActBlue" ->
                        Decode.succeed ActBlue

                    "Stripe" ->
                        Decode.succeed Stripe

                    "dashboard" ->
                        Decode.succeed Dashboard

                    "donate_form" ->
                        Decode.succeed DonateForm

                    "DONATE_FORM" ->
                        Decode.succeed DonateForm

                    "finicity" ->
                        Decode.succeed Finicity

                    _ ->
                        Decode.succeed Other
            )
