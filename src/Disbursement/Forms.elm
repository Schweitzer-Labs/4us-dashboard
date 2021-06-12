module Disbursement.Forms exposing (yesOrNoCol, yesOrNoRows)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


yesOrNoCol : String -> (Bool -> msg) -> Maybe Bool -> Column msg
yesOrNoCol question msg maybeState =
    let
        state =
            Maybe.withDefault "" <|
                Maybe.map
                    (\val ->
                        if val then
                            "yes"

                        else
                            "no"
                    )
                    maybeState
    in
    Grid.col
        []
    <|
        [ div [] [ text question ] ]
            ++ Radio.radioList question
                [ Radio.createCustom
                    [ Radio.id (question ++ "yes")
                    , Radio.inline
                    , Radio.onClick (msg True)
                    , Radio.checked (state == "yes")
                    , Radio.danger
                    ]
                    "Yes"
                , Radio.createCustom
                    [ Radio.id (question ++ "no")
                    , Radio.inline
                    , Radio.onClick (msg False)
                    , Radio.checked (state == "no")
                    , Radio.danger
                    ]
                    "No"
                ]


yesOrNoRows :
    (Bool -> msg)
    -> Maybe Bool
    -> (Bool -> msg)
    -> Maybe Bool
    -> (Bool -> msg)
    -> Maybe Bool
    -> Bool
    -> List (Html msg)
yesOrNoRows updateIsSubcontractedMsg updateIsSubcontractedState updateIsPartialPaymentMsg updateIsPartialPaymentState updateIsExistingLiabilityMsg updateIsExistingLiabilityState submitted =
    let
        anyBlank =
            updateIsSubcontractedState == Nothing || updateIsPartialPaymentState == Nothing || updateIsExistingLiabilityState == Nothing

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
