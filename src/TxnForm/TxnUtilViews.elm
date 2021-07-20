module TxnForm.TxnUtilViews exposing (editHeader)

import Asset
import Bootstrap.Form as Form
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, span, text)
import Html.Attributes exposing (class, for)
import Html.Events exposing (onClick)


editHeader : Bool -> msg -> String -> Html msg
editHeader isEditable msg name =
    Form.label [ for "recipient-name" ]
        [ text name
        , if isEditable then
            span [ class "hover-underline hover-pointer", Spacing.ml2, onClick msg ] [ Asset.editGlyph [] ]

          else
            span [] []
        ]
