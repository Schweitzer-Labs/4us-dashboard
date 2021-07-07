module BankData exposing (MakeBankDataConfig, view)

import BankIdHeader exposing (BankData)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html)
import LabelWithData exposing (labelWithData)
import PaymentMethod exposing (PaymentMethod)



--- Model ---


type alias PaymentData =
    { postedDate : String
    , paymentType : PaymentMethod
    }


type alias MakeBankDataConfig =
    { bankData : BankData
    , paymentDate : PaymentData
    }


bankInfoRow : BankData -> List (Html msg)
bankInfoRow data =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData data.analyzedPayeeName ]
        , Grid.col [ Col.md4, Col.offsetMd3 ] [ labelWithData data.analyzedCategory ]
        ]
    , Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData data.description ] ]
    ]
