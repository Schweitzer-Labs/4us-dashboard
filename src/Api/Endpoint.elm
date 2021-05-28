module Api.Endpoint exposing
    ( Endpoint
    , contribute
    , contributions
    , disbursement
    , disbursements
    , graphql
    , needsReviewDisbursements
    , request
    , transactions
    , user
    , verifyDisbursement
    )

import Api.DisbursementsFilter as DisbursementsFilter exposing (DisbursementsFilter)
import Config.Env exposing (env)
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



-- TYPES


{-| Get a URL to the 4US API.

This is not publicly exposed, because we want to make sure the only way to get one of these URLs is from this module.

-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str



-- "https://9wp0a5f6ic.execute-api.us-east-1.amazonaws.com/dev"


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    -- NOTE: Url.Builder takes care of percent-encoding special URL characters.
    -- See https://package.elm-lang.org/packages/elm/url/latest/Url#percentEncode
    Url.Builder.crossOrigin env.apiEndpoint
        paths
        queryParams
        |> Endpoint



-- ENDPOINTS


contributions : String -> Endpoint
contributions committeeId =
    url [ "contributions", committeeId ] []


disbursements : String -> List DisbursementsFilter -> Endpoint
disbursements committeeId filters =
    let
        queryParams =
            List.map DisbursementsFilter.toQueryParam filters
    in
    url [ "disbursements", committeeId ] queryParams


needsReviewDisbursements : String -> Endpoint
needsReviewDisbursements committeeId =
    disbursements committeeId
        [ DisbursementsFilter.RuleProcessed False
        , DisbursementsFilter.BankProcessed True
        ]


disbursement : String -> Endpoint
disbursement committeeId =
    url [ "disbursement", committeeId ] []


contribute : Endpoint
contribute =
    url [ "contribution" ] []


graphql : Endpoint
graphql =
    url [] []


transactions : String -> Maybe Direction -> Endpoint
transactions committeeId maybeDirection =
    let
        query =
            case maybeDirection of
                Just direction ->
                    [ string "direction" <| Direction.toString direction ]

                Nothing ->
                    []
    in
    url [ "transactions", committeeId ] query


verifyDisbursement : String -> Endpoint
verifyDisbursement committeeId =
    url [ "disbursement", "verify", committeeId ] []


user : Endpoint
user =
    url [ "user" ] []
