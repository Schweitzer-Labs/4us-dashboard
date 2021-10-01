module Address exposing (Config, view)

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
            [ Input.text
                [ Input.id <| id ++ "addressLine1"
                , Input.value addressLine1
                , Input.onInput address1Msg
                , Input.placeholder "Street Address"
                , Input.disabled disabled
                , Input.attrs [ attribute "data-cy" (id ++ "addressLine1") ]
                ]
            ]
        , Grid.col [ Col.lg6 ]
            [ Input.text
                [ Input.id <| id ++ "addressLine2"
                , Input.value addressLine2
                , Input.onInput address2Msg
                , Input.placeholder "Secondary Address"
                , Input.disabled disabled
                , Input.attrs [ attribute "data-cy" (id ++ "addressLine2") ]
                ]
            ]
        ]
    , Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.lg6 ]
            [ Input.text
                [ Input.id <| id ++ "city"
                , Input.value city
                , Input.onInput cityMsg
                , Input.placeholder "City"
                , Input.disabled disabled
                , Input.attrs [ attribute "data-cy" (id ++ "city") ]
                ]
            ]
        , Grid.col [ Col.lg3 ]
            [ State.view stateMsg state disabled id ]
        , Grid.col [ Col.lg3 ]
            [ Input.text
                [ Input.id <| id ++ "postalCode"
                , Input.value postalCode
                , Input.onInput postalCodeMsg
                , Input.placeholder "Postal Code"
                , Input.disabled disabled
                , Input.attrs [ attribute "data-cy" (id ++ "postalCode") ]
                ]
            ]
        ]
    ]
