module Flags exposing (Model, fromSessionAndConfig, toConfig, toMaybeToken)

import Config
import Session


type alias Model =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    , donorUrl : String
    , apiEndpoint : String
    , token : Maybe String
    }


toConfig : Model -> Config.Model
toConfig flags =
    { cognitoDomain = flags.cognitoDomain
    , cognitoClientId = flags.cognitoClientId
    , redirectUri = flags.redirectUri
    , donorUrl = flags.donorUrl
    , apiEndpoint = flags.apiEndpoint
    }


toMaybeToken : Model -> Maybe String
toMaybeToken model =
    model.token


fromSessionAndConfig : Session.Model -> Config.Model -> Model
fromSessionAndConfig session config =
    { cognitoDomain = config.cognitoDomain
    , cognitoClientId = config.cognitoClientId
    , redirectUri = config.redirectUri
    , donorUrl = config.donorUrl
    , apiEndpoint = config.apiEndpoint
    , token = Session.toToken session
    }
