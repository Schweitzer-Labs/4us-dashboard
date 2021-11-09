module YearSelector exposing (view)

import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (value)


view : (String -> msg) -> String -> Html msg
view updateMsg currentValue =
    Select.select
        [ Select.id "card-year"
        , Select.onChange updateMsg
        ]
        [ Select.item [ Attribute.selected (currentValue == ""), value "" ] [ text "Select year" ]
        , Select.item [ Attribute.selected (currentValue == "2020"), value "2020" ] [ text "2020" ]
        , Select.item [ Attribute.selected (currentValue == "2021"), value "2021" ] [ text "2021" ]
        , Select.item [ Attribute.selected (currentValue == "2022"), value "2022" ] [ text "2022" ]
        , Select.item [ Attribute.selected (currentValue == "2023"), value "2023" ] [ text "2023" ]
        , Select.item [ Attribute.selected (currentValue == "2024"), value "2024" ] [ text "2024" ]
        , Select.item [ Attribute.selected (currentValue == "2025"), value "2025" ] [ text "2025" ]
        , Select.item [ Attribute.selected (currentValue == "2026"), value "2026" ] [ text "2026" ]
        , Select.item [ Attribute.selected (currentValue == "2027"), value "2027" ] [ text "2027" ]
        , Select.item [ Attribute.selected (currentValue == "2028"), value "2028" ] [ text "2028" ]
        , Select.item [ Attribute.selected (currentValue == "2029"), value "2029" ] [ text "2029" ]
        , Select.item [ Attribute.selected (currentValue == "2030"), value "2030" ] [ text "2030" ]
        ]
