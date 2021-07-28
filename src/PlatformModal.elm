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
    , mutationRespSucceeded : Bool
    , formType : TxnForm.Model
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
            (if config.mutationRespSucceeded then
                [ successMessage config.formType ]

             else
                [ Html.map config.updateMsg <|
                    config.subView config.subModel
                ]
            )
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow config.hideMsg config.submitText config.submitMsg config.isSubmitting True config.mutationRespSucceeded config.isSubmitDisabled ]
            ]
        |> Modal.view config.visibility


buttonRow : msg -> String -> msg -> Bool -> Bool -> Bool -> Bool -> Html msg
buttonRow hideMsg displayText msg submitting enableExit disableSave disabled =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            (if enableExit then
                [ exitButton hideMsg ]

             else
                []
            )
        , Grid.col
            [ Col.lg3 ]
            (if disableSave then
                []

             else
                [ submitButton displayText msg submitting disabled ]
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


successMessage : TxnForm.Model -> Html msg
successMessage formType =
    h2 [ class "align-middle text-green", Spacing.p3 ]
        [ Asset.circleCheckGlyph []
        , span
            [ class "align-middle text-green"
            , Spacing.ml3
            ]
            (case formType of
                DisbRuleVerified ->
                    [ text <| " Revised Disbursement Successful" ]

                DisbRuleUnverified ->
                    [ text <| " Reconciled Disbursement Successful" ]

                ContribRuleVerified ->
                    [ text <| " Revised Contribution Successful" ]

                ContribRuleUnverified ->
                    [ text <| " Reconciled Contribution Successful" ]

                NoOp ->
                    []
            )
        ]
