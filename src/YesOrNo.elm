module YesOrNo exposing (yesOrNo)

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import DataMsg exposing (toData, toMsg)
import Html exposing (Html, div, text)
import Html.Attributes exposing (attribute, class)


yesOrNo : String -> String -> DataMsg.MsgMaybeBool msg -> Maybe String -> Bool -> Column msg
yesOrNo cyId question data txnID disabled =
    let
        bool =
            toData data

        state =
            radioState bool

        msg =
            toMsg data

        id =
            Maybe.withDefault "" txnID
    in
    Grid.col
        []
        [ Form.form []
            [ Fieldset.config
                |> Fieldset.asGroup
                |> Fieldset.legend [ class "font-size-18" ] [ text question ]
                |> Fieldset.children
                    (Radio.radioList "radios"
                        [ Radio.createCustomAdvanced
                            [ Radio.id (id ++ question ++ "yes")
                            , Radio.inline
                            , Radio.onClick (msg <| Just True)
                            , Radio.checked <| "Yes" == state
                            , Radio.disabled disabled
                            ]
                            (Radio.label [ attribute "data-cy" (cyId ++ "yes") ] [ text "Yes" ])
                        , Radio.createCustomAdvanced
                            [ Radio.id (id ++ question ++ "no")
                            , Radio.inline
                            , Radio.onClick (msg <| Just False)
                            , Radio.checked <| "No" == state
                            , Radio.disabled disabled
                            ]
                            (Radio.label [ attribute "data-cy" (cyId ++ "no") ] [ text "No" ])
                        ]
                    )
                |> Fieldset.view
            ]
        ]


radioState : Maybe Bool -> String
radioState maybeBool =
    case maybeBool of
        Just bool ->
            case bool of
                True ->
                    "Yes"

                False ->
                    "No"

        Nothing ->
            ""
