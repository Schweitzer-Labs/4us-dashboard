module Api.GetReport exposing (Model, encode, send, toCsvData)

import Api.GraphQL as GraphQL exposing (encodeQuery)
import Config exposing (Config)
import Http exposing (Body)
import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


query : String
query =
    """
    query($committeeId: String!) {
      report(committeeId: $committeeId) {
        csvData
      }
    }
    """


encode : String -> Body
encode committeeId =
    encodeQuery query <|
        Encode.object <|
            [ ( "committeeId", Encode.string committeeId )
            ]


type alias Model =
    { data : Object
    }


type alias Object =
    { report : Report
    }


type alias Report =
    { csvData : String
    }


decoder : Decode.Decoder Model
decoder =
    Decode.map
        Model
        (Decode.field "data" decodeObject)


reportDecoder : Decode.Decoder Report
reportDecoder =
    Decode.succeed Report
        |> required "csvData" string


decodeObject : Decode.Decoder Object
decodeObject =
    Decode.map
        Object
        (Decode.field "report" reportDecoder)


toCsvData : Model -> String
toCsvData model =
    model.data.report.csvData



-- We want to compose this function i.e encode >> send


send : (Result Http.Error Model -> msg) -> Config -> Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
