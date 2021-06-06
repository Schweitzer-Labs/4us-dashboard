module MonthSelector exposing (view)

import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes exposing (value)


view : (String -> msg) -> Html msg
view updateMsg =
    Select.select
        [ Select.id "card-month"
        , Select.onChange updateMsg
        ]
        [ Select.item [ value "" ] [ text "Select month" ]
        , Select.item [ value "1" ] [ text "1 - Jan" ]
        , Select.item [ value "2" ] [ text "2 - Feb" ]
        , Select.item [ value "3" ] [ text "3 - Mar" ]
        , Select.item [ value "4" ] [ text "4 - Apr" ]
        , Select.item [ value "5" ] [ text "5 - May" ]
        , Select.item [ value "6" ] [ text "6 - Jun" ]
        , Select.item [ value "7" ] [ text "7 - Jul" ]
        , Select.item [ value "8" ] [ text "8 - Aug" ]
        , Select.item [ value "9" ] [ text "9 - Sept" ]
        , Select.item [ value "10" ] [ text "10 - Oct" ]
        , Select.item [ value "11" ] [ text "11 - Nov" ]
        , Select.item [ value "12" ] [ text "12 - Dec" ]
        ]
