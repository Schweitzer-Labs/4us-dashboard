module ProcessorFeeData exposing (Model, decoder)

import Json.Decode as Decoder exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (optional, required)
import PaymentMethod


type alias Model =
    { amount : Int
    , paymentMethod : PaymentMethod.Model
    , entityName : String
    , paymentDate : Int
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , country : String
    , checkNumber : String
    }


decoder : Decoder Model
decoder =
    Decoder.succeed Model
        |> required "amount" int
        |> required "paymentMethod" PaymentMethod.decoder
        |> required "entityName" string
        |> required "paymentDate" int
        |> required "addressLine1" string
        |> optional "addressLine2" string ""
        |> required "city" string
        |> required "state" string
        |> required "postalCode" string
        |> required "country" string
        |> required "checkNumber" string
