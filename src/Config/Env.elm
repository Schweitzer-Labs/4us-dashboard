module Config.Env exposing (apiEndpoint, cognitoClientId, cognitoDomain, donorUrl, loginUrl, redirectUri)


cognitoDomain : String
cognitoDomain =
    "https://platform-user-p2-qa.auth.us-west-2.amazoncognito.com"


cognitoClientId : String
cognitoClientId =
    "6lu9jttlb740s8abf2683583b"


redirectUri : String
redirectUri =
    "http://localhost:3000"


donorUrl : String
donorUrl =
    "http://localhost:3001"


loginUrl : String -> String
loginUrl =
    \committeeId -> cognitoDomain ++ "/login?client_id=" ++ cognitoClientId ++ "&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=" ++ redirectUri ++ "&state=" ++ committeeId


apiEndpoint : String
apiEndpoint =
    "http://localhost:8010/proxy"
