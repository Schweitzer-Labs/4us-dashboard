module Api.ReconcileDemoTxn exposing (..)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder)
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


query : String
query =
    """
mutation(
  $password: String!
  $committeeId: String!
) {
  reconcileOneDemoTransaction(
    manageDemoCommitteeInput: {
      password: $password,
      committeeId: $committeeId,
    }
  ) {
    id
  }
}
    """


type alias EncodeModel =
    { password : String
    , committeeId : String
    }


encode : (a -> EncodeModel) -> a -> Http.Body
encode mapper val =
    let
        model =
            mapper val

        variables =
            Encode.object <|
                [ ( "password", Encode.string model.password )
                , ( "committeeId", Encode.string model.committeeId )
                ]
    in
    encodeQuery query variables


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "reconcileOneDemoTransaction" <|
                Decode.field "id" <|
                    Decode.string


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
