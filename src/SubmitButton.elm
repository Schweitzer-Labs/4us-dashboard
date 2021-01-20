module SubmitButton exposing (submitButton)

import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Html exposing (Html, text)
import Html.Events exposing (onClick)


submitButton : String -> msg -> Bool -> Html msg
submitButton label submitMsg loading =
    Button.button
        [ Button.primary
        , Button.block
        , Button.attrs [ onClick submitMsg ]
        ]
        [ if loading then
            spinner

          else
            text label
        ]


spinner : Html msg
spinner =
    Spinner.spinner
        [ Spinner.small
        ]
        [ Spinner.srMessage "Loading..."
        ]
