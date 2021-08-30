module Committee exposing (Model, decoder, init)

import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (required)


type alias Model =
    { candidateLastName : String
    , bankName : String
    , officeType : String
    , id : String
    }


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> required "candidateLastName" string
        |> required "bankName" string
        |> required "officeType" string
        |> required "id" string


init : Model
init =
    { candidateLastName = ""
    , bankName = ""
    , officeType = ""
    , id = ""
    }
