module Main exposing (Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Aggregations
import Browser exposing (Document)
import Browser.Navigation as Nav
import Committee
import CommitteeId
import Config exposing (Config)
import Html exposing (Html)
import Page
import Page.Blank as Blank
import Page.Demo as Demo
import Page.LinkBuilder as LinkBuilder
import Page.NotFound as NotFound
import Page.Transactions as Transactions
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



---- MODEL ----


type Model
    = NotFound Session
    | Redirect Session
    | LinkBuilder LinkBuilder.Model
    | Transactions Transactions.Model
    | Demo Demo.Model


init : Config -> Url -> Nav.Key -> ( Model, Cmd Msg )
init config url navKey =
    changeRouteTo
        url
        config
        (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey config.token))


changeRouteTo : Url -> Config -> Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo url config maybeRoute model =
    let
        session =
            toSession model

        committeeId =
            CommitteeId.parse url

        aggregations =
            toAggregations model

        committee =
            toCommittee model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        -- rest of the routes
        Just Route.Home ->
            Transactions.init
                config
                session
                aggregations
                committee
                committeeId
                |> updateWith Transactions GotTransactionsMsg

        Just (Route.Transactions id) ->
            Transactions.init
                config
                session
                aggregations
                committee
                id
                |> updateWith Transactions GotTransactionsMsg

        Just (Route.LinkBuilder id) ->
            LinkBuilder.init
                config
                session
                aggregations
                committee
                id
                |> updateWith LinkBuilder GotLinkBuilderMsg

        Just (Route.Demo id) ->
            Demo.init
                config
                session
                aggregations
                committee
                id
                |> updateWith Demo GotDemoMsg



---- UPDATE ----


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotSession Session
    | GotTransactionsMsg Transactions.Msg
    | GotDemoMsg Demo.Msg


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Transactions transactions ->
            Transactions.toSession transactions

        LinkBuilder session ->
            LinkBuilder.toSession session

        Demo session ->
            Demo.toSession session


toAggregations : Model -> Aggregations.Model
toAggregations page =
    case page of
        Redirect session ->
            Aggregations.init

        NotFound session ->
            Aggregations.init

        Transactions transactions ->
            transactions.aggregations

        LinkBuilder linkBuilder ->
            linkBuilder.aggregations

        Demo demo ->
            demo.aggregations


toCommittee : Model -> Committee.Model
toCommittee page =
    case page of
        Redirect session ->
            Committee.init

        NotFound session ->
            Committee.init

        Transactions transactions ->
            transactions.committee

        LinkBuilder linkBuilder ->
            linkBuilder.committee

        Demo demo ->
            demo.committee


toConfig : Model -> Config
toConfig page =
    case page of
        Redirect session ->
            { apiEndpoint = ""
            , cognitoClientId = ""
            , redirectUri = ""
            , donorUrl = ""
            , token = ""
            , cognitoDomain = ""
            }

        NotFound session ->
            { apiEndpoint = ""
            , cognitoClientId = ""
            , redirectUri = ""
            , donorUrl = ""
            , token = ""
            , cognitoDomain = ""
            }

        Transactions transactions ->
            transactions.config

        LinkBuilder linkBuilder ->
            linkBuilder.config

        Demo demo ->
            demo.config


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo url (toConfig model) (Route.fromUrl url) model

        ( GotTransactionsMsg subMsg, Transactions home ) ->
            Transactions.update subMsg home
                |> updateWith Transactions GotTransactionsMsg

        ( GotLinkBuilderMsg subMsg, LinkBuilder linkBuilder ) ->
            LinkBuilder.update subMsg linkBuilder
                |> updateWith LinkBuilder GotLinkBuilderMsg

        ( GotDemoMsg subMsg, Demo demo ) ->
            Demo.update subMsg demo
                |> updateWith Demo GotDemoMsg

        ( GotSession session, Redirect _ ) ->
            ( Redirect session
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



---- VIEW ----


view : Model -> Document Msg
view model =
    let
        aggregations =
            toAggregations model

        committee =
            toCommittee model

        config =
            toConfig model

        viewPage page toMsg conf =
            let
                { title, body } =
                    Page.view config aggregations committee page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view config aggregations committee Page.Other Blank.view

        NotFound _ ->
            Page.view config aggregations committee Page.Other NotFound.view

        Transactions transactions ->
            viewPage Page.Transactions GotTransactionsMsg (Transactions.view transactions)

        LinkBuilder linkBuilder ->
            viewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        Demo demo ->
            viewPage Page.Demo GotDemoMsg (Demo.view demo)



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Transactions transactions ->
            Sub.map GotTransactionsMsg (Transactions.subscriptions transactions)

        LinkBuilder linkBuilder ->
            Sub.map GotLinkBuilderMsg (LinkBuilder.subscriptions linkBuilder)

        Demo demo ->
            Sub.map GotDemoMsg (Demo.subscriptions demo)

        _ ->
            Sub.none


main : Program Config Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
