module SelectRadio exposing (view)

import Bootstrap.Form.Radio as Radio exposing (Radio)


view : (String -> msg) -> String -> String -> String -> Bool -> Radio msg
view msg dataValue displayValue currentValue disabled =
    Radio.createCustom
        [ Radio.id displayValue
        , Radio.inline
        , Radio.onClick (msg dataValue)
        , Radio.checked (currentValue == dataValue)
        , Radio.disabled disabled
        ]
        displayValue
