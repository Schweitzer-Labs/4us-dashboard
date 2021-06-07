module Disbursement.Forms exposing (yesOrNoCol, yesOrNoRows)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


yesOrNoCol : String -> (String -> msg) -> String -> Column msg
yesOrNoCol question msg state =
    Grid.col
        []
    <|
        [ div [] [ text question ] ]
            ++ Radio.radioList question
                [ Radio.createCustom
                    [ Radio.id (question ++ "yes")
                    , Radio.inline
                    , Radio.onClick (msg "yes")
                    , Radio.checked (state == "yes")
                    , Radio.danger
                    ]
                    "Yes"
                , Radio.createCustom
                    [ Radio.id (question ++ "no")
                    , Radio.inline
                    , Radio.onClick (msg "no")
                    , Radio.checked (state == "no")
                    , Radio.danger
                    ]
                    "No"
                ]


yesOrNoRows :
    (String -> msg)
    -> String
    -> (String -> msg)
    -> String
    -> (String -> msg)
    -> String
    -> Bool
    -> List (Html msg)
yesOrNoRows updateIsSubcontractedMsg updateIsSubcontractedState updateIsPartialPaymentMsg updateIsPartialPaymentState updateIsExistingLiabilityMsg updateIsExistingLiabilityState submitted =
    let
        anyBlank =
            updateIsSubcontractedState == "" || updateIsPartialPaymentState == "" || updateIsExistingLiabilityState == ""

        errorRowsOrBlank =
            if anyBlank && submitted then
                errorRows "Please answer the following questions:"

            else
                errorRows ""
    in
    errorRowsOrBlank
        ++ [ Grid.row
                []
                [ yesOrNoCol "Is expenditure subcontracted?" updateIsSubcontractedMsg updateIsSubcontractedState
                , yesOrNoCol "Is expenditure a partial payment?" updateIsPartialPaymentMsg updateIsPartialPaymentState
                , yesOrNoCol "Is this an existing Liability?" updateIsExistingLiabilityMsg updateIsExistingLiabilityState
                ]
           ]


errorRows : String -> List (Html msg)
errorRows message =
    [ Grid.row
        []
        [ Grid.col
            [ Col.attrs [ class "text-danger" ] ]
            [ text message ]
        ]
    ]
