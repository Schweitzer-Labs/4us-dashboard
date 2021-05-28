module Page.Contributions exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Aggregations
import Api exposing (Cred, Token)
import Api.Endpoint as Endpoint
import Asset
import Bootstrap.Grid as Grid
import Browser.Dom as Dom
import Charts exposing (contributionsByRefCode, donorByRefCode, monthlyContributionsByReferenceCode)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Loading
import Session exposing (Session)
import Svg exposing (use)
import Task exposing (Task)
import Time
import Transaction.TransactionsData as TransactionsData exposing (TransactionsData)
import Transactions



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , timeZone : Time.Zone
    , transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , committeeId : String
    , token : Token
    }


init : Token -> Session -> Aggregations.Model -> String -> ( Model, Cmd Msg )
init token session aggs committeeId =
    ( { session = session
      , loading = True
      , timeZone = Time.utc
      , transactions = []
      , aggregations = aggs
      , committeeId = committeeId
      , token = token
      }
    , getTransactionsData token committeeId
    )



-- VIEW


contentView : Model -> Html Msg
contentView model =
    div [ class "fade-in" ]
        [ Grid.containerFluid
            []
            [ Grid.row
                []
                [ Grid.col
                    []
                    [ h3 [] [ text "Monthly Contributions by Ref Code" ]
                    , monthlyContributionsByReferenceCode []
                    ]
                ]
            , Grid.row
                []
                [ Grid.col
                    []
                    [ contributionsByRefCode []
                    ]
                , Grid.col
                    []
                    [ donorByRefCode []
                    ]
                ]
            ]
        ]


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        if model.loading then
            Loading.view

        else
            contentView model
    }



-- TAGS
-- UPDATE


type ContributionId
    = ContributionId String


type Msg
    = GotSession Session
    | LoadTransactionsData (Result Http.Error TransactionsData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        LoadTransactionsData res ->
            case res of
                Ok body ->
                    ( { model
                        | transactions = body.data.transactions
                        , aggregations = body.data.aggregations
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )



-- HTTP


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session


getTransactionsData : Token -> String -> Cmd Msg
getTransactionsData token committeeId =
    Http.send LoadTransactionsData <|
        Api.get (Endpoint.transactions committeeId Nothing) token TransactionsData.decode
