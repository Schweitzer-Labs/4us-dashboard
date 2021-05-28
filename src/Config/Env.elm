module Config.Env exposing (env)

import Config exposing (Config)



--env : Config
--env =
--    { apiEndpoint = "https://api.4usdemo.com"
--    , donorUrl = "https://donor.4usdemo.com"
--    , loginUrl = \committeeId -> "https://platform-user.auth.us-east-1.amazoncognito.com/login?client_id=28rfo8p9m1qkocimbnsm3ilhrs&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=https://committee.4usdemo.com&state=" ++ committeeId
--    }


clientId =
    "278u1u3mahq6psc3bi877iac4d"


loginBaseUrl =
    "https://platform-user.auth.us-west-2.amazoncognito.com/login"


appUrl =
    "http://localhost:3000"


env : Config
env =
    { apiEndpoint = "http://localhost:8010/proxy"
    , donorUrl = "http://localhost:3001"
    , loginUrl = \committeeId -> "https://platform-user.auth.us-west-2.amazoncognito.com/login?client_id=7m2eek97td4smg2svd15mvq96j&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=http://localhost:3000&state=907b427a-f8a9-450b-9d3c-33d8ec4a4cc4"
    }



--fn =
--    \committeeId ->
--        loginBaseUrls
--            ++ "?client_id="
--            ++ clientId
--            ++ "&response_type=token"
--            ++ "&scope=email+openid+phone+profile"
--            ++ "&redirect_uri="
--            ++ appUrl
--            ++ "&state="
--            ++ committeeId
