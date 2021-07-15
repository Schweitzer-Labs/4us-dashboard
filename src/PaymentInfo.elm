module PaymentInfo exposing (dataView, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Html exposing (Html, div, h4, h6, text)
import Html.Attributes exposing (class)
import LabelWithData exposing (labelWithContent, labelWithData, labelWithTimeData)
import PaymentMethod
import Transaction


view : Transaction.Model -> List (Html msg)
view txn =
    [ div
        [ class "fade-in" ]
        [ h6 [] [ text "Payment Info" ]
        , dataView txn
        ]
    ]


statusContent : Bool -> Html msg
statusContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green font-size-large" ]

    else
        Asset.minusCircleGlyph [ class "text-warning font-size-large" ]


verified : String -> Bool -> Html msg
verified label isVerified =
    labelWithContent label <| statusContent isVerified


dataView : Transaction.Model -> Html msg
dataView txn =
    Grid.container []
        [ Grid.row [ Row.attrs [ Spacing.mt4 ] ]
            [ Grid.col [] [ labelWithData "Amount" <| Cents.toDollar txn.amount ]
            , Grid.col [] [ labelWithTimeData "Date Initiated" <| txn.initiatedTimestamp ]
            , Grid.col [] [ labelWithData "Payment Type" <| PaymentMethod.toDisplayString txn.paymentMethod ]
            ]
        , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
            [ Grid.col [] [ verified "Rule Verified" txn.ruleVerified ]
            , Grid.col [] [ verified "Bank Verified" txn.bankVerified ]
            , Grid.col [] [ labelWithData "Rule Verified" "400" ]
            ]
        ]
