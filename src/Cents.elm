module Cents exposing
    ( fromDollars
    , fromMaybeDollars
    , stringToDollar
    , toDollar
    , toDollarData
    , toUnsignedDollar
    )

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
                "-" ++ "$" ++ strToUnsignedDollar rest

            else
                "$" ++ strToUnsignedDollar numStr

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
                "-" ++ "$" ++ strToUnsignedDollar rest

            else
                "$" ++ strToUnsignedDollar str

        Nothing ->
            "$"


fromDollars : String -> Int
fromDollars amountStr =
    case String.toFloat amountStr of
        Just float ->
            round <| float * 100

        Nothing ->
            0


fromMaybeDollars : String -> Maybe Int
fromMaybeDollars =
    String.toFloat >> Maybe.map ((*) 100 >> round)


strToUnsignedDollar : String -> String
strToUnsignedDollar cents =
    case String.toFloat cents of
        Just val ->
            format FormatNumber.usLocale (val / 100)

        Nothing ->
            ""


toUnsignedDollar : Int -> String
toUnsignedDollar cents =
    format FormatNumber.usLocale (toFloat cents / 100)


toDollarData : Int -> String
toDollarData cents =
    String.replace "," "" <| toUnsignedDollar cents
