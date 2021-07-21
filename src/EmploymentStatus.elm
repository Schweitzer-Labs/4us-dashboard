module EmploymentStatus exposing (..)

import Bootstrap.Form.Radio as Radio exposing (Radio)
import Json.Decode as Decode exposing (Decoder)


type EmploymentStatus
    = EMPLOYED
    | SELFEMPLOYED
    | RETIRED
    | UNEMPLOYED


fromString : String -> Maybe EmploymentStatus
fromString str =
    case str of
        "Employed" ->
            Just EMPLOYED

        "SelfEmployed" ->
            Just SELFEMPLOYED

        "Retired" ->
            Just RETIRED

        "Unemployed" ->
            Just UNEMPLOYED

        _ ->
            Nothing


toDataString : EmploymentStatus -> String
toDataString src =
    case src of
        EMPLOYED ->
            "Employed"

        SELFEMPLOYED ->
            "SelfEmployed"

        RETIRED ->
            "Retired"

        UNEMPLOYED ->
            "Unemployed"


fromMaybeToString : Maybe EmploymentStatus -> String
fromMaybeToString =
    Maybe.withDefault "" << Maybe.map toDataString


toDisplayString : EmploymentStatus -> String
toDisplayString src =
    case src of
        EMPLOYED ->
            "Employed"

        SELFEMPLOYED ->
            "Self-Employed"

        RETIRED ->
            "Retired"

        UNEMPLOYED ->
            "Unemployed"


decoder : Decoder EmploymentStatus
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Employed" ->
                        Decode.succeed EMPLOYED

                    "SelfEmployed" ->
                        Decode.succeed SELFEMPLOYED

                    "Retired" ->
                        Decode.succeed RETIRED

                    "Unemployed" ->
                        Decode.succeed UNEMPLOYED

                    badVal ->
                        Decode.fail <| "Unknown employment status: " ++ badVal
            )


employmentRadio : Maybe EmploymentStatus -> (Maybe EmploymentStatus -> msg) -> String -> Bool -> Radio (Maybe EmploymentStatus -> msg)
employmentRadio maybeData maybeMsg currentValue disabled =
    Radio.createCustom
        [ Radio.id <| fromMaybeToString <| fromString currentValue
        , Radio.inline
        , Radio.onClick maybeMsg
        , Radio.checked (maybeData == fromString currentValue)
        , Radio.disabled disabled
        ]
        (fromMaybeToString maybeData)
