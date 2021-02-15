module Config exposing (Config)


type alias Config =
    { apiEndpoint : String
    , donorUrl : String
    , loginUrl : String -> String
    }
