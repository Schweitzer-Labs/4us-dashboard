module Page.Transactions exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Token)
import Api.AmendDisb as AmendDisb
import Api.CreateContrib as CreateConrib
import Api.CreateDisb as CreateDisb
import Api.GetTxn as GetTxn
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.ReconcileDisb as ReconcileDisb
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Browser.Navigation exposing (load)
import Cognito exposing (loginUrl)
import Committee
import Config exposing (Config)
import CreateContribution
import CreateDisbursement
import Delay
import File.Download as Download
import FileDisclosure
import FileFormat exposing (FileFormat)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Loading
import PlatformModal
import Session exposing (Session)
import SubmitButton exposing (submitButton)
import Task exposing (Task)
import Time
import Transaction
import TransactionType exposing (TransactionType(..))
import Transactions
import TxnForm as TxnForm
import TxnForm.DisbRuleUnverified as DisbRuleUnverified
import TxnForm.DisbRuleVerified as DisbRuleVerified
import Validate exposing (validate)



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , committeeId : String
    , timeZone : Time.Zone
    , transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , createContributionModalVisibility : Modal.Visibility
    , createContributionModal : CreateContribution.Model
    , createContributionSubmitting : Bool
    , generateDisclosureModalVisibility : Modal.Visibility
    , generateDisclosureModalDownloadDropdownState : Dropdown.State
    , actionsDropdown : Dropdown.State
    , filtersDropdown : Dropdown.State
    , filterTransactionType : Maybe TransactionType
    , disclosureSubmitting : Bool
    , disclosureSubmitted : Bool
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModal : CreateDisbursement.Model
    , createDisbursementSubmitting : Bool
    , disbRuleUnverifiedModal : DisbRuleUnverified.Model
    , disbRuleUnverifiedSubmitting : Bool
    , disbRuleUnverifiedModalVisibility : Modal.Visibility
    , disbRuleVerifiedModal : DisbRuleVerified.Model
    , disbRuleVerifiedSubmitting : Bool
    , disbRuleVerifiedModalVisibility : Modal.Visibility
    , config : Config
    }


init : Config -> Session -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
init config session aggs committee committeeId =
    let
        initModel =
            { session = session
            , loading = True
            , committeeId = committeeId
            , timeZone = Time.utc
            , transactions = []
            , aggregations = aggs
            , committee = committee
            , createContributionModalVisibility = Modal.hidden
            , createContributionModal = CreateContribution.init committeeId
            , createContributionSubmitting = False
            , generateDisclosureModalVisibility = Modal.hidden
            , actionsDropdown = Dropdown.initialState
            , filtersDropdown = Dropdown.initialState
            , generateDisclosureModalDownloadDropdownState = Dropdown.initialState
            , filterTransactionType = Nothing
            , disclosureSubmitting = False
            , disclosureSubmitted = False
            , createDisbursementModalVisibility = Modal.hidden
            , createDisbursementModal = CreateDisbursement.init committeeId
            , createDisbursementSubmitting = False
            , disbRuleUnverifiedModal = DisbRuleUnverified.init config [] Transaction.init
            , disbRuleUnverifiedSubmitting = False
            , disbRuleUnverifiedModalVisibility = Modal.hidden
            , disbRuleVerifiedModal = DisbRuleVerified.init Transaction.init
            , disbRuleVerifiedSubmitting = False
            , disbRuleVerifiedModalVisibility = Modal.hidden
            , config = config
            }
    in
    ( initModel
    , getTransactions initModel Nothing
    )



-- VIEW


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ dropdowns model
        , Transactions.viewInteractive model.committee ShowTxnFormModal model.transactions
        , createContributionModal model
        , generateDisclosureModal model
        , createDisbursementModal model
        , disbRuleUnverifiedModal model
        , disbRuleVerifiedModal model
        ]


