module Config.Env exposing (env)

import Config exposing (Config)



--env : Config
--env =
--    { apiEndpoint = "https://api.4usdemo.com"
--    , donorUrl = "https://donor.4usdemo.com"
--    , loginUrl = \committeeId -> "https://platform-user.auth.us-east-1.amazoncognito.com/login?client_id=28rfo8p9m1qkocimbnsm3ilhrs&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=https://committee.4usdemo.com&state=" ++ committeeId
--    }


env : Config
env =
    { apiEndpoint = "http://localhost:5000"
    , donorUrl = "http://localhost:3001"
    , loginUrl = \committeeId -> "https://4us-demo-committee-api-user.auth.us-east-1.amazoncognito.com/login?client_id=5edttkv3teplb003a5ljhqe4lv&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=http://localhost:3000&state=" ++ committeeId
    }
