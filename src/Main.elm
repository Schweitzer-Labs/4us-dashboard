module Main exposing (Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Aggregations
import Api exposing (Token)
import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import CommitteeId
import Config exposing (Config)
import Html exposing (Html)
import Page
import Page.Blank as Blank
import Page.LinkBuilder as LinkBuilder
import Page.NeedsReview as NeedsReview
import Page.NotFound as NotFound
import Page.Transactions as Transactions
import Route exposing (Route)
import Session exposing (Session)
import Task exposing (Task)
import Url exposing (Url)



---- MODEL ----


type Model
    = NotFound Session
    | Redirect Session
    | LinkBuilder LinkBuilder.Model
    | NeedsReview NeedsReview.Model
    | Transactions Transactions.Model


init : Config -> Url -> Nav.Key -> ( Model, Cmd Msg )
init config url navKey =
    let
        ( model, cmdMsg ) =
            changeRouteTo
                url
                config
                (Route.fromUrl url)
                (Redirect (Session.fromViewer navKey config.token))
    in
    ( model, cmdMsg )



---- UPDATE ----


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotSession Session
    | GotNeedsReviewMsg NeedsReview.Msg
    | GotTransactionsMsg Transactions.Msg


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

        NeedsReview session ->
            NeedsReview.toSession session


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

        NeedsReview needsReview ->
            needsReview.aggregations


toToken : Model -> Token
toToken page =
    case page of
        Redirect session ->
            Api.Token ""

        NotFound session ->
            Api.Token ""

        Transactions transactions ->
            Api.Token transactions.config.token

        LinkBuilder linkBuilder ->
            Api.Token linkBuilder.config.token

        NeedsReview needsReview ->
            Api.Token needsReview.config.token


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

        NeedsReview needsReview ->
            needsReview.config


changeRouteTo : Url -> Config -> Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo url config maybeRoute model =
    let
        session =
            toSession model

        committeeId =
            CommitteeId.parse url

        aggregations =
            toAggregations model
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
                committeeId
                |> updateWith Transactions GotTransactionsMsg model

        Just Route.Transactions ->
            Transactions.init
                config
                session
                aggregations
                committeeId
                |> updateWith Transactions GotTransactionsMsg model

        Just Route.LinkBuilder ->
            LinkBuilder.init
                config
                session
                aggregations
                committeeId
                |> updateWith LinkBuilder GotLinkBuilderMsg model

        Just Route.NeedsReview ->
            NeedsReview.init
                config
                session
                aggregations
                committeeId
                |> updateWith NeedsReview GotNeedsReviewMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case url.fragment of
                        Nothing ->
                            -- If we got a link that didn't include a fragment,
                            -- it's from one of those (href "") attributes that
                            -- we have to include to make the RealWorld CSS work.
                            --
                            -- In an application doing path routing instead of
                            -- fragment-based routing, this entire
                            -- `case url.fragment of` expression this comment
                            -- is inside would be unnecessary.
                            ( model, Cmd.none )

                        Just _ ->
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
                |> updateWith Transactions GotTransactionsMsg model

        ( GotLinkBuilderMsg subMsg, LinkBuilder linkBuilder ) ->
            LinkBuilder.update subMsg linkBuilder
                |> updateWith LinkBuilder GotLinkBuilderMsg model

        ( GotNeedsReviewMsg subMsg, NeedsReview disbursements ) ->
            NeedsReview.update subMsg disbursements
                |> updateWith NeedsReview GotNeedsReviewMsg model

        ( GotSession session, Redirect _ ) ->
            ( Redirect session
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



---- VIEW ----


view : Model -> Document Msg
view model =
    let
        viewer =
            Session.viewer (toSession model)

        aggregations =
            toAggregations model

        config =
            toConfig model

        viewPage page toMsg conf =
            let
                { title, body } =
                    Page.view config aggregations page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view config aggregations Page.Other Blank.view

        NotFound _ ->
            Page.view config aggregations Page.Other NotFound.view

        Transactions transactions ->
            viewPage Page.Transactions GotTransactionsMsg (Transactions.view transactions)

        LinkBuilder linkBuilder ->
            viewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        NeedsReview disbursements ->
            viewPage Page.NeedsReview GotNeedsReviewMsg (NeedsReview.view disbursements)



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Transactions transactions ->
            Sub.map GotTransactionsMsg (Transactions.subscriptions transactions)

        LinkBuilder linkBuilder ->
            Sub.map GotLinkBuilderMsg (LinkBuilder.subscriptions linkBuilder)

        NeedsReview disbursements ->
            Sub.map GotNeedsReviewMsg (NeedsReview.subscriptions disbursements)

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


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())
