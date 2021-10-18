module ViewportHeight exposing (..)

import FormID exposing (Model(..))


bottom : Float
bottom =
    0


middle : Float
middle =
    400


top : Float
top =
    800


idToViewHeight : String -> Float
idToViewHeight id =
    case FormID.fromString id of
        Just CreateContrib ->
            bottom

        Just ReconcileContrib ->
            middle

        Just AmendContrib ->
            top

        _ ->
            bottom
