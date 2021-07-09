module LabelWithData exposing (dataLabel, dataText, labelWithData, labelWithDescriptionData)

import Html exposing (Attribute, Html, div, h4, h5, h6, text)
import Html.Attributes exposing (class)


dataLabelStyle : Attribute msg
dataLabelStyle =
    class "font-weight-bold font-size-medium"


dataLabel : String -> Html msg
dataLabel label =
    h6 [ dataLabelStyle ] [ text label ]


dataText : String -> Html msg
dataText data =
    h4 [ class "font-size-large" ] [ text data ]


labelWithDescriptionData : String -> String -> Html msg
labelWithDescriptionData label data =
    div []
        [ dataLabel label
        , h6 [] [ text data ]
        ]


labelWithData : String -> String -> Html msg
labelWithData label data =
    div []
        [ dataLabel label
        , dataText data
        ]