createDisbursementModal : Model -> Html Msg
createDisbursementModal model =
    PlatformModal.view
        { hideMsg = CreateDisbursementModalHide
        , animateMsg = CreateDisbursementModalAnimate
        , title = "Create Disbursement"
        , updateMsg = CreateDisbursementModalUpdate
        , subModel = model.createDisbursementModal
        , subView = CreateDisbursement.view
        , submitMsg = CreateDisbursementSubmit
        , submitText = "Create Disbursement"
        , isSubmitting = model.createDisbursementSubmitting
        , isSubmitDisabled = model.createDisbursementModal.isSubmitDisabled
        , visibility = model.createDisbursementModalVisibility
        }


createContributionModal : Model -> Html Msg
createContributionModal model =
    PlatformModal.view
        { hideMsg = HideCreateContributionModal
        , animateMsg = AnimateCreateContributionModal
        , title = "Create Contribution"
        , updateMsg = CreateContributionModalUpdated
        , subModel = model.createContributionModal
        , subView = CreateContribution.view
        , submitMsg = SubmitCreateContribution
        , submitText = "Submit"
        , isSubmitting = model.createContributionSubmitting
        , isSubmitDisabled = False
        , visibility = model.createContributionModalVisibility
        }


disbRuleUnverifiedModal : Model -> Html Msg
disbRuleUnverifiedModal model =
    PlatformModal.view
        { hideMsg = DisbRuleUnverifiedModalHide
        , animateMsg = DisbRuleUnverifiedModalAnimate
        , title = "Reconcile Disbursement"
        , updateMsg = DisbRuleUnverifiedModalUpdate
        , subModel = model.disbRuleUnverifiedModal
        , subView = DisbRuleUnverified.view
        , submitMsg = DisbRuleUnverifiedSubmit
        , submitText = "Reconcile"
        , isSubmitting = model.disbRuleUnverifiedSubmitting
        , isSubmitDisabled = model.disbRuleUnverifiedModal.isSubmitDisabled
        , visibility = model.disbRuleUnverifiedModalVisibility
        }


disbRuleVerifiedModal : Model -> Html Msg
disbRuleVerifiedModal model =
    PlatformModal.view
        { hideMsg = DisbRuleVerifiedModalHide
        , animateMsg = DisbRuleVerifiedModalAnimate
        , title = "Disbursement"
        , updateMsg = DisbRuleVerifiedModalUpdate
        , subModel = model.disbRuleVerifiedModal
        , subView = DisbRuleVerified.view
        , submitMsg = DisbRuleVerifiedSubmit
        , submitText = "Save"
        , isSubmitting = model.disbRuleVerifiedSubmitting
        , isSubmitDisabled = model.disbRuleVerifiedModal.isSubmitDisabled
        , visibility = model.disbRuleVerifiedModalVisibility
        }


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        if model.loading then
            Loading.view

        else
            loadedView model
    }


dropdowns : Model -> Html Msg
dropdowns model =
    Grid.containerFluid
        []
        [ Grid.row
            [ Row.attrs [ class "justify-content-start" ] ]
            [ Grid.col
                [ Col.xs1, Col.attrs [ Spacing.ml0, Spacing.pl0 ] ]
                [ actionsDropdown model ]
            , Grid.col
                [ Col.xs2 ]
                [ filtersDropdown model ]
            , Grid.col
                [ Col.attrs [ class "text-center" ] ]
                [ h2
                    []
                    [ text <|
                        Maybe.withDefault "All Transactions" <|
                            Maybe.map TransactionType.toDisplayString model.filterTransactionType
                    ]
                ]
            , Grid.col
                [ Col.xs1, Col.attrs [ Spacing.ml0, Spacing.pl0 ] ]
                []
            , Grid.col
                [ Col.xs2 ]
                []
            ]
        ]


actionsDropdown : Model -> Html Msg
actionsDropdown model =
    div [ Spacing.mb2 ]
        [ Dropdown.dropdown
            model.actionsDropdown
            { options = []
            , toggleMsg = ToggleActionsDropdown
            , toggleButton =
                Dropdown.toggle [ Button.success, Button.disabled False, Button.attrs [ Spacing.pl3, Spacing.pr3 ] ] [ text "Actions" ]
            , items =
                [ Dropdown.buttonItem [ onClick ShowCreateContributionModal ] [ text "Create Contribution" ]
                , Dropdown.buttonItem [ onClick CreateDisbursementModalShow ] [ text "Create Disbursement" ]
                , Dropdown.buttonItem [ onClick ShowGenerateDisclosureModal ] [ text "File Disclosure" ]
                ]
            }

        -- etc
        ]


