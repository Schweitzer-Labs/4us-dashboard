module Config.Env exposing (env)

import Config exposing (Config)



--env : Config
--env =
--    { apiEndpoint = "https://api.4usdemo.com"
--    , donorUrl = "https://donor.4usdemo.com"
--    }


env : Config
env =
    { apiEndpoint = "http://localhost:5000"
    , donorUrl = "http://localhost:3001"
    , loginUrl = \committeeId -> "https://platform-user.auth.us-east-1.amazoncognito.com/login?client_id=6bhp15ot1l2tqe849ikq06hvet&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=http://localhost:3000&state=" ++ committeeId
    }
