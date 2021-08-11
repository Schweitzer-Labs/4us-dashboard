module PaymentMethod exposing (Model(..), decoder, dropdown, fromMaybeToString, select, toDataString, toDisplayString)

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio exposing (Radio)
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (for, value)
import Json.Decode as Decode exposing (Decoder)


type Model
    = Ach
    | Wire
    | Check
    | Credit
    | InKind
    | Debit
    | Transfer
    | Other


toDataString : Model -> String
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


decoder : Decoder Model
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


paymentMethods : List Model
paymentMethods =
    [ Ach
    , Wire
    , Check
    , Credit
    , Debit
    , InKind
    , Transfer
    ]


toDisplayString : Model -> String
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


fromMaybeToString : Maybe Model -> String
fromMaybeToString =
    Maybe.withDefault "---" << Maybe.map toDataString


fromString : String -> Maybe Model
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

        "InKind" ->
            Just InKind

        "Transfer" ->
            Just Transfer

        "Other" ->
            Just Other

        _ ->
            Nothing


type AccountType
    = Checking
    | Saving


select : (Model -> msg) -> Maybe Model -> Bool -> List (Html msg)
select msg currentValue disabled =
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList
                    "paymentMethod"
                    [ Radio.createCustom
                        [ Radio.id "paymentMethod-check"
                        , Radio.inline
                        , Radio.onClick (msg Check)
                        , Radio.checked (currentValue == Just Check)
                        , Radio.disabled disabled
                        ]
                        "Check"
                    , Radio.createCustom
                        [ Radio.id "paymentMethod-credit"
                        , Radio.inline
                        , Radio.onClick (msg Credit)
                        , Radio.checked (currentValue == Just Credit)
                        , Radio.disabled disabled
                        ]
                        "Credit"
                    , Radio.createCustom
                        [ Radio.id "familyOfCandidate-retired"
                        , Radio.inline
                        , Radio.onClick (msg InKind)
                        , Radio.checked (currentValue == Just InKind)
                        , Radio.disabled disabled
                        ]
                        "In-Kind"
                    ]
                )
            |> Fieldset.view
        ]
    ]


dropdown : Maybe Model -> (Maybe Model -> msg) -> List (Html msg)
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
