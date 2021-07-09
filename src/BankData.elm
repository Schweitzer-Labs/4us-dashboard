module BankData exposing (Model, view)

import BankIdHeader exposing (BankData)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, h5, h6, text)
import LabelWithData exposing (labelWithData, labelWithDescriptionData)
import PaymentMethod exposing (PaymentMethod)



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
        [ Grid.col [ Col.md4 ] [ h6 [] [ text str ] ] ]
    ]


bankInfoRows : BankData -> List (Html msg)
bankInfoRows data =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithData "Analyzed Payee Name" data.analyzedPayeeName ]
        , Grid.col [ Col.md4, Col.offsetLg3 ] [ labelWithData "Analyzed Category" data.analyzedCategory ]
        ]
    , Grid.row []
        [ Grid.col [ Col.attrs [ Spacing.mt2, Spacing.ml2 ] ] [ labelWithDescriptionData "Description" data.description ] ]
    , Grid.row []
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.mt2, Spacing.ml2 ] ] [ labelWithData "Initiated Date" data.analyzedTransactionDate ]
        ]
    ]


paymentInfoRow : PaymentData -> List (Html msg)
paymentInfoRow data =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithData "Posted Date" data.postedDate ]
        , Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithData "Payment Type" <| PaymentMethod.toDisplayString data.paymentType ]
        ]
    ]


view : Model -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Bank Data"
            ++ bankInfoRows model.bankData
            ++ paymentInfoRow model.paymentData
