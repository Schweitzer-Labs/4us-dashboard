module BankPaymentInfoView exposing (MakeBankPaymentInfoConfig, view)

import AppLabelWithData exposing (dataLabel, dataText, labelWithData)
import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, h4, h5, text)
import Html.Attributes exposing (class)
import PaymentMethod exposing (PaymentMethod, toDataString)



--- MODEL


type alias MakeBankPaymentInfoConfig =
    { amount : ( String, String )
    , date : ( String, String )
    , paymentType : ( String, PaymentMethod )
    , ruleVerified : ( String, Bool )
    , bankVerified : ( String, Bool )
    , verificationScore : ( String, String )
    }


statusContent : Bool -> Html msg
statusContent val =
    if val then
        Asset.circleCheckGlyph [ class "text-green data-icon-size" ]

    else
        Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]


formLabelRow : String -> List (Html msg)
formLabelRow str =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ h5 [] [ text str ] ] ]
    ]



--- Todo refactor branching logic here


labelWithPaymentMethodData : ( String, PaymentMethod ) -> Html msg
labelWithPaymentMethodData ( label, paymentMethod ) =
    div []
        [ dataLabel label
        , dataText <| toDataString paymentMethod
        ]


labelWithBankVerificationIcon : ( String, Bool ) -> Html msg
labelWithBankVerificationIcon ( label, verificationStatus ) =
    div []
        [ dataLabel label
        , statusContent verificationStatus
        ]


verificationInfoRow : MakeBankPaymentInfoConfig -> List (Html msg)
verificationInfoRow model =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon model.ruleVerified ]
        , Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon model.bankVerified ]
        , Grid.col [ Col.md4 ] [ labelWithData model.verificationScore ]
        ]
    ]


paymentInfoRow : MakeBankPaymentInfoConfig -> List (Html msg)
paymentInfoRow model =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData model.amount ]
        , Grid.col [ Col.md4 ] [ labelWithData model.date ]
        , Grid.col [ Col.md4 ] [ labelWithPaymentMethodData model.paymentType ]
        ]
    ]



---- VIEW


view : MakeBankPaymentInfoConfig -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Payment Info"
            ++ paymentInfoRow model
            ++ verificationInfoRow model
