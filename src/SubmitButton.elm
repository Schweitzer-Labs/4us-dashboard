module SubmitButton exposing (block, blockWithLoadingBar, custom, submitButton)

import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Html exposing (Attribute, Html, text)
import Html.Events exposing (onClick)
import List exposing (singleton)
import LoadingBar


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


block : List (Attribute msg) -> String -> msg -> Bool -> Bool -> Html msg
block attrs label submitMsg loading disabled =
    Button.button
        [ Button.outlinePrimary
        , Button.attrs <| onClick submitMsg :: attrs
        , Button.disabled disabled
        , Button.block
        ]
        [ if loading then
            spinner

          else
            text label
        ]


blockWithLoadingBar : List (Attribute msg) -> String -> msg -> Bool -> Int -> List (Html msg)
blockWithLoadingBar attrs label submitMsg isSubmitting progress =
    case isSubmitting of
        True ->
            LoadingBar.view True progress

        False ->
            singleton <| block attrs label submitMsg isSubmitting isSubmitting


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
