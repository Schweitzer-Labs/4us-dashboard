module Api exposing
    ( Cred
    , Token(..)
    , addServerError
    , decodeError
    , decodeErrors
    , delete
    , get
    , post
    , put
    , username
    )

{-| This module is responsible for communicating to the Conduit API.

It exposes an opaque Endpoint type which is guaranteed to point to the correct URL.

-}

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http exposing (Body, Expect)
import Json.Decode as Decode exposing (Decoder, Value, decodeString, field, string)
import Username exposing (Username)



-- CRED


{-| The authentication credentials for the Viewer (that is, the currently logged-in user.)

This includes:

  - The cred's Username
  - The cred's authentication token

By design, there is no way to access the token directly as a String.
It can be encoded for persistence, and it can be added to a header
to a HttpBuilder for a request, but that's it.

This token should never be rendered to the end user, and with this API, it
can't be!

-}
type Cred
    = Cred Username String


type Token
    = Token String


username : Cred -> Username
username (Cred val _) =
    val


credHeader : Token -> Http.Header
credHeader (Token token) =
    Http.header "authorization" ("Bearer " ++ token)



-- PERSISTENCE
-- SERIALIZATION
-- APPLICATION
-- HTTP


get : Endpoint -> Token -> Decoder a -> Http.Request a
get url token decoder =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = Http.emptyBody
        , timeout = Nothing
        , withCredentials = False
        }


put : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
put url token body decoder =
    Endpoint.request
        { method = "PUT"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }


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


delete : Endpoint -> Token -> Body -> Decoder a -> Http.Request a
delete url token body decoder =
    Endpoint.request
        { method = "DELETE"
        , url = url
        , expect = Http.expectJson decoder
        , headers = [ credHeader token ]
        , body = body
        , timeout = Nothing
        , withCredentials = False
        }



--settings : Cred -> Http.Body -> Decoder (Cred -> a) -> Http.Request a
--settings cred body decoder =
--    put Endpoint.user cred body (Decode.field "user" (decoderFromCred decoder))
-- ERRORS


addServerError : List String -> List String
addServerError list =
    "Server error" :: list


{-| Many API endpoints include an "errors" field in their BadStatus responses.
-}
decodeErrors : Http.Error -> List String
decodeErrors error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errors" errorsDecoder)
                |> Result.withDefault [ "Server error" ]

        err ->
            [ "Server error" ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    Decode.keyValuePairs (Decode.list Decode.string)
        |> Decode.map (List.concatMap fromPair)


fromPair : ( String, List String ) -> List String
fromPair ( field, errors ) =
    List.map (\error -> field ++ " " ++ error) errors


decodeError : Http.Error -> String
decodeError error =
    case error of
        Http.BadStatus response ->
            response.body
                |> decodeString (field "errorMessage" string)
                |> Result.withDefault "Server error"

        err ->
            "Server error"
