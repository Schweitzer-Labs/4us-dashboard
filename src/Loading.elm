module Loading exposing (view)

{-| A loading spinner icon.
-}

import Bootstrap.Spinner as Spinner
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class)


spinner : Html msg
spinner =
    Spinner.spinner
        [ Spinner.large
        , Spinner.color Text.primary
        , Spinner.attrs [ class "opacity-light" ]
        ]
        [ Spinner.srMessage "Loading..."
        ]


view : Html msg
view =
    div [ class "text-center", Spacing.mt5 ] [ spinner ]
