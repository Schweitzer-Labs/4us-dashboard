module Session exposing (Session(..), build, setToken, toNavKey, toToken)

import Browser.Navigation as Nav



-- TYPES


type Session
    = LoggedIn Nav.Key String
    | LoggedOut Nav.Key



-- INFO


toToken : Session -> Maybe String
toToken session =
    case session of
        LoggedIn key token ->
            Just token

        LoggedOut key ->
            Nothing


toNavKey : Session -> Nav.Key
toNavKey session =
    case session of
        LoggedIn key _ ->
            key

        LoggedOut key ->
            key



-- CHANGES


build : Nav.Key -> Maybe String -> Session
build key maybeToken =
    case maybeToken of
        Just token ->
            LoggedIn key token

        Nothing ->
            LoggedOut key


setToken : String -> Session -> Session
setToken token session =
    LoggedIn (toNavKey session) token
