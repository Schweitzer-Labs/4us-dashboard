module BankData exposing (Model, view)

import BankIdHeader exposing (BankData)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, h5, h6, text)
import LabelWithData exposing (labelWithData, labelWithMaybeData, labelWithMaybeTimeData, labelWithTimeData)
import PaymentMethod exposing (PaymentMethod)
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction



--- Model ---


type alias Model =
    Transaction.Model


formLabelRow : String -> List (Html msg)
formLabelRow str =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ h6 [] [ text str ] ] ]
    ]


bankInfoRows : Model -> List (Html msg)
bankInfoRows data =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithMaybeData "Analyzed Payee Name" data.finicityNormalizedPayeeName ]
        , Grid.col [ Col.md4, Col.offsetLg3 ] [ labelWithMaybeData "Analyzed Category" data.finicityCategory ]
        ]
    , Grid.row []
        [ Grid.col [ Col.attrs [ Spacing.mt2, Spacing.ml2 ] ] [ labelWithMaybeData "Description" data.finicityDescription ] ]
    , Grid.row []
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.mt2, Spacing.ml2 ] ] [ labelWithMaybeTimeData "Initiated Date" data.finicityTransactionDate ]
        ]
    ]


paymentInfoRow : Model -> List (Html msg)
paymentInfoRow data =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithTimeData "Posted Date" <| data.initiatedTimestamp ]
        , Grid.col [ Col.md4, Col.attrs [ Spacing.ml2 ] ] [ labelWithData "Payment Type" <| PaymentMethod.toDisplayString data.paymentMethod ]
        ]
    ]


view : Model -> Html msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Bank Data"
            ++ bankInfoRows model
            ++ paymentInfoRow model
