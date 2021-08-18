module PaymentInfo exposing (dataView, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover exposing (State)
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Html exposing (Html, div, h4, h6, span, text)
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
            , Grid.col [] [ Grid.row [] [ Grid.col [] [ labelWithTimeData "Date Initiated" <| txn.paymentDate ] ] ]
            , Grid.col [] [ labelWithData "Payment Type" <| PaymentMethod.toDisplayString txn.paymentMethod ]
            ]
        , Grid.row [ Row.attrs [ Spacing.mt4 ] ]
            [ Grid.col [] [ verified "Rule Verified" txn.ruleVerified ]
            , Grid.col [] [ verified "Bank Verified" txn.bankVerified ]
            , Grid.col [] [ labelWithData "Verification Score" "20" ]
            ]
        ]



--infoPopover : State -> (State -> msg) -> Html msg
--infoPopover popoverState msg =
--    Popover.config
--        (span
--            ([ class "hover-underline hover-pointer align-middle", Spacing.ml3 ]
--                ++ Popover.onClick popoverState msg
--            )
--            [ Asset.infoCircleGlyph [] ]
--        )
--        |> Popover.top
--        |> Popover.content []
--            [ text verificationScore ]
--        |> Popover.view popoverState
