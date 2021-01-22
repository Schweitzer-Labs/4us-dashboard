module Aggregations exposing (Model, decoder, init, view)

import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode


type alias Model =
    { balance : String
    , totalRaised : String
    , totalSpent : String
    , totalDonors : String
    , qualifyingDonors : String
    , qualifyingFunds : String
    , totalTransactions : String
    , totalInProcessing : String
    }


dollar : String -> String
dollar str =
    "$" ++ str


type Msg
    = Got


view : Model -> Html msg
view aggregates =
    Grid.containerFluid
        []
        [ Grid.row [] <|
            List.map agg
                [ ( "Balance", dollar aggregates.balance )
                , ( "Total pending", dollar aggregates.totalInProcessing )
                , ( "Total raised", dollar aggregates.totalRaised )
                , ( "Total spent", dollar aggregates.totalSpent )
                , ( "Total donors", aggregates.totalDonors )
                ]
        ]


agg : ( String, String ) -> Column msg
agg ( name, number ) =
    Grid.col
        [ Col.attrs [ class "text-center" ] ]
        [ Grid.row [ Row.attrs [ class "font-weight-bold" ] ] [ Grid.col [] [ text name ] ]
        , Grid.row [ Row.attrs [ class "font-size-24" ] ] [ Grid.col [] [ text number ] ]
        ]


decoder : Decode.Decoder Model
decoder =
    Decode.map8
        Model
        (Decode.field "balance" Decode.string)
        (Decode.field "totalRaised" Decode.string)
        (Decode.field "totalSpent" Decode.string)
        (Decode.field "totalDonors" Decode.string)
        (Decode.field "qualifyingDonors" Decode.string)
        (Decode.field "qualifyingFunds" Decode.string)
        (Decode.field "totalTransactions" Decode.string)
        (Decode.field "totalInProcessing" Decode.string)


init : Model
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