filtersDropdown : Model -> Html Msg
filtersDropdown model =
    div [ Spacing.mb2 ]
        [ Dropdown.dropdown
            model.filtersDropdown
            { options = []
            , toggleMsg = ToggleFiltersDropdown
            , toggleButton =
                Dropdown.toggle [ Button.success, Button.attrs [ Spacing.pl3, Spacing.pr3 ] ] [ text "Filters" ]
            , items =
                [ Dropdown.buttonItem [ onClick FilterByContributions ] [ text "Contributions" ]
                , Dropdown.buttonItem [ onClick FilterByDisbursements ] [ text "Disbursements" ]
                , Dropdown.buttonItem [ onClick FilterAll ] [ text "All Transactions" ]
                ]
            }

        -- etc
        ]


generateDisclosureModal : Model -> Html Msg
generateDisclosureModal model =
    Modal.config HideGenerateDisclosureModal
        |> Modal.withAnimation AnimateGenerateDisclosureModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "File Disclosure" ]
        |> Modal.body
            []
            [ FileDisclosure.view
                model.aggregations
                ( ToggleGenerateDisclosureModalDownloadDropdown
                , model.generateDisclosureModalDownloadDropdownState
                )
                GenerateReport
                model.disclosureSubmitted
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow "File" FileDisclosure model.disclosureSubmitting False model.disclosureSubmitted ]
            ]
        |> Modal.view model.generateDisclosureModalVisibility


buttonRow : String -> Msg -> Bool -> Bool -> Bool -> Html Msg
buttonRow displayText msg submitting enableExit disabled =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            (if enableExit then
                [ exitButton ]

             else
                []
            )
        , Grid.col
            [ Col.lg3 ]
            [ submitButton displayText msg submitting disabled ]
        ]


exitButton : Html Msg
exitButton =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick HideCreateContributionModal ]
        ]
        [ text "Exit" ]


openTxnFormModalLoading : Model -> Transaction.Model -> ( Model, Cmd Msg )
openTxnFormModalLoading model txn =
    case TxnForm.fromTxn txn of
        TxnForm.DisbRuleUnverified ->
            ( { model
                | disbRuleUnverifiedModalVisibility = Modal.shown
                , disbRuleUnverifiedModal = DisbRuleUnverified.init model.config model.transactions txn
              }
            , Cmd.none
            )

        TxnForm.DisbRuleVerified ->
            ( { model
                | disbRuleVerifiedModalVisibility = Modal.shown
                , disbRuleVerifiedModal = DisbRuleVerified.loadingInit
              }
            , getTransaction model txn.id
            )

        _ ->
            ( model, Cmd.none )


