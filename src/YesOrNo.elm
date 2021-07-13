module YesOrNo exposing (errorRows, view, yesOrNoCol)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import DataMsg exposing (toData, toMsg)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)


type alias Config msg =
    { isSubcontracted : DataMsg.MsgMaybeBool msg
    , isPartialPayment : DataMsg.MsgMaybeBool msg
    , isExistingLiability : DataMsg.MsgMaybeBool msg
    , isInKind : DataMsg.MsgMaybeBool msg
    , disabled : Bool
    }


view : Config msg -> List (Html msg)
view { isSubcontracted, isPartialPayment, isExistingLiability, isInKind, disabled } =
    --let
    --    anyBlank =
    --        updateIsSubcontractedState == Nothing || updateIsPartialPaymentState == Nothing || updateIsExistingLiabilityState == Nothing
    --in
    [ Grid.row
        []
        [ yesOrNoCol "Is expenditure subcontracted?" (toMsg isSubcontracted) (toData isSubcontracted) disabled
        , yesOrNoCol "Is expenditure a partial payment?" (toMsg isPartialPayment) (toData isPartialPayment) disabled
        , yesOrNoCol "Is this an existing Liability?" (toMsg isExistingLiability) (toData isExistingLiability) disabled
        , yesOrNoCol "Is this an In-Kind payment?" (toMsg isInKind) (toData isInKind) disabled
        ]
    ]


yesOrNoCol : String -> (Maybe Bool -> msg) -> Maybe Bool -> Bool -> Column msg
yesOrNoCol question msg maybeState disabled =
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
                    , Radio.onClick (msg <| Just True)
                    , Radio.checked (state == "yes")
                    , Radio.danger
                    , Radio.disabled disabled
                    ]
                    "Yes"
                , Radio.createCustom
                    [ Radio.id (question ++ "no")
                    , Radio.inline
                    , Radio.onClick (msg <| Just False)
                    , Radio.checked (state == "no")
                    , Radio.danger
                    , Radio.disabled disabled
                    ]
                    "No"
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
