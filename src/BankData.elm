module BankData exposing (Model, view)

import BankIdHeader exposing (BankData)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, h5, text)
import LabelWithData exposing (dataLabel, dataText, labelWithData, labelWithDescriptionData)
import PaymentMethod exposing (PaymentMethod, toDataString)



--- Model ---


type alias PaymentData =
    { postedDate : String
    , paymentType : PaymentMethod
    }


type alias Model =
    { bankData : BankData
    , paymentData : PaymentData
    }


formLabelRow : String -> List (Html msg)
formLabelRow str =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ h5 [] [ text str ] ] ]
    ]


labelWithPaymentMethodData : String -> PaymentMethod -> Html msg
labelWithPaymentMethodData label paymentMethod =
    div []
        [ dataLabel label
        , dataText <| toDataString paymentMethod
        ]


bankInfoRows : BankData -> List (Html msg)
bankInfoRows data =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData "Analyzed Payee Name" data.analyzedPayeeName ]
        , Grid.col [ Col.md4, Col.offsetMd3 ] [ labelWithData "Analyzed Category" data.analyzedCategory ]
        ]
    , Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithDescriptionData "Description" data.description ] ]
    ]


paymentInfoRow : PaymentData -> List (Html msg)
paymentInfoRow data =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData "Posted Date" data.postedDate ]
        , Grid.col [ Col.md4 ] [ labelWithPaymentMethodData "Payment Type" data.paymentType ]
        ]
    ]


view : Model -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Payment Info"
            ++ bankInfoRows model.bankData
            ++ paymentInfoRow model.paymentData
