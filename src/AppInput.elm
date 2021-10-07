module AppInput exposing (inputDate, inputEmail, inputNumber, inputText)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (Html, text)
import Html.Attributes exposing (attribute)


inputText : (String -> msg) -> String -> String -> Bool -> String -> String -> Html msg
inputText msg placeholder val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.text
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id ]
            ]
        ]


inputEmail : (String -> msg) -> String -> String -> Bool -> String -> String -> Html msg
inputEmail msg placeholder val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.email
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id ]
            ]
        ]


inputNumber : (String -> msg) -> String -> String -> Bool -> String -> String -> Html msg
inputNumber msg placeholder val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.number
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id ]
            ]
        ]


inputDate : (String -> msg) -> String -> String -> Bool -> String -> String -> Html msg
inputDate msg placeholder val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.date
            [ Input.value val
            , Input.onInput msg
            , Input.placeholder placeholder
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id ]
            ]
        ]
