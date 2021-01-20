module Transaction exposing (Transaction(..), decoder)

import Contribution as Contribution
import Disbursement as Disbursement
import Json.Decode as Decode exposing (bool, oneOf, string)


type Transaction
    = Contribution Contribution.Model
    | Disbursement Disbursement.Model


decoder : Decode.Decoder Transaction
decoder =
    oneOf
        [ Contribution.decoder |> Decode.map Contribution
        , Disbursement.decoder |> Decode.map Disbursement
        ]
