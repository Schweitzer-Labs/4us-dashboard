module Route exposing (Route(..), fragmentToQuery, fromUrl, href, replaceUrl, routeToString)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url.Parser.Query as Query



-- ROUTING


type Route
    = Home (Maybe String) (Maybe String)
    | LinkBuilder String
    | Transactions String
    | Demo String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home (Parser.top <?> Query.string "id_token" <?> Query.string "state")
        , Parser.map Transactions (s "committee" </> string)
        , Parser.map LinkBuilder (s "committee" </> string </> s "link-builder")
        , Parser.map Demo (s "committee" </> string </> s "demo")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl =
    fragmentToQuery >> Parser.parse parser


routeToString : Route -> String
routeToString page =
    "/" ++ String.join "/" (routeToPieces page)


fragmentToQuery : Url -> Url
fragmentToQuery url =
    { protocol = url.protocol
    , host = url.host
    , port_ = url.port_
    , path = url.path
    , query = Maybe.map2 (\a b -> a ++ "&" ++ b) url.query url.fragment
    , fragment = url.fragment
    }


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Transactions id ->
            [ "committee", id ]

        LinkBuilder id ->
            [ "committee", id, "link-builder" ]

        Demo id ->
            [ "committee", id, "demo" ]

        _ ->
            []
