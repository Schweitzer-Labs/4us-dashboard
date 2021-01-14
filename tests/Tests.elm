module Tests exposing (..)

import Test exposing (..)
import Expect
import Purpose as Purpose


-- Check out https://package.elm-lang.org/packages/elm-explorations/test/latest to learn more about testing in Elm!


all : Test
all =
    describe "A Test Suite"
        [ test "Purpose " <|
            \_ ->
                Expect.equal "TVADS" (Purpose.purposeToString Purpose.TVADS)
        ]
