module LabelWithData exposing (labelWithData)

import Html exposing (Html, div, h4, text)
import Html.Attributes exposing (class)


dataLabel : String -> Html msg
dataLabel label =
    h4 [ class "data-label" ] [ text label ]


dataText : String -> Html msg
dataText data =
    h4 [ class "data-text" ] [ text data ]


labelWithData : ( String, String ) -> Html msg
labelWithData ( label, data ) =
    div []
        [ dataLabel label
        , dataText data
        ]
