module Main exposing (Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Aggregations
import Api exposing (Token)
import Browser exposing (Document)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import CommitteeId
import Html exposing (Html)
import Http
import Page
import Page.Blank as Blank
import Page.Contributions as Contributions
import Page.Disbursements as Disbursements
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
    | Contributions Contributions.Model
    | LinkBuilder LinkBuilder.Model
    | Disbursements Disbursements.Model
    | NeedsReview NeedsReview.Model
    | Transactions Transactions.Model


init : String -> Url -> Nav.Key -> ( Model, Cmd Msg )
init token url navKey =
    let
        ( model, cmdMsg ) =
            changeRouteTo
                url
                (Api.Token token)
                (Route.fromUrl url)
                (Redirect (Session.fromViewer navKey token))
    in
    ( model, cmdMsg )



---- UPDATE ----


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotContributionsMsg Contributions.Msg
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotDisbursementsMsg Disbursements.Msg
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

        Contributions contributions ->
            Contributions.toSession contributions

        Transactions transactions ->
            Transactions.toSession transactions

        LinkBuilder session ->
            LinkBuilder.toSession session

        Disbursements session ->
            Disbursements.toSession session

        NeedsReview session ->
            NeedsReview.toSession session


toAggregations : Model -> Aggregations.Model
toAggregations page =
    case page of
        Redirect session ->
            Aggregations.init

        NotFound session ->
            Aggregations.init

        Contributions contributions ->
            contributions.aggregations

        Transactions transactions ->
            transactions.aggregations

        LinkBuilder linkBuilder ->
            linkBuilder.aggregations

        Disbursements disbursement ->
            disbursement.aggregations

        NeedsReview needsReview ->
            needsReview.aggregations


toToken : Model -> Token
toToken page =
    case page of
        Redirect session ->
            Api.Token ""

        NotFound session ->
            Api.Token ""

        Contributions contributions ->
            contributions.token

        Transactions transactions ->
            transactions.token

        LinkBuilder linkBuilder ->
            linkBuilder.token

        Disbursements disbursement ->
            disbursement.token

        NeedsReview needsReview ->
            needsReview.token


changeRouteTo : Url -> Token -> Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo url token maybeRoute model =
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
                token
                session
                aggregations
                committeeId
                |> updateWith Transactions GotTransactionsMsg model

        Just Route.Transactions ->
            Transactions.init
                token
                session
                aggregations
                committeeId
                |> updateWith Transactions GotTransactionsMsg model

        Just Route.Analytics ->
            Contributions.init
                token
                session
                aggregations
                committeeId
                |> updateWith Contributions GotContributionsMsg model

        Just Route.LinkBuilder ->
            LinkBuilder.init
                token
                session
                aggregations
                committeeId
                |> updateWith LinkBuilder GotLinkBuilderMsg model

        Just Route.Disbursements ->
            Disbursements.init
                token
                session
                aggregations
                committeeId
                |> updateWith Disbursements GotDisbursementsMsg model

        Just Route.NeedsReview ->
            NeedsReview.init
                token
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
            changeRouteTo url (toToken model) (Route.fromUrl url) model

        ( GotTransactionsMsg subMsg, Transactions home ) ->
            Transactions.update subMsg home
                |> updateWith Transactions GotTransactionsMsg model

        ( GotLinkBuilderMsg subMsg, LinkBuilder linkBuilder ) ->
            LinkBuilder.update subMsg linkBuilder
                |> updateWith LinkBuilder GotLinkBuilderMsg model

        ( GotDisbursementsMsg subMsg, Disbursements disbursements ) ->
            Disbursements.update subMsg disbursements
                |> updateWith Disbursements GotDisbursementsMsg model

        ( GotContributionsMsg subMsg, Contributions disbursements ) ->
            Contributions.update subMsg disbursements
                |> updateWith Contributions GotContributionsMsg model

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

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view viewer aggregations page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view viewer aggregations Page.Other Blank.view

        NotFound _ ->
            Page.view viewer aggregations Page.Other NotFound.view

        Contributions contributions ->
            viewPage Page.Analytics GotContributionsMsg (Contributions.view contributions)

        Transactions transactions ->
            viewPage Page.Transactions GotTransactionsMsg (Transactions.view transactions)

        LinkBuilder linkBuilder ->
            viewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        Disbursements disbursements ->
            viewPage Page.Disbursements GotDisbursementsMsg (Disbursements.view disbursements)

        NeedsReview disbursements ->
            viewPage Page.NeedsReview GotNeedsReviewMsg (NeedsReview.view disbursements)



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Contributions contributions ->
            Sub.map GotContributionsMsg (Contributions.subscriptions contributions)

        Transactions transactions ->
            Sub.map GotTransactionsMsg (Transactions.subscriptions transactions)

        LinkBuilder linkBuilder ->
            Sub.map GotLinkBuilderMsg (LinkBuilder.subscriptions linkBuilder)

        Disbursements disbursements ->
            Sub.map GotDisbursementsMsg (Disbursements.subscriptions disbursements)

        NeedsReview disbursements ->
            Sub.map GotNeedsReviewMsg (NeedsReview.subscriptions disbursements)

        _ ->
            Sub.none


main : Program String Model Msg
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
