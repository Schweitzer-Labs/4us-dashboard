module SelectButton exposing (selectButton)

import Bootstrap.Button as Button
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)
import Html.Attributes exposing (class)


selectButton : (a -> msg) -> String -> a -> a -> Html msg
selectButton msg displayText value currentVal =
    let
        selected =
            currentVal == value

        color =
            if selected then
                Button.success

            else
                Button.secondary
    in
    Button.button
        [ color
        , Button.block
        , Button.attrs [ Spacing.mt4, Spacing.p2, class "font-weight-bold border-round" ]
        , Button.onClick (msg value)
        ]
        [ text <| displayText ]
