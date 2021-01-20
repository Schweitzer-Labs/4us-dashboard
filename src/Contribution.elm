module Contribution exposing (Model, decoder)

import Json.Decode as Decode


type alias Model =
    { record : String
    , datetime : String
    , rule : String
    , entityName : String
    , amount : String
    , paymentMethod : String
    , verified : String
    , refCode : Maybe String
    }


decoder : Decode.Decoder Model
decoder =
    Decode.map8
        Model
        (Decode.field "record" Decode.string)
        (Decode.field "datetime" Decode.string)
        (Decode.field "rule" Decode.string)
        (Decode.field "entityName" Decode.string)
        (Decode.field "amount" Decode.string)
        (Decode.field "paymentMethod" Decode.string)
        (Decode.field "verified" Decode.string)
        (Decode.maybe <| Decode.field "refCode" Decode.string)
