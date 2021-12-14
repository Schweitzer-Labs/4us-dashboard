module Page.Demo exposing
    ( Model
    , Msg(..)
    , formRow
    , getTransactions
    , init
    , setSession
    , subscriptions
    , toConfig
    , toSession
    , update
    , view
    )

import Aggregations
import Api
import Api.GenDemoCommittee as GenDemoCommittee
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..), MutationResponseOnAll(..))
import Api.ReconcileDemoTxn as ReconcileDemoTxs
import Api.SeedDemoBankRecords as SeedDemoBankRecords
import Api.SeedExtContribs as SeedExtContribs
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cognito
import Committee
import Config
import Errors
import Html exposing (..)
import Html.Attributes as SvgA exposing (attribute, class, for, href, target)
import Http
import LabelWithData exposing (dataText)
import Session
import SubmitButton
import Time
import TransactionType exposing (TransactionType)



-- MODEL


type alias Model =
    { committeeId : String
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , isSubmitting : Bool
    , config : Config.Model
    , session : Session.Model
    , password : String
    , maybeDemoCommitteeId : Maybe String
    , errors : List String
    , loadingProgress : Int
    , eventLogs : List String
    , demoView : DemoView
    , transactionType : Maybe String
    , externalSource : Maybe String
    , seedMoneyInLoading : Bool
    , seedMoneyOutLoading : Bool
    , reconcileOneLoading : Bool
    , seedActBlueLoading : Bool
    , seedWinRedLoading : Bool
    , seedPayoutLoading : Bool
    , amount : Maybe String
    }


init : Config.Model -> Session.Model -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
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
            , externalSource = Nothing
            , seedMoneyInLoading = False
            , seedMoneyOutLoading = False
            , reconcileOneLoading = False
            , seedActBlueLoading = False
            , seedWinRedLoading = False
            , seedPayoutLoading = False
            , amount = Nothing
            }
    in
    ( initModel
    , getTransactions initModel Nothing
    )


defaultExtTxnAmount : String
defaultExtTxnAmount =
    "28814"



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


type TxnType
    = Contribution
    | Disbursement


type ExternalSource
    = ActBlue
    | WinRed


externalSourceToString : ExternalSource -> String
externalSourceToString externalSource =
    case externalSource of
        ActBlue ->
            "ActBlue"

        WinRed ->
            "WinRed"


externalSourceLoading : Model -> ExternalSource -> Model
externalSourceLoading model source =
    case source of
        ActBlue ->
            { model
                | seedActBlueLoading = True
                , seedWinRedLoading = False
            }

        WinRed ->
            { model
                | seedActBlueLoading = False
                , seedWinRedLoading = True
            }


txnTypeToString : TxnType -> String
txnTypeToString transactionType =
    case transactionType of
        Contribution ->
            "Contribution"

        Disbursement ->
            "Disbursement"



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
            [ Grid.col [ Col.xs12 ] <|
                [ dataText "Manage Demo Committee" ]
                    ++ Errors.view model.errors
                    ++ manageDemoUrl model
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.xs3 ]
              <|
                demoLabel "General Actions"
                    ++ [ SubmitButton.block [ attribute "data-cy" "seedMoneyIn" ] "Seed Money In" (SeedBankRecordClicked Contribution) model.seedMoneyInLoading False ]
                    ++ [ SubmitButton.block [ attribute "data-cy" "seedMoneyOut", Spacing.mt3 ] "Seed Money Out" (SeedBankRecordClicked Disbursement) model.seedMoneyOutLoading False ]
                    ++ [ SubmitButton.block [ attribute "data-cy" "reconcileOne", Spacing.mt3 ] "Reconcile One" ReconcileDemoTxnClicked model.reconcileOneLoading False ]
                    ++ demoLabel "External Contributions"
                    ++ [ SubmitButton.block [ attribute "data-cy" "seedActBlue", Spacing.mt3 ] "Seed ActBlue" (SeedExtContribsClicked ActBlue) model.seedActBlueLoading False ]
                    ++ [ SubmitButton.block [ attribute "data-cy" "seedWinRed", Spacing.mt3 ] "Seed WinRed" (SeedExtContribsClicked WinRed) model.seedWinRedLoading False ]
                    ++ [ SubmitButton.block [ attribute "data-cy" "seedPayout", Spacing.mt3 ] "Seed Payout" (SeedExtPayoutClicked Contribution) model.seedPayoutLoading False ]
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


idToCommitteeUrl : Config.Model -> String -> String
idToCommitteeUrl config id =
    config.redirectUri ++ "/committee/" ++ id


