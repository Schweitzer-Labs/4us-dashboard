module ReconcileItemsView exposing (MakeReconcileItemsViewConfig, view)

-- MODEL

import Asset
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Html exposing (Html, div, h5, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import LabelWithData exposing (dataLabel, labelWithData)
import String as String


type alias MakeReconcileItemsViewConfig =
    { amount : ( String, Int )
    , totalSelected : ( String, Int )
    , matches : ( String, Bool )
    }


formLabelRow : String -> List (Html msg)
formLabelRow str =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ h5 [] [ text str ] ] ]
    ]


toStringData : ( String, Int ) -> ( String, String )
toStringData ( label, data ) =
    ( label, String.fromInt data )


matchesIcon : Bool -> Html msg
matchesIcon val =
    if val then
        Asset.timesGlyph [ class "text-red" ]

    else
        Asset.circleCheckGlyph [ class "text-slate-blue" ]


labelWithBankVerificationIcon : ( String, Bool ) -> Html msg
labelWithBankVerificationIcon ( label, matchesStatus ) =
    div []
        [ dataLabel label
        , matchesIcon matchesStatus
        ]


reconcileInfoRow : MakeReconcileItemsViewConfig -> List (Html msg)
reconcileInfoRow model =
    [ Grid.row []
        [ Grid.col [ Col.md4 ] [ labelWithData <| toStringData model.amount ]
        , Grid.col [ Col.md4 ] [ labelWithData <| toStringData model.totalSelected ]
        , Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon model.matches ]
        ]
    ]


addDisbursementButton : msg -> List (Html msg)
addDisbursementButton msg =
    [ Grid.row []
        [ Grid.col []
            [ h5 [ class "text-slate-blue", onClick msg ]
                [ Asset.plusCircleGlyph [ class "text-slate-blue" ]
                , text "Add Disbursement"
                ]
            ]
        ]
    ]



--- TODO add data table for element
--- VIEW


view : MakeReconcileItemsViewConfig -> msg -> Html msg
view model msg =
    Grid.containerFluid
        []
    <|
        []
            ++ formLabelRow "Reconcile"
            ++ reconcileInfoRow model
            ++ addDisbursementButton msg
