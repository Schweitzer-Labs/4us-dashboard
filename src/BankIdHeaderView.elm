module BankIdHeaderView exposing (BankData, MakeBankIdHeaderConfig, infoRow, view)

import AppLabelWithData exposing (labelWithData, labelWithDescriptionData)
import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Attribute, Html, div, h4, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias BankData =
    { analyzedPayeeName : ( String, String )
    , analyzedCategory : ( String, String )
    , description : ( String, String )
    }


type alias MakeBankIdHeaderConfig =
    { data : BankData
    , displayBankData : Bool
    }


angleIcon : Bool -> Html msg
angleIcon val =
    if val then
        Asset.angleDownGlyph [ class "text-slate-blue" ]

    else
        Asset.angleUpGlyph [ class "text-slate-blue" ]


headerRow : String -> msg -> Bool -> List (Html msg)
headerRow id msg val =
    [ Grid.row []
        [ Grid.col [] [ h4 [ class "bank-data-header", onClick msg ] [ text <| "Bank Data: " ++ id, angleIcon val ] ] ]
    ]


infoRow : MakeBankIdHeaderConfig -> List (Html msg)
infoRow model =
    if model.displayBankData then
        [ Grid.row []
            [ Grid.col [ Col.md4 ] [ labelWithData model.data.analyzedPayeeName ]
            , Grid.col [ Col.md4, Col.offsetMd3 ] [ labelWithData model.data.analyzedCategory ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md4 ] [ labelWithDescriptionData model.data.description ] ]
        ]

    else
        []



---- VIEW ----


view : MakeBankIdHeaderConfig -> String -> msg -> Html msg
view model id toggleMsg =
    Grid.containerFluid
        []
    <|
        []
            ++ headerRow id toggleMsg model.displayBankData
            ++ infoRow model