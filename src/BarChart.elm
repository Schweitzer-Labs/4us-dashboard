module BarChart exposing (main)

import Axis
import Color exposing (rgb255)
import DateFormat
import Scale exposing (BandConfig, BandScale, ContinuousScale, defaultBandConfig)
import Time exposing (millisToPosix)
import TypedSvg exposing (g, rect, style, svg, text_)
import TypedSvg.Attributes exposing (class, fill, textAnchor, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (height, width, x, y)
import TypedSvg.Core exposing (Svg, text)
import TypedSvg.Types exposing (AnchorAlignment(..), Paint(..), Transform(..))


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    30


xScale : List ( Time.Posix, Float ) -> BandScale Time.Posix
xScale model =
    List.map Tuple.first model
        |> Scale.band { defaultBandConfig | paddingInner = 0.1, paddingOuter = 0.2 } ( 0, w - 2 * padding )


yScale : ContinuousScale Float
yScale =
    Scale.linear ( h - 2 * padding, 0 ) ( 0, 100 )


dateFormat : Time.Posix -> String
dateFormat =
    DateFormat.format [ DateFormat.dayOfMonthFixed, DateFormat.text " ", DateFormat.monthNameAbbreviated ] Time.utc


xAxis : List ( Time.Posix, Float ) -> Svg msg
xAxis model =
    Axis.bottom [] (Scale.toRenderable dateFormat (xScale model))


yAxis : Svg msg
yAxis =
    Axis.left [ Axis.tickCount 5 ] yScale


column : BandScale Time.Posix -> ( Time.Posix, Float ) -> Svg msg
column scale ( date, value ) =
    g [ class [ "column" ] ]
        [ rect
            [ x <| Scale.convert scale date
            , y <| Scale.convert yScale value
            , width <| Scale.bandwidth scale
            , height <| h - Scale.convert yScale value - 2 * padding
            , fill (Paint <| rgb255 80 83 208)
            ]
            []
        , text_
            [ x <| Scale.convert (Scale.toRenderable dateFormat scale) date
            , y <| Scale.convert yScale value - 100
            , textAnchor AnchorMiddle
            ]
            [ text <| String.fromFloat value ]
        ]


view : List ( Time.Posix, Float ) -> Svg msg
view model =
    svg [ viewBox 0 0 w h ]
        [ style [] [ text """
            .column rect { fill: rgba(80, 83, 208, 0.8); }
            .column text { display: none; }
            .column:hover rect { fill: rgba(60, 63, 180, 0.8); }
            .column:hover text { display: inline; }
          """ ]
        , g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis model ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ] <|
            List.map (column (xScale model)) model
        ]


timeSeries : List ( Time.Posix, Float )
timeSeries =
    [ ( millisToPosix (2629800000 * 3), 33 )
    , ( millisToPosix (2629800000 * 4), 60 )
    , ( millisToPosix (2629800000 * 5), 80 )
    , ( millisToPosix (2629800000 * 6), 70 )
    , ( millisToPosix (2629800000 * 7), 30 )
    , ( millisToPosix (2629800000 * 8), 50 )
    , ( millisToPosix (2629800000 * 9), 19 )
    , ( millisToPosix (2629800000 * 10), 23 )
    , ( millisToPosix (2629800000 * 11), 40 )
    , ( millisToPosix (2629800000 * 12), 33 )
    , ( millisToPosix (2629800000 * 13), 29 )
    , ( millisToPosix (2629800000 * 14), 28 )
    ]


main =
    view timeSeries
