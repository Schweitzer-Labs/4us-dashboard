module AmountDate exposing (Config, row, view)

import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg
import Html exposing (Html)


type alias Config msg =
    { amount : DataMsg.MsgString msg
    , paymentDate : DataMsg.MsgString msg
    , disabled : Bool
    }


view : Config msg -> List (Html msg)
view { amount, paymentDate, disabled } =
    [ row amount paymentDate disabled ]


row :
    ( String, String -> msg )
    -> ( String, String -> msg )
    -> Bool
    -> Html msg
row ( amount, amountMsg ) ( paymentDate, paymentDateMsg ) disabled =
    Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "amount"
                , Input.onInput amountMsg
                , Input.value amount
                , Input.placeholder "Enter amount"
                , Input.disabled disabled
                ]
            ]
        , Grid.col
            []
            [ Input.date
                [ Input.id "date"
                , Input.onInput paymentDateMsg
                , Input.value paymentDate
                , Input.disabled disabled
                ]
            ]
        ]
