module AppInput exposing (inputEmail, inputMonth, inputNumber, inputText)

import Bootstrap.Form.Input as Input
import Html exposing (Html)


inputNumber : (String -> msg) -> String -> String -> Html msg
inputNumber msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputMonth : (String -> msg) -> String -> String -> Html msg
inputMonth msg placeholder val =
    Input.month
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputText : (String -> msg) -> String -> String -> Html msg
inputText msg placeholder val =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]


inputEmail : (String -> msg) -> String -> String -> Html msg
inputEmail msg placeholder val =
    Input.email
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        ]
