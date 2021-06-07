module PaymentMethod exposing (PaymentMethod(..), decoder, dropdown, select, toDataString, toDisplayString)

import Bootstrap.Form as Form
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes exposing (for, value)
import Json.Decode as Decode exposing (Decoder)
import SelectRadio


type PaymentMethod
    = Ach
    | Wire
    | Check
    | Credit
    | InKind
    | Debit
    | Transfer


toDataString : PaymentMethod -> String
toDataString method =
    case method of
        Ach ->
            "Ach"

        Wire ->
            "Wire"

        Check ->
            "Check"

        Debit ->
            "Debit"

        Credit ->
            "Credit"

        InKind ->
            "InKind"

        Transfer ->
            "Transfer"


decoder : Decoder PaymentMethod
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Ach" ->
                        Decode.succeed Ach

                    "Wire" ->
                        Decode.succeed Wire

                    "Check" ->
                        Decode.succeed Check

                    "Credit" ->
                        Decode.succeed Credit

                    "Debit" ->
                        Decode.succeed Debit

                    "InKind" ->
                        Decode.succeed InKind

                    "Transfer" ->
                        Decode.succeed Transfer

                    badVal ->
                        Decode.fail <| "Unknown payment method: " ++ badVal
            )


paymentMethods : List PaymentMethod
paymentMethods =
    [ Ach
    , Wire
    , Check
    , Credit
    , Debit
    , InKind
    , Transfer
    ]


toDisplayString : PaymentMethod -> String
toDisplayString src =
    case src of
        Ach ->
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


select : (String -> msg) -> String -> List (Html msg)
select updateMsg paymentMethodString =
    Radio.radioList
        "Payment Method"
        [ SelectRadio.view updateMsg (toDataString Check) "Check" paymentMethodString
        , SelectRadio.view updateMsg (toDataString Credit) "Credit" paymentMethodString
        , SelectRadio.view updateMsg (toDataString InKind) "In-Kind" paymentMethodString
        ]


dropdown : (String -> msg) -> Html msg
dropdown updateMsg =
    Form.group
        []
        [ Form.label [ for "payment-method" ] [ text "Payment Method" ]
        , Select.select
            [ Select.id "payment-method"
            , Select.onChange updateMsg
            ]
          <|
            (++) [ Select.item [] [ text "---" ] ] <|
                List.map
                    (\paymentMethod -> Select.item [ value (toDataString paymentMethod) ] [ text (toDisplayString paymentMethod) ])
                    paymentMethods
        ]
