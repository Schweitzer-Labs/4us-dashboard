module LoadingBar exposing (view)

import Bootstrap.Progress as Progress
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


progressToPercent : Int -> String
progressToPercent val =
    String.fromInt val ++ "%"


view : Bool -> Int -> List (Html msg)
view isSubmitting progress =
    case isSubmitting of
        True ->
            let
                fixedProg =
                    if progress >= 100 then
                        99

                    else
                        progress
            in
            [ Progress.progress
                [ Progress.attrs [ Spacing.mt1, Spacing.mb1 ]
                , Progress.value <| toFloat fixedProg
                , Progress.label <| progressToPercent fixedProg
                , Progress.striped
                , Progress.attrs [ class "rounded" ]
                , Progress.wrapperAttrs [ Spacing.mt3, class "height-md" ]
                ]
            ]

        False ->
            []
