module Address exposing (Config, view)

import AppInput exposing (inputText)
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg
import Html exposing (Html)
import Html.Attributes exposing (attribute)
import State


type alias Config msg =
    { addressLine1 : DataMsg.MsgString msg
    , addressLine2 : DataMsg.MsgString msg
    , city : DataMsg.MsgString msg
    , state : DataMsg.MsgString msg
    , postalCode : DataMsg.MsgString msg
    , disabled : Bool
    , id : String
    }


view : Config msg -> List (Html msg)
view { addressLine1, addressLine2, city, state, postalCode, disabled, id } =
    rows addressLine1 addressLine2 city state postalCode disabled id


rows :
    ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> Bool
    -> String
    -> List (Html msg)
rows ( addressLine1, address1Msg ) ( addressLine2, address2Msg ) ( city, cityMsg ) ( state, stateMsg ) ( postalCode, postalCodeMsg ) disabled id =
    [ Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.lg6 ]
            [ inputText
                address1Msg
                addressLine1
                disabled
                (id ++ "addressLine1")
                "Street Address"
            ]
        , Grid.col [ Col.lg6 ]
            [ inputText
                address2Msg
                addressLine2
                disabled
                (id ++ "addressLine2")
                "Secondary Address"
            ]
        ]
    , Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.lg6 ]
            [ inputText
                cityMsg
                city
                disabled
                (id ++ "city")
                "City"
            ]
        , Grid.col [ Col.lg3 ]
            [ State.view stateMsg state disabled id ]
        , Grid.col [ Col.lg3 ]
            [ inputText
                postalCodeMsg
                postalCode
                disabled
                (id ++ "postalCode")
                "Postal Code"
            ]
        ]
    ]
