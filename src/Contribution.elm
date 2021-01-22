module Contribution exposing (Model, decoder)

import Json.Decode as Decode exposing (maybe, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { record : String
    , datetime : String
    , rule : String
    , entityName : String
    , firstName : String
    , lastName : String
    , amount : String
    , paymentMethod : String
    , verified : String
    , refCode : Maybe String
    , contributionId : String
    }


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> optional "record" string ""
        |> optional "timestamp" string ""
        |> optional "rule" string ""
        |> optional "entityName" string ""
        |> optional "firstName" string ""
        |> optional "lastName" string ""
        |> optional "amount" string ""
        |> optional "paymentMethod" string ""
        |> optional "verified" string ""
        |> optional "refCode" (maybe string) Nothing
        |> required "contributionId" string
