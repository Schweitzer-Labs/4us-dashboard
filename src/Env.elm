module Env exposing (Model(..), toEnv)

--TYPES


type Model
    = PROD
    | DEMO
    | QA
    | LOCAL



-- CHANGES


toEnv : String -> Maybe Model
toEnv str =
    case str of
        "prod" ->
            Just PROD

        "demo" ->
            Just DEMO

        "qa" ->
            Just QA

        "local" ->
            Just LOCAL

        _ ->
            Nothing
