module PaymentMethod exposing (Model(..), decoder, dropdown, fromMaybeToString, fromString, select, toDataString, toDisplayString)

import AppInput
import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio exposing (Radio)
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (attribute, class, for, value)
import Json.Decode as Decode exposing (Decoder)


type Model
    = Cash
    | Ach
    | Wire
    | Check
    | Credit
    | InKind
    | Debit
    | Transfer
    | OnlineProcessor
    | Other


toDataString : Model -> String
toDataString method =
    case method of
        Cash ->
            "Cash"

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

        OnlineProcessor ->
            "OnlineProcessor"

        Other ->
            "Other"


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Cash" ->
                        Decode.succeed Cash

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

                    "OnlineProcessor" ->
                        Decode.succeed OnlineProcessor

                    "Other" ->
                        Decode.succeed Other

                    badVal ->
                        Decode.fail <| "Unknown payment method: " ++ badVal
            )


paymentMethods : List Model
paymentMethods =
    [ Cash
    , Ach
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
        Cash ->
            "Cash"

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

        InKind ->
            "In-kind"

        Transfer ->
            "Transfer"

        OnlineProcessor ->
            "Online Processor"

        Other ->
            "Other"


fromMaybeToString : Maybe Model -> String
fromMaybeToString =
    Maybe.withDefault "---" << Maybe.map toDataString


fromString : String -> Maybe Model
fromString str =
    case str of
        "Cash" ->
            Just Cash

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

        "OnlineProcessor" ->
            Just OnlineProcessor

        "Other" ->
            Just Other

        _ ->
            Nothing


type AccountType
    = Checking
    | Saving


select : Bool -> (Model -> msg) -> Maybe Model -> Bool -> Maybe String -> List (Html msg)
select processPayment msg currentValue disabled txnId =
    let
        id =
            Maybe.withDefault "" txnId

        inKindRadio =
            if processPayment then
                [ Radio.createCustomAdvanced
                    [ Radio.id <| id ++ "paymentMethodInKind-retired"
                    , Radio.inline
                    , Radio.onClick (msg InKind)
                    , Radio.checked (currentValue == Just InKind)
                    , Radio.disabled disabled
                    ]
                    (Radio.label [ attribute "data-cy" "payMethod-inKind" ]
                        [ text "In-Kind" ]
                    )
                ]

            else
                []
    in
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList
                    "paymentMethod"
                 <|
                    [ Radio.createCustomAdvanced
                        [ Radio.id <| id ++ "paymentMethod-check"
                        , Radio.inline
                        , Radio.onClick (msg Check)
                        , Radio.checked (currentValue == Just Check)
                        , Radio.disabled disabled
                        ]
                        (Radio.label [ attribute "data-cy" "payMethod-check" ]
                            [ text "Check" ]
                        )
                    , Radio.createCustomAdvanced
                        [ Radio.id <| id ++ "paymentMethod-credit"
                        , Radio.inline
                        , Radio.onClick (msg Credit)
                        , Radio.checked (currentValue == Just Credit)
                        , Radio.disabled disabled
                        ]
                        (Radio.label [ attribute "data-cy" "payMethod-credit" ]
                            [ text "Credit" ]
                        )
                    , Radio.createCustomAdvanced
                        [ Radio.id <| id ++ "paymentMethod-cash"
                        , Radio.inline
                        , Radio.onClick (msg Cash)
                        , Radio.checked (currentValue == Just Cash)
                        , Radio.disabled disabled
                        ]
                        (Radio.label [ attribute "data-cy" "payMethod-cash" ]
                            [ text "Cash" ]
                        )
                    ]
                        ++ inKindRadio
                )
            |> Fieldset.view
        ]
    ]


dropdown : Maybe Model -> (Maybe Model -> msg) -> Bool -> List (Html msg)
dropdown maybePaymentMethod updateMsg isDisbursement =
    [ Form.group
        []
        [ Form.label [ for "paymentMethod" ] [ text "Payment Method" ]
        , Select.select
            [ Select.id "paymentMethod"
            , Select.onChange (fromString >> updateMsg)
            , Select.attrs <| [ Attribute.value <| fromMaybeToString maybePaymentMethod, class <| AppInput.inputStyle False ]
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
                <|
                    if isDisbursement then
                        List.filter (\paymentMethod -> paymentMethod /= InKind) paymentMethods

                    else
                        paymentMethods
        ]
    ]
