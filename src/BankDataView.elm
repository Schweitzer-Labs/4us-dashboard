module BankDataView exposing (MakeBankDataConfig, view)

import BankIdHeaderView exposing (BankData)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, h5, text)
import LabelWithData exposing (dataLabel, dataText, labelWithData, labelWithDescriptionData)
import PaymentMethod exposing (PaymentMethod, toDataString)



--- Model ---


type alias PaymentData =
    { postedDate : ( String, String )
    , paymentType : ( String, PaymentMethod )
    }


type alias MakeBankDataConfig =
    { bankData : BankData
    , paymentData : PaymentData
    }


formLabelRow : String -> List (Html msg)
formLabelRow str =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ h5 [] [ text str ] ] ]
    ]


labelWithPaymentMethodData : ( String, PaymentMethod ) -> Html msg
labelWithPaymentMethodData ( label, paymentMethod ) =
    div []
        [ dataLabel label
        , dataText <| toDataString paymentMethod
        ]


bankInfoRow : BankData -> List (Html msg)
bankInfoRow data =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData data.analyzedPayeeName ]
        , Grid.col [ Col.md4, Col.offsetMd3 ] [ labelWithData data.analyzedCategory ]
        ]
    , Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithDescriptionData data.description ] ]
    ]


paymentInfoRow : PaymentData -> List (Html msg)
paymentInfoRow data =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData data.postedDate ]
        , Grid.col [ Col.md4 ] [ labelWithPaymentMethodData data.paymentType ]
        ]
    ]


view : MakeBankDataConfig -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Payment Info"
            ++ bankInfoRow model.bankData
            ++ paymentInfoRow model.paymentData
