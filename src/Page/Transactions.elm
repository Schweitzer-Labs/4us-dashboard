module Page.Transactions exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Token)
import Api.AmendContrib as AmendContrib
import Api.AmendDisb as AmendDisb
import Api.CreateContrib as CreateContrib
import Api.CreateDisb as CreateDisb
import Api.DeleteTxn as DeleteTxn
import Api.GetReport as GetReport
import Api.GetTxn as GetTxn
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.ReconcileTxn as ReconcileTxn
import Bootstrap.Alert as Alert
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
import ContribInfo
import CreateContribution
import CreateDisbursement
import Delay
import File.Download as Download
import FileDisclosure
import FileFormat exposing (FileFormat)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events exposing (on, onClick)
import Http
import List exposing (concat, head, length, reverse)
import Loading
import Pagination
import PlatformModal
import Session exposing (Session)
import SubmitButton exposing (submitButton)
import Task exposing (Task)
import Time
import Transaction
import TransactionType exposing (TransactionType(..))
import Transactions
import TxnForm as TxnForm
import TxnForm.ContribRuleUnverified as ContribRuleUnverified
import TxnForm.ContribRuleVerified as ContribRuleVerified
import TxnForm.DisbRuleUnverified as DisbRuleUnverified
import TxnForm.DisbRuleVerified as DisbRuleVerified
import Validate exposing (validate)



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , heading : String
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
    , getTransactionCanceled : Bool
    , generateDisclosureModalPreviewDropdownState : Dropdown.State
    , generateDisclosureModalContext : DiscDropdownContext
    , generateDisclosureModalPreview : Maybe String
    , actionsDropdown : Dropdown.State
    , filtersDropdown : Dropdown.State
    , filterTransactionType : Maybe TransactionType
    , filterNeedsReview : Bool
    , disclosureSubmitting : Bool
    , disclosureSubmitted : Bool
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModal : CreateDisbursement.Model
    , createDisbursementSubmitting : Bool

    -- Disb unverified modal
    , disbRuleUnverifiedModal : DisbRuleUnverified.Model
    , disbRuleUnverifiedSubmitting : Bool
    , disbRuleUnverifiedSuccessViewActive : Bool
    , disbRuleUnverifiedModalVisibility : Modal.Visibility

    -- Disb verified
    , disbRuleVerifiedModal : DisbRuleVerified.Model
    , disbRuleVerifiedSubmitting : Bool
    , disbRuleVerifiedSuccessViewActive : Bool
    , disbRuleVerifiedModalVisibility : Modal.Visibility

    -- Contrib unverified modal
    , contribRuleUnverifiedModal : ContribRuleUnverified.Model
    , contribRuleUnverifiedSubmitting : Bool
    , contribRuleUnverifiedSuccessViewActive : Bool
    , contribRuleUnverifiedModalVisibility : Modal.Visibility

    -- Contrib verified
    , contribRuleVerifiedModal : ContribRuleVerified.Model
    , contribRuleVerifiedSubmitting : Bool
    , contribRuleVerifiedSuccessViewActive : Bool
    , contribRuleVerifiedModalVisibility : Modal.Visibility
    , config : Config

    -- Transaction Feed Pagination Setting
    , fromId : Maybe String
    , moreLoading : Bool
    , moreDisabled : Bool

    -- Deletions
    , isDeleting : Bool
    , isDeletionConfirmed : DelConfirmationState
    , alertVisibility : Alert.Visibility
    }


