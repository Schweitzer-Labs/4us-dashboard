module PlatformModal exposing (MakeModalConfig, view)

import Asset
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, h2, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import SubmitButton exposing (submitButton)
import TxnForm exposing (Model(..))


type alias MakeModalConfig msg subMsg subModel =
    { hideMsg : msg
    , animateMsg : Modal.Visibility -> msg
    , title : String
    , updateMsg : subMsg -> msg
    , subModel : subModel
    , subView : subModel -> Html subMsg
    , submitMsg : msg
    , submitText : String
    , isSubmitting : Bool
    , isSubmitDisabled : Bool
    , successViewActive : Bool
    , successViewMessage : String
    , visibility : Modal.Visibility
    }


view : MakeModalConfig msg subMsg model -> Html msg
view config =
    Modal.config config.hideMsg
        |> Modal.withAnimation config.animateMsg
        |> Modal.large
        |> Modal.scrollableBody True
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text config.title ]
        |> Modal.body
            []
            (if config.successViewActive then
                [ successMessage config.successViewMessage ]

             else
                [ Html.map config.updateMsg <|
                    config.subView config.subModel
                ]
            )
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow
                    { submitText = config.submitText
                    , submitting = config.isSubmitting
                    , enableExit = True
                    , disableSave = config.successViewActive
                    , disabled = config.isSubmitDisabled
                    , hideMsg = config.hideMsg
                    , submitMsg = config.submitMsg
                    }
                ]
            ]
        |> Modal.view config.visibility


type alias ButtonRowConfig hideMsg submitMsg =
    { hideMsg : hideMsg
    , submitText : String
    , submitMsg : submitMsg
    , submitting : Bool
    , enableExit : Bool
    , disableSave : Bool
    , disabled : Bool
    }


buttonRow : ButtonRowConfig msg msg -> Html msg
buttonRow config =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            (if config.enableExit then
                [ exitButton config.hideMsg ]

             else
                []
            )
        , Grid.col
            [ Col.lg3 ]
            (if config.disableSave then
                []

             else
                [ submitButton config.submitText config.submitMsg config.submitting config.disabled ]
            )
        ]


exitButton : msg -> Html msg
exitButton hideMsg =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick hideMsg ]
        ]
        [ text "Exit" ]


successMessage : String -> Html msg
successMessage successViewMessage =
    h2 [ class "align-middle text-green", Spacing.p3 ]
        [ Asset.circleCheckGlyph []
        , span
            [ class "align-middle text-green"
            , Spacing.ml3
            ]
            [ text <| successViewMessage ]
        ]
