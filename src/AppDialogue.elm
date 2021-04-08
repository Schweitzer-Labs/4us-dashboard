module AppDialogue exposing (warning)

import Asset
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)


warning : Html msg -> Html msg
warning content =
    div
        [ class "border border-danger text-danger font-weight-bold shadow-sm rounded", Spacing.p3 ]
        [ Asset.exclamationCircleGlyph [ class "font-size-22" ]
        , span [ Spacing.ml3 ] [ content ]
        ]
