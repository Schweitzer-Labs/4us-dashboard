module Address exposing (Config, view)

import AppInput exposing (inputText)
import Bootstrap.Form as Form
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
    , cyId : String
    }


view : Config msg -> List (Html msg)
view { addressLine1, addressLine2, city, state, postalCode, disabled, id, cyId } =
    rows addressLine1 addressLine2 city state postalCode disabled id cyId


rows :
    ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> ( String, String -> msg )
    -> Bool
    -> String
    -> String
    -> List (Html msg)
rows ( addressLine1, address1Msg ) ( addressLine2, address2Msg ) ( city, cityMsg ) ( state, stateMsg ) ( postalCode, postalCodeMsg ) disabled id cyId =
    [ Form.form []
        [ Form.row [ Row.centerLg, Row.attrs [ Spacing.mt2, attribute "id" (id ++ "addressRow") ] ]
            [ Form.col [ Col.lg6 ]
                [ inputText
                    address1Msg
                    addressLine1
                    disabled
                    (cyId ++ "addressLine1")
                    "*Street Address"
                ]
            , Form.col [ Col.lg6 ]
                [ inputText
                    address2Msg
                    addressLine2
                    disabled
                    (cyId ++ "addressLine2")
                    "Secondary Address"
                ]
            ]
        , Form.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
            [ Form.col [ Col.lg6 ]
                [ inputText
                    cityMsg
                    city
                    disabled
                    (cyId ++ "city")
                    "*City"
                ]
            , Form.col [ Col.lg3 ]
                [ State.view stateMsg state disabled id cyId ]
            , Form.col [ Col.lg3 ]
                [ inputText
                    postalCodeMsg
                    postalCode
                    disabled
                    (cyId ++ "postalCode")
                    "*Postal Code"
                ]
            ]
        ]
    ]
