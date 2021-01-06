module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Banner
import Browser.Dom as Dom
import Content
import DataTable
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Http
import Task exposing (Task)
import Transaction.DisbursementsData as DD exposing (Disbursement, DisbursementsData)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , disbursements: List Disbursement
    , balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    , totalInProcessing: String
    }



init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , timeZone = Time.utc
      , disbursements = []
      , balance = ""
      , totalRaised = ""
      , totalSpent = ""
      , totalDonors = ""
      , qualifyingDonors = ""
      , qualifyingFunds = ""
      , totalTransactions = ""
      , totalInProcessing = ""
      }
    , send
    )



-- VIEW

view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div
            []
            [ Banner.container [] <| aggsContainer model
            , Content.container <| [ disbursementsContainer model.disbursements ]
            ]
    }

aggsContainer : Model -> Html msg
aggsContainer model =
    Grid.row
        [ Row.attrs [class "align-items-center"] ]
        [ Grid.col [Col.xs2] [aggsTitleContainer]
        , Grid.col [Col.attrs [Spacing.pr0]] [aggsDataContainer model]
        ]


aggsTitleContainer : Html msg
aggsTitleContainer = Grid.containerFluid
    []
    [ Grid.row
        [Row.centerXs, Row.attrs [class "text-center text-xl"]]
        [ Grid.col [Col.xs4, Col.attrs [class "bg-ruby"]] [text "LIVE"]
        , Grid.col [Col.xs5] [text "Transactions"]
        ]
     ]

aggsDataContainer : Model -> Html msg
aggsDataContainer model = Grid.containerFluid
    []
    [ Grid.row []
        <| List.map agg
           [ ("Balance", dollar model.balance)
           , ("Total pending", dollar model.totalInProcessing)
           , ("Total raised", dollar model.totalRaised)
           , ("Total spent", dollar model.totalSpent)
           , ("Total donors", model.totalDonors)
           , ("Qualifying donors", model.qualifyingDonors)
           , ("Qualifying funds", dollar model.qualifyingFunds)
           ]
    ]

agg : (String, String) -> Column msg
agg (name, number) = Grid.col
    [Col.attrs [class "border-left text-center"]]
    [ Grid.row [Row.attrs [Spacing.pt1, Spacing.pb1]] [Grid.col [] [text name]]
    , Grid.row [Row.attrs [class "border-top", Spacing.pt1, Spacing.pb1]] [Grid.col [] [text number]]
    ]



-- Disbursements

disbursementsContainer : List Disbursement -> Html msg
disbursementsContainer disbursements =
        Grid.row
            []
            [ Grid.col [] [disbursementsTable disbursements ]
            ]

dollar : String -> String
dollar str = "$" ++ str

-- Disbursements

labels : List String
labels =
    [ "Record"
    , "Date / Time"
    , "Entity Name"
    , "Address"
    , "Amount"
    , "Purpose"
    , "Record Date"
    ]

disbursementsTable : List Disbursement -> Html msg
disbursementsTable c
    = DataTable.view labels disbursementRowMap c

stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" -> True
        _ -> False


disbursementRowMap : Disbursement -> (List (String, (Html msg)))
disbursementRowMap d =
    let
        address = d.addressLine1
            ++ ", "
            ++ d.addressLine2
            ++ ","
            ++ d.city
            ++ ", "
            ++ d.state
            ++ " "
            ++ d.postalCode
    in
        [ ("Record", text d.recordNumber)
        , ("Date / Time", text d.date)
        , ("Entity Name", text d.entityName)
        , ("Address", text address)
        , ("Amount", span [class "text-failure font-weight-bold"] [text <| dollar d.amount])
        , ("Purpose", text d.purposeCode)
        , ("Record Date", text d.date)
        ]


-- TAGS

-- UPDATE


type ContributionId = ContributionId String

type Msg
    = GotSession Session
    | LoadDisbursementsData (Result Http.Error DisbursementsData)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )
        LoadDisbursementsData res ->
            case res of
                  Ok data ->
                      let aggregates = data.aggregations
                      in
                      (
                        { model
                        | disbursements = data.disbursements
                        , balance = aggregates.balance
                        , totalRaised = aggregates.totalRaised
                        , totalSpent = "10,534"
                        , totalDonors = aggregates.totalDonors
                        , qualifyingDonors = aggregates.qualifyingDonors
                        , qualifyingFunds = aggregates.qualifyingFunds
                        , totalTransactions = aggregates.totalTransactions
                        , totalInProcessing = aggregates.totalInProcessing
                        }
                      , Cmd.none
                      )
                  Err _ ->
                      ( model, Cmd.none )


-- HTTP

getDisbursementsData : Http.Request DisbursementsData
getDisbursementsData =
  Api.get (Endpoint.disbursements Session.committeeId) Nothing DD.decode

send : Cmd Msg
send =
  Http.send LoadDisbursementsData getDisbursementsData

scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
