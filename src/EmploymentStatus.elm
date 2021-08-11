module EmploymentStatus exposing (Model(..), employmentRadioList, fromMaybeToString, fromString, toDataString, toDisplayString)

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio exposing (Radio)
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)


type Model
    = Employed
    | SelfEmployed
    | Retired
    | Unemployed


fromString : String -> Maybe Model
fromString str =
    case str of
        "Employed" ->
            Just Employed

        "SelfEmployed" ->
            Just SelfEmployed

        "Retired" ->
            Just Retired

        "Unemployed" ->
            Just Unemployed

        _ ->
            Nothing


toDataString : Model -> String
toDataString src =
    case src of
        Employed ->
            "Employed"

        SelfEmployed ->
            "SelfEmployed"

        Retired ->
            "Retired"

        Unemployed ->
            "Unemployed"


fromMaybeToString : Maybe Model -> String
fromMaybeToString =
    Maybe.withDefault "" << Maybe.map toDataString


toDisplayString : Model -> String
toDisplayString src =
    case src of
        Employed ->
            "Employed"

        SelfEmployed ->
            "Self-Employed"

        Retired ->
            "Retired"

        Unemployed ->
            "Unemployed"


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Employed" ->
                        Decode.succeed Employed

                    "SelfEmployed" ->
                        Decode.succeed SelfEmployed

                    "Retired" ->
                        Decode.succeed Retired

                    "Unemployed" ->
                        Decode.succeed Unemployed

                    badVal ->
                        Decode.fail <| "Unknown employment status: " ++ badVal
            )


employmentRadioList : (Model -> msg) -> Maybe Model -> Bool -> Maybe String -> List (Html msg)
employmentRadioList msg currentValue disabled txnId =
    let
        id =
            Maybe.withDefault "" txnId
    in
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList
                    "employmentStatus"
                    [ Radio.createCustom
                        [ Radio.id <| id ++ "employmentStatus-employed"
                        , Radio.inline
                        , Radio.onClick (msg Employed)
                        , Radio.checked (currentValue == Just Employed)
                        , Radio.disabled disabled
                        ]
                        "Employed"
                    , Radio.createCustom
                        [ Radio.id <| id ++ "employmentStatus-unemployed"
                        , Radio.inline
                        , Radio.onClick (msg Unemployed)
                        , Radio.checked (currentValue == Just Unemployed)
                        , Radio.disabled disabled
                        ]
                        "Unemployed"
                    , Radio.createCustom
                        [ Radio.id <| id ++ "employmentStatus-retired"
                        , Radio.inline
                        , Radio.onClick (msg Retired)
                        , Radio.checked (currentValue == Just Retired)
                        , Radio.disabled disabled
                        ]
                        "Retired"
                    , Radio.createCustom
                        [ Radio.id <| id ++ "employmentStatus-selfEmployed"
                        , Radio.inline
                        , Radio.onClick (msg SelfEmployed)
                        , Radio.checked (currentValue == Just SelfEmployed)
                        , Radio.disabled disabled
                        ]
                        "Self Employed"
                    ]
                )
            |> Fieldset.view
        ]
    ]
