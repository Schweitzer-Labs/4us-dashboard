module ExpandableBankData exposing (view)

import Asset
import BankData
import Bootstrap.Grid as Grid
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Attribute, Html, div, text, u)
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
    class "font-weight-bold text-decoration-underline hover-pointer text-slate-blue"


headerRow : String -> msg -> Bool -> Html msg
headerRow id msg val =
    div [ Spacing.mt5 ] [ u [ bankHeaderStyle, onClick msg ] [ text <| "Bank Data: " ++ id, angleIcon val ] ]



---- VIEW ----


view : Bool -> Transaction.Model -> msg -> List (Html msg)
view dataIsVisible txn toggleMsg =
    [ headerRow txn.id toggleMsg dataIsVisible
    , Grid.containerFluid
        []
      <|
        ([]
            ++ (if dataIsVisible then
                    [ BankData.view False txn ]

                else
                    []
               )
        )
    ]
