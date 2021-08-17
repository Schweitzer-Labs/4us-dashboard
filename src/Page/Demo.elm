module Page.Demo exposing (Model, Msg(..), formRow, getTransactions, init, subscriptions, toSession, update, view)

import Aggregations
import Api.GetTxns as GetTxns
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cognito exposing (loginUrl)
import Committee
import Config exposing (Config)
import Html exposing (..)
import Html.Attributes as SvgA exposing (class, for)
import Http
import Session exposing (Session)
import TransactionType exposing (TransactionType)



-- MODEL


type alias Model =
    { session : Session
    , committeeId : String
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , config : Config
    , password : String
    }


init : Config -> Session -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
init config session aggs committee committeeId =
    let
        initModel =
            { session = session
            , committeeId = committeeId
            , aggregations = aggs
            , committee = committee
            , config = config
            , password = ""
            }
    in
    ( initModel
    , getTransactions initModel Nothing
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US - Demo"
    , content =
        div [] [ formRow model ]
    }



-- Form


formRow : Model -> Html Msg
formRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            [ Col.sm5 ]
            [ Form.group []
                [ Form.label [ for "password" ] [ text "Source" ]
                , Input.text [ Input.id "password", Input.onInput PasswordUpdated ]
                , Form.help [] [ text "" ]
                ]
            ]
        ]



-- UPDATE


type Msg
    = GotSession Session
    | PasswordUpdated String
    | GotTransactionsData (Result Http.Error GetTxns.Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PasswordUpdated str ->
            ( { model | password = str }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GotTransactionsData res ->
            case res of
                Ok body ->
                    ( { model
                        | aggregations = body.data.aggregations
                        , committee = body.data.committee
                      }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        { cognitoDomain, cognitoClientId, redirectUri } =
                            model.config
                    in
                    ( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )



-- HTTP


getTransactions : Model -> Maybe TransactionType -> Cmd Msg
getTransactions model maybeTxnType =
    GetTxns.send GotTransactionsData model.config <| GetTxns.encode model.committeeId maybeTxnType Nothing Nothing



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
