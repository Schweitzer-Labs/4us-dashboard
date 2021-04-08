module Transactions exposing (Label(..), Model, decoder, labels, statusContent, stringToBool, transactionRowMap, verifiedContent, view)

import Asset
import Cents
import ContributorType
import DataTable exposing (DataRow)
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import PaymentMethod
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
    , ( sortMsg Context, "Context" )
    , ( sortMsg Amount, "Amount" )
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
    case method of
        "credit" ->
            img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

        "debit" ->
            img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

        "ach" ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

        "check" ->
            img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []

        _ ->
            text "N/A"


getEntityName : Transaction.Model -> String
getEntityName transaction =
    let
        personName =
            transaction.firstName ++ " " ++ transaction.lastName
    in
    case ( transaction.direction, transaction.contributorType ) of
        ( "out", _ ) ->
            transaction.entityName

        ( "in", "ind" ) ->
            personName

        ( "in", "fam" ) ->
            personName

        _ ->
            transaction.companyName


getEntityType : Transaction.Model -> String
getEntityType transaction =
    Maybe.withDefault "LLC"
        (Maybe.map ContributorType.toGridString (ContributorType.fromString transaction.contributorType))


getContext : Transaction.Model -> Html msg
getContext transaction =
    case transaction.direction of
        "out" ->
            if transaction.purposeCode == "" then
                span [ class "text-danger" ] [ text "Missing" ]

            else
                text transaction.purposeCode

        _ ->
            text <| Maybe.withDefault "Home" transaction.refCode


getAmount : Transaction.Model -> Html msg
getAmount transaction =
    case transaction.direction of
        "out" ->
            span [ class "text-danger font-weight-bold" ] [ text <| "(" ++ Cents.toDollar transaction.amount ++ ")" ]

        _ ->
            span [ class "text-green font-weight-bold" ] [ text <| Cents.toDollar transaction.amount ]


getPaymentMethod : Transaction.Model -> String
getPaymentMethod transaction =
    case transaction.direction of
        "out" ->
            "check"

        _ ->
            Maybe.withDefault "Home" transaction.refCode


transactionRowMap : ( Maybe msg, Transaction.Model ) -> ( Maybe msg, DataRow msg )
transactionRowMap ( maybeMsg, transaction ) =
    let
        name =
            getEntityName transaction

        context =
            getContext transaction

        amount =
            getAmount transaction

        entityType =
            getEntityType transaction
    in
    ( maybeMsg
    , [ ( "Date / Time", text transaction.timestamp )
      , ( "Entity Name", text <| name )
      , ( "Context", text entityType )
      , ( "Context", context )
      , ( "Amount", amount )
      , ( "Verified", verifiedContent <| transaction.ruleVerified )
      , ( "Payment Method", text <| PaymentMethod.toDisplayString transaction.paymentMethod )
      , ( "Processor", processor transaction.paymentMethod )
      , ( "Status", getStatus transaction )
      ]
    )


getStatus : Transaction.Model -> Html msg
getStatus model =
    case model.paymentMethod of
        "in-kind" ->
            Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

        _ ->
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
