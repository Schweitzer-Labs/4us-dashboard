module Committee exposing (Model, decoder, init, isPolicapital)

import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (required)
import PlatformPlan


type alias Model =
    { candidateLastName : String
    , bankName : String
    , officeType : String
    , id : String
    , platformPlan : PlatformPlan.Model
    }


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> required "candidateLastName" string
        |> required "bankName" string
        |> required "officeType" string
        |> required "id" string
        |> required "platformPlan" PlatformPlan.decoder


init : Model
init =
    { candidateLastName = ""
    , bankName = ""
    , officeType = ""
    , id = ""
    , platformPlan = PlatformPlan.Policapital
    }


isPolicapital : Model -> Bool
isPolicapital model =
    model.platformPlan == PlatformPlan.Policapital
