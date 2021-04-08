module Disbursement exposing (Model, decoder, init)

import Json.Decode as Decode exposing (bool, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { disbursementId : String
    , committeeId : String
    , vendorId : String
    , date : String
    , amount : String
    , purposeCode : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , recordNumber : String
    , entityName : String
    , bankVerified : Bool
    , ruleVerified : Bool
    , paymentMethod : String
    , dateProcessed : String
    , rule : String
    , isSubcontracted : String
    , isPartialPayment : String
    , isExistingLiability : String
    }


init : Model
init =
    { disbursementId = ""
    , committeeId = ""
    , vendorId = ""
    , date = ""
    , amount = ""
    , purposeCode = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , recordNumber = ""
    , entityName = ""
    , bankVerified = False
    , ruleVerified = False
    , paymentMethod = ""
    , dateProcessed = ""
    , rule = ""
    , isSubcontracted = ""
    , isPartialPayment = ""
    , isExistingLiability = ""
    }


fields : List ( Model -> String, String )
fields =
    [ ( .addressLine1, "Street address" )
    , ( .city, "City" )
    , ( .state, "State" )
    , ( .postalCode, "Zip" )
    , ( .entityName, "Vendor Name" )
    , ( .purposeCode, "Purpose code" )
    ]


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> required "disbursementId" string
        |> optional "committeeId" string ""
        |> optional "vendorId" string ""
        |> optional "timestamp" string ""
        |> optional "amount" string ""
        |> optional "purposeCode" string ""
        |> optional "addressLine1" string ""
        |> optional "addressLine2" string ""
        |> optional "city" string ""
        |> optional "state" string ""
        |> optional "postalCode" string ""
        |> optional "recordNumber" string ""
        |> optional "entityName" string ""
        |> optional "bankVerified" bool False
        |> optional "ruleVerified" bool False
        |> optional "paymentMethod" string "Check"
        |> optional "dateProcessed" string ""
        |> optional "rule" string ""
        |> optional "isSubcontracted" string ""
        |> optional "isPartialPayment" string ""
        |> optional "isExistingLiability" string ""
