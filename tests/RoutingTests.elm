module RoutingTests exposing (..)

import Expect exposing (Expectation)
import Json.Decode as Decode exposing (decodeString)
import Route exposing (Route(..))
import Test exposing (..)
import Url exposing (Url)
import Username exposing (Username)


-- TODO need to add lots more tests!


fromUrl : Test
fromUrl =
    describe "Route.fromUrl"
        [ testUrl "" Home
        , testUrl "link-builder" LinkBuilder
        , testUrl "disbursements" Disbursements
        , testUrl "needs-review" NeedsReview
        ]



-- HELPERS


testUrl : String -> Route -> Test
testUrl hash route =
    test ("Parsing hash: \"" ++ hash ++ "\"") <|
        \() ->
            fragment hash
                |> Route.fromUrl
                |> Expect.equal (Just route)


fragment : String -> Url
fragment frag =
    { protocol = Url.Http
    , host = "foo.com"
    , port_ = Nothing
    , path = "bar"
    , query = Nothing
    , fragment = Just frag
    }


