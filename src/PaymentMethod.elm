module PaymentMethod exposing (PaymentMethod(..), decoder, dropdown, fromMaybeToString, select, toDataString, toDisplayString)

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio exposing (Radio)
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (for, value)
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
    | Other


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

        Other ->
            "Other"


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

                    "Other" ->
                        Decode.succeed Other

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

        Other ->
            "Other"


fromMaybeToString : Maybe PaymentMethod -> String
fromMaybeToString =
    Maybe.withDefault "---" << Maybe.map toDataString


fromString : String -> Maybe PaymentMethod
fromString str =
    case str of
        "Ach" ->
            Just Ach

        "Wire" ->
            Just Wire

        "Check" ->
            Just Check

        "Credit" ->
            Just Credit

        "Debit" ->
            Just Debit

        "Transfer" ->
            Just Transfer

        "InKind" ->
            Just InKind

        "Other" ->
            Just Other

        _ ->
            Nothing


type AccountType
    = Checking
    | Saving


select : (String -> msg) -> String -> Bool -> List (Html msg)
select msg val disabled =
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList "Payment Method"
                    [ radio msg Check val disabled
                    , radio msg Credit val disabled
                    , radio msg InKind val disabled
                    ]
                )
            |> Fieldset.view
        ]
    ]


radio : (String -> msg) -> PaymentMethod -> String -> Bool -> Radio msg
radio msg paymentMethod val disabled =
    let
        checked =
            Maybe.withDefault False <| Maybe.map ((==) paymentMethod) (fromString val)
    in
    Radio.create
        [ Radio.inline
        , Radio.onClick <| msg (toDataString paymentMethod)
        , Radio.disabled disabled
        , Radio.checked checked
        ]
        (toDisplayString paymentMethod)


dropdown : Maybe PaymentMethod -> (Maybe PaymentMethod -> msg) -> List (Html msg)
dropdown maybePaymentMethod updateMsg =
    [ Form.group
        []
        [ Form.label [ for "paymentMethod" ] [ text "Payment Method" ]
        , Select.select
            [ Select.id "paymentMethod"
            , Select.onChange (fromString >> updateMsg)
            , Select.attrs <| [ Attribute.value <| fromMaybeToString maybePaymentMethod ]
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (maybePaymentMethod == Nothing)
                    , Attribute.value "---"
                    ]
                    [ text "---" ]
                ]
            <|
                List.map
                    (\paymentMethod ->
                        Select.item
                            [ Attribute.value (toDataString paymentMethod)
                            , Attribute.selected (Just paymentMethod == maybePaymentMethod)
                            ]
                            [ text (toDisplayString paymentMethod) ]
                    )
                    paymentMethods
        ]
    ]
