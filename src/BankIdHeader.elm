module BankIdHeader exposing (BankData, Model, infoRows, view)

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Attribute, Html, div, h4, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import LabelWithData exposing (labelWithData, labelWithDescriptionData)


type alias BankData =
    { analyzedPayeeName : String
    , analyzedCategory : String
    , description : String
    }


type alias Model =
    { data : BankData
    , dataIsVisible : Bool
    }


angleIcon : Bool -> Html msg
angleIcon val =
    if val then
        Asset.angleDownGlyph [ class "text-slate-blue" ]

    else
        Asset.angleUpGlyph [ class "text-slate-blue" ]


bankHeaderStyle : Attribute msg
bankHeaderStyle =
    class "font-weight-bold text-decoration-underline"


headerRow : String -> msg -> Bool -> List (Html msg)
headerRow id msg val =
    [ Grid.row []
        [ Grid.col [] [ h4 [ bankHeaderStyle, onClick msg ] [ text <| "Bank Data: " ++ id, angleIcon val ] ] ]
    ]


infoRows : Model -> List (Html msg)
infoRows model =
    if model.dataIsVisible then
        [ Grid.row []
            [ Grid.col [ Col.md4 ] [ labelWithData "Analyzed Payee Name" model.data.analyzedPayeeName ]
            , Grid.col [ Col.md4, Col.offsetMd3 ] [ labelWithData "Analyzed Category" model.data.analyzedCategory ]
            ]
        , Grid.row []
            [ Grid.col [ Col.md4 ] [ labelWithDescriptionData "Description" model.data.description ] ]
        ]

    else
        []



---- VIEW ----


view : Model -> String -> msg -> Html msg
view model id toggleMsg =
    Grid.containerFluid
        []
    <|
        []
            ++ headerRow id toggleMsg model.dataIsVisible
            ++ infoRows model
