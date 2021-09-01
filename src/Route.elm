module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING


type Route
    = Home
    | LinkBuilder String
    | Transactions String
    | Demo String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Transactions (s "committee" </> string)
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
    Parser.parse parser



-- INTERNAL


routeToString : Route -> String
routeToString page =
    "/" ++ String.join "/" (routeToPieces page)


routeToPieces : Route -> List String
routeToPieces page =
    case page of
        Home ->
            []

        Transactions id ->
            [ "committee", id ]

        LinkBuilder id ->
            [ "committee", id, "link-builder" ]

        Demo id ->
            [ "committee", id, "demo" ]