init : Config -> Session -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
init config session aggs committee committeeId =
    let
        initModel =
            { session = session
            , loading = True
            , heading = "All Transactions"
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
            , generateDisclosureModalPreviewDropdownState = Dropdown.initialState
            , generateDisclosureModalContext = Closed
            , generateDisclosureModalPreview = Nothing
            , filterTransactionType = Nothing
            , filterNeedsReview = False
            , disclosureSubmitting = False
            , disclosureSubmitted = False
            , createDisbursementModalVisibility = Modal.hidden
            , createDisbursementModal = CreateDisbursement.init committeeId
            , createDisbursementSubmitting = False
            , getTransactionCanceled = False

            -- Disb rule unverified state
            , disbRuleUnverifiedModal = DisbRuleUnverified.init config [] Transaction.init
            , disbRuleUnverifiedSubmitting = False
            , disbRuleUnverifiedSuccessViewActive = False
            , disbRuleUnverifiedModalVisibility = Modal.hidden

            -- Disb rule verified state
            , disbRuleVerifiedModal = DisbRuleVerified.init Transaction.init
            , disbRuleVerifiedSubmitting = False
            , disbRuleVerifiedSuccessViewActive = False
            , disbRuleVerifiedModalVisibility = Modal.hidden

            -- Contrib rule unverified state
            , contribRuleUnverifiedModal = ContribRuleUnverified.init config [] Transaction.init
            , contribRuleUnverifiedSubmitting = False
            , contribRuleUnverifiedSuccessViewActive = False
            , contribRuleUnverifiedModalVisibility = Modal.hidden

            -- Contrib rule verified state
            , contribRuleVerifiedModal = ContribRuleVerified.init Transaction.init
            , contribRuleVerifiedSubmitting = False
            , contribRuleVerifiedSuccessViewActive = False
            , contribRuleVerifiedModalVisibility = Modal.hidden
            , config = config

            -- Pagination Settings
            , fromId = Nothing
            , moreLoading = False
            , moreDisabled = False
            , isDeleting = False
            , isDeletionConfirmed = Uninitialized
            , alertVisibility = Alert.closed
            }
    in
    ( initModel
    , getNextTxnsSet initModel
    )



-- VIEW


toDeleteMsg : Model -> (a -> Transaction.Model) -> a -> Maybe Msg
toDeleteMsg model mapper subModel =
    let
        txn =
            mapper subModel

        isUnreconciled =
            not txn.bankVerified

        isUnprocessed =
            txn.stripePaymentIntentId == Nothing

        notBlank =
            String.length txn.id > 0
    in
    case isUnreconciled && isUnprocessed && notBlank of
        True ->
            case model.isDeletionConfirmed of
                Confirmed ->
                    Just (TxnDelete txn)

                Unconfirmed ->
                    Just ToggleDeletePrompt

                Uninitialized ->
                    case isUnreconciled && isUnprocessed && notBlank of
                        True ->
                            Just ToggleDeletePrompt

                        False ->
                            Nothing

        False ->
            Nothing


moreTxnsButton : Model -> Html Msg
moreTxnsButton model =
    div [ class "text-center" ] <|
        if model.moreDisabled then
            []

        else
            [ SubmitButton.custom [ Spacing.pl5, Spacing.pr5 ] "Load More" MoreTxnsClicked model.moreLoading model.moreLoading
            ]


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ dropdowns model
        , Transactions.viewInteractive model.committee ShowTxnFormModal model.transactions
        , moreTxnsButton model
        , createContributionModal model
        , generateDisclosureModal model
        , createDisbursementModal model
        , disbRuleUnverifiedModal model
        , disbRuleVerifiedModal model
        , contribRuleUnverifiedModal model
        , contribRuleVerifiedModal model
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
        , successViewActive = False
        , successViewMessage = ""
        , isSubmitDisabled = model.createDisbursementModal.isSubmitDisabled
        , visibility = model.createDisbursementModalVisibility
        , maybeDeleteMsg = Nothing
        , isDeleting = False
        , alertMsg = Nothing
        , alertVisibility = Nothing
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
        , successViewActive = False
        , successViewMessage = ""
        , isSubmitDisabled = False
        , visibility = model.createContributionModalVisibility
        , maybeDeleteMsg = Nothing
        , isDeleting = False
        , alertMsg = Nothing
        , alertVisibility = Nothing
        }



-- Disbursement


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
        , successViewActive = model.disbRuleUnverifiedSuccessViewActive
        , successViewMessage = " Reconciliation Successful!"
        , isSubmitDisabled = DisbRuleUnverified.toSubmitDisabled model.disbRuleUnverifiedModal
        , visibility = model.disbRuleUnverifiedModalVisibility
        , maybeDeleteMsg = Nothing
        , isDeleting = False
        , alertMsg = Nothing
        , alertVisibility = Nothing
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
        , successViewActive = model.disbRuleVerifiedSuccessViewActive
        , successViewMessage = " Revision Successful!"
        , isSubmitDisabled = model.disbRuleVerifiedModal.isSubmitDisabled
        , visibility = model.disbRuleVerifiedModalVisibility
        , maybeDeleteMsg = toDeleteMsg model DisbRuleVerified.toTxn model.disbRuleVerifiedModal
        , isDeleting = model.isDeleting
        , alertMsg = Just DeleteAlertMsg
        , alertVisibility = Just model.alertVisibility
        }



