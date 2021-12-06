module Transactions exposing
    ( Model
    , decoder
    , getAmount
    , getContext
    , getEntityName
    , getFee
    , getStatus
    , labels
    , missingContent
    , statusContent
    , toPaymentMethodOrProcessor
    , transactionRowMap
    , uppercaseText
    , verifiedContent
    , view
    , viewInteractive
    )

import Asset
import Bank
import Cents
import Committee
import DataTable exposing (DataRow)
import Direction
import EntityType
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import List exposing (sortBy)
import PaymentMethod
import PaymentSource
import PurposeCode
import Time exposing (utc)
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction


type alias Model =
    List Transaction.Model


decoder : Decode.Decoder Model
decoder =
    Decode.list Transaction.decoder


labels : List String
labels =
    [ "Date"
    , "Name"
    , "Type"
    , "Amount"
    , "Verified"
    , "Source"
    , "Ref"
    , "Bank Status"
    ]


view : Committee.Model -> List Transaction.Model -> Html msg
view committee txns =
    DataTable.view "Awaiting Transactions." labels (transactionRowMap committee) <|
        List.map (\d -> ( Nothing, Nothing, d )) <|
            List.reverse (sortBy .paymentDate txns)


viewInteractive : Committee.Model -> (Transaction.Model -> msg) -> List Transaction.Model -> Html msg
viewInteractive committee selectMsg txns =
    DataTable.view "Awaiting Transactions." labels (transactionRowMap committee) <|
        List.map (\t -> ( Nothing, Just <| selectMsg t, t )) <|
            List.reverse (sortBy .paymentDate txns)


processor : Committee.Model -> Transaction.Model -> Html msg
processor committee model =
    case model.paymentMethod of
        PaymentMethod.Credit ->
            if model.stripePaymentIntentId /= Nothing then
                img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

            else
                Bank.stringToLogo committee.bankName

        PaymentMethod.Debit ->
            Bank.stringToLogo committee.bankName

        PaymentMethod.Ach ->
            Bank.stringToLogo committee.bankName

        PaymentMethod.Check ->
            Bank.stringToLogo committee.bankName

        _ ->
            text "N/A"


getEntityName : Transaction.Model -> Maybe String
getEntityName transaction =
    let
        personName =
            Maybe.map2 (\a b -> a ++ " " ++ b) transaction.firstName transaction.lastName
    in
    case ( transaction.direction, transaction.entityType ) of
        ( Direction.Out, _ ) ->
            transaction.entityName

        ( Direction.In, Just EntityType.Individual ) ->
            personName

        ( Direction.In, Just EntityType.Family ) ->
            personName

        ( Direction.In, Just EntityType.Candidate ) ->
            personName

        _ ->
            transaction.entityName


getEntityType : Transaction.Model -> Html msg
getEntityType transaction =
    let
        missingText =
            if transaction.direction == Direction.Out then
                text <| PurposeCode.toText transaction.purposeCode

            else
                missingContent
    in
    Maybe.withDefault missingText <|
        Maybe.map (text << EntityType.toGridString) transaction.entityType


missingContent : Html msg
missingContent =
    span [ class "text-danger" ] [ text "Missing" ]


getContext : Transaction.Model -> Html msg
getContext transaction =
    case transaction.direction of
        Direction.Out ->
            Maybe.withDefault
                missingContent
                (Maybe.map (text << PurposeCode.toString) transaction.purposeCode)

        Direction.In ->
            Maybe.withDefault
                missingContent
                (Maybe.map (text << EntityType.toDisplayString) transaction.entityType)


getPaymentMethod : Transaction.Model -> String
getPaymentMethod txn =
    case ( txn.paymentMethod, txn.stripePaymentIntentId ) of
        --( _, Just a ) ->
        --    "Online Processor"
        _ ->
            PaymentMethod.toDisplayString txn.paymentMethod


getAmount : Transaction.Model -> Html msg
getAmount transaction =
    case transaction.direction of
        Direction.Out ->
            span [ class "text-danger" ] [ text <| "(" ++ Cents.toDollar transaction.amount ++ ")" ]

        _ ->
            span [ class "text-green" ] [ text <| Cents.toDollar transaction.amount ]


getFee : Transaction.Model -> Html msg
getFee transaction =
    case transaction.processorFeeData of
        Nothing ->
            span [] [ text <| "N/A" ]

        Just feeData ->
            let
                fee =
                    feeData.amount
            in
            span [ class "text-danger" ] [ text <| "(" ++ Cents.toDollar fee ++ ")" ]


uppercaseText : String -> Html msg
uppercaseText str =
    span [ class "text-capitalize" ] [ text str ]


transactionRowMap : Committee.Model -> ( Maybe a, Maybe msg, Transaction.Model ) -> ( Maybe msg, DataRow msg )
transactionRowMap committee ( _, maybeMsg, transaction ) =
    let
        name =
            Maybe.withDefault missingContent (Maybe.map uppercaseText <| getEntityName transaction)

        context =
            getContext transaction

        amount =
            getAmount transaction

        entityType =
            getEntityType transaction
    in
    ( maybeMsg
    , [ ( "Date / Time", text <| Timestamp.format (america__new_york ()) transaction.paymentDate )
      , ( "Entity Name", name )
      , ( "Context", entityType )
      , ( "Amount", amount )
      , ( "Verified", verifiedContent <| transaction.ruleVerified )
      , ( "Payment Source", toPaymentMethodOrProcessor transaction )
      , ( "Ref Code", text <| Maybe.withDefault "N/A" transaction.refCode )
      , ( "Status", getStatus transaction )
      ]
    )


toPaymentMethodOrProcessor : Transaction.Model -> Html msg
toPaymentMethodOrProcessor txn =
    let
        source =
            txn.source
    in
    case source of
        PaymentSource.ActBlue ->
            img [ Asset.src Asset.actBlueLogo, class "stripe-logo" ] []

        PaymentSource.Stripe ->
            img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

        PaymentSource.WinRed ->
            img [ Asset.src Asset.winRedLogo, class "stripe-logo" ] []

        _ ->
            text <| getPaymentMethod txn


getStatus : Transaction.Model -> Html msg
getStatus model =
    statusContent model.bankVerified


statusContent : Bool -> Html msg
statusContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

    else
        Asset.circleCheckGlyph [ class "text-warning data-icon-size" ]


verifiedContent : Bool -> Html msg
verifiedContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

    else
        Asset.circleCheckGlyph [ class "text-warning data-icon-size" ]
