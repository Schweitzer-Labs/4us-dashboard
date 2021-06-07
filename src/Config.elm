module Config exposing (Config)


type alias Config =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    , donorUrl : String
    , apiEndpoint : String
    , token : String
    }
