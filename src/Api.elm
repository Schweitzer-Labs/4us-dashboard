module Api exposing
    ( Token(..)
    , decodeError
    , post
    )

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string, value)



-- CRED


type Token
    = Token String


credHeader : Token -> Http.Header
credHeader (Token token) =
    Http.header "authorization" ("Bearer " ++ token)


post : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
post url token body decoder =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


graphQLErrorDecoder =
    Decode.field "errors" <|
        Decode.list <|
            Decode.field "message" string


decodeError : Http.Error -> List String
decodeError error =
    case error of
        Http.BadStatus response ->
            case decodeString graphQLErrorDecoder response.body of
                Ok value ->
                    value

                Err err ->
                    [ "Server error" ]

        _ ->
            [ "Server Error" ]
