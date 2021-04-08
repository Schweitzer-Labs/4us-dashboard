module Disbursements exposing (Label(..), decoder, view, viewInteractive)

import Asset
import Cents
import DataTable exposing (DataRow)
import Disbursement as Disbursement
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode


decoder : Decode.Decoder (List Disbursement.Model)
decoder =
    Decode.list Disbursement.decoder



-- Disbursements


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg DateTime, "Date / Time" )
    , ( sortMsg EntityName, "Entity Name" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg Purpose, "Purpose" )
    , ( sortMsg Verified, "Verified" )
    , ( sortMsg PaymentMethod, "Payment Method" )
    , ( sortMsg Status, "Status" )
    ]


type Label
    = Record
    | DateTime
    | EntityName
    | Amount
    | Purpose
    | PaymentMethod
    | Status
    | Verified


view : (Label -> msg) -> List (Html msg) -> List Disbursement.Model -> Html msg
view sortMsg content disbursements =
    DataTable.view "Awaiting Disbursements." content (labels sortMsg) disbursementRowMap <|
        List.map (\d -> ( Nothing, d )) disbursements


viewInteractive :
    (Label -> msg)
    -> (Disbursement.Model -> msg)
    -> List (Html msg)
    -> List Disbursement.Model
    -> Html msg
viewInteractive sortMsg msg content disbursements =
    DataTable.view "Awaiting Disbursements." content (labels sortMsg) disbursementRowMap <|
        List.map (\d -> ( Just (msg d), d )) disbursements


disbursementRowMap : ( Maybe msg, Disbursement.Model ) -> ( Maybe msg, DataRow msg )
disbursementRowMap ( maybeMsg, d ) =
    let
        status =
            if d.bankVerified then
                Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]

        verified =
            if d.ruleVerified then
                Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]
    in
    ( maybeMsg
    , [ ( "Date / Time", text d.date )
      , ( "Entity Name", text d.entityName )
      , ( "Amount", span [ class "text-danger font-weight-bold" ] [ text <| "(" ++ Cents.toDollar d.amount ++ ")" ] )
      , ( "Purpose"
        , if d.purposeCode == "" then
            span [ class "text-danger" ] [ text "Missing" ]

          else
            text d.purposeCode
        )
      , ( "Verified", verified )
      , ( "Payment Method", span [ class "text-capitalize" ] [ text d.paymentMethod ] )
      , ( "Status", status )
      ]
    )
