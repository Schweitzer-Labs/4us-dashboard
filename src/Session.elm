module Session exposing (Session, fromViewer, navKey, viewer)

import Browser.Navigation as Nav



-- TYPES


type Session
    = LoggedIn Nav.Key String



-- INFO


viewer : Session -> String
viewer (LoggedIn key token) =
    token


navKey : Session -> Nav.Key
navKey (LoggedIn key _) =
    key



-- CHANGES


fromViewer : Nav.Key -> String -> Session
fromViewer key token =
    LoggedIn key token
