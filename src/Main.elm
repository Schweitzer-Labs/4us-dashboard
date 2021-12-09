port module Main exposing (Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Aggregations
import Browser exposing (Document)
import Browser.Navigation as Nav
import Cognito
import Committee
import CommitteeId
import Config exposing (Config, FlagConfig)
import Html exposing (Html)
import Page
import Page.Blank as Blank
import Page.Demo as Demo
import Page.Home as Home
import Page.LinkBuilder as LinkBuilder
import Page.NotFound as NotFound
import Page.Transactions as Transactions
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)


port putTokenInLocalStorage : String -> Cmd msg


port tokenHasBeenSet : (String -> msg) -> Sub msg



---- MODEL ----


type Model
    = NotFound Session
    | Redirect Session
    | LinkBuilder LinkBuilder.Model
    | Transactions Transactions.Model
    | Demo Demo.Model
    | Home Home.Model


init : FlagConfig -> Url -> Nav.Key -> ( Model, Cmd Msg )
init fconfig url navKey =
    changeRouteTo
        url
        fconfig
        (Route.fromUrl url)
        (Redirect (Session.build navKey fconfig.token))


changeRouteTo : Url -> FlagConfig -> Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo url flagConfig maybeRoute model =
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
    case ( maybeRoute, flagConfig.token ) of
        -- No token behavior
        ( Just (Route.Home maybeToken maybeCommitteeId), Nothing ) ->
            case ( maybeToken, maybeCommitteeId ) of
                ( Just token, Just id ) ->
                    ( Redirect session, putTokenInLocalStorage token )

                _ ->
                    ( NotFound session, Cmd.none )

        ( _, Nothing ) ->
            ( Redirect session
            , flagConfig
                |> Cognito.fromFlagConfig
                |> Cognito.toLoginUrl Nothing
                |> Nav.load
            )

        ( Just (Route.Home _ _), Just token ) ->
            Home.init
                (Config.fromFlags token flagConfig)
                (Session.setToken token session)
                |> updateWith Home GotHomeMsg

        ( Just (Route.Transactions id), Just token ) ->
            Transactions.init
                (Config.fromFlags token flagConfig)
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith Transactions GotTransactionsMsg

        ( Just (Route.LinkBuilder id), Just token ) ->
            LinkBuilder.init
                (Config.fromFlags token flagConfig)
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith LinkBuilder GotLinkBuilderMsg

        ( Just (Route.Demo id), Just token ) ->
            Demo.init
                (Config.fromFlags token flagConfig)
                (Session.setToken token session)
                aggregations
                committee
                id
                |> updateWith Demo GotDemoMsg

        ( _, _ ) ->
            ( NotFound session, Cmd.none )



---- UPDATE ----


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


toConfig : Model -> Config
toConfig page =
    case page of
        Transactions transactions ->
            transactions.config

        LinkBuilder linkBuilder ->
            linkBuilder.config

        Demo demo ->
            demo.config

        _ ->
            { apiEndpoint = ""
            , cognitoClientId = ""
            , redirectUri = ""
            , donorUrl = ""
            , token = ""
            , cognitoDomain = ""
            }


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotLinkBuilderMsg LinkBuilder.Msg
    | GotSession Session
    | GotTransactionsMsg Transactions.Msg
    | GotDemoMsg Demo.Msg
    | GotHomeMsg Home.Msg
    | TokenHasBeenSet String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( TokenHasBeenSet str, _ ) ->
            ( model, Cmd.none )

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.toNavKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo url (Config.toFlags <| toConfig model) (Route.fromUrl url) model

        ( GotTransactionsMsg subMsg, Transactions home ) ->
            Transactions.update subMsg home
                |> updateWith Transactions GotTransactionsMsg

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

        config =
            toConfig model

        userViewPage page toMsg conf =
            let
                { title, body } =
                    Page.userLayout config page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }

        committeeViewPage page toMsg conf =
            let
                { title, body } =
                    Page.committeeLayout config aggregations committee page conf
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Home home ->
            userViewPage Page.Home GotHomeMsg (Home.view home)

        Redirect _ ->
            Page.userLayout config Page.Other Blank.view

        NotFound _ ->
            Page.userLayout config Page.Other NotFound.view

        Transactions transactions ->
            committeeViewPage Page.Transactions GotTransactionsMsg (Transactions.view transactions)

        LinkBuilder linkBuilder ->
            committeeViewPage Page.LinkBuilder GotLinkBuilderMsg (LinkBuilder.view linkBuilder)

        Demo demo ->
            committeeViewPage Page.Demo GotDemoMsg (Demo.view demo)



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

                _ ->
                    Sub.none
    in
    Sub.batch [ tokenHasBeenSet TokenHasBeenSet, pageSub ]


main : Program FlagConfig Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
