module Direction exposing (Direction(..), decoder, fromString, toDisplayTitle, toString)

import Json.Decode as Decode exposing (Decoder)


type Direction
    = In
    | Out


toString : Direction -> String
toString direction =
    if direction == In then
        "In"

    else
        "Out"


fromString : String -> Maybe Direction
fromString str =
    case str of
        "In" ->
            Just In

        "Out" ->
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
                    "In" ->
                        Decode.succeed In

                    "Out" ->
                        Decode.succeed Out

                    badVal ->
                        Decode.fail <| "Unknown direction: " ++ badVal
            )
