module Api exposing
    ( Token(..)
    , decodeError
    , post
    )

{-| This module is responsible for communicating to the Conduit API.

It exposes an opaque Endpoint type which is guaranteed to point to the correct URL.

-}

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)



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


decodeError : Http.Error -> String
decodeError error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errorMessage" string)
                |> Result.withDefault "Server error"

        err ->
            "Server error"