openTxnFormModalLoaded : Model -> Transaction.Model -> ( Model, Cmd Msg )
openTxnFormModalLoaded model txn =
    case TxnForm.fromTxn txn of
        TxnForm.DisbRuleUnverified ->
            ( { model
                | disbRuleUnverifiedModalVisibility = Modal.shown
                , disbRuleUnverifiedModal = DisbRuleUnverified.init model.config model.transactions txn
              }
            , Cmd.none
            )

        TxnForm.DisbRuleVerified ->
            ( { model
                | disbRuleVerifiedModalVisibility = Modal.shown
                , disbRuleVerifiedModal = DisbRuleVerified.init txn
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


type Msg
    = GotSession Session
    | GotTransactionsData (Result Http.Error GetTxns.Model)
    | GenerateReport FileFormat
    | HideCreateContributionModal
    | ShowCreateContributionModal
    | HideGenerateDisclosureModal
    | ShowGenerateDisclosureModal
    | AnimateGenerateDisclosureModal Modal.Visibility
    | CreateContributionModalUpdated CreateContribution.Msg
    | AnimateCreateContributionModal Modal.Visibility
    | GotCreateContributionResponse (Result Http.Error MutationResponse)
    | GotCreateDisbursementResponse (Result Http.Error MutationResponse)
    | GotTransactionData (Result Http.Error GetTxn.Model)
    | SubmitCreateContribution
    | ToggleActionsDropdown Dropdown.State
    | ToggleFiltersDropdown Dropdown.State
    | ToggleGenerateDisclosureModalDownloadDropdown Dropdown.State
    | FileDisclosure
    | FileDisclosureDelayed
    | FilterByContributions
    | FilterByDisbursements
    | NoOp
    | FilterAll
    | CreateDisbursementModalHide
    | CreateDisbursementModalAnimate Modal.Visibility
    | CreateDisbursementModalUpdate CreateDisbursement.Msg
    | CreateDisbursementModalShow
    | CreateDisbursementSubmit
      -- Disb Unverified Modal
    | DisbRuleUnverifiedModalHide
    | DisbRuleUnverifiedModalAnimate Modal.Visibility
    | DisbRuleUnverifiedModalUpdate DisbRuleUnverified.Msg
    | DisbRuleUnverifiedSubmit
    | DisbRuleUnverifiedGotReconcileMutResp (Result Http.Error MutationResponse)
      -- Disb Verified Modal
    | DisbRuleVerifiedModalHide
    | DisbRuleVerifiedModalAnimate Modal.Visibility
    | DisbRuleVerifiedModalUpdate DisbRuleVerified.Msg
    | DisbRuleVerifiedSubmit
    | DisbRuleVerifiedGotMutResp (Result Http.Error MutationResponse)
    | ShowTxnFormModal Transaction.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowTxnFormModal txn ->
            openTxnFormModalLoading model txn

        -- Disb Rule Unverified Modal State
        DisbRuleUnverifiedModalAnimate visibility ->
            ( { model | disbRuleUnverifiedModalVisibility = visibility }, Cmd.none )

        DisbRuleUnverifiedModalHide ->
            ( { model
                | disbRuleUnverifiedModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        DisbRuleUnverifiedSubmit ->
            ( { model | disbRuleUnverifiedSubmitting = True }, reconcileDisb model )

        DisbRuleUnverifiedModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    DisbRuleUnverified.update subMsg model.disbRuleUnverifiedModal
            in
            ( { model | disbRuleUnverifiedModal = subModel }, Cmd.map DisbRuleUnverifiedModalUpdate subCmd )

        DisbRuleUnverifiedGotReconcileMutResp res ->
            case res of
                Ok mutResp ->
                    case mutResp of
                        Success id ->
                            ( { model
                                | disbRuleUnverifiedModalVisibility = Modal.hidden
                                , disbRuleUnverifiedSubmitting = False

                                -- @Todo make this state impossible
                                , disbRuleUnverifiedModal = DisbRuleUnverified.init model.config [] model.disbRuleUnverifiedModal.bankTxn
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | disbRuleUnverifiedModal =
                                    DisbRuleUnverified.fromError model.disbRuleUnverifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , disbRuleUnverifiedSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | disbRuleUnverifiedModal =
                            DisbRuleUnverified.fromError model.disbRuleUnverifiedModal <|
                                Api.decodeError err
                        , disbRuleUnverifiedSubmitting = False
                      }
                    , Cmd.none
                    )

        DisbRuleVerifiedGotMutResp res ->
            case res of
                Ok mutResp ->
                    case mutResp of
                        Success id ->
                            ( { model
                                | disbRuleVerifiedModalVisibility = Modal.hidden
                                , disbRuleVerifiedSubmitting = False

                                -- @Todo make this state impossible
                                , disbRuleVerifiedModal = DisbRuleVerified.loadingInit
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | disbRuleVerifiedModal =
                                    DisbRuleVerified.fromError model.disbRuleVerifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , disbRuleVerifiedSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | disbRuleVerifiedModal =
                            DisbRuleVerified.fromError model.disbRuleVerifiedModal <|
                                Api.decodeError err
                        , disbRuleVerifiedSubmitting = False
                      }
                    , Cmd.none
                    )

        -- Disb Rule Verified Modal State
        DisbRuleVerifiedModalAnimate visibility ->
            ( { model | disbRuleVerifiedModalVisibility = visibility }, Cmd.none )

        DisbRuleVerifiedModalHide ->
            ( { model
                | disbRuleVerifiedModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        DisbRuleVerifiedSubmit ->
            case validate DisbRuleVerified.validator model.disbRuleVerifiedModal of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( { model | disbRuleVerifiedModal = DisbRuleVerified.fromError model.disbRuleVerifiedModal error }, Cmd.none )

                Ok val ->
                    ( { model
                        | disbRuleVerifiedSubmitting = True
                      }
                    , amendDisb model
                    )

        DisbRuleVerifiedModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    DisbRuleVerified.update subMsg model.disbRuleVerifiedModal
            in
            ( { model | disbRuleVerifiedModal = subModel }, Cmd.map DisbRuleVerifiedModalUpdate subCmd )

        -- Main page stuff
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GenerateReport format ->
            case format of
                FileFormat.PDF ->
                    ( model, Download.string "2021-periodic-report-july.pdf" "text/pdf" "2021-periodic-report-july" )

                FileFormat.CSV ->
                    ( model, Download.string "2021-periodic-report-july.csv" "text/csv" "2021-periodic-report-july" )

        AnimateGenerateDisclosureModal visibility ->
            ( { model | generateDisclosureModalVisibility = visibility }, Cmd.none )

        GotTransactionData res ->
            case res of
                Ok body ->
                    openTxnFormModalLoaded model (GetTxn.toTxn body)

                Err _ ->
                    let
                        { cognitoDomain, cognitoClientId, redirectUri } =
                            model.config
                    in
                    ( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )

        GotTransactionsData res ->
            case res of
                Ok body ->
                    ( { model
                        | transactions = GetTxns.toTxns body
                        , aggregations = GetTxns.toAggs body
                        , committee = GetTxns.toCommittee body
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        { cognitoDomain, cognitoClientId, redirectUri } =
                            model.config
                    in
                    ( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )

        --( model, Cmd.none )
        ShowCreateContributionModal ->
            ( { model
                | createContributionModalVisibility = Modal.shown
                , createContributionModal = CreateContribution.init model.committeeId
              }
            , Cmd.none
            )

        HideCreateContributionModal ->
            ( { model
                | createContributionModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        SubmitCreateContribution ->
            ( { model
                | createContributionSubmitting = True
              }
            , createContribution model
            )

        AnimateCreateContributionModal visibility ->
            ( { model | createContributionModalVisibility = visibility }, Cmd.none )

        ShowGenerateDisclosureModal ->
            ( { model
                | generateDisclosureModalVisibility = Modal.shown
              }
            , Cmd.none
            )

        HideGenerateDisclosureModal ->
            ( { model
                | generateDisclosureModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        CreateContributionModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateContribution.update subMsg model.createContributionModal
            in
            ( { model | createContributionModal = subModel }, Cmd.map CreateContributionModalUpdated subCmd )

        GotCreateContributionResponse res ->
            case res of
                Ok createContribResp ->
                    case createContribResp of
                        Success id ->
                            ( { model
                                | createContributionModalVisibility = Modal.hidden
                                , createContributionSubmitting = False
                              }
                            , getTransactions model model.filterTransactionType
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | createContributionModal =
                                    CreateContribution.setError model.createContributionModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , createContributionSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | createContributionModal =
                            CreateContribution.setError model.createContributionModal <|
                                Api.decodeError err
                        , createContributionSubmitting = False
                      }
                    , Cmd.none
                    )

        GotCreateDisbursementResponse res ->
            case res of
                Ok createDisbResp ->
                    case createDisbResp of
                        Success id ->
                            ( { model
                                | createDisbursementModalVisibility = Modal.hidden
                                , createDisbursementSubmitting = False
                                , createDisbursementModal = CreateDisbursement.init model.committeeId
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | createDisbursementModal =
                                    CreateDisbursement.fromError model.createDisbursementModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , createDisbursementSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | createDisbursementModal =
                            CreateDisbursement.fromError model.createDisbursementModal <|
                                Api.decodeError err
                        , createContributionSubmitting = False
                      }
                    , Cmd.none
                    )

        ToggleActionsDropdown state ->
            ( { model | actionsDropdown = state }, Cmd.none )

        ToggleFiltersDropdown state ->
            ( { model | filtersDropdown = state }, Cmd.none )

        ToggleGenerateDisclosureModalDownloadDropdown state ->
            ( { model | generateDisclosureModalDownloadDropdownState = state }, Cmd.none )

        FilterByContributions ->
            ( { model | filterTransactionType = Just TransactionType.Contribution }
            , getTransactions model (Just TransactionType.Contribution)
            )

        FilterByDisbursements ->
            ( { model | filterTransactionType = Just TransactionType.Disbursement }
            , getTransactions model (Just TransactionType.Disbursement)
            )

        FilterAll ->
            ( { model | filterTransactionType = Nothing }
            , getTransactions model Nothing
            )

        FileDisclosure ->
            ( { model | disclosureSubmitting = True }, Delay.after 2 Delay.Second FileDisclosureDelayed )

        FileDisclosureDelayed ->
            ( { model | disclosureSubmitting = False, disclosureSubmitted = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        CreateDisbursementModalShow ->
            ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none )

        CreateDisbursementModalHide ->
            ( { model | createDisbursementModalVisibility = Modal.hidden, createDisbursementModal = CreateDisbursement.init model.committeeId }
            , Cmd.none
            )

        CreateDisbursementSubmit ->
            case validate CreateDisbursement.validator model.createDisbursementModal of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( { model | createDisbursementModal = CreateDisbursement.fromError model.createDisbursementModal error }, Cmd.none )

                Ok val ->
                    ( { model
                        | createDisbursementSubmitting = True
                      }
                    , createDisbursement model
                    )

        CreateDisbursementModalAnimate visibility ->
            ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )

        CreateDisbursementModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateDisbursement.update subMsg model.createDisbursementModal
            in
            ( { model | createDisbursementModal = subModel }, Cmd.map CreateDisbursementModalUpdate subCmd )


generateReport : Cmd msg
generateReport =
    Download.string "2021_Q1.pdf" "text/pdf" "2021_Q1"



-- HTTP


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    CreateDisb.send GotCreateDisbursementResponse model.config <| CreateDisb.encode model.createDisbursementModal


createContribution : Model -> Cmd Msg
createContribution model =
    CreateConrib.send GotCreateContributionResponse model.config <| CreateConrib.encode model.createContributionModal


reconcileDisb : Model -> Cmd Msg
reconcileDisb model =
    ReconcileDisb.send DisbRuleUnverifiedGotReconcileMutResp model.config <| ReconcileDisb.encode model.disbRuleUnverifiedModal


getTransactions : Model -> Maybe TransactionType -> Cmd Msg
getTransactions model maybeTxnType =
    GetTxns.send GotTransactionsData model.config <| GetTxns.encode model.committeeId maybeTxnType


getTransaction : Model -> String -> Cmd Msg
getTransaction model txnId =
    GetTxn.send GotTransactionData model.config <| GetTxn.encode model.committeeId txnId


amendDisb : Model -> Cmd Msg
amendDisb model =
    AmendDisb.send DisbRuleVerifiedGotMutResp model.config <| AmendDisb.encode model.disbRuleVerifiedModal



-- Dom interactions


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Modal.subscriptions model.createContributionModalVisibility AnimateCreateContributionModal
        , Modal.subscriptions model.generateDisclosureModalVisibility AnimateGenerateDisclosureModal
        , Dropdown.subscriptions model.actionsDropdown ToggleActionsDropdown
        , Dropdown.subscriptions model.filtersDropdown ToggleFiltersDropdown
        , Dropdown.subscriptions model.generateDisclosureModalDownloadDropdownState ToggleGenerateDisclosureModalDownloadDropdown
        , Modal.subscriptions model.createDisbursementModalVisibility CreateDisbursementModalAnimate
        , Modal.subscriptions model.disbRuleUnverifiedModalVisibility DisbRuleUnverifiedModalAnimate
        , Modal.subscriptions model.disbRuleVerifiedModalVisibility DisbRuleVerifiedModalAnimate
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
