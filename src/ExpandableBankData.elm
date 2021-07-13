module ExpandableBankData exposing (view)

import Asset
import BankData
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, text, u)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Transaction


angleIcon : Bool -> Html msg
angleIcon val =
    case val of
        True ->
            Asset.angleUpGlyph [ class "text-slate-blue ml-2" ]

        False ->
            Asset.angleDownGlyph [ class "text-slate-blue ml-2" ]


bankHeaderStyle : Attribute msg
bankHeaderStyle =
    class "font-weight-bold text-decoration-underline text-slate-blue"


headerRow : String -> msg -> Bool -> List (Html msg)
headerRow id msg val =
    [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col [] [ u [ bankHeaderStyle, onClick msg ] [ text <| "Bank Data: " ++ id, angleIcon val ] ] ]
    ]



---- VIEW ----


view : Bool -> Transaction.Model -> msg -> Html msg
view dataIsVisible txn toggleMsg =
    Grid.containerFluid
        []
    <|
        ([]
            ++ headerRow txn.id toggleMsg dataIsVisible
            ++ (if dataIsVisible then
                    [ BankData.view False txn ]

                else
                    []
               )
        )
