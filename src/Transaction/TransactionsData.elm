module Transaction.TransactionsData exposing (TransactionsData, decode)

import Aggregations
import Committee
import Json.Decode as Decode exposing (Decoder)
import Transactions


type alias TransactionsData =
    { data : TransactionObject
    }


type alias TransactionObject =
    { transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    }


decode : Decode.Decoder TransactionsData
decode =
    Decode.map
        TransactionsData
        (Decode.field "data" decodeTransactionObject)


decodeTransactionObject : Decode.Decoder TransactionObject
decodeTransactionObject =
    Decode.map3
        TransactionObject
        (Decode.field "transactions" Transactions.decoder)
        (Decode.field "aggregations" Aggregations.decoder)
        (Decode.field "committee" Committee.decoder)
