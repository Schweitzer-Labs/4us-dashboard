module Transaction.DisbursementsData exposing (DisbursementsData, decode)

import Aggregations
import Disbursement as Disbursement
import Disbursements
import Json.Decode as Decode exposing (Decoder)


type alias DisbursementsData =
    { disbursements : List Disbursement.Model
    , aggregations : Aggregations.Model
    }


decode : Decode.Decoder DisbursementsData
decode =
    Decode.map2
        DisbursementsData
        (Decode.field "disbursements" Disbursements.decoder)
        (Decode.field "aggregations" Aggregations.decoder)
