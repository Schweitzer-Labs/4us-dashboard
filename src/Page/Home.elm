module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Aggregations exposing (Aggregations)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Asset as Asset exposing (Image)
import Banner
import Bootstrap.Grid as Grid exposing (Column)
import Browser.Dom as Dom
import Content
import DataTable
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Session exposing (Session)
import Task exposing (Task)
import Time
import Transaction.ContributionsData as ContributionsData exposing (Contribution, ContributionsData)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , contributions : List Contribution
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


contributionsContainer : List Contribution -> Html msg
contributionsContainer contributions =
    Grid.row
        []
        [ Grid.col [] [ contributionsTable contributions ]
        ]


dollar : String -> String
dollar str =
    "$" ++ str



-- CONTRIBUTIONS


labels : List String
labels =
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


contributionsTable : List Contribution -> Html msg
contributionsTable c =
    DataTable.view [] labels contributionRowMap c


stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" ->
            True

        _ ->
            False


contributionRowMap : Contribution -> List ( String, Html msg )
contributionRowMap c =
    let
        status =
            if stringToBool c.verified then
                Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]

        refCode =
            text <|
                (\n ->
                    if n == "" then
                        "home"

                    else
                        n
                )
                <|
                    Maybe.withDefault "Home" c.refCode
    in
    [ ( "Record", text c.record )
    , ( "Date / Time", text c.datetime )
    , ( "Rule", text c.rule )
    , ( "Entity name", text c.entityName )
    , ( "Amount", span [ class "text-success font-weight-bold" ] [ text <| dollar c.amount ] )
    , ( "Payment Method", text c.paymentMethod )
    , ( "Processor", img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] [] )
    , ( "Status", status )
    , ( "Verified", Asset.circleCheckGlyph [ class "text-success data-icon-size" ] )
    , ( "Reference Code", refCode )
    ]



-- TAGS
-- UPDATE


type ContributionId
    = ContributionId String


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
                    ( { model
                        | contributions = data.contributions
                        , aggregations = data.aggregations
                      }
                    , Cmd.none
                    )

                Err _ ->
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
