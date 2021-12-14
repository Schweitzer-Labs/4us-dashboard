port module Main exposing (Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Aggregations
import Browser exposing (Document)
import Browser.Navigation as Nav
import Cognito
import Committee
import Config
import Flags
import Html exposing (Html)
import Page
import Page.Blank as Blank
import Page.Demo as Demo
import Page.Home as Home
import Page.LinkBuilder as LinkBuilder
import Page.LogIn as LogIn
import Page.NotFound as NotFound
import Page.Transactions as Transactions
import Route exposing (Route)
import Session
import Url exposing (Url)


port tokenHasBeenSet : (String -> msg) -> Sub msg



---- MODEL ----


type Model
    = NotFound Config.Model Session.Model
    | Redirect Config.Model Session.Model
    | LinkBuilder LinkBuilder.Model
    | Transactions Transactions.Model
    | Demo Demo.Model
    | Home Home.Model
    | LogIn LogIn.Model


init : Flags.Model -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo
        flags
        (Route.fromUrl url)
        (Redirect (Flags.toConfig flags) (Session.build navKey <| Flags.toMaybeToken flags))


changeRouteTo : Flags.Model -> Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo flags maybeRoute model =
    let
        session =
            toSession model

        aggregations =
            toAggregations model

        committee =
            toCommittee model

        config =
            toConfig model
    in
    case ( maybeRoute, Flags.toMaybeToken flags ) of
        -- No token behavior
        ( Just route, Nothing ) ->
            LogIn.init
                config
                (toSession model)
                route
                |> updateWith LogIn GotLogInMsg

        ( Just Route.Home, Just token ) ->
            Home.init
                config
                (Session.setToken token session)
                |> updateWith Home GotHomeMsg

        ( Just (Route.Transactions id), Just token ) ->
            Transactions.init
                config
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith Transactions GotTransactionsMsg

        ( Just (Route.LinkBuilder id), Just token ) ->
            LinkBuilder.init
                config
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith LinkBuilder GotLinkBuilderMsg

        ( Just (Route.Demo id), Just token ) ->
            Demo.init
                config
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith Demo GotDemoMsg

        ( _, _ ) ->
            ( NotFound config session, Cmd.none )



---- UPDATE ----


toSession : Model -> Session.Model
toSession page =
    case page of
        Redirect _ session ->
            session

        NotFound _ session ->
            session

        Transactions transactions ->
            Transactions.toSession transactions

        LinkBuilder session ->
            LinkBuilder.toSession session

        Demo session ->
            Demo.toSession session

        LogIn session ->
            LogIn.toSession session

        Home session ->
            Home.toSession session


toAggregations : Model -> Aggregations.Model
toAggregations page =
    case page of
        Transactions transactions ->
            transactions.aggregations

        LinkBuilder linkBuilder ->
            linkBuilder.aggregations

        Demo demo ->
            demo.aggregations

        _ ->
            Aggregations.init


toCommittee : Model -> Committee.Model
toCommittee page =
    case page of
        Transactions transactions ->
            transactions.committee

        LinkBuilder linkBuilder ->
            linkBuilder.committee

        Demo demo ->
            demo.committee

        _ ->
            Committee.init


toConfig : Model -> Config.Model
toConfig page =
    case page of
        Transactions transactions ->
            Transactions.toConfig transactions

        LinkBuilder linkBuilder ->
            LinkBuilder.toConfig linkBuilder

        Demo demo ->
            Demo.toConfig demo

        Redirect config _ ->
            config

        LogIn logIn ->
            LogIn.toConfig logIn

        Home home ->
            Home.toConfig home

        NotFound config _ ->
            config


setSession : Session.Model -> Model -> Model
setSession session model =
    case model of
        Transactions transactions ->
            Transactions { transactions | session = session }

        LinkBuilder linkBuilder ->
            LinkBuilder <| LinkBuilder.setSession session linkBuilder

        Demo demo ->
            Demo <| Demo.setSession session demo

        Redirect config _ ->
            Redirect config session

        LogIn logIn ->
            LogIn <| LogIn.setSession session logIn

        Home home ->
            Home <| Home.setSession session home

        NotFound config _ ->
            NotFound config session


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotTransactionsMsg Transactions.Msg
    | GotDemoMsg Demo.Msg
    | GotHomeMsg Home.Msg
    | GotLogInMsg LogIn.Msg
    | TokenHasBeenSet String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( TokenHasBeenSet token, _ ) ->
            let
                newSession =
                    Session.setToken token (toSession model)

                newModel =
                    setSession newSession model
            in
            ( newModel
            , Cmd.none
            )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        navKey =
                            Session.toNavKey (toSession model)

                        urlStr =
                            Url.toString url
                    in
                    ( model
                    , Nav.pushUrl navKey urlStr
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            let
                flags =
                    Flags.fromSessionAndConfig (toSession model) (toConfig model)

                route =
                    Route.fromUrl url
            in
            changeRouteTo flags route model

        ( GotTransactionsMsg subMsg, Transactions home ) ->
            Transactions.update subMsg home
                |> updateWith Transactions GotTransactionsMsg

        ( GotLogInMsg subMsg, LogIn logIn ) ->
            LogIn.update subMsg logIn
                |> updateWith LogIn GotLogInMsg

        ( GotLinkBuilderMsg subMsg, LinkBuilder linkBuilder ) ->
            LinkBuilder.update subMsg linkBuilder
                |> updateWith LinkBuilder GotLinkBuilderMsg

        ( GotDemoMsg subMsg, Demo demo ) ->
            Demo.update subMsg demo
                |> updateWith Demo GotDemoMsg

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg

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

        userViewPage page toMsg conf =
            let
                { title, body } =
                    Page.userLayout page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }

        committeeViewPage page toMsg conf =
            let
                { title, body } =
                    Page.committeeLayout aggregations committee page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Home home ->
            userViewPage Page.Home GotHomeMsg (Home.view home)

        Redirect _ _ ->
            Page.userLayout Page.Other Blank.view

        NotFound _ _ ->
            Page.userLayout Page.Other NotFound.view

        Transactions transactions ->
            committeeViewPage Page.Transactions GotTransactionsMsg (Transactions.view transactions)

        LinkBuilder linkBuilder ->
            committeeViewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        Demo demo ->
            committeeViewPage Page.Demo GotDemoMsg (Demo.view demo)

        LogIn logIn ->
            userViewPage Page.LogIn GotLogInMsg (LogIn.view logIn)



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        pageSub =
            case model of
                Transactions transactions ->
                    Sub.map GotTransactionsMsg (Transactions.subscriptions transactions)

                LinkBuilder linkBuilder ->
                    Sub.map GotLinkBuilderMsg (LinkBuilder.subscriptions linkBuilder)

                Demo demo ->
                    Sub.map GotDemoMsg (Demo.subscriptions demo)

                LogIn login ->
                    Sub.map GotLogInMsg (LogIn.subscriptions login)

                _ ->
                    Sub.none
    in
    Sub.batch [ tokenHasBeenSet TokenHasBeenSet, pageSub ]


main : Program Flags.Model Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
