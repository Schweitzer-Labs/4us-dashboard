module Transaction.TransactionsData exposing (TransactionsData, decode)

import Aggregations
import Json.Decode as Decode exposing (Decoder)
import Transactions


type alias TransactionsData =
    { data : TransactionObject
    }


type alias TransactionObject =
    { transactions : Transactions.Model
    , aggregations : Aggregations.Model
    }


decode : Decode.Decoder TransactionsData
decode =
    Decode.map
        TransactionsData
        (Decode.field "data" decodeTransactionObject)


decodeTransactionObject : Decode.Decoder TransactionObject
decodeTransactionObject =
    Decode.map2
        TransactionObject
        (Decode.field "transactions" Transactions.decoder)
        (Decode.field "aggregations" Aggregations.decoder)
