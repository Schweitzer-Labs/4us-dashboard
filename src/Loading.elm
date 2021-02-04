module Loading exposing (error, icon, slowThreshold, view)

{-| A loading spinner icon.
-}

import Asset
import Bootstrap.Spinner as Spinner
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (alt, class, height, src, width)
import Process
import Task exposing (Task)


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


icon : Html msg
icon =
    Html.img
        [ Asset.src Asset.loading
        , width 64
        , height 64
        , alt "Loading..."
        ]
        []


error : String -> Html msg
error str =
    Html.text ("Error loading " ++ str ++ ".")


slowThreshold : Task x ()
slowThreshold =
    Process.sleep 500
