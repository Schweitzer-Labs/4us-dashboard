module Direction exposing (Direction(..), decoder, fromString, toDisplayTitle, toString)

import Json.Decode as Decode exposing (Decoder)


type Direction
    = In
    | Out


toString : Direction -> String
toString direction =
    if direction == In then
        "in"

    else
        "out"


fromString : String -> Maybe Direction
fromString str =
    case str of
        "in" ->
            Just In

        "out" ->
            Just Out

        _ ->
            Nothing


toDisplayTitle : Direction -> String
toDisplayTitle direction =
    case direction of
        In ->
            "Contributions"

        Out ->
            "Disbursements"


decoder : Decoder Direction
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "in" ->
                        Decode.succeed In

                    "out" ->
                        Decode.succeed Out

                    badVal ->
                        Decode.fail <| "Unknown direction: " ++ badVal
            )
