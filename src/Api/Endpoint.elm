module Api.Endpoint exposing
    ( Endpoint
    , articles
    , contribute
    , contributions
    , disbursement
    , disbursements
    , feed
    , follow
    , login
    , needsReviewDisbursements
    , profiles
    , request
    , tags
    , transactions
    , user
    , users
    , verifyDisbursement
    )

import Api.DisbursementsFilter as DisbursementsFilter exposing (DisbursementsFilter)
import Config.Env exposing (env)
import Http
import Url.Builder exposing (QueryParameter, string)
import Username exposing (Username)


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
    url [ "contributions" ] [ string "committeeId" committeeId ]


disbursements : String -> List DisbursementsFilter -> Endpoint
disbursements committeeId filters =
    let
        filterQueryParams =
            List.map DisbursementsFilter.toQueryParam filters

        queryParams =
            [ string "committeeId" committeeId ] ++ filterQueryParams
    in
    url [ "disbursements" ] queryParams


needsReviewDisbursements : String -> Endpoint
needsReviewDisbursements committeeId =
    disbursements committeeId
        [ DisbursementsFilter.RuleProcessed False
        , DisbursementsFilter.BankProcessed True
        ]


disbursement : Endpoint
disbursement =
    url [ "disbursement" ] []


contribute : Endpoint
contribute =
    url [ "contribution" ] []


transactions : String -> Endpoint
transactions committeeId =
    url [ "transactions" ] [ string "committeeId" committeeId ]


verifyDisbursement : Endpoint
verifyDisbursement =
    url [ "disbursement", "verify" ] []


login : Endpoint
login =
    url [ "users", "login" ] []


user : Endpoint
user =
    url [ "user" ] []


users : Endpoint
users =
    url [ "users" ] []


follow : Username -> Endpoint
follow uname =
    url [ "profiles", Username.toString uname, "follow" ] []



-- ARTICLE ENDPOINTS


articles : List QueryParameter -> Endpoint
articles params =
    url [ "articles" ] params


profiles : Username -> Endpoint
profiles uname =
    url [ "profiles", Username.toString uname ] []


feed : List QueryParameter -> Endpoint
feed params =
    url [ "articles", "feed" ] params


tags : Endpoint
tags =
    url [ "tags" ] []
