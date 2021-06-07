module Api.Endpoint exposing
    ( Endpoint(..)
    , fromString
    , request
    , transactions
    , verifyDisbursement
    )

import Direction exposing (Direction)
import Http
import Url.Builder exposing (QueryParameter, string)


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , withCredentials : Bool
    }
    -> Http.Request a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , withCredentials = config.withCredentials
        }


fromString : String -> Endpoint
fromString str =
    Endpoint str



-- TYPES


{-| Get a URL to the 4US API.

This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.

-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : String -> List String -> List QueryParameter -> Endpoint
url endpoint paths queryParams =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.crossOrigin endpoint
        paths
        queryParams
        |> Endpoint



-- ENDPOINTS


transactions : String -> String -> Maybe Direction -> Endpoint
transactions endpoint committeeId maybeDirection =
    let
        query =
            case maybeDirection of
                Just direction ->
                    [ string "direction" <| Direction.toString direction ]

                Nothing ->
                    []
    in
    url endpoint [ "transactions", committeeId ] query


verifyDisbursement : String -> String -> Endpoint
verifyDisbursement endpoint committeeId =
    url endpoint [ "disbursement", "verify", committeeId ] []
