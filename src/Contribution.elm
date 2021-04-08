module Contribution exposing (Model, decoder)

import Json.Decode as Decode exposing (bool, maybe, string)
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
    , refCode : Maybe String
    , contributionId : String
    , bankVerified : Bool
    , ruleVerified : Bool
    }


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> optional "record" string ""
        |> optional "timestamp" string ""
        |> optional "code" string ""
        |> optional "entityName" string ""
        |> optional "firstName" string ""
        |> optional "lastName" string ""
        |> optional "amount" string ""
        |> optional "paymentMethod" string ""
        |> optional "refCode" (maybe string) Nothing
        |> required "contributionId" string
        |> optional "bankVerified" bool False
        |> optional "ruleVerified" bool False
