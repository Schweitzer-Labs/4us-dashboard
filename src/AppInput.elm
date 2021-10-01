module AppInput exposing (inputEmail, inputNumber, inputText)

import Bootstrap.Form.Input as Input
import Html exposing (Html)
import Html.Attributes exposing (attribute)


inputText : (String -> msg) -> String -> String -> Bool -> String -> Html msg
inputText msg placeholder val disabled id =
    Input.text
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        , Input.attrs [ attribute "data-cy" id ]
        ]


inputEmail : (String -> msg) -> String -> String -> Bool -> String -> Html msg
inputEmail msg placeholder val disabled id =
    Input.email
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        , Input.attrs [ attribute "data-cy" id ]
        ]


inputNumber : (String -> msg) -> String -> String -> Bool -> String -> Html msg
inputNumber msg placeholder val disabled id =
    Input.number
        [ Input.value val
        , Input.onInput msg
        , Input.placeholder placeholder
        , Input.disabled disabled
        , Input.attrs [ attribute "data-cy" id ]
        ]
