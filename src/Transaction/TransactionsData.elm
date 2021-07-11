module Transaction.TransactionsData exposing (TransactionsData, decode)

import Aggregations
import Committee
import Json.Decode as Decode exposing (Decoder)
import Transactions


type alias TransactionsData =
    { data : TransactionsObject
    }


type alias TransactionsObject =
    { transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    }


decode : Decode.Decoder TransactionsData
decode =
    Decode.map
        TransactionsData
        (Decode.field "data" decodeTransactionObject)


decodeTransactionObject : Decode.Decoder TransactionsObject
decodeTransactionObject =
    Decode.map3
        TransactionsObject
        (Decode.field "transactions" Transactions.decoder)
        (Decode.field "aggregations" Aggregations.decoder)
        (Decode.field "committee" Committee.decoder)
