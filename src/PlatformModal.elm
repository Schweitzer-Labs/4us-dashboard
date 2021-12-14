module PlatformModal exposing (MakeModalConfig, view)

import Asset
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import DeleteInfo
import Html exposing (Html, h2, span, text)
import Html.Attributes as Attr exposing (attribute, class)
import Html.Events exposing (onClick)
import SubmitButton exposing (submitButton)


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
    , maybeDeleteMsg : Maybe msg
    , isDeleting : Bool
    , alertMsg : Maybe (Alert.Visibility -> msg)
    , alertVisibility : Maybe Alert.Visibility
    , isDeleteConfirmed : DeleteInfo.Model
    , id : String
    , cyId : String
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
            [ Attr.id config.id ]
            (if config.successViewActive then
                [ successMessage config.cyId config.successViewMessage ]

             else
                [ Html.map config.updateMsg <|
                    config.subView config.subModel
                ]
            )
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ DeleteInfo.deletionAlert config.alertMsg config.alertVisibility
                , if config.successViewActive then
                    successButtonRow config.cyId config.hideMsg

                  else
                    buttonRow
                        { submitText = config.submitText
                        , maybeDeleteMsg = config.maybeDeleteMsg
                        , submitting = config.isSubmitting
                        , enableExit = True
                        , disableSave = config.successViewActive
                        , disabled = config.isSubmitDisabled
                        , hideMsg = config.hideMsg
                        , submitMsg = config.submitMsg
                        , isDeleting = config.isDeleting
                        , isDeleteConfirmed = config.isDeleteConfirmed
                        , cyId = config.cyId
                        }
                ]
            ]
        |> Modal.view config.visibility


type alias ButtonRowConfig hideMsg submitMsg =
    { hideMsg : hideMsg
    , maybeDeleteMsg : Maybe hideMsg
    , submitText : String
    , submitMsg : submitMsg
    , submitting : Bool
    , enableExit : Bool
    , disableSave : Bool
    , disabled : Bool
    , isDeleting : Bool
    , isDeleteConfirmed : DeleteInfo.Model
    , cyId : String
    }


buttonRow : ButtonRowConfig msg msg -> Html msg
buttonRow config =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
          <|
            case ( config.enableExit, config.maybeDeleteMsg ) of
                ( True, Just deleteMsg ) ->
                    [ SubmitButton.delete config.cyId deleteMsg config.isDeleting config.isDeleteConfirmed ]

                ( True, Nothing ) ->
                    [ exitButton config.hideMsg ]

                _ ->
                    []
        , Grid.col
            [ Col.lg3 ]
            (if config.disableSave then
                []

             else
                [ submitButton config.cyId config.submitText config.submitMsg config.submitting config.disabled ]
            )
        ]


successButtonRow : String -> msg -> Html msg
successButtonRow cyId hideMsg =
    Grid.row
        [ Row.aroundXs ]
        [ Grid.col [ Col.offsetLg10 ]
            [ Button.button
                [ Button.outlinePrimary
                , Button.block
                , Button.attrs [ onClick hideMsg, attribute "data-cy" (cyId ++ "platformSucessOkBtn") ]
                ]
                [ text "OK" ]
            ]
        ]


exitButton : msg -> Html msg
exitButton hideMsg =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick hideMsg ]
        ]
        [ text "Exit" ]


successMessage : String -> String -> Html msg
successMessage cyId successViewMessage =
    h2 [ class "align-middle text-green", Spacing.p3 ]
        [ Asset.circleCheckGlyph []
        , span
            [ class "align-middle text-green"
            , Spacing.ml3
            , attribute "data-cy" (cyId ++ "platformSucessMessage")
            ]
            [ text <| successViewMessage ]
        ]
