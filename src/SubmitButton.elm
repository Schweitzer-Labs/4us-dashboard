module SubmitButton exposing (block, blockWithLoadingBar, custom, delete, submitButton)

import Asset
import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Bootstrap.Utilities.Spacing as Spacing
import DeleteInfo
import Html exposing (Attribute, Html, text)
import Html.Attributes exposing (attribute)
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


delete : String -> msg -> Bool -> DeleteInfo.Model -> Html msg
delete cyId submitMsg isSending isDeleteConfirmed =
    Button.button
        [ Button.outlineDanger
        , Button.onClick submitMsg
        , Button.disabled isSending
        , Button.block
        , Button.attrs [ attribute "data-cy" (cyId ++ "deleteButton") ]
        ]
        [ if isSending then
            spinner

          else
            text "Delete"
        , case isDeleteConfirmed of
            DeleteInfo.Confirmed ->
                Asset.lockOpenGlyph [ Spacing.ml2, Spacing.mb1 ]

            DeleteInfo.Unconfirmed ->
                Asset.lockGlyph [ Spacing.ml2, Spacing.mb1 ]

            DeleteInfo.Uninitialized ->
                Asset.lockGlyph [ Spacing.ml2, Spacing.mb1 ]
        ]


blockWithLoadingBar : List (Attribute msg) -> String -> msg -> Bool -> Int -> List (Html msg)
blockWithLoadingBar attrs label submitMsg isSubmitting progress =
    case isSubmitting of
        True ->
            LoadingBar.view True progress

        False ->
            singleton <| block attrs label submitMsg isSubmitting isSubmitting


submitButton : String -> String -> msg -> Bool -> Bool -> Html msg
submitButton cyId label submitMsg loading disabled =
    Button.button
        [ Button.success
        , Button.block
        , Button.attrs [ onClick submitMsg, attribute "data-cy" (cyId ++ "submitButton") ]
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
