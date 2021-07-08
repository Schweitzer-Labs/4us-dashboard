module BankPaymentInfo exposing (Model, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, h4, h5, text)
import Html.Attributes exposing (class)
import LabelWithData exposing (dataLabel, dataText, labelWithData)
import PaymentMethod exposing (PaymentMethod, toDataString)



--- MODEL


type alias Model =
    { amount : String
    , date : String
    , paymentType : PaymentMethod
    , ruleVerified : Bool
    , bankVerified : Bool
    , verificationScore : String
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


labelWithPaymentMethodData : String -> PaymentMethod -> Html msg
labelWithPaymentMethodData label paymentMethod =
    div []
        [ dataLabel label
        , dataText <| toDataString paymentMethod
        ]


labelWithBankVerificationIcon : String -> Bool -> Html msg
labelWithBankVerificationIcon label verificationStatus =
    div []
        [ dataLabel label
        , statusContent verificationStatus
        ]


verificationInfoRow : Model -> List (Html msg)
verificationInfoRow model =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon "Rule Verified" model.ruleVerified ]
        , Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon "Bank Verified" model.bankVerified ]
        , Grid.col [ Col.md4 ] [ labelWithData "Verification Score" model.verificationScore ]
        ]
    ]


paymentInfoRow : Model -> List (Html msg)
paymentInfoRow model =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData "Amount" model.amount ]
        , Grid.col [ Col.md4 ] [ labelWithData "Date" model.date ]
        , Grid.col [ Col.md4 ] [ labelWithPaymentMethodData "Payment Type" model.paymentType ]
        ]
    ]



---- VIEW


view : Model -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Payment Info"
            ++ paymentInfoRow model
            ++ verificationInfoRow model
