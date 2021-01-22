module Aggregations exposing (Model, decoder, init, view)

import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (string)
import Json.Decode.Pipeline exposing (optional)


type alias Model =
    { balance : String
    , totalRaised : String
    , totalSpent : String
    , totalDonors : String
    , qualifyingDonors : String
    , qualifyingFunds : String
    , totalTransactions : String
    , totalInProcessing : String
    , needReviewCount : String
    }


dollar : String -> String
dollar str =
    let
        maybeTup =
            String.uncons str
    in
    case maybeTup of
        Just (( firstChar, rest ) as val) ->
            if firstChar == '-' then
                "-" ++ "$" ++ rest

            else
                "$" ++ str

        Nothing ->
            "$"


type Msg
    = Got


view : Model -> Html msg
view aggregates =
    Grid.containerFluid
        []
        [ Grid.row [] <|
            List.map agg
                [ ( "Balance", dollar aggregates.balance )
                , ( "Pending in", dollar aggregates.totalInProcessing )
                , ( "Total raised", dollar aggregates.totalRaised )
                , ( "Total spent", dollar aggregates.totalSpent )
                , ( "Total donors", aggregates.totalDonors )
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
        |> optional "balance" string ""
        |> optional "totalRaised" string ""
        |> optional "totalSpent" string ""
        |> optional "totalDonors" string ""
        |> optional "qualifyingDonors" string ""
        |> optional "qualifyingFunds" string ""
        |> optional "totalTransactions" string ""
        |> optional "totalInProcessing" string ""
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
    , totalInProcessing = ""
    , needReviewCount = ""
    }
