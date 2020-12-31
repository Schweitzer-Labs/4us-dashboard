module Content exposing(container)

import Bootstrap.Grid as Grid
import Html exposing (Html)
import Html.Attributes exposing (class)

container : Html msg -> Html msg
container content =
    Grid.containerFluid
        [class "content-container"]
        [ content ]
