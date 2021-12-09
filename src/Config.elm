module Config exposing (Config, FlagConfig, fromFlags, toFlags)


type alias FlagConfig =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    , donorUrl : String
    , apiEndpoint : String
    , token : Maybe String
    }


type alias Config =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    , donorUrl : String
    , apiEndpoint : String
    , token : String
    }


fromFlags : String -> FlagConfig -> Config
fromFlags token fConf =
    { cognitoDomain = fConf.cognitoDomain
    , cognitoClientId = fConf.cognitoClientId
    , redirectUri = fConf.redirectUri
    , donorUrl = fConf.donorUrl
    , apiEndpoint = fConf.apiEndpoint
    , token = token
    }


toFlags : Config -> FlagConfig
toFlags config =
    { cognitoDomain = config.cognitoDomain
    , cognitoClientId = config.cognitoClientId
    , redirectUri = config.redirectUri
    , donorUrl = config.donorUrl
    , apiEndpoint = config.apiEndpoint
    , token = Just config.token
    }
