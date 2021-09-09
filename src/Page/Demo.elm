module Page.Demo exposing (Model, Msg(..), formRow, getTransactions, init, subscriptions, toSession, update, view)

import Aggregations
import Api
import Api.GenDemoCommittee as GenDemoCommittee
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.ReconcileDemoTxn as ReconcileDemoTxs
import Api.SeedDemoBankRecords as SeedDemoBankRecords
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cognito exposing (loginUrl)
import Committee
import Config exposing (Config)
import Errors
import Html exposing (..)
import Html.Attributes as SvgA exposing (class, for, href, target)
import Http
import LabelWithData exposing (dataText)
import Session exposing (Session)
import SubmitButton
import Time
import TransactionType exposing (TransactionType)



-- MODEL


type alias Model =
    { session : Session
    , committeeId : String
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , isSubmitting : Bool
    , config : Config
    , password : String
    , maybeDemoCommitteeId : Maybe String
    , errors : List String
    , loadingProgress : Int
    , eventLogs : List String
    , demoView : DemoView
    , transactionType : Maybe String
    , seedMoneyInLoading : Bool
    , seedMoneyOutLoading : Bool
    , reconcileOneLoading : Bool
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
            , isSubmitting = False
            , password = ""
            , maybeDemoCommitteeId = Nothing
            , errors = []
            , loadingProgress = 0
            , eventLogs = []
            , demoView = GenerateCommittee
            , transactionType = Nothing
            , seedMoneyInLoading = False
            , seedMoneyOutLoading = False
            , reconcileOneLoading = False
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
        div []
            [ case model.demoView of
                GenerateCommittee ->
                    formRow model

                ManageDemoCommittee ->
                    manageDemoView model
            ]
    }


type DemoView
    = GenerateCommittee
    | ManageDemoCommittee



-- Form


formRow : Model -> Html Msg
formRow model =
    Grid.containerFluid
        [ Spacing.mt3, class "fade-in" ]
    <|
        [ Grid.row []
            [ Grid.col [] [ h2 [] [ text "Generate Demo Committee" ] ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.xs6 ]
              <|
                Errors.view model.errors
                    ++ [ Form.group []
                            [ Form.label [ for "password" ] [ text "Passcode" ]
                            , Input.password [ Input.id "password", Input.onInput PasswordUpdated, Input.value model.password ]
                            , Form.help [] [ text "Or maybe you shouldn't be here..." ]
                            ]
                       ]
                    ++ SubmitButton.blockWithLoadingBar [] "Generate" GenDemoCommitteeClicked model.isSubmitting model.loadingProgress
            ]
        ]
            ++ urlRow model


manageDemoView : Model -> Html Msg
manageDemoView model =
    Grid.containerFluid
        [ Spacing.mt3, class "fade-in" ]
    <|
        [ Grid.row []
            [ Grid.col [] [ dataText "Manage Demo Committee" ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.xs3 ]
              <|
                Errors.view model.errors
                    ++ manageDemoUrlRow model
                    ++ demoLabel "Actions"
                    ++ [ SubmitButton.block [] "Seed Money In" SeedDemoBankRecordInClicked model.seedMoneyInLoading False ]
                    ++ [ SubmitButton.block [ Spacing.mt3 ] "Seed Money Out" SeedDemoBankRecordOutClicked model.seedMoneyOutLoading False ]
                    ++ [ SubmitButton.block [ Spacing.mt3 ] "Reconcile One" ReconcileDemoTxnClicked model.reconcileOneLoading False ]
                    ++ [ resetButton ResetView ]
                    ++ demoLabel "Event Log"
                    ++ [ eventList model ]
            ]
        ]


demoLabel : String -> List (Html msg)
demoLabel label =
    [ div [ Spacing.mt3 ] [ text label ] ]


resetButton : Msg -> Html Msg
resetButton msg =
    Button.button
        [ Button.outlineDanger
        , Button.onClick msg
        , Button.disabled False
        , Button.block
        , Button.attrs [ Spacing.mt3 ]
        ]
        [ text "Reset" ]


eventList : Model -> Html msg
eventList model =
    model.eventLogs
        |> List.map (\e -> li [] [ text e ])
        |> ul []


idToCommitteeUrl : Config -> String -> String
idToCommitteeUrl config id =
    config.redirectUri ++ "/committee/" ++ id


manageDemoUrlRow : Model -> List (Html Msg)
manageDemoUrlRow model =
    case model.maybeDemoCommitteeId of
        Just id ->
            demoLabel "Committee Link"
                ++ (List.singleton <|
                        a
                            [ href <| idToCommitteeUrl model.config id, target "_blank" ]
                            [ text <| idToCommitteeUrl model.config id ]
                   )

        Nothing ->
            []


urlRow : Model -> List (Html Msg)
urlRow model =
    case model.maybeDemoCommitteeId of
        Just id ->
            List.singleton <|
                Grid.row
                    []
                    [ Grid.col []
                        [ h5 [ Spacing.mt5 ] [ text "Committee Link" ]
                        , a
                            [ href <| idToCommitteeUrl model.config id, class "d-block max-height-80", target "_blank", Spacing.mt3 ]
                            [ text <| idToCommitteeUrl model.config id ]
                        ]
                    ]

        Nothing ->
            []



-- UPDATE


