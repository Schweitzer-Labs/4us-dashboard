module Transaction.TransactionsData exposing (TransactionsData, decode)

import Aggregations
import Disbursement as Disbursement
import Disbursements
import Json.Decode as Decode exposing (Decoder)
import Transactions


type alias TransactionsData =
    { transactions : Transactions.Model
    , aggregations : Aggregations.Model
    }


decode : Decode.Decoder TransactionsData
decode =
    Decode.map2
        TransactionsData
        (Decode.field "transactions" Transactions.decoder)
        (Decode.field "aggregates" Aggregations.decoder)
