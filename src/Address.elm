module Address exposing (row)

import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div)


row :
    ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> List (Html msg)
row ( address1, address1Msg ) ( address2, address2Msg ) ( city, cityMsg ) ( state, stateMsg ) ( postalCode, postalCodeMsg ) =
    [ Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.lg6 ]
            [ Input.text
                [ Input.value address1
                , Input.onInput address1Msg
                , Input.placeholder "Street Address"
                ]
            ]
        , Grid.col [ Col.lg6 ]
            [ Input.text
                [ Input.value address2
                , Input.onInput address2Msg
                , Input.placeholder "Secondary Address"
                ]
            ]
        ]
    , Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.lg6 ]
            [ Input.text
                [ Input.value city
                , Input.onInput cityMsg
                , Input.placeholder "City"
                ]
            ]
        , Grid.col [ Col.lg3 ]
            [ Input.text
                [ Input.value state
                , Input.onInput stateMsg
                , Input.placeholder "State"
                ]
            ]
        , Grid.col [ Col.lg3 ]
            [ Input.text
                [ Input.value postalCode
                , Input.onInput postalCodeMsg
                , Input.placeholder "Postal Code"
                ]
            ]
        ]
    ]
