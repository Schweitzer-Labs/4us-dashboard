module Dollar exposing (toDisplayString)

import FormatNumber exposing (format)
import FormatNumber.Locales as FormatNumber


toDisplayString : String -> String
toDisplayString str =
    let
        maybeTup =
            String.uncons str
    in
    case maybeTup of
        Just (( firstChar, rest ) as val) ->
            if firstChar == '-' then
                "-" ++ "$" ++ fromCents rest

            else
                "$" ++ fromCents str

        Nothing ->
            "$"


fromCents : String -> String
fromCents cents =
    case String.toFloat cents of
        Just val ->
            format FormatNumber.usLocale (val / 100)

        Nothing ->
            ""
