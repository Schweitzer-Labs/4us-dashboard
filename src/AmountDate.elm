module AmountDate exposing (Config, row, view)

import AppInput exposing (inputDate, inputText)
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
    , label : String
    }


view : Config msg -> List (Html msg)
view { amount, paymentDate, disabled, label } =
    [ row amount paymentDate disabled label ]


row :
    ( String, String -> msg )
    -> ( String, String -> msg )
    -> Bool
    -> String
    -> Html msg
row ( amount, amountMsg ) ( paymentDate, paymentDateMsg ) disabled label =
    Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText
                amountMsg
                amount
                disabled
                "paymentAmount"
                "Payment Amount"
            ]
        , Grid.col
            []
            [ inputDate paymentDateMsg paymentDate disabled "paymentDate" label
            ]
        ]
