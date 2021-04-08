module State exposing (view, withAbbrKeys, withStateKeys)

import Bootstrap.Form.Select as Select
import Dict
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)
import String.Extra exposing (toTitleCase)


statesAndAbbrsList : List ( String, String )
statesAndAbbrsList =
    [ ( "al", "Alabama" )
    , ( "ak", "Alaska" )
    , ( "az", "Arizona" )
    , ( "ar", "Arkansas" )
    , ( "ca", "California" )
    , ( "co", "Colorado" )
    , ( "ct", "Connecticut" )
    , ( "de", "Delaware" )
    , ( "dc", "District of Columbia" )
    , ( "fl", "Florida" )
    , ( "ga", "Georgia" )
    , ( "hi", "Hawaii" )
    , ( "id", "Idaho" )
    , ( "il", "Illinois" )
    , ( "in", "Indiana" )
    , ( "ia", "Iowa" )
    , ( "ks", "Kansas" )
    , ( "ky", "Kentucky" )
    , ( "la", "Louisiana" )
    , ( "me", "Maine" )
    , ( "md", "Maryland" )
    , ( "ma", "Massachusetts" )
    , ( "mi", "Michigan" )
    , ( "mn", "Minnesota" )
    , ( "ms", "Mississippi" )
    , ( "mo", "Missouri" )
    , ( "mt", "Montana" )
    , ( "ne", "Nebraska" )
    , ( "nv", "Nevada" )
    , ( "nh", "New Hampshire" )
    , ( "nj", "New Jersey" )
    , ( "nm", "New Mexico" )
    , ( "ny", "New York" )
    , ( "nc", "North Carolina" )
    , ( "nd", "North Dakota" )
    , ( "oh", "Ohio" )
    , ( "ok", "Oklahoma" )
    , ( "or", "Oregon" )
    , ( "pa", "Pennsylvania" )
    , ( "ri", "Rhode Island" )
    , ( "sc", "South Carolina" )
    , ( "sd", "South Dakota" )
    , ( "tn", "Tennessee" )
    , ( "tx", "Texas" )
    , ( "ut", "Utah" )
    , ( "vt", "Vermont" )
    , ( "va", "Virginia" )
    , ( "wa", "Washington" )
    , ( "wv", "West Virginia" )
    , ( "wi", "Wisconsin" )
    , ( "wy", "Wyoming" )
    ]


withAbbrKeys : Dict.Dict String String
withAbbrKeys =
    Dict.fromList statesAndAbbrsList


withStateKeys : Dict.Dict String String
withStateKeys =
    Dict.fromList <| List.map (\( a, b ) -> ( b, a )) statesAndAbbrsList


view : (String -> msg) -> String -> Html msg
view msg currentValue =
    Select.select
        [ Select.id "State", Select.onChange msg ]
    <|
        [ Select.item [ value "" ] [ text "-- State --" ] ]
            ++ List.map
                (\( abbr, whole ) ->
                    Select.item [ value abbr, selected (currentValue == abbr) ] [ text whole ]
                )
                statesAndAbbrsList
