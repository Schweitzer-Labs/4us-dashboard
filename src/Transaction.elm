module Transaction exposing (Model(..), decoder)

import Contribution as Contribution
import Disbursement as Disbursement
import Json.Decode as Decode exposing (bool, oneOf, string)


type Model
    = Contribution Contribution.Model
    | Disbursement Disbursement.Model


decoder : Decode.Decoder Model
decoder =
    oneOf
        [ Contribution.decoder |> Decode.map Contribution
        , Disbursement.decoder |> Decode.map Disbursement
        ]
