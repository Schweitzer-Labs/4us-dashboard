module Aggregations exposing (Model, decoder, init, view)

import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Cents
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (int, string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { balance : Int
    , totalRaised : Int
    , totalSpent : Int
    , totalDonors : Int
    , totalTransactions : Int
    , totalContributionsInProcessing : Int
    , totalDisbursementsInProcessing : Int
    , needsReviewCount : Int
    }


type Msg
    = Got


view : Model -> Html msg
view aggregates =
    Grid.containerFluid
        []
        [ Grid.row [] <|
            List.map agg
                [ ( "Balance", Cents.toDollar aggregates.balance )
                , ( "Pending in", Cents.toDollar aggregates.totalContributionsInProcessing )
                , ( "Pending out", Cents.toDollar aggregates.totalDisbursementsInProcessing )
                , ( "Total raised", Cents.toDollar aggregates.totalRaised )
                , ( "Total spent", Cents.toDollar aggregates.totalSpent )
                , ( "Total donors", String.fromInt aggregates.totalDonors )
                ]
        ]


agg : ( String, String ) -> Column msg
agg ( name, amount ) =
    Grid.col
        [ Col.attrs [ class "text-center" ] ]
        [ Grid.row [ Row.attrs [ class "font-weight-bold" ] ] [ Grid.col [] [ text name ] ]
        , Grid.row [ Row.attrs [ class "font-size-24" ] ] [ Grid.col [] [ text amount ] ]
        ]


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> required "balance" int
        |> required "totalRaised" int
        |> required "totalSpent" int
        |> required "totalDonors" int
        |> required "totalTransactions" int
        |> required "totalContributionsInProcessing" int
        |> required "totalDisbursementsInProcessing" int
        |> required "needsReviewCount" int


init : Model
init =
    { balance = 0
    , totalRaised = 0
    , totalSpent = 0
    , totalDonors = 0
    , totalTransactions = 0
    , totalContributionsInProcessing = 0
    , totalDisbursementsInProcessing = 0
    , needsReviewCount = 0
    }
