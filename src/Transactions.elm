module Transactions exposing (Transactions)

import Json.Decode as Decode
import Transaction exposing (Transaction)


type alias Transactions =
    List Transaction


decoder : Decode.Decoder Transactions
decoder =
    Decode.list Transaction.decoder
