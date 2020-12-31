module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Banner
import Browser.Dom as Dom
import Content
import Html exposing (..)
import Html.Attributes exposing (attribute, class, classList, href, id, placeholder)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Table as Table exposing (Cell)
import Asset as Asset exposing (Image)
import Http
import Task exposing (Task)
import Transaction.ContributionsData as ContributionsData exposing (Contribution, ContributionsData)



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
    , totalInProcessing: String
    }



init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , timeZone = Time.utc
      , contributions = []
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
            , Content.container <| [ contributionsContainer model.contributions ]
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



-- Contributions

contributionsContainer : List Contribution -> Html msg
contributionsContainer contributions =
        Grid.row
            []
            [ Grid.col [] [contributionsTable contributions ]
            ]

dollar : String -> String
dollar str = "$" ++ str

-- CONTRIBUTIONS

contributionsTable : List Contribution -> Html msg
contributionsTable contributions
    = Table.table
        { options = [Table.attr <| class "main-table border-left"]
        , thead = Table.thead
                  []
                  <| List.singleton
                  <| Table.tr []
                  <| List.map stickyTh
                      [ "Record"
                      , "Date / Time"
                      , "Rule"
                      , "Entity name"
                      , "Amount"
                      , "Payment Method"
                      , "Processor"
                      , "Status"
                      , "Verified"
                      , "Reference Code"
                      ]
        , tbody = Table.tbody [] <| List.map contributionRow contributions
        }

stickyTh : String -> Cell msg
stickyTh label = Table.th [Table.cellAttr <| class "sticky-top sticky-th bg-white shadow-sm"] [ text label]

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
        , Table.td [] [ text <| Maybe.withDefault "" c.refCode ]
        ]


-- TAGS

-- UPDATE


type ContributionId = ContributionId String

type Msg
    = GotSession Session
    | LoadContributionsData (Result Http.Error ContributionsData)



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )
        LoadContributionsData res ->
            case res of
                  Ok data ->
                      let aggregates = data.aggregations
                      in
                      (
                        { model
                        | contributions = data.contributions
                        , balance = aggregates.balance
                        , totalRaised = aggregates.totalRaised
                        , totalSpent = aggregates.totalSpent
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

getContributionsData : Http.Request ContributionsData
getContributionsData =
  Api.get (Endpoint.contributions Session.committeeId) Nothing ContributionsData.decode

send : Cmd Msg
send =
  Http.send LoadContributionsData getContributionsData




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
