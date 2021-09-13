module BankData exposing (formLabelRow, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div, h5, h6, text)
import Html.Attributes exposing (class)
import LabelWithData exposing (labelWithData, labelWithMaybeData, labelWithMaybeLongData, labelWithMaybeTimeData, labelWithTimeData)
import PaymentMethod
import Transaction


formLabelRow : Bool -> String -> List (Html msg)
formLabelRow showHeading str =
    case showHeading of
        True ->
            [ Grid.row []
                [ Grid.col [ Col.md4 ] [ h6 [] [ text str ] ] ]
            ]

        False ->
            []


bankDataRows : Transaction.Model -> List (Html msg)
bankDataRows data =
    [ Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithMaybeData "Analyzed Payee Name" data.finicityNormalizedPayeeName ]
        , Grid.col [] [ labelWithMaybeData "Analyzed Category" data.finicityCategory ]
        ]
    , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ labelWithMaybeLongData "Description" data.finicityDescription ]

        --, Grid.col [] [ labelWithData "Payment Type" <| Maybe.withDefault "N/A" <| Maybe.map PaymentMethod.toDisplayString data.finicityPaymentMethod ]
        ]
    , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ Maybe.withDefault (text "N/A") <| Maybe.map (labelWithTimeData "Posted Date") data.finicityPostedDate ]
        , Grid.col [] [ labelWithMaybeTimeData "Transaction Date" data.finicityTransactionDate ]
        ]
    ]


view : Bool -> Transaction.Model -> Html msg
view isShowing model =
    let
        heading =
            if isShowing then
                [ div [ class "text-size-medium" ] [ text "Bank Data" ] ]

            else
                []
    in
    div
        []
    <|
        heading
            ++ bankDataRows model
