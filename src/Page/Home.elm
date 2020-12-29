module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Table as Table
import Asset as Asset exposing (Image)
import Http
import Random
import Task exposing (Task)
import Json.Decode as Decode exposing (Decoder, field, string)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , contributions: List Contribution
    , balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    }


type alias Contribution =
    { record : String
    , datetime: String
    , rule: String
    , entityName: String
    , amount: String
    , paymentMethod: String
    , verified: String
    }

init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , timeZone = Time.utc
      , contributions = []
      , balance = "0"
      , totalRaised = "0"
      , totalSpent = "0"
      , totalDonors = "0"
      , qualifyingDonors = "0"
      , qualifyingFunds = "0"
      , totalTransactions = "0"
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
            [ aggsContainer model
            , transactionsContainer model
            ]
    }

aggsContainer : Model -> Html msg
aggsContainer model = Grid.containerFluid
    [ class "bg-slate-blue text-white font-weight-bold", Spacing.mt3 ]
    [ Grid.row
        [ Row.attrs [class "align-items-center"] ]
        [ Grid.col [Col.xs2] [ aggsTitleContainer ]
        , Grid.col [Col.attrs [Spacing.pr0]] [ aggsDataContainer model ]
        ]
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
           , ("Total pending", dollar model.totalRaised)
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

transactionsContainer : Model -> Html msg
transactionsContainer model =
    Grid.containerFluid
        []
        [ transactionsLabelContainer
        , Grid.row
            []
            [ Grid.col [Col.xs1] [txnSortContainer]
            , Grid.col [] [txnDataContainer model ]
            ]
         ]

transactionsLabelContainer : Html msg
transactionsLabelContainer =
    Grid.row
        [ Row.attrs [class "align-items-center"] ]
        [ Grid.col [Col.xs1 ] [h2 [class "text-center"] [text "Tools"]]
        , Grid.col [] []
        ]


txnSortContainer : Html msg
txnSortContainer = Grid.containerFluid
    [ class "text-center mt-2"]
    [ txnSort Asset.calendar "Calendar"
    , txnSort Asset.person "Contributions"
    , txnSort Asset.house "Disbursements"
    , txnSort Asset.binoculars "Needs review"
    , txnSort Asset.documents "Documents"
    ]

txnSort : Image -> String ->  Html msg
txnSort image label = Grid.row
    [ Row.attrs [class "mt-3"]]
    [ Grid.col
        []
        [ Grid.containerFluid
            [ class "text-center" ]
            [ Grid.row
                [ Row.centerXs ]
                [ Grid.col [] [img [Asset.src image, class "sort-asset text-center"] []] ]
            , Grid.row
                []
                [ Grid.col [] [text label] ]
            ]
        ]
    ]

dollar : String -> String
dollar str = "$" ++ str

txnDataContainer : Model -> Html msg
txnDataContainer model = Table.simpleTable
    ( Table.simpleThead
        [ Table.th [] [ text "Record"]
        , Table.th [] [ text "Date / Time"]
        , Table.th [] [ text "Rule"]
        , Table.th [] [ text "Entity name"]
        , Table.th [] [ text "Amount"]
        , Table.th [] [ text "Payment Method"]
        , Table.th [] [ text "Processor"]
        , Table.th [] [ text "Status"]
        , Table.th [] [ text "Verified"]
        ]
    , Table.tbody [] <| List.map contributionRow model.contributions
    )



stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" -> True
        _ -> False


contributionRow : Contribution -> Table.Row msg
contributionRow c =
    Table.tr []
        [ Table.td [] [ text c.record ]
        , Table.td [] [ text c.datetime ]
        , Table.td [] [ text c.rule ]
        , Table.td [] [ text c.entityName ]
        , Table.td [] [ span [class "text-success font-weight-bold"] [text <| dollar c.amount] ]
        , Table.td [] [ text c.paymentMethod ]
        , Table.td [] [ img [Asset.src Asset.stripeLogo, class "stripe-logo"] [] ]
        , Table.td [] [
            if (stringToBool c.verified)
                then Asset.circleCheckGlyph [class "text-success"]
            else Asset.minusCircleGlyph [class "text-warning"]
          ]
        , Table.td [] [ Asset.circleCheckGlyph [class "text-success"]]
        ]


-- TABS

-- TAGS

-- UPDATE


type ContributionId = ContributionId String

type Msg
    = GotSession Session
    | GetContributions ContributionId
    | GotContributionResponse (Result Http.Error String)
    | GotContributionResponseFailure
    | Roll
    | NewFace Int
    | LoadMetadata (Result Http.Error Metadata)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )
        GotContributionResponse res ->
            case res of
              Ok str ->
                  ( model, Cmd.none )
              Err _ ->
                  ( model, Cmd.none )
        Roll ->
              ( model
              , Random.generate NewFace (Random.int 1 6)
              )
        NewFace newFace ->
          ( { model | balance = String.fromInt newFace }
          , Cmd.none
          )
        LoadMetadata res ->
            case res of
                  Ok str ->
                      let aggregates = str.aggregations
                      in
                      (
                        { model
                        | contributions = str.contributions
                        , balance = aggregates.balance
                        , totalRaised = aggregates.totalRaised
                        , totalSpent = aggregates.totalSpent
                        , totalDonors = aggregates.totalDonors
                        , qualifyingDonors = aggregates.qualifyingDonors
                        , qualifyingFunds = aggregates.qualifyingFunds
                        , totalTransactions = aggregates.totalTransactions
                        }
                      , Cmd.none
                      )
                  Err _ ->
                      ( model, Cmd.none )
        _ ->
            ( model, Cmd.none )


-- HTTP

getMetadata : Http.Request Metadata
getMetadata =
  Http.get "http://localhost:5000/contributions?committeeId=3e947da3-c8bd-4881-a9aa-5afb57ef5b12" decodeMetadata


type alias Aggregations =
    { balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    }

type alias Metadata =
  { contributions : List Contribution
  , aggregations : Aggregations
  }


decodeMetadata : Decode.Decoder Metadata
decodeMetadata =
  Decode.map2
    Metadata
    (Decode.field "transactions" listOfRecordsDecoder)
    (Decode.field "aggregates" aggregationsDecoder)


aggregationsDecoder : Decode.Decoder Aggregations
aggregationsDecoder =
    Decode.map7
        Aggregations
        (Decode.field "balance" Decode.string)
        (Decode.field "totalRaised" Decode.string)
        (Decode.field "totalSpent" Decode.string)
        (Decode.field "totalDonors" Decode.string)
        (Decode.field "qualifyingDonors" Decode.string)
        (Decode.field "qualifyingFunds" Decode.string)
        (Decode.field "totalTransactions" Decode.string)


recordDecoder : Decode.Decoder Contribution
recordDecoder =
    Decode.map7
        Contribution
        (Decode.field "record" Decode.string)
        (Decode.field "datetime" Decode.string)
        (Decode.field "rule" Decode.string)
        (Decode.field "entityName" Decode.string)
        (Decode.field "amount" Decode.string)
        (Decode.field "paymentMethod" Decode.string)
        (Decode.field "verified" Decode.string)


listOfRecordsDecoder : Decode.Decoder (List Contribution)
listOfRecordsDecoder =
    Decode.list recordDecoder

send : Cmd Msg
send =
  Http.send LoadMetadata getMetadata




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


type alias Aggregates =
    { balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    }

type alias ContribResponse =
    { aggregates: Aggregates
    , contributions: List Contribution
    }

