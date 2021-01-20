module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Aggregations exposing (Aggregations)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Banner
import Bootstrap.Grid as Grid exposing (Column)
import Browser.Dom as Dom
import Content
import Contribution as Contribution
import Contributions
import Html exposing (..)
import Http
import Session exposing (Session)
import Task exposing (Task)
import Time
import Transaction.ContributionsData as ContributionsData exposing (ContributionsData)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , contributions : List Contribution.Model
    , aggregations : Aggregations
    , committeeId : String
    }


init : Session -> String -> ( Model, Cmd Msg )
init session committeeId =
    ( { session = session
      , timeZone = Time.utc
      , contributions = []
      , aggregations = Aggregations.init
      , committeeId = committeeId
      }
    , getContributionsData committeeId
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div
            []
            [ Banner.container [] [ Aggregations.view model.aggregations ]
            , Content.container [] [ contributionsContainer model.contributions ]
            ]
    }



-- Contributions


contributionsContainer : List Contribution.Model -> Html Msg
contributionsContainer contributions =
    Grid.row
        []
        [ Grid.col [] [ Contributions.view SortContributions [] contributions ]
        ]



-- TAGS
-- UPDATE


type ContributionId
    = ContributionId String


type Msg
    = GotSession Session
    | LoadContributionsData (Result Http.Error ContributionsData)
    | SortContributions Contributions.Label


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        LoadContributionsData res ->
            case res of
                Ok data ->
                    ( { model
                        | contributions = data.contributions
                        , aggregations = data.aggregations
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )

        SortContributions label ->
            case label of
                Contributions.Record ->
                    ( { model
                        | contributions = model.contributions
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



-- HTTP


getContributionsData : String -> Cmd Msg
getContributionsData committeeId =
    Http.send LoadContributionsData <|
        Api.get (Endpoint.contributions committeeId) Nothing ContributionsData.decode


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
