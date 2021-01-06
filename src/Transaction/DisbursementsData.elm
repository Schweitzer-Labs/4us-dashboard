module Transaction.DisbursementsData exposing (Disbursement, DisbursementsData, decode)

import Json.Decode as Decode exposing (Decoder, int, string, float)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)


type alias Disbursement =
    { disbursementId : String
    , committeeId: String
    , vendorId: String
    , date: String
    , amount: String
    , purposeCode: String
    , stripTxnId: String
    , addressLine1: String
    , addressLine2: String
    , city: String
    , state: String
    , postalCode: String
    , recordNumber: String
    , entityName: String
    }

type alias Aggregations =
    { balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    , totalInProcessing: String
    }

type alias DisbursementsData =
  { disbursements : List Disbursement
  , aggregations : Aggregations
  }

decode : Decode.Decoder DisbursementsData
decode =
  Decode.map2
    DisbursementsData
    (Decode.field "disbursements" listOfDisbursementsDecoder)
    (Decode.field "aggregates" aggregationsDecoder)


aggregationsDecoder : Decode.Decoder Aggregations
aggregationsDecoder =
    Decode.map8
        Aggregations
        (Decode.field "balance" Decode.string)
        (Decode.field "totalRaised" Decode.string)
        (Decode.field "totalSpent" Decode.string)
        (Decode.field "totalDonors" Decode.string)
        (Decode.field "qualifyingDonors" Decode.string)
        (Decode.field "qualifyingFunds" Decode.string)
        (Decode.field "totalTransactions" Decode.string)
        (Decode.field "totalInProcessing" Decode.string)


disbursementDecoder : Decode.Decoder Disbursement
disbursementDecoder =
    Decode.succeed Disbursement
            |> required "disbursementId" string
            |> required "committeeId" string
            |> required "vendorId" string
            |> required "date" string
            |> required "amount" string
            |> required "purposeCode" string
            |> required "stripTxnId" string
            |> required "addressLine1" string
            |> required "addressLine2" string
            |> required "city" string
            |> required "state" string
            |> required "postalCode" string
            |> required "recordNumber" string
            |> required "entityName" string


listOfDisbursementsDecoder : Decode.Decoder (List Disbursement)
listOfDisbursementsDecoder =
    Decode.list disbursementDecoder
