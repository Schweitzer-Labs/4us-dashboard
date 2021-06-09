module Transactions exposing (Label(..), Model, decoder, labels, statusContent, stringToBool, transactionRowMap, verifiedContent, view)

import Asset
import Cents
import DataTable exposing (DataRow)
import Direction
import EntityType exposing (EntityType(..))
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import List exposing (sortBy)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction


type alias Model =
    List Transaction.Model


decoder : Decode.Decoder Model
decoder =
    Decode.list Transaction.decoder


type Label
    = DateTime
    | EntityName
    | Amount
    | Context
    | Rule
    | PaymentMethod
    | Status
    | Verified


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg DateTime, "Date / Time" )
    , ( sortMsg EntityName, "Entity Name" )
    , ( sortMsg Context, "Entity Type" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg Verified, "Verified" )
    , ( sortMsg PaymentMethod, "Payment Method" )
    , ( sortMsg PaymentMethod, "Processor" )
    , ( sortMsg Status, "Status" )
    ]


view : (Label -> msg) -> List (Html msg) -> List Transaction.Model -> Html msg
view sortMsg content txns =
    DataTable.view "Awaiting Transactions." content (labels sortMsg) transactionRowMap <|
        List.map (\d -> ( Nothing, d )) <|
            List.reverse (sortBy .initiatedTimestamp txns)


processor : PaymentMethod -> Html msg
processor method =
    case method of
        PaymentMethod.Credit ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

        PaymentMethod.Debit ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

        PaymentMethod.Ach ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

        PaymentMethod.Check ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

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

        _ ->
            transaction.entityName


getEntityType : Transaction.Model -> Html msg
getEntityType transaction =
    let
        missingText =
            if transaction.direction == Direction.Out then
                text "N/A"

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

        _ ->
            text <| Maybe.withDefault "Home" transaction.refCode


getAmount : Transaction.Model -> Html msg
getAmount transaction =
    case transaction.direction of
        Direction.Out ->
            span [ class "text-danger" ] [ text <| "(" ++ Cents.toDollar transaction.amount ++ ")" ]

        _ ->
            span [ class "text-green" ] [ text <| Cents.toDollar transaction.amount ]


uppercaseText : String -> Html msg
uppercaseText str =
    span [ class "text-capitalize" ] [ text str ]


transactionRowMap : ( Maybe msg, Transaction.Model ) -> ( Maybe msg, DataRow msg )
transactionRowMap ( maybeMsg, transaction ) =
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
    , [ ( "Date / Time", text <| Timestamp.format (america__new_york ()) transaction.initiatedTimestamp )
      , ( "Entity Name", name )
      , ( "Context", entityType )
      , ( "Amount", amount )
      , ( "Verified", verifiedContent <| transaction.ruleVerified )
      , ( "Payment Method", text <| PaymentMethod.toDisplayString transaction.paymentMethod )
      , ( "Processor", processor transaction.paymentMethod )
      , ( "Status", getStatus transaction )
      ]
    )


getStatus : Transaction.Model -> Html msg
getStatus model =
    statusContent model.bankVerified


statusContent : Bool -> Html msg
statusContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

    else
        Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]


verifiedContent : Bool -> Html msg
verifiedContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

    else
        Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]


stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" ->
            True

        _ ->
            False
