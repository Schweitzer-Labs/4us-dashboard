module Api.GraphQL exposing
    ( MutationResponse(..)
    , MutationResponseOnAll(..)
    , encodeQuery
    , graphQLErrorDecoder
    , mutationValidationFailureDecoder
    , mutationValidationFailureDecoderAll
    , optionalFieldNotZero
    , optionalFieldOwners
    , optionalFieldString
    , optionalFieldStringInt
    , send
    )

import Api
import Api.Endpoint exposing (Endpoint(..))
import Config
import Http exposing (Body)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Owners
import Session


encodeQuery : String -> Value -> Body
encodeQuery query variables =
    Http.jsonBody <|
        Encode.object
            [ ( "query", Encode.string query )
            , ( "variables", variables )
            ]


graphQLErrorDecoder : Decode.Decoder (List String)
graphQLErrorDecoder =
    Decode.field "errors" <|
        Decode.list <|
            Decode.field "message" <|
                Decode.string


type MutationResponse
    = Success String
    | ResValidationFailure (List String)


type MutationResponseOnAll
    = SuccessAll (List String)
    | ResValidationFailureAll (List String)


mutationValidationFailureDecoder : Decode.Decoder MutationResponse
mutationValidationFailureDecoder =
    Decode.map ResValidationFailure graphQLErrorDecoder


mutationValidationFailureDecoderAll : Decode.Decoder MutationResponseOnAll
mutationValidationFailureDecoderAll =
    Decode.map ResValidationFailureAll graphQLErrorDecoder


send :
    Decode.Decoder a
    -> (Result Http.Error a -> msg)
    -> Config.Model
    -> Session.Model
    -> Body
    -> Cmd msg
send decoder msg config session body =
    let
        apiEndpoint =
            Config.toApiEndpoint config

        token =
            Maybe.withDefault "" (Session.toToken session)

        request =
            Api.post
                (Endpoint apiEndpoint)
                (Api.Token token)
                body
                decoder
    in
    Http.send msg request


optionalFieldString : String -> String -> List ( String, Value )
optionalFieldString key val =
    if val == "" then
        []

    else
        [ ( key, Encode.string val ) ]


optionalFieldStringInt : String -> String -> List ( String, Value )
optionalFieldStringInt key val =
    if val == "" then
        []

    else
        [ ( key, Encode.int <| Maybe.withDefault 1 <| String.toInt val ) ]


optionalFieldNotZero : String -> Int -> List ( String, Value )
optionalFieldNotZero key val =
    if val > 0 then
        [ ( key, Encode.int val ) ]

    else
        []


optionalFieldOwners : String -> Owners.Owners -> List ( String, Value )
optionalFieldOwners key val =
    if val == [] then
        []

    else
        [ ( key, Encode.list Owners.encoder val ) ]
