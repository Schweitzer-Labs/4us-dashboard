module LabelWithData exposing
    ( dataLabel
    , dataLongText
    , dataText
    , labelWithData
    , labelWithMaybeData
    , labelWithMaybeLongData
    , labelWithMaybeTimeData
    , labelWithTimeData
    )

import Html exposing (Attribute, Html, div, h4, h5, h6, span, text)
import Html.Attributes exposing (class)
import TimeZone exposing (america__new_york)
import Timestamp


dataLabelStyle : Attribute msg
dataLabelStyle =
    class "font-weight-bold font-size-medium"


dataLabel : String -> Html msg
dataLabel label =
    div [ dataLabelStyle ] [ text label ]


dataText : String -> Html msg
dataText data =
    div [ class "font-size-large" ] [ text data ]


dataLongText : String -> Html msg
dataLongText data =
    div [ class "font-size-medium" ] [ text data ]


labelWithMaybeData : String -> Maybe String -> Html msg
labelWithMaybeData label data =
    case data of
        Just a ->
            div []
                [ dataLabel label
                , dataText a
                ]

        Nothing ->
            div []
                [ dataLabel label
                , dataText "N/A"
                ]


labelWithMaybeLongData : String -> Maybe String -> Html msg
labelWithMaybeLongData label data =
    case data of
        Just a ->
            div []
                [ dataLabel label
                , dataLongText a
                ]

        Nothing ->
            div []
                [ dataLabel label
                , dataText "N/A"
                ]


labelWithData : String -> String -> Html msg
labelWithData label data =
    div []
        [ dataLabel label
        , dataText data
        ]


labelWithMaybeTimeData : String -> Maybe Int -> Html msg
labelWithMaybeTimeData label data =
    case data of
        Just a ->
            div []
                [ dataLabel label
                , dataText <| Timestamp.format (america__new_york ()) a
                ]

        Nothing ->
            div []
                [ dataLabel label
                , dataText "N/A"
                ]


labelWithTimeData : String -> Int -> Html msg
labelWithTimeData label data =
    div []
        [ dataLabel label
        , dataText <| Timestamp.format (america__new_york ()) data
        ]
