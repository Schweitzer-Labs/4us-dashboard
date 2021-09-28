module AppInput exposing (inputEmail, inputNumber, inputText)

import Bootstrap.Form.Input as Input
import Html exposing (Html)


inputText : (String -> msg) -> String -> String -> Bool -> Html msg
inputText msg placeholder val disabled =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        ]


inputEmail : (String -> msg) -> String -> String -> Bool -> Html msg
inputEmail msg placeholder val disabled =
    Input.email
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        ]


inputNumber : (String -> msg) -> String -> String -> Bool -> Html msg
inputNumber msg placeholder val disabled =
    Input.number
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        ]