type Msg
    = GotSession Session
    | PasswordUpdated String
    | GenDemoCommitteeGotResp (Result Http.Error MutationResponse)
    | GotTransactionsData (Result Http.Error GetTxns.Model)
    | GenDemoCommitteeClicked
    | Tick Time.Posix
    | SeedDemoBankRecordInClicked
    | SeedDemoBankRecordOutClicked
    | SeedDemoBankRecordGotResp (Result Http.Error MutationResponse)
    | ReconcileDemoTxnGotResp (Result Http.Error MutationResponse)
    | ReconcileDemoTxnClicked
    | ResetView
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            case model.isSubmitting of
                True ->
                    ( { model | loadingProgress = model.loadingProgress + 7 }, Cmd.none )

                False ->
                    ( model, Cmd.none )

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
                        , errors = []
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.config model.committeeId )

        GenDemoCommitteeClicked ->
            ( { model | isSubmitting = True, errors = [] }, genDemoCommittee model )

        GenDemoCommitteeGotResp res ->
            case res of
                Ok createContribResp ->
                    case createContribResp of
                        Success id ->
                            ( { model
                                | isSubmitting = False
                                , maybeDemoCommitteeId = Just id
                                , errors = []
                                , loadingProgress = 0
                                , demoView = ManageDemoCommittee
                              }
                            , Cmd.none
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                                , isSubmitting = False
                                , loadingProgress = 0
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = [ Api.decodeError err ]
                        , isSubmitting = False
                        , loadingProgress = 0
                      }
                    , Cmd.none
                    )

        SeedDemoBankRecordInClicked ->
            ( { model
                | seedMoneyInLoading = True
              }
            , seedDemoBankRecord model (Just "Contribution")
            )

        SeedDemoBankRecordOutClicked ->
            ( { model
                | seedMoneyOutLoading = True
              }
            , seedDemoBankRecord model (Just "Disbursement")
            )

        SeedDemoBankRecordGotResp res ->
            case res of
                Ok seedDemoResp ->
                    case seedDemoResp of
                        Success id ->
                            ( { model
                                | errors = []
                                , eventLogs = model.eventLogs ++ [ "Bank Record Seeded" ]
                                , seedMoneyInLoading = False
                                , seedMoneyOutLoading = False
                              }
                            , Cmd.none
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                                , seedMoneyInLoading = False
                                , seedMoneyOutLoading = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = [ Api.decodeError err ]
                        , isSubmitting = False
                        , loadingProgress = 0
                        , seedMoneyInLoading = False
                        , seedMoneyOutLoading = False
                      }
                    , Cmd.none
                    )

        ReconcileDemoTxnClicked ->
            ( { model | reconcileOneLoading = True }, reconcileDemoTxn model )

        ReconcileDemoTxnGotResp res ->
            case res of
                Ok seedDemoResp ->
                    case seedDemoResp of
                        Success id ->
                            ( { model
                                | errors = []
                                , eventLogs = model.eventLogs ++ [ "Transaction Reconciled" ]
                                , reconcileOneLoading = False
                              }
                            , Cmd.none
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                                , reconcileOneLoading = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = [ Api.decodeError err ]
                        , reconcileOneLoading = False
                      }
                    , Cmd.none
                    )

        ResetView ->
            ( { model
                | demoView = GenerateCommittee
                , isSubmitting = False
                , password = ""
                , maybeDemoCommitteeId = Nothing
                , errors = []
                , loadingProgress = 0
                , eventLogs = []
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- HTTP


getTransactions : Model -> Maybe TransactionType -> Cmd Msg
getTransactions model maybeTxnType =
    GetTxns.send GotTransactionsData model.config <| GetTxns.encode model.committeeId maybeTxnType Nothing Nothing



-- Generate Committee


genDemoCommittee : Model -> Cmd Msg
genDemoCommittee model =
    GenDemoCommittee.send GenDemoCommitteeGotResp model.config <| GenDemoCommittee.encode toGenDemoCommittee model


toGenDemoCommittee : Model -> GenDemoCommittee.EncodeModel
toGenDemoCommittee model =
    { password = model.password, demoType = "Clean" }



-- Seed Bank Record


toSeedDemoBankRecord : Model -> SeedDemoBankRecords.EncodeModel
toSeedDemoBankRecord model =
    { password = model.password
    , committeeId = Maybe.withDefault "" model.maybeDemoCommitteeId
    , transactionType = Maybe.withDefault "" model.transactionType
    }


seedDemoBankRecord : Model -> Maybe String -> Cmd Msg
seedDemoBankRecord model txnType =
    let
        state =
            { model | transactionType = txnType }
    in
    SeedDemoBankRecords.send SeedDemoBankRecordGotResp model.config <| SeedDemoBankRecords.encode toSeedDemoBankRecord state



-- Reconcile Bank Record


toReconcileDemoTxn : Model -> ReconcileDemoTxs.EncodeModel
toReconcileDemoTxn model =
    { password = model.password
    , committeeId = Maybe.withDefault "" model.maybeDemoCommitteeId
    }


reconcileDemoTxn : Model -> Cmd Msg
reconcileDemoTxn model =
    ReconcileDemoTxs.send ReconcileDemoTxnGotResp model.config <| ReconcileDemoTxs.encode toReconcileDemoTxn model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