manageDemoUrl : Model -> List (Html Msg)
manageDemoUrl model =
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
    = GotSession Session.Model
    | PasswordUpdated String
    | GenDemoCommitteeGotResp (Result Http.Error MutationResponse)
    | GotTransactionsData (Result Http.Error GetTxns.Model)
    | GenDemoCommitteeClicked
    | Tick Time.Posix
    | SeedBankRecordClicked TxnType
    | SeedDemoBankRecordGotResp (Result Http.Error MutationResponse)
    | ReconcileDemoTxnGotResp (Result Http.Error MutationResponse)
    | ReconcileDemoTxnClicked
    | ResetView
    | SeedExtContribsClicked ExternalSource
    | SeedExtContribsGotResp (Result Http.Error MutationResponseOnAll)
    | SeedExtPayoutClicked TxnType
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
                    ( model
                    , model.config
                        |> Cognito.fromConfig
                        |> Cognito.toLoginUrl (Just model.committeeId)
                        |> load
                    )

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
                        | errors = Api.decodeError err
                        , isSubmitting = False
                        , loadingProgress = 0
                      }
                    , Cmd.none
                    )

        SeedBankRecordClicked txnType ->
            let
                loadingModel =
                    if txnType == Disbursement then
                        { model | seedMoneyOutLoading = True }

                    else
                        { model | seedMoneyInLoading = True }
            in
            ( { loadingModel
                | transactionType = Just <| txnTypeToString txnType
              }
            , seedDemoBankRecord
                { model = model
                , txnType = Just <| txnTypeToString txnType
                , amount = Nothing
                }
            )

        SeedDemoBankRecordGotResp res ->
            case res of
                Ok seedDemoResp ->
                    case seedDemoResp of
                        Success id ->
                            let
                                txn =
                                    Maybe.withDefault "" model.transactionType

                                eventLogMessage =
                                    case model.seedPayoutLoading of
                                        True ->
                                            model.eventLogs ++ [ "External Payout Record Seeded" ]

                                        False ->
                                            model.eventLogs ++ [ txn ++ " Bank Record" ++ " Seeded" ]
                            in
                            ( { model
                                | errors = []
                                , eventLogs = eventLogMessage
                                , seedMoneyInLoading = False
                                , seedMoneyOutLoading = False
                                , seedPayoutLoading = False
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
                                , seedPayoutLoading = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = Api.decodeError err
                        , isSubmitting = False
                        , loadingProgress = 0
                        , seedMoneyInLoading = False
                        , seedMoneyOutLoading = False
                      }
                    , Cmd.none
                    )

        SeedExtContribsClicked source ->
            let
                extSource =
                    Just <| externalSourceToString source

                state =
                    externalSourceLoading model source
            in
            ( state
            , seedExtContribs model extSource
            )

        SeedExtContribsGotResp res ->
            case res of
                Ok seedExtContribRes ->
                    case seedExtContribRes of
                        SuccessAll idList ->
                            ( { model
                                | errors = []
                                , eventLogs = model.eventLogs ++ [ "ActBlue Contributions Seeded" ]
                                , seedActBlueLoading = False
                                , seedWinRedLoading = False
                              }
                            , Cmd.none
                            )

                        ResValidationFailureAll errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                                , seedActBlueLoading = False
                                , seedWinRedLoading = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = Api.decodeError err
                        , isSubmitting = False
                        , loadingProgress = 0
                        , seedActBlueLoading = False
                        , seedWinRedLoading = False
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
                        | errors = Api.decodeError err
                        , reconcileOneLoading = False
                      }
                    , Cmd.none
                    )

        SeedExtPayoutClicked txnType ->
            ( { model
                | transactionType = Just <| txnTypeToString txnType
                , seedPayoutLoading = True
              }
            , seedDemoBankRecord
                { model = model
                , txnType = Just <| txnTypeToString txnType
                , amount = Just defaultExtTxnAmount
                }
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
    GetTxns.send GotTransactionsData model.config model.session <| GetTxns.encode model.committeeId maybeTxnType Nothing Nothing



-- Generate Committee


genDemoCommittee : Model -> Cmd Msg
genDemoCommittee model =
    GenDemoCommittee.send GenDemoCommitteeGotResp model.config model.session <| GenDemoCommittee.encode toGenDemoCommittee model


toGenDemoCommittee : Model -> GenDemoCommittee.EncodeModel
toGenDemoCommittee model =
    { password = model.password, demoType = "Clean" }



-- Seed Bank Record


toSeedDemoBankRecord : Model -> SeedDemoBankRecords.EncodeModel
toSeedDemoBankRecord model =
    { password = model.password
    , committeeId = Maybe.withDefault "" model.maybeDemoCommitteeId
    , transactionType = Maybe.withDefault "" model.transactionType
    , amount = Maybe.withDefault "" model.amount
    }


type alias SeedDemoBankRecordConfig =
    { model : Model
    , txnType : Maybe String
    , amount : Maybe String
    }


seedDemoBankRecord : SeedDemoBankRecordConfig -> Cmd Msg
seedDemoBankRecord config =
    let
        model =
            config.model

        state =
            { model
                | transactionType = config.txnType
                , amount = config.amount
            }
    in
    SeedDemoBankRecords.send SeedDemoBankRecordGotResp model.config model.session <| SeedDemoBankRecords.encode toSeedDemoBankRecord state


toSeedExtContribs : Model -> SeedExtContribs.EncodeModel
toSeedExtContribs model =
    { password = model.password
    , committeeId = Maybe.withDefault "" model.maybeDemoCommitteeId
    , externalSource = Maybe.withDefault "" model.externalSource
    }


seedExtContribs : Model -> Maybe String -> Cmd Msg
seedExtContribs model source =
    let
        state =
            { model | externalSource = source }
    in
    SeedExtContribs.send SeedExtContribsGotResp model.config model.session <| SeedExtContribs.encode toSeedExtContribs state


toReconcileDemoTxn : Model -> ReconcileDemoTxs.EncodeModel
toReconcileDemoTxn model =
    { password = model.password
    , committeeId = Maybe.withDefault "" model.maybeDemoCommitteeId
    }


reconcileDemoTxn : Model -> Cmd Msg
reconcileDemoTxn model =
    ReconcileDemoTxs.send ReconcileDemoTxnGotResp model.config model.session <| ReconcileDemoTxs.encode toReconcileDemoTxn model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- EXPORT


toSession : Model -> Session.Model
toSession model =
    model.session


toConfig : Model -> Config.Model
toConfig model =
    model.config


setSession : Session.Model -> Model -> Model
setSession session model =
    { model | session = session }
