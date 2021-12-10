module Api.GetReport exposing (Model, encode, send, toCsvData)

import Api.GraphQL as GraphQL exposing (encodeQuery)
import Config
import Http exposing (Body)
import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Session


query : String
query =
    """
    query(
      $committeeId: String!
      $includeHeaders: Boolean!
    ) {
      report(
        committeeId: $committeeId
        includeHeaders: $includeHeaders
      ) {
        csvData
      }
    }
    """


encode : String -> Bool -> Body
encode committeeId includeHeaders =
    encodeQuery query <|
        Encode.object <|
            [ ( "committeeId", Encode.string committeeId )
            , ( "includeHeaders", Encode.bool includeHeaders )
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


send : (Result Http.Error Model -> msg) -> Config.Model -> Session.Model -> Body -> Cmd msg
send =
    GraphQL.send decoder
