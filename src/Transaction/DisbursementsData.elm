module Transaction.DisbursementsData exposing (DisbursementsData, decode)

import Aggregations exposing (Aggregations)
import Disbursements exposing (Disbursement)
import Json.Decode as Decode exposing (Decoder, float, int, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)


type alias DisbursementsData =
    { disbursements : List Disbursement
    , aggregations : Aggregations
    }


decode : Decode.Decoder DisbursementsData
decode =
    Decode.map2
        DisbursementsData
        (Decode.field "disbursements" Disbursements.decoder)
        (Decode.field "aggregates" Aggregations.decoder)
