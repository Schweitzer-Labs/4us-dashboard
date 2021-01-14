module Disbursements exposing (Disbursement, decoder, view)

import Asset
import DataTable
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Disbursement =
    { disbursementId : String
    , committeeId : String
    , vendorId : String
    , date : String
    , amount : String
    , purposeCode : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , recordNumber : String
    , entityName : String
    , verified : String
    , paymentMethod : String
    }


disbursementDecoder : Decode.Decoder Disbursement
disbursementDecoder =
    Decode.succeed Disbursement
        |> required "disbursementId" string
        |> required "committeeId" string
        |> required "vendorId" string
        |> required "timestamp" string
        |> required "amount" string
        |> required "purposeCode" string
        |> optional "addressLine1" string ""
        |> optional "addressLine2" string ""
        |> optional "city" string ""
        |> optional "state" string ""
        |> optional "postalCode" string ""
        |> required "recordNumber" string
        |> required "entityName" string
        |> required "verified" string
        |> optional "paymentMethod" string "Check"


decoder : Decode.Decoder (List Disbursement)
decoder =
    Decode.list disbursementDecoder



-- Disbursements


labels : List String
labels =
    [ "Record"
    , "Date / Time"
    , "Entity Name"
    , "Amount"
    , "Purpose"
    , "Payment Method"
    , "Status"
    , "Verified"
    ]


view : List (Html msg) -> List Disbursement -> Html msg
view content disbursements =
    DataTable.view content labels disbursementRowMap disbursements


stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" ->
            True

        _ ->
            False


disbursementRowMap : Disbursement -> List ( String, Html msg )
disbursementRowMap d =
    let
        status =
            if stringToBool d.verified then
                Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]
    in
    [ ( "Record", text d.recordNumber )
    , ( "Date / Time", text d.date )
    , ( "Entity Name", text d.entityName )
    , ( "Amount", span [ class "text-failure font-weight-bold" ] [ text <| "$" ++ d.amount ] )
    , ( "Purpose", text d.purposeCode )
    , ( "Payment Method", span [ class "text-failure font-weight-bold" ] [ text d.paymentMethod ] )
    , ( "Status", status )
    , ( "Verified", Asset.circleCheckGlyph [ class "text-success data-icon-size" ] )
    ]
