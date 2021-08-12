module SubmitButton exposing (custom, submitButton)

import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Html exposing (Attribute, Html, text)
import Html.Events exposing (onClick)
import List exposing (concat)


custom : List (Attribute msg) -> String -> msg -> Bool -> Bool -> Html msg
custom attrs label submitMsg loading disabled =
    Button.button
        [ Button.outlinePrimary
        , Button.attrs <| onClick submitMsg :: attrs
        , Button.disabled disabled
        ]
        [ if loading then
            spinner

          else
            text label
        ]


submitButton : String -> msg -> Bool -> Bool -> Html msg
submitButton label submitMsg loading disabled =
    Button.button
        [ Button.success
        , Button.block
        , Button.attrs [ onClick submitMsg ]
        , Button.disabled disabled
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
