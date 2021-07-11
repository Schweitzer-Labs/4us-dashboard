module Transaction.TransactionData exposing (TransactionData, decode)

import Json.Decode as Decode
import Transaction


type alias TransactionData =
    { data : TransactionObject
    }


type alias TransactionObject =
    { transaction : Transaction.Model
    }


decode : Decode.Decoder TransactionData
decode =
    Decode.map
        TransactionData
        (Decode.field "data" decodeTransactionObject)


decodeTransactionObject : Decode.Decoder TransactionObject
decodeTransactionObject =
    Decode.map
        TransactionObject
        (Decode.field "transaction" Transaction.decoder)
