module Cognito exposing (loginUrl)


loginUrl : String -> String -> String -> String -> String
loginUrl cognitoDomain cognitoClientId redirectUri committeeId =
    cognitoDomain ++ "/login?client_id=" ++ cognitoClientId ++ "&response_type=token&scope=email+openid+profile&redirect_uri=" ++ redirectUri ++ "&state=" ++ committeeId
