module BankData exposing (Model, formLabelRow, view)

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div, h5, h6, text)
import LabelWithData exposing (labelWithData, labelWithMaybeData, labelWithMaybeLongData, labelWithMaybeTimeData, labelWithTimeData)
import PaymentMethod exposing (PaymentMethod)
import Transaction



--- Model ---


type alias Model =
    Transaction.Model


formLabelRow : Bool -> String -> List (Html msg)
formLabelRow showHeading str =
    case showHeading of
        True ->
            [ Grid.row []
                [ Grid.col [ Col.md4 ] [ h6 [] [ text str ] ] ]
            ]

        False ->
            []


bankDataRows : Model -> List (Html msg)
bankDataRows data =
    [ Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithMaybeData "Analyzed Payee Name" data.finicityNormalizedPayeeName ]
        , Grid.col [] [ labelWithMaybeData "Analyzed Category" data.finicityCategory ]
        ]
    , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithMaybeLongData "Description" data.finicityDescription ] ]
    , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithTimeData "Posted Date" <| data.initiatedTimestamp ]
        , Grid.col [] [ labelWithData "Payment Type" <| PaymentMethod.toDisplayString data.paymentMethod ]
        ]
    , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithMaybeTimeData "Initiated Date" data.finicityTransactionDate ]
        ]
    ]


view : Model -> Html msg
view model =
    div
        []
        [ h6 [] [ text "Payment Info" ]
        , Grid.containerFluid
            []
            (bankDataRows model)
        ]
