module Session exposing (Model(..), build, setToken, toNavKey, toToken)

import Browser.Navigation as Nav



-- TYPES


type Model
    = LoggedIn Nav.Key String
    | LoggedOut Nav.Key



-- INFO


toToken : Model -> Maybe String
toToken session =
    case session of
        LoggedIn key token ->
            Just token

        LoggedOut key ->
            Nothing


toNavKey : Model -> Nav.Key
toNavKey session =
    case session of
        LoggedIn key _ ->
            key

        LoggedOut key ->
            key



-- CHANGES


build : Nav.Key -> Maybe String -> Model
build key maybeToken =
    case maybeToken of
        Just token ->
            LoggedIn key token

        Nothing ->
            LoggedOut key


setToken : String -> Model -> Model
setToken token session =
    LoggedIn (toNavKey session) token
