module InKindType exposing (Model(..), fromDataString, radioList, toDataString)

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)


type Model
    = ServicesFacilitiesProvided
    | CampaignExpensesPaid
    | PropertyGiven


fromDataString : String -> Maybe Model
fromDataString str =
    case str of
        "ServicesFacilitiesProvided" ->
            Just ServicesFacilitiesProvided

        "CampaignExpensesPaid" ->
            Just CampaignExpensesPaid

        "PropertyGiven" ->
            Just PropertyGiven

        _ ->
            Nothing


toDataString : Model -> String
toDataString src =
    case src of
        ServicesFacilitiesProvided ->
            "ServicesFacilitiesProvided"

        CampaignExpensesPaid ->
            "CampaignExpensesPaid"

        PropertyGiven ->
            "PropertyGiven"


fromMaybeToString : Maybe Model -> String
fromMaybeToString =
    Maybe.withDefault "" << Maybe.map toDataString


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "ServicesFacilitiesProvided" ->
                        Decode.succeed ServicesFacilitiesProvided

                    "CampaignExpensesPaid" ->
                        Decode.succeed CampaignExpensesPaid

                    "PropertyGiven" ->
                        Decode.succeed PropertyGiven

                    badVal ->
                        Decode.fail <| "Unknown InKind Description: " ++ badVal
            )


radioList : (Model -> msg) -> Maybe Model -> Bool -> List (Html msg)
radioList msg currentValue disabled =
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList
                    "inKindType"
                    [ Radio.createCustom
                        [ Radio.id "inKindType-servicesFacilitiesProvided"
                        , Radio.inline
                        , Radio.onClick (msg ServicesFacilitiesProvided)
                        , Radio.checked (currentValue == Just ServicesFacilitiesProvided)
                        , Radio.disabled disabled
                        ]
                        "Service/Facilities Provided"
                    , Radio.createCustom
                        [ Radio.id "inKindType-campaignExpensesPaid"
                        , Radio.inline
                        , Radio.onClick (msg CampaignExpensesPaid)
                        , Radio.checked (currentValue == Just CampaignExpensesPaid)
                        , Radio.disabled disabled
                        ]
                        "Campaign Expenses Paid"
                    , Radio.createCustom
                        [ Radio.id "inKindType-propertyGiven"
                        , Radio.inline
                        , Radio.onClick (msg PropertyGiven)
                        , Radio.checked (currentValue == Just PropertyGiven)
                        , Radio.disabled disabled
                        ]
                        "Property Given"
                    ]
                )
            |> Fieldset.view
        ]
    ]
