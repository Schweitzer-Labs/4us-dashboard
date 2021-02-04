module Transactions exposing (Label(..), Model, decoder, labels, statusContent, stringToBool, transactionRowMap, verifiedContent, view)

import Asset
import DataTable exposing (DataRow)
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import PaymentMethod
import Transaction exposing (Model(..))


type alias Model =
    List Transaction.Model


decoder : Decode.Decoder Model
decoder =
    Decode.list Transaction.decoder


type Label
    = DateTime
    | EntityName
    | Amount
    | Rule
    | PaymentMethod
    | Status
    | Verified


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg DateTime, "Date / Time" )
    , ( sortMsg EntityName, "Entity Name" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg Rule, "Rule" )
    , ( sortMsg Verified, "Verified" )
    , ( sortMsg PaymentMethod, "Payment Method" )
    , ( sortMsg PaymentMethod, "Processor" )
    , ( sortMsg Status, "Status" )
    ]


view : (Label -> msg) -> List (Html msg) -> List Transaction.Model -> Html msg
view sortMsg content disbursements =
    DataTable.view "Awaiting Transactions." content (labels sortMsg) transactionRowMap <|
        List.map (\d -> ( Nothing, d )) disbursements


processor : String -> Html msg
processor method =
    if method == "credit" then
        img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

    else
        img [ Asset.src Asset.tbdBankLogo, class "tbd-logo" ] []


transactionRowMap : ( Maybe msg, Transaction.Model ) -> ( Maybe msg, DataRow msg )
transactionRowMap ( maybeMsg, transaction ) =
    case transaction of
        Contribution contribution ->
            ( maybeMsg
            , [ ( "Date / Time", text contribution.datetime )
              , ( "Entity Name", text <| contribution.firstName ++ " " ++ contribution.lastName )
              , ( "Amount", span [ class "text-success font-weight-bold" ] [ text <| "$" ++ contribution.amount ] )
              , ( "Rule", text "MA11" )
              , ( "Verified", verifiedContent True )
              , ( "Payment Method", text <| PaymentMethod.toDisplayString contribution.paymentMethod )
              , ( "Processor", processor contribution.paymentMethod )
              , ( "Status", statusContent <| stringToBool contribution.verified )
              ]
            )

        Disbursement disbursement ->
            ( maybeMsg
            , [ ( "Date / Time", text disbursement.date )
              , ( "Entity Name", text disbursement.entityName )
              , ( "Amount", span [ class "text-danger font-weight-bold" ] [ text <| "($" ++ disbursement.amount ++ ")" ] )
              , ( "Rule", text "MAD" )
              , ( "Verified", verifiedContent <| disbursement.ruleVerified )
              , ( "Payment Method"
                , span
                    [ class "text-capitalize" ]
                    [ text disbursement.paymentMethod ]
                )
              , ( "Processor", processor disbursement.paymentMethod )
              , ( "Status", statusContent <| disbursement.bankVerified )
              ]
            )


statusContent : Bool -> Html msg
statusContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

    else
        Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]


verifiedContent : Bool -> Html msg
verifiedContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

    else
        Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]


stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" ->
            True

        _ ->
            False
