module Api.SeedExtContribs exposing (EncodeModel, ID, decoder, encode, query, send, successDecoder)

import Api.GraphQL as GraphQL exposing (MutationResponseOnAll(..), encodeQuery, mutationValidationFailureDecoderAll)
import Config
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Session


query : String
query =
    """
mutation(
  $password: String!
  $committeeId: String!
  $externalSource: ExternalSource!
) {
  seedDemoExternalContributions(
    seedExternContributionsInput: {
      password: $password
      committeeId: $committeeId
      externalSource: $externalSource
    }
  ) {
    id
  }
}
    """


type alias EncodeModel =
    { password : String
    , committeeId : String
    , externalSource : String
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
                , ( "externalSource", Encode.string model.externalSource )
                ]
    in
    encodeQuery query variables


type alias ID =
    { id : String
    }


successDecoder : Decode.Decoder MutationResponseOnAll
successDecoder =
    Decode.map SuccessAll <|
        Decode.field "data" <|
            Decode.field "seedDemoExternalContributions" <|
                Decode.list <|
                    Decode.field "id" <|
                        Decode.string


decoder : Decode.Decoder MutationResponseOnAll
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoderAll ]


send : (Result Http.Error MutationResponseOnAll -> msg) -> Config.Model -> Session.Model -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
