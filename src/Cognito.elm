port module Cognito exposing (fromConfig, fromFlags, goToCommitteeUrl, toLoginUrl, urlToCommitteeId, urlToRedirectQS)

import Browser.Navigation exposing (load)
import Config
import Flags
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Url exposing (Url)
import Url.Parser as Parser exposing (parse)
import Url.Parser.Query as Query exposing (string)


port storeCache : Maybe Value -> Cmd msg


port onStoreChange : (Value -> msg) -> Sub msg


type alias Args =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    }


fromConfig : Config.Model -> Args
fromConfig { cognitoDomain, cognitoClientId, redirectUri } =
    { cognitoDomain = cognitoDomain
    , cognitoClientId = cognitoClientId
    , redirectUri = redirectUri
    }


fromFlags : Flags.Model -> Args
fromFlags { cognitoDomain, cognitoClientId, redirectUri } =
    { cognitoDomain = cognitoDomain
    , cognitoClientId = cognitoClientId
    , redirectUri = redirectUri
    }


toLoginUrl : Maybe String -> Args -> String
toLoginUrl maybeCommitteeId { cognitoDomain, cognitoClientId, redirectUri } =
    let
        state =
            maybeCommitteeId
                |> Maybe.map (\cid -> "&state=" ++ cid)
                |> Maybe.withDefault ""
    in
    cognitoDomain ++ "/login?client_id=" ++ cognitoClientId ++ "&response_type=token&scope=email+openid+profile&redirect_uri=" ++ redirectUri ++ state


type alias RedirectQS =
    { token : String
    , committeeId : String
    }


type alias RedirectQSWithMaybes =
    { token : Maybe String
    , committeeId : Maybe String
    }


urlToRedirectQS : Url -> Maybe RedirectQS
urlToRedirectQS url =
    let
        res =
            Maybe.withDefault { token = Nothing, committeeId = Nothing } <|
                Parser.parse
                    (Parser.query <|
                        Query.map2
                            RedirectQSWithMaybes
                            (string "committeeId")
                            (string "token")
                    )
                    url
    in
    case ( res.token, res.committeeId ) of
        ( Just token, Just committeeId ) ->
            Just (RedirectQS token committeeId)

        _ ->
            Nothing


setTokenToStorage : String -> Cmd msg
setTokenToStorage token =
    let
        json =
            Encode.object
                [ ( "token", Encode.string token )
                ]
    in
    storeCache <| Just json


configToCommitteeUrl : Config.Model -> String -> String
configToCommitteeUrl { redirectUri } committeeId =
    redirectUri ++ "?committeeId=" ++ committeeId


goToCommitteeUrl : Config.Model -> String -> Cmd msg
goToCommitteeUrl config str =
    load <| configToCommitteeUrl config str


urlToCommitteeId : Url -> Maybe String
urlToCommitteeId url =
    Maybe.withDefault Nothing <| parse (Parser.query (Query.string "committeeId")) url
