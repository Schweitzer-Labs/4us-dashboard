module AppInput exposing (inputDate, inputEmail, inputNumber, inputStyle, inputText)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Html exposing (Html, text)
import Html.Attributes exposing (attribute, class)


inputStyle : Bool -> String
inputStyle disabled =
    if disabled then
        ""

    else
        "border-top-0 border-left-0 border-right-0 rounded-0"


inputText : (String -> msg) -> String -> Bool -> String -> String -> Html msg
inputText msg val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.text
            [ Input.value val
            , Input.onInput msg
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id, class <| inputStyle disabled ]
            ]
        ]


inputEmail : (String -> msg) -> String -> Bool -> String -> String -> Html msg
inputEmail msg val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.email
            [ Input.value val
            , Input.onInput msg
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id, class <| inputStyle disabled ]
            ]
        ]


inputNumber : (String -> msg) -> String -> Bool -> String -> String -> Html msg
inputNumber msg val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.number
            [ Input.value val
            , Input.onInput msg
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id, class <| inputStyle disabled ]
            ]
        ]


inputDate : (String -> msg) -> String -> Bool -> String -> String -> Html msg
inputDate msg val disabled id label =
    Form.group []
        [ Form.label [] [ text label ]
        , Input.date
            [ Input.value val
            , Input.onInput msg
            , Input.disabled disabled
            , Input.attrs [ attribute "data-cy" id, class <| inputStyle disabled ]
            ]
        ]
