module SelectRadio exposing (view)

import Bootstrap.Form.Radio as Radio exposing (Radio)


view : (String -> msg) -> String -> String -> String -> Radio msg
view msg dataValue displayValue currentValue =
    Radio.createCustom
        [ Radio.id displayValue
        , Radio.inline
        , Radio.onClick (msg dataValue)
        , Radio.checked (currentValue == dataValue)
        ]
        displayValue
