module Direction exposing (Direction(..), fromString, toDisplayTitle, toString)


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
