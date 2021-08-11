module State exposing (view, withAbbrKeys, withStateKeys)

import Bootstrap.Form.Select as Select
import Dict
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)
import String exposing (toUpper)
import String.Extra exposing (toTitleCase)


statesAndAbbrsList : List ( String, String )
statesAndAbbrsList =
    [ ( "AL", "Alabama" )
    , ( "AK", "Alaska" )
    , ( "AS", "American Samoa" )
    , ( "AZ", "Arizona" )
    , ( "AR", "Arkansas" )
    , ( "CA", "California" )
    , ( "CO", "Colorado" )
    , ( "CT", "Connecticut" )
    , ( "DE", "Delaware" )
    , ( "DC", "District of Columbia" )
    , ( "FL", "Florida" )
    , ( "GA", "Georgia" )
    , ( "GU", "Guam" )
    , ( "HI", "Hawaii" )
    , ( "ID", "Idaho" )
    , ( "IL", "Illinois" )
    , ( "IN", "Indiana" )
    , ( "IA", "Iowa" )
    , ( "KS", "Kansas" )
    , ( "KY", "Kentucky" )
    , ( "LA", "Louisiana" )
    , ( "ME", "Maine" )
    , ( "MD", "Maryland" )
    , ( "MA", "Massachusetts" )
    , ( "MI", "Michigan" )
    , ( "MN", "Minnesota" )
    , ( "MS", "Mississippi" )
    , ( "MO", "Missouri" )
    , ( "MT", "Montana" )
    , ( "NE", "Nebraska" )
    , ( "NV", "Nevada" )
    , ( "NH", "New Hampshire" )
    , ( "NJ", "New Jersey" )
    , ( "NM", "New Mexico" )
    , ( "NY", "New York" )
    , ( "NC", "North Carolina" )
    , ( "ND", "North Dakota" )
    , ( "MP", "Northern Mariana Islands" )
    , ( "OH", "Ohio" )
    , ( "OK", "Oklahoma" )
    , ( "OR", "Oregon" )
    , ( "PA", "Pennsylvania" )
    , ( "PR", "Puerto Rico" )
    , ( "RI", "Rhode Island" )
    , ( "SC", "South Carolina" )
    , ( "SD", "South Dakota" )
    , ( "TN", "Tennessee" )
    , ( "TX", "Texas" )
    , ( "UT", "Utah" )
    , ( "VT", "Vermont" )
    , ( "VI", "Virgin Islands" )
    , ( "VA", "Virginia" )
    , ( "WA", "Washington" )
    , ( "WV", "West Virginia" )
    , ( "WI", "Wisconsin" )
    , ( "WY", "Wyoming" )
    ]


withAbbrKeys : Dict.Dict String String
withAbbrKeys =
    Dict.fromList statesAndAbbrsList


withStateKeys : Dict.Dict String String
withStateKeys =
    Dict.fromList <| List.map (\( a, b ) -> ( b, a )) statesAndAbbrsList


view : (String -> msg) -> String -> Bool -> Html msg
view msg currentValue isDisabled =
    Select.select
        [ Select.id "State", Select.onChange msg, Select.disabled isDisabled ]
    <|
        [ Select.item [ value "" ] [ text "-- State --" ] ]
            ++ List.map
                (\( abbr, whole ) ->
                    Select.item [ value abbr, selected (currentValue == abbr || toUpper currentValue == abbr) ] [ text whole ]
                )
                statesAndAbbrsList
