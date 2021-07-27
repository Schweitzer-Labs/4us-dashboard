module Timestamp exposing (dateStringToMillis, formDate, format, view)

import Date
import DateFormat
import DateTime
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Time exposing (Month(..), Posix, Zone)



-- VIEW


view : Time.Zone -> Int -> Html msg
view timeZone timestamp =
    span [ class "date" ] [ text (format timeZone timestamp) ]



-- FORMAT


{-| Format a timestamp as a String, like so:

    "February 14, 2018"

For more complex date formatting scenarios, here's a nice package:
<https://package.elm-lang.org/packages/ryannhg/date-format/latest/>

-}
format : Time.Zone -> Int -> String
format zone time =
    let
        timePosix =
            Time.millisToPosix time

        month =
            case Time.toMonth zone timePosix of
                Jan ->
                    "January"

                Feb ->
                    "February"

                Mar ->
                    "March"

                Apr ->
                    "April"

                May ->
                    "May"

                Jun ->
                    "June"

                Jul ->
                    "July"

                Aug ->
                    "August"

                Sep ->
                    "September"

                Oct ->
                    "October"

                Nov ->
                    "November"

                Dec ->
                    "December"

        day =
            String.fromInt (Time.toDay zone timePosix)

        year =
            String.fromInt (Time.toYear zone timePosix)
    in
    month ++ " " ++ day ++ ", " ++ year


dateStringToMillis : String -> Int
dateStringToMillis val =
    if val == "" then
        0

    else
        case Date.fromIsoString val of
            Ok date ->
                let
                    y =
                        Date.year date

                    m =
                        Date.month date

                    d =
                        Date.day date
                in
                case DateTime.fromRawParts { day = d, month = m, year = y } { hours = 0, milliseconds = 0, seconds = 0, minutes = 0 } of
                    Just datetime ->
                        DateTime.toMillis datetime

                    Nothing ->
                        0

            Err a ->
                0


isoFormatter : Zone -> Posix -> String
isoFormatter =
    DateFormat.format
        [ DateFormat.yearNumber
        , DateFormat.text "-"
        , DateFormat.monthFixed
        , DateFormat.text "-"
        , DateFormat.dayOfMonthFixed
        ]


formDate : Zone -> Int -> String
formDate timezone milliTime =
    let
        posixTime =
            Time.millisToPosix milliTime
    in
    isoFormatter timezone posixTime
