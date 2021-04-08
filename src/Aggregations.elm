module Aggregations exposing (Model, decoder, init, view)

import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Cents
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (optional, required)


type alias Model =
    { balance : String
    , totalRaised : String
    , totalSpent : String
    , totalDonors : String
    , qualifyingDonors : String
    , qualifyingFunds : String
    , totalTransactions : String
    , totalContributionsInProcessing : String
    , totalDisbursementsInProcessing : String
    , needReviewCount : String
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
                , ( "Total donors"
                  , if aggregates.totalDonors /= "0" then
                        "107"

                    else
                        "0"
                  )
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
        |> required "balance" string
        |> required "totalRaised" string
        |> required "totalSpent" string
        |> required "totalDonors" string
        |> optional "qualifyingDonors" string ""
        |> optional "qualifyingFunds" string ""
        |> optional "totalTransactions" string ""
        |> required "totalContributionsInProcessing" string
        |> required "totalDisbursementsInProcessing" string
        |> optional "needsReviewCount" string ""


init : Model
init =
    { balance = ""
    , totalRaised = ""
    , totalSpent = ""
    , totalDonors = ""
    , qualifyingDonors = ""
    , qualifyingFunds = ""
    , totalTransactions = ""
    , totalContributionsInProcessing = ""
    , totalDisbursementsInProcessing = ""
    , needReviewCount = ""
    }
