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
    }
