module YearSelector exposing (view)

import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes exposing (value)


view : (String -> msg) -> Html msg
view updateMsg =
    Select.select
        [ Select.id "card-year"
        , Select.onChange updateMsg
        ]
        [ Select.item [ value "" ] [ text "Select year" ]
        , Select.item [ value "2020" ] [ text "2020" ]
        , Select.item [ value "2021" ] [ text "2021" ]
        , Select.item [ value "2022" ] [ text "2022" ]
        , Select.item [ value "2023" ] [ text "2023" ]
        , Select.item [ value "2024" ] [ text "2024" ]
        , Select.item [ value "2025" ] [ text "2025" ]
        , Select.item [ value "2026" ] [ text "2026" ]
        , Select.item [ value "2027" ] [ text "2027" ]
        , Select.item [ value "2028" ] [ text "2028" ]
        , Select.item [ value "2029" ] [ text "2029" ]
        , Select.item [ value "2030" ] [ text "2030" ]
        ]