-- Contributions


contribRuleUnverifiedModal : Model -> Html Msg
contribRuleUnverifiedModal model =
    PlatformModal.view
        { hideMsg = ContribRuleUnverifiedModalHide
        , animateMsg = ContribRuleUnverifiedModalAnimate
        , title = "Reconcile Contribution"
        , updateMsg = ContribRuleUnverifiedModalUpdate
        , subModel = model.contribRuleUnverifiedModal
        , subView = ContribRuleUnverified.view
        , submitMsg = ContribRuleUnverifiedSubmit
        , submitText = "Reconcile"
        , isSubmitting = model.contribRuleUnverifiedSubmitting
        , successViewActive = model.contribRuleUnverifiedSuccessViewActive
        , successViewMessage = " Reconciliation Successful!"
        , isSubmitDisabled = False
        , visibility = model.contribRuleUnverifiedModalVisibility
        , maybeDeleteMsg = Nothing
        , isDeleting = False
        , alertMsg = Nothing
        , alertVisibility = Nothing
        }


contribRuleVerifiedModal : Model -> Html Msg
contribRuleVerifiedModal model =
    PlatformModal.view
        { hideMsg = ContribRuleVerifiedModalHide
        , animateMsg = ContribRuleVerifiedModalAnimate
        , title = "Contribution"
        , updateMsg = ContribRuleVerifiedModalUpdate
        , subModel = model.contribRuleVerifiedModal
        , subView = ContribRuleVerified.view
        , submitMsg = ContribRuleVerifiedSubmit
        , submitText = "Save"
        , isSubmitting = model.contribRuleVerifiedSubmitting
        , successViewActive = model.contribRuleVerifiedSuccessViewActive
        , successViewMessage = " Revision Successful!"
        , isSubmitDisabled = model.contribRuleVerifiedModal.isSubmitDisabled
        , visibility = model.contribRuleVerifiedModalVisibility
        , maybeDeleteMsg = toDeleteMsg model ContribRuleVerified.toTxn model.contribRuleVerifiedModal
        , isDeleting = model.isDeleting
        , alertMsg = Just DeleteAlertMsg
        , alertVisibility = Just model.alertVisibility
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
                    [ text <| model.heading
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
                , Dropdown.buttonItem [ onClick ShowGenerateDisclosureModal ] [ text "Get Disclosure" ]
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
                [ Dropdown.buttonItem [ onClick FilterNeedsReview ] [ text "Needs Review" ]
                , Dropdown.buttonItem [ onClick FilterByContributions ] [ text "Contributions" ]
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
        |> Modal.scrollableBody True
        |> Modal.h3 [] [ text "Get Disclosure" ]
        |> Modal.body
            []
            [ FileDisclosure.view
                model.aggregations
                ( ToggleGenerateDisclosureModalDownloadDropdown
                , model.generateDisclosureModalDownloadDropdownState
                )
                ( ToggleGenerateDisclosureModalPreviewDropdown
                , model.generateDisclosureModalPreviewDropdownState
                )
                GenerateReport
                FilterNeedsReview
                model.disclosureSubmitted
                model.generateDisclosureModalPreview
                ReturnFromGenerateDisclosureModalPreview
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow "File" FileDisclosure model.disclosureSubmitting False True ]
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

        TxnForm.ContribRuleUnverified ->
            ( { model
                | contribRuleUnverifiedModalVisibility = Modal.shown
                , contribRuleUnverifiedModal = ContribRuleUnverified.init model.config model.transactions txn
              }
            , Cmd.none
            )

        TxnForm.ContribRuleVerified ->
            ( { model
                | contribRuleVerifiedModalVisibility = Modal.shown
                , contribRuleVerifiedModal = ContribRuleVerified.loadingInit
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

        TxnForm.ContribRuleVerified ->
            ( { model
                | contribRuleVerifiedModalVisibility = Modal.shown
                , contribRuleVerifiedModal = ContribRuleVerified.init txn
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
    | GotReportData (Result Http.Error GetReport.Model)
    | SubmitCreateContribution
    | ToggleActionsDropdown Dropdown.State
    | ToggleFiltersDropdown Dropdown.State
    | ToggleGenerateDisclosureModalDownloadDropdown Dropdown.State
    | ToggleGenerateDisclosureModalPreviewDropdown Dropdown.State
    | ReturnFromGenerateDisclosureModalPreview
    | FileDisclosure
    | FileDisclosureDelayed
    | FilterByContributions
    | FilterByDisbursements
    | FilterNeedsReview
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
      --- Contrib Unverified
    | ContribRuleUnverifiedModalHide
    | ContribRuleUnverifiedModalAnimate Modal.Visibility
    | ContribRuleUnverifiedModalUpdate ContribRuleUnverified.Msg
    | ContribRuleUnverifiedSubmit
    | ContribRuleUnverifiedGotReconcileMutResp (Result Http.Error MutationResponse)
      -- Contrib Verified Modal
    | ContribRuleVerifiedModalHide
    | ContribRuleVerifiedModalAnimate Modal.Visibility
    | ContribRuleVerifiedModalUpdate ContribRuleVerified.Msg
    | ContribRuleVerifiedSubmit
    | ContribRuleVerifiedGotMutResp (Result Http.Error MutationResponse)
      -- Deletion
    | TxnDelete Transaction.Model
    | GotDeleteTxnMutResp (Result Http.Error MutationResponse)
      -- Feed pagination
    | MoreTxnsClicked
    | GotTxnSet (Result Http.Error GetTxns.Model)
    | ToggleDeletePrompt
    | DeleteAlertMsg Alert.Visibility



-- Feed pagination


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TxnDelete txn ->
            ( { model | isDeleting = True, isDeletionConfirmed = Unconfirmed }, deleteTxn model txn.id )

        GotDeleteTxnMutResp res ->
            case res of
                Ok mutResp ->
                    case mutResp of
                        Success id ->
                            ( { model
                                | isDeleting = False
                                , contribRuleVerifiedModalVisibility = Modal.hidden
                                , disbRuleVerifiedModalVisibility = Modal.hidden
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | isDeleting = False
                                , contribRuleVerifiedModal =
                                    ContribRuleVerified.fromError model.contribRuleVerifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , disbRuleVerifiedModal =
                                    DisbRuleVerified.fromError model.disbRuleVerifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | contribRuleVerifiedModal =
                            ContribRuleVerified.fromError model.contribRuleVerifiedModal <|
                                Api.decodeError err
                        , disbRuleVerifiedModal =
                            DisbRuleVerified.fromError model.disbRuleVerifiedModal <|
                                Api.decodeError err
                      }
                    , Cmd.none
                    )

        ShowTxnFormModal txn ->
            let
                state =
                    { model | getTransactionCanceled = False }
            in
            openTxnFormModalLoading state txn

        -- Disb Rule Unverified
        DisbRuleUnverifiedModalAnimate visibility ->
            ( { model | disbRuleUnverifiedModalVisibility = visibility }, Cmd.none )

        DisbRuleUnverifiedModalHide ->
            ( { model
                | disbRuleUnverifiedModalVisibility = Modal.hidden
                , disbRuleUnverifiedSuccessViewActive = False
                , getTransactionCanceled = True
              }
            , getTransactions model Nothing
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
                                | disbRuleUnverifiedSuccessViewActive = True
                                , disbRuleUnverifiedSubmitting = False

                                -- @Todo make this state impossible
                                , disbRuleUnverifiedModal = DisbRuleUnverified.init model.config [] model.disbRuleUnverifiedModal.bankTxn
                              }
                            , Cmd.batch [ getTransactions model Nothing, Task.attempt (\_ -> NoOp) scrollToTop ]
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
                                | disbRuleVerifiedSuccessViewActive = True
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
                , disbRuleVerifiedSuccessViewActive = False
                , getTransactionCanceled = True
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

        -- Contrib Rule Unverified
        ContribRuleUnverifiedModalAnimate visibility ->
            ( { model | contribRuleUnverifiedModalVisibility = visibility }, Cmd.none )

        ContribRuleUnverifiedModalHide ->
            ( { model
                | contribRuleUnverifiedModalVisibility = Modal.hidden
                , contribRuleUnverifiedSuccessViewActive = False
                , getTransactionCanceled = True
              }
            , getTransactions model Nothing
            )

        ContribRuleUnverifiedSubmit ->
            ( { model | contribRuleUnverifiedSubmitting = True }, reconcileContrib model )

        ContribRuleUnverifiedModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    ContribRuleUnverified.update subMsg model.contribRuleUnverifiedModal
            in
            ( { model | contribRuleUnverifiedModal = subModel }, Cmd.map ContribRuleUnverifiedModalUpdate subCmd )

        ContribRuleUnverifiedGotReconcileMutResp res ->
            case res of
                Ok mutResp ->
                    case mutResp of
                        Success id ->
                            ( { model
                                | contribRuleUnverifiedSuccessViewActive = True
                                , contribRuleUnverifiedSubmitting = False

                                -- @Todo make this state impossible
                                , contribRuleUnverifiedModal = ContribRuleUnverified.init model.config [] model.contribRuleUnverifiedModal.bankTxn
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | contribRuleUnverifiedModal =
                                    ContribRuleUnverified.fromError model.contribRuleUnverifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , contribRuleUnverifiedSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | contribRuleUnverifiedModal =
                            ContribRuleUnverified.fromError model.contribRuleUnverifiedModal <|
                                Api.decodeError err
                        , contribRuleUnverifiedSubmitting = False
                      }
                    , Cmd.none
                    )

        ContribRuleVerifiedGotMutResp res ->
            case res of
                Ok mutResp ->
                    case mutResp of
                        Success id ->
                            ( { model
                                | contribRuleVerifiedSuccessViewActive = True
                                , contribRuleVerifiedSubmitting = False

                                -- @Todo make this state impossible
                                , contribRuleVerifiedModal = ContribRuleVerified.loadingInit
                              }
                            , getTransactions model Nothing
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | contribRuleVerifiedModal =
                                    ContribRuleVerified.fromError model.contribRuleVerifiedModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , contribRuleVerifiedSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | contribRuleVerifiedModal =
                            ContribRuleVerified.fromError model.contribRuleVerifiedModal <|
                                Api.decodeError err
                        , contribRuleVerifiedSubmitting = False
                      }
                    , Cmd.none
                    )

        -- Contrib Rule Verified Modal State
        ContribRuleVerifiedModalAnimate visibility ->
            ( { model | contribRuleVerifiedModalVisibility = visibility }, Cmd.none )

        ContribRuleVerifiedModalHide ->
            ( { model
                | contribRuleVerifiedModalVisibility = Modal.hidden
                , contribRuleVerifiedSuccessViewActive = False
                , getTransactionCanceled = True
              }
            , Cmd.none
            )

        ContribRuleVerifiedSubmit ->
            case ContribInfo.validateModel ContribRuleVerified.validationMapper model.contribRuleVerifiedModal of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( { model | contribRuleVerifiedModal = ContribRuleVerified.fromError model.contribRuleVerifiedModal error }, Cmd.none )

                Ok val ->
                    ( { model
                        | contribRuleVerifiedSubmitting = True
                      }
                    , amendContrib model
                    )

        ContribRuleVerifiedModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    ContribRuleVerified.update subMsg model.contribRuleVerifiedModal
            in
            ( { model | contribRuleVerifiedModal = subModel }, Cmd.map ContribRuleVerifiedModalUpdate subCmd )

        -- Main page stuff
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GenerateReport format ->
            case format of
                FileFormat.CSV ->
                    ( model, getReport model )

                FileFormat.PDF ->
                    ( model, Download.string "2021-periodic-report-july.pdf" "text/pdf" "2021-periodic-report-july" )

        GotReportData res ->
            case model.generateDisclosureModalContext of
                Download ->
                    case res of
                        Ok body ->
                            ( model, Download.string "report.csv" "text/csv" <| GetReport.toCsvData body )

                        Err _ ->
                            ( model, load <| loginUrl model.config model.committeeId )

                Preview ->
                    case res of
                        Ok body ->
                            ( { model | generateDisclosureModalPreview = Just (GetReport.toCsvData body) }, Cmd.none )

                        Err _ ->
                            ( model, load <| loginUrl model.config model.committeeId )

                Closed ->
                    ( model, Cmd.none )

        AnimateGenerateDisclosureModal visibility ->
            ( { model | generateDisclosureModalVisibility = visibility }, Cmd.none )

        GotTransactionData res ->
            case model.getTransactionCanceled of
                False ->
                    case res of
                        Ok body ->
                            openTxnFormModalLoaded model (GetTxn.toTxn body)

                        Err _ ->
                            ( model, Cmd.none )

                True ->
                    ( model, Cmd.none )

        --( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )
        GotTransactionsData res ->
            case res of
                Ok body ->
                    let
                        txns =
                            applyNeedsReviewFilter model <| GetTxns.toTxns body

                        aggs =
                            GetTxns.toAggs body

                        committee =
                            GetTxns.toCommittee body
                    in
                    ( { model
                        | transactions = txns
                        , aggregations = aggs
                        , committee = committee
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.config model.committeeId )

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
            case ContribInfo.validateModel CreateContribution.validationMapper model.createContributionModal of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( { model | createContributionModal = CreateContribution.fromError model.createContributionModal error }, Cmd.none )

                Ok val ->
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
                , generateDisclosureModalPreview = Nothing
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
                                    CreateContribution.fromError model.createContributionModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , createContributionSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | createContributionModal =
                            CreateContribution.fromError model.createContributionModal <|
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
            ( { model
                | generateDisclosureModalDownloadDropdownState = state
                , generateDisclosureModalContext = Download
              }
            , Cmd.none
            )

        ToggleGenerateDisclosureModalPreviewDropdown state ->
            ( { model
                | generateDisclosureModalPreviewDropdownState = state
                , generateDisclosureModalContext = Preview
              }
            , Cmd.none
            )

        ReturnFromGenerateDisclosureModalPreview ->
            ( { model | generateDisclosureModalPreview = Nothing }
            , Cmd.none
            )

        FilterByContributions ->
            ( { model | filterTransactionType = Just TransactionType.Contribution, filterNeedsReview = False, heading = "Contributions" }
            , getTransactions model (Just TransactionType.Contribution)
            )

        FilterByDisbursements ->
            ( { model | filterTransactionType = Just TransactionType.Disbursement, filterNeedsReview = False, heading = "Disbursements" }
            , getTransactions model (Just TransactionType.Disbursement)
            )

        FilterNeedsReview ->
            ( { model | filterNeedsReview = True, heading = "Needs Review (" ++ String.fromInt model.aggregations.needsReviewCount ++ ")", generateDisclosureModalVisibility = Modal.hidden }
            , getTransactions model Nothing
            )

        FilterAll ->
            ( { model | filterTransactionType = Nothing, filterNeedsReview = False, heading = "All Transactions" }
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

        -- Feed pagination
        MoreTxnsClicked ->
            ( { model | moreLoading = True }, getNextTxnsSet model )

        GotTxnSet res ->
            case res of
                Ok body ->
                    let
                        txns =
                            applyNeedsReviewFilter model <| GetTxns.toTxns body

                        moreDisabled =
                            length txns == 0

                        fromId =
                            Maybe.map (\txn -> txn.id) <| head <| reverse txns

                        aggs =
                            GetTxns.toAggs body

                        committee =
                            GetTxns.toCommittee body
                    in
                    ( { model
                        | transactions = concat [ model.transactions, txns ]
                        , aggregations = aggs
                        , committee = committee
                        , moreLoading = False
                        , loading = False
                        , moreDisabled = moreDisabled
                        , fromId = fromId
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.config model.committeeId )

        ToggleDeletePrompt ->
            ( { model | alertVisibility = Alert.shown }, Cmd.none )

        DeleteAlertMsg visibility ->
            ( { model | alertVisibility = visibility, isDeletionConfirmed = Confirmed }, Cmd.none )


generateReport : Cmd msg
generateReport =
    Download.string "2021_Q1.pdf" "text/pdf" "2021_Q1"


deleteTxnMapper : String -> Model -> DeleteTxn.EncodeModel
deleteTxnMapper txnId model =
    { committeeId = model.committeeId
    , id = txnId
    }



-- HTTP


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    CreateDisb.send GotCreateDisbursementResponse model.config <| CreateDisb.encode CreateDisbursement.toEncodeModel model.createDisbursementModal


createContribution : Model -> Cmd Msg
createContribution model =
    CreateContrib.send GotCreateContributionResponse model.config <| CreateContrib.encode CreateContribution.toEncodeModel model.createContributionModal


reconcileDisb : Model -> Cmd Msg
reconcileDisb model =
    ReconcileTxn.send DisbRuleUnverifiedGotReconcileMutResp model.config <| ReconcileTxn.encode DisbRuleUnverified.reconcileTxnEncoder model.disbRuleUnverifiedModal


reconcileContrib : Model -> Cmd Msg
reconcileContrib model =
    ReconcileTxn.send ContribRuleUnverifiedGotReconcileMutResp model.config <| ReconcileTxn.encode ContribRuleUnverified.reconcileTxnEncoder model.contribRuleUnverifiedModal


deleteTxn : Model -> String -> Cmd Msg
deleteTxn model txnId =
    DeleteTxn.send GotDeleteTxnMutResp model.config <| DeleteTxn.encode (deleteTxnMapper txnId) model


getNextTxnsSet : Model -> Cmd Msg
getNextTxnsSet model =
    GetTxns.send
        GotTxnSet
        model.config
    <|
        GetTxns.encode model.committeeId
            model.filterTransactionType
            (Just Pagination.size)
            model.fromId


getTransactions : Model -> Maybe TransactionType -> Cmd Msg
getTransactions model maybeTxnType =
    GetTxns.send GotTransactionsData model.config <| GetTxns.encode model.committeeId maybeTxnType Nothing Nothing


getTransaction : Model -> String -> Cmd Msg
getTransaction model txnId =
    GetTxn.send GotTransactionData model.config <| GetTxn.encode model.committeeId txnId


getReport : Model -> Cmd Msg
getReport model =
    GetReport.send GotReportData model.config <| GetReport.encode model.committeeId


amendDisb : Model -> Cmd Msg
amendDisb model =
    AmendDisb.send DisbRuleVerifiedGotMutResp model.config <| AmendDisb.encode model.disbRuleVerifiedModal


amendContrib : Model -> Cmd Msg
amendContrib model =
    AmendContrib.send ContribRuleVerifiedGotMutResp model.config <| AmendContrib.encode ContribRuleVerified.amendTxnEncoder model.contribRuleVerifiedModal



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
        , Dropdown.subscriptions model.generateDisclosureModalPreviewDropdownState ToggleGenerateDisclosureModalPreviewDropdown
        , Modal.subscriptions model.createDisbursementModalVisibility CreateDisbursementModalAnimate
        , Modal.subscriptions model.disbRuleUnverifiedModalVisibility DisbRuleUnverifiedModalAnimate
        , Modal.subscriptions model.disbRuleVerifiedModalVisibility DisbRuleVerifiedModalAnimate
        , Modal.subscriptions model.contribRuleUnverifiedModalVisibility ContribRuleUnverifiedModalAnimate
        , Modal.subscriptions model.contribRuleVerifiedModalVisibility ContribRuleVerifiedModalAnimate
        , Alert.subscriptions model.alertVisibility DeleteAlertMsg
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



-- Utils


isNeedsReviewTxn : Transaction.Model -> Bool
isNeedsReviewTxn txn =
    (not txn.ruleVerified && txn.bankVerified) || (txn.ruleVerified && not txn.bankVerified)


applyNeedsReviewFilter : Model -> Transactions.Model -> Transactions.Model
applyNeedsReviewFilter model txns =
    if model.filterNeedsReview then
        List.filter isNeedsReviewTxn txns

    else
        txns


type DiscDropdownContext
    = Download
    | Preview
    | Closed


type DelConfirmationState
    = Confirmed
    | Unconfirmed
    | Uninitialized
