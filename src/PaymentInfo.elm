module PaymentInfo exposing (dataView, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Html exposing (Html, div, h4, h6, span, text)
import Html.Attributes exposing (class)
import LabelWithData exposing (dataLabel, labelWithContent, labelWithData, labelWithTimeData)
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
            , Grid.col [] [ labelWithScore (toInt txn.donorVerificationScore) "Verification Score" <| toDisplayScore txn.donorVerificationScore ]
            ]
        ]


toDisplayScore : Maybe Int -> String
toDisplayScore =
    Maybe.withDefault "N/A" << Maybe.map String.fromInt


toInt : Maybe Int -> Int
toInt score =
    Maybe.withDefault 0 score


labelWithScore : Int -> String -> String -> Html msg
labelWithScore score label data =
    div []
        [ dataLabel label
        , scoreText data score
        ]


scoreText : String -> Int -> Html msg
scoreText data score =
    let
        style =
            if score /= 0 then
                "font-size-large"

            else
                "text-danger font-size-large"
    in
    div [ class style ] [ text data ]



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
