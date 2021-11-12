module MonthSelector exposing (view)

import Bootstrap.Form as Form
import Bootstrap.Form.Select as Select
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (value)


view : (String -> msg) -> String -> Html msg
view updateMsg currentValue =
    Form.group []
        [ Select.select
            [ Select.id "card-month"
            , Select.onChange updateMsg
            ]
            [ Select.item [ Attribute.selected (currentValue == ""), value "" ] [ text "Select month" ]
            , Select.item [ Attribute.selected (currentValue == "1"), value "1" ] [ text "1 - Jan" ]
            , Select.item [ Attribute.selected (currentValue == "2"), value "2" ] [ text "2 - Feb" ]
            , Select.item [ Attribute.selected (currentValue == "3"), value "3" ] [ text "3 - Mar" ]
            , Select.item [ Attribute.selected (currentValue == "4"), value "4" ] [ text "4 - Apr" ]
            , Select.item [ Attribute.selected (currentValue == "5"), value "5" ] [ text "5 - May" ]
            , Select.item [ Attribute.selected (currentValue == "6"), value "6" ] [ text "6 - Jun" ]
            , Select.item [ Attribute.selected (currentValue == "7"), value "7" ] [ text "7 - Jul" ]
            , Select.item [ Attribute.selected (currentValue == "8"), value "8" ] [ text "8 - Aug" ]
            , Select.item [ Attribute.selected (currentValue == "9"), value "9" ] [ text "9 - Sept" ]
            , Select.item [ Attribute.selected (currentValue == "10"), value "10" ] [ text "10 - Oct" ]
            , Select.item [ Attribute.selected (currentValue == "11"), value "11" ] [ text "11 - Nov" ]
            , Select.item [ Attribute.selected (currentValue == "12"), value "12" ] [ text "12 - Dec" ]
            ]
        ]
