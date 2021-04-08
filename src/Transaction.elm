module Transaction exposing (Model, decoder)

import Json.Decode as Decode exposing (bool, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { timestamp : String
    , contributionId : String
    , donorId : String
    , committeeId : String
    , amount : String
    , stripeTxnId : String
    , firstName : String
    , lastName : String
    , employer : String
    , addressLine1 : String
    , addressLine2 : String
    , postalCode : String
    , city : String
    , state : String
    , paymentMethod : String
    , contributorType : String
    , companyName : String
    , ruleVerified : Bool
    , bankVerified : Bool
    , transactionType : String
    , direction : String
    , refCode : Maybe String
    , purposeCode : String
    , entityName : String
    }


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> optional "timestamp" string ""
        |> optional "contributionId" string ""
        |> optional "donorId" string ""
        |> optional "committeeId" string ""
        |> optional "amount" string ""
        |> optional "stripeTxnId" string ""
        |> optional "firstName" string ""
        |> optional "lastName" string ""
        |> optional "employer" string ""
        |> optional "addressLine1" string ""
        |> optional "addressLine2" string ""
        |> optional "postalCode" string ""
        |> optional "city" string ""
        |> optional "state" string ""
        |> optional "paymentMethod" string ""
        |> optional "contributorType" string ""
        |> optional "companyName" string ""
        |> optional "ruleVerified" bool False
        |> optional "bankVerified" bool False
        |> optional "transactionType" string ""
        |> optional "direction" string ""
        |> optional "refCode" (maybe string) Nothing
        |> optional "purposeCode" string ""
        |> optional "entityName" string ""
