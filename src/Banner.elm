module Banner exposing (container)

import Bootstrap.Grid as Grid
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html)
import Html.Attributes exposing (class)


container : List (Attribute msg) -> List (Html msg) -> Html msg
container attr content =
    Grid.containerFluid
        ([ class "banner-container bg-slate-blue text-white font-weight-bold", Spacing.mt0 ] ++ attr)
        content
