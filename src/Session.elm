module Session exposing (Session, changes, cred, fromViewer, navKey, viewer, committeeId)

import Api exposing (Cred)
import Browser.Navigation as Nav
import Viewer exposing (Viewer)


-- TYPES


type Session
    = LoggedIn Nav.Key Viewer
    | Guest Nav.Key


-- INFO


viewer : Session -> Maybe Viewer
viewer session =
    case session of
        LoggedIn _ val ->
            Just val

        Guest _ ->
            Nothing


cred : Session -> Maybe Cred
cred session =
    case session of
        LoggedIn _ val ->
            Just (Viewer.cred val)

        Guest _ ->
            Nothing


navKey : Session -> Nav.Key
navKey session =
    case session of
        LoggedIn key _ ->
            key

        Guest key ->
            key



-- CHANGES


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    Api.viewerChanges (\maybeViewer -> toMsg (fromViewer key maybeViewer)) Viewer.decoder


fromViewer : Nav.Key -> Maybe Viewer -> Session
fromViewer key maybeViewer =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    case maybeViewer of
        Just viewerVal ->
            LoggedIn key viewerVal

        Nothing ->
            Guest key

committeeId : String
committeeId = "dc551f13-dc27-4ca5-8533-60000fdfc9eb"
