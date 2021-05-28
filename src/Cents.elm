module Cents exposing (fromDollars, stringToDollar, toDollar)

import FormatNumber exposing (format)
import FormatNumber.Locales as FormatNumber


toDollar : Int -> String
toDollar num =
    let
        numStr =
            String.fromInt num

        maybeTup =
            String.uncons <| numStr
    in
    case maybeTup of
        Just (( firstChar, rest ) as val) ->
            if firstChar == '-' then
                "-" ++ "$" ++ toUnsignedDollar rest

            else
                "$" ++ toUnsignedDollar numStr

        Nothing ->
            "$"


stringToDollar : String -> String
stringToDollar str =
    let
        maybeTup =
            String.uncons str
    in
    case maybeTup of
        Just (( firstChar, rest ) as val) ->
            if firstChar == '-' then
                "-" ++ "$" ++ toUnsignedDollar rest

            else
                "$" ++ toUnsignedDollar str

        Nothing ->
            "$"


fromDollars : String -> Int
fromDollars amountStr =
    case String.toFloat amountStr of
        Just float ->
            round <| float * 100

        Nothing ->
            0


toUnsignedDollar : String -> String
toUnsignedDollar cents =
    case String.toFloat cents of
        Just val ->
            format FormatNumber.usLocale (val / 100)

        Nothing ->
            ""
