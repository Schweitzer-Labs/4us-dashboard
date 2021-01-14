module Aggregations exposing (Aggregations, decoder, init, view)

import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode


type alias Aggregations =
    { balance : String
    , totalRaised : String
    , totalSpent : String
    , totalDonors : String
    , qualifyingDonors : String
    , qualifyingFunds : String
    , totalTransactions : String
    , totalInProcessing : String
    }


view : Aggregations -> Html msg
view aggregations =
    Grid.row
        [ Row.attrs [ class "align-items-center" ] ]
        [ Grid.col [ Col.xs2 ] [ aggsTitleContainer ]
        , Grid.col [ Col.attrs [ Spacing.pr0 ] ] [ aggsDataContainer aggregations ]
        ]


aggsTitleContainer : Html msg
aggsTitleContainer =
    Grid.containerFluid
        []
        [ Grid.row
            [ Row.centerXs, Row.attrs [ class "text-center text-xl" ] ]
            [ Grid.col [ Col.xs4, Col.attrs [ class "bg-ruby" ] ] [ text "LIVE" ]
            , Grid.col [ Col.xs5 ] [ text "Transactions" ]
            ]
        ]


dollar : String -> String
dollar str =
    "$" ++ str


aggsDataContainer : Aggregations -> Html msg
aggsDataContainer aggregates =
    Grid.containerFluid
        []
        [ Grid.row [] <|
            List.map agg
                [ ( "Balance", dollar aggregates.balance )
                , ( "Total pending", dollar aggregates.totalInProcessing )
                , ( "Total raised", dollar aggregates.totalRaised )
                , ( "Total spent", dollar aggregates.totalSpent )
                , ( "Total donors", aggregates.totalDonors )
                , ( "Qualifying donors", aggregates.qualifyingDonors )
                , ( "Qualifying funds", dollar aggregates.qualifyingFunds )
                ]
        ]


agg : ( String, String ) -> Column msg
agg ( name, number ) =
    Grid.col
        [ Col.attrs [ class "border-left text-center" ] ]
        [ Grid.row [ Row.attrs [ Spacing.pt1, Spacing.pb1 ] ] [ Grid.col [] [ text name ] ]
        , Grid.row [ Row.attrs [ class "border-top", Spacing.pt1, Spacing.pb1 ] ] [ Grid.col [] [ text number ] ]
        ]


decoder : Decode.Decoder Aggregations
decoder =
    Decode.map8
        Aggregations
        (Decode.field "balance" Decode.string)
        (Decode.field "totalRaised" Decode.string)
        (Decode.field "totalSpent" Decode.string)
        (Decode.field "totalDonors" Decode.string)
        (Decode.field "qualifyingDonors" Decode.string)
        (Decode.field "qualifyingFunds" Decode.string)
        (Decode.field "totalTransactions" Decode.string)
        (Decode.field "totalInProcessing" Decode.string)


init : Aggregations
init =
    { balance = ""
    , totalRaised = ""
    , totalSpent = ""
    , totalDonors = ""
    , qualifyingDonors = ""
    , qualifyingFunds = ""
    , totalTransactions = ""
    , totalInProcessing = ""
    }
