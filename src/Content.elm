module Content exposing (container)

import Bootstrap.Grid as Grid
import Html exposing (Attribute, Html)
import Html.Attributes exposing (class)


container : List (Attribute msg) -> List (Html msg) -> Html msg
container attr content =
    Grid.containerFluid
        ([ class "content-container border-left" ] ++ attr)
        [ Grid.row
            []
            [ Grid.col [] content
            ]
        ]
