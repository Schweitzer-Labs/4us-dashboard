module Config exposing (Model, toApiEndpoint)


type alias Model =
    { cognitoDomain : String
    , cognitoClientId : String
    , redirectUri : String
    , donorUrl : String
    , apiEndpoint : String
    }


toApiEndpoint : Model -> String
toApiEndpoint model =
    model.apiEndpoint
