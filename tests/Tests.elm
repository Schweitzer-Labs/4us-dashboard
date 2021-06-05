module Tests exposing (all)

import Expect
import PurposeCode as PurposeCode exposing (PurposeCode)
import Test exposing (..)



-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Purpose " <|
            \_ ->
                Expect.equal "TVADS" (PurposeCode.purposeToString PurposeCode.TVADS)
        ]
