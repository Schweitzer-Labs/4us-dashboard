module Api.DeleteTxn exposing (EncodeModel, decoder, encode, query, send, successDecoder)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder)
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


query : String
query =
    """
    mutation(
        $id: String!
        $committeeId: String!
      ) {
        deleteTransaction(
          id: $id
          committeeId: $committeeId
        ) {
          id
        }
      }
    """


type alias EncodeModel =
    { committeeId : String
    , id : String
    }


encode : (a -> EncodeModel) -> a -> Http.Body
encode mapper val =
    let
        model =
            mapper val

        variables =
            Encode.object <|
                [ ( "id", Encode.string model.id )
                , ( "committeeId", Encode.string model.committeeId )
                ]
    in
    encodeQuery query variables


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "deleteTransaction" <|
                Decode.field "id" <|
                    Decode.string


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
