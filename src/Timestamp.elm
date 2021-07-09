module Timestamp exposing (dateStringToMillis, format, view)

import Date
import DateTime
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Time exposing (Month(..))
import TimeZone exposing (america__new_york)



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
                        let
                            dPosix =
                                DateTime.toPosix datetime

                            offset =
                                DateTime.getTimezoneOffset (america__new_york ()) dPosix

                            dMillis =
                                DateTime.toMillis datetime

                            res =
                                dMillis + offset
                        in
                        res

                    Nothing ->
                        0

            Err a ->
                0
