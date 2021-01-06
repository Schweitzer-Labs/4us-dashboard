module Main exposing (..)

import Api
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode exposing (Value)
import Page
import Page.Blank as Blank
import Page.Home as Home
import Page.LinkBuilder as LinkBuilder
import Page.NotFound as NotFound
import Page.Disbursements as Disbursements
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Viewer exposing (Viewer)


---- MODEL ----

type Model
    = NotFound Session
    | Redirect Session
    | Home Home.Model
    | LinkBuilder LinkBuilder.Model
    | Disbursements Disbursements.Model


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromViewer navKey maybeViewer))


---- UPDATE ----

type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotDisbursementsMsg Disbursements.Msg
    | GotSession Session

toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        LinkBuilder session ->
            LinkBuilder.toSession session

        Disbursements session ->
            Disbursements.toSession session


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )
        -- rest of the routes
        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg model
        Just Route.LinkBuilder ->
            LinkBuilder.init session
                |> updateWith LinkBuilder GotLinkBuilderMsg model
        Just Route.Disbursements ->
            Disbursements.init session
                |> updateWith Disbursements GotDisbursementsMsg model

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
            changeRouteTo (Route.fromUrl url) model

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg model

        ( GotLinkBuilderMsg subMsg, LinkBuilder linkBuilder ) ->
            LinkBuilder.update subMsg linkBuilder
                |> updateWith LinkBuilder GotLinkBuilderMsg model

        ( GotDisbursementsMsg subMsg, Disbursements disbursements ) ->
            Disbursements.update subMsg disbursements
                |> updateWith Disbursements GotDisbursementsMsg model

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

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view viewer page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view viewer Page.Other Blank.view

        NotFound _ ->
            Page.view viewer Page.Other NotFound.view

        Home home ->
            viewPage Page.Home GotHomeMsg (Home.view home)

        LinkBuilder linkBuilder ->
            viewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        Disbursements disbursements ->
            viewPage Page.Disbursements GotDisbursementsMsg (Disbursements.view disbursements)


---- PROGRAM ----

subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model))

        Home home ->
            Sub.map GotHomeMsg (Home.subscriptions home)

        LinkBuilder linkBuilder ->
            Sub.map GotLinkBuilderMsg (LinkBuilder.subscriptions linkBuilder)

        Disbursements disbursements ->
            Sub.map GotDisbursementsMsg (Disbursements.subscriptions disbursements)



main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
