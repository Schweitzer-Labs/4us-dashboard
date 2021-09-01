module LabelWithData exposing
    ( dataLabel
    , dataLongText
    , dataText
    , labelWithContent
    , labelWithData
    , labelWithMaybeData
    , labelWithMaybeLongData
    , labelWithMaybeTimeData
    , labelWithTimeData
    )

import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class)
import Time exposing (utc)
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
    div [ Spacing.mt1, class "font-size-medium" ] [ text data ]


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


labelWithContent : String -> Html msg -> Html msg
labelWithContent label content =
    div []
        [ dataLabel label
        , div [ Spacing.mt2 ] [ content ]
        ]


labelWithMaybeTimeData : String -> Maybe Int -> Html msg
labelWithMaybeTimeData label data =
    case data of
        Just a ->
            div []
                [ dataLabel label
                , dataText <| Timestamp.format utc a
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
        , dataText <| Timestamp.format utc data
        ]
