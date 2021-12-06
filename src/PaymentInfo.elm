module PaymentInfo exposing (dataView, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Direction
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
        Asset.circleCheckGlyph [ class "text-warning font-size-large" ]


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
        , verificationRow txn
        ]


donorScoreToString : Maybe Int -> String
donorScoreToString score =
    case score of
        Nothing ->
            "N/A"

        Just a ->
            String.fromInt a


labelWithDonorScore : Maybe Int -> String -> Html msg
labelWithDonorScore score label =
    div []
        [ dataLabel label
        , scoreText <| donorScoreToString score
        ]


businessScoreToString : Maybe String -> String
businessScoreToString score =
    case score of
        Nothing ->
            "N/A"

        Just a ->
            a


labelWithBusinessScore : Maybe String -> String -> Html msg
labelWithBusinessScore score label =
    div []
        [ dataLabel label
        , scoreText <| businessScoreToString score
        ]


scoreText : String -> Html msg
scoreText score =
    let
        style =
            if score /= "0" then
                "font-size-large"

            else
                "text-danger font-size-large"
    in
    div [ class style ] [ text score ]


verificationRow : Transaction.Model -> Html msg
verificationRow txn =
    let
        label =
            "Verification Score"

        labelWithScore =
            case txn.direction of
                Direction.In ->
                    labelWithDonorScore txn.donorVerificationScore label

                Direction.Out ->
                    labelWithBusinessScore txn.businessIdVerificationScore label
    in
    Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ verified "Rule Verified" txn.ruleVerified ]
        , Grid.col [] [ verified "Bank Verified" txn.bankVerified ]
        , Grid.col [] [ labelWithScore ]
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
