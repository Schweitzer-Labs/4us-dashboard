module Page.Transactions exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Token)
import Api.Endpoint exposing (Endpoint(..))
import Api.GraphQL exposing (MutationResponse(..), contributionMutation, createDisbursementMutation, encodeQuery, encodeTransactionQuery, getTransactions, graphQLErrorDecoder, transactionQuery)
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Browser.Navigation exposing (load)
import Cents
import Cognito exposing (loginUrl)
import Committee
import Config exposing (Config)
import CreateContribution
import CreateDisbursement
import Delay
import Disbursement as Disbursement
import EnrichTransaction
import EntityType
import File.Download as Download
import FileDisclosure
import FileFormat exposing (FileFormat)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (string)
import Json.Encode as Encode exposing (Value)
import Loading
import PaymentMethod
import PlatformModal
import PurposeCode
import Session exposing (Session)
import SubmitButton exposing (submitButton)
import Task exposing (Task)
import Time
import Timestamp exposing (dateStringToMillis)
import Transaction
import Transaction.TransactionsData as TransactionsData exposing (TransactionsData)
import TransactionType exposing (TransactionType(..))
import Transactions
import TxnForm as TxnForm
import TxnForm.DisbRuleUnverified as DisbRuleUnverified
import TxnForm.DisbRuleVerified as DisbRuleVerified



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
    ( { session = session
      , loading = True
      , committeeId = committeeId
      , timeZone = Time.utc
      , transactions = []
      , aggregations = aggs
      , committee = committee
      , createContributionModalVisibility = Modal.hidden
      , createContributionModal = CreateContribution.init
      , createContributionSubmitting = False
      , generateDisclosureModalVisibility = Modal.hidden
      , actionsDropdown = Dropdown.initialState
      , filtersDropdown = Dropdown.initialState
      , generateDisclosureModalDownloadDropdownState = Dropdown.initialState
      , filterTransactionType = Nothing
      , disclosureSubmitting = False
      , disclosureSubmitted = False
      , createDisbursementModalVisibility = Modal.hidden
      , createDisbursementModal = CreateDisbursement.init
      , createDisbursementSubmitting = False
      , disbRuleUnverifiedModal = DisbRuleUnverified.init [] Transaction.init
      , disbRuleUnverifiedSubmitting = False
      , disbRuleUnverifiedModalVisibility = Modal.hidden
      , disbRuleVerifiedModal = DisbRuleVerified.init Transaction.init
      , disbRuleVerifiedSubmitting = False
      , disbRuleVerifiedModalVisibility = Modal.hidden
      , config = config
      }
    , getTransactions config committeeId LoadTransactionsData Nothing
    )



-- VIEW


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ dropdowns model
        , Transactions.viewInteractive model.committee SortTransactions ShowTxnFormModal [] model.transactions
        , createContributionModal model
        , generateDisclosureModal model
        , createDisbursementModal model
        , disbRuleUnverifiedModal model
        , disbRuleVerifiedModal model
        ]


createDisbursementModal : Model -> Html Msg
createDisbursementModal model =
    PlatformModal.view
        { hideMsg = HideCreateDisbursementModal
        , animateMsg = AnimateCreateDisbursementModal
        , title = "Create Disbursement"
        , updateMsg = CreateDisbursementModalUpdated
        , subModel = model.createDisbursementModal
        , subView = CreateDisbursement.view
        , submitMsg = SubmitCreateDisbursement
        , submitText = "Create Disbursement"
        , isSubmitting = model.createDisbursementSubmitting
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
                , Dropdown.buttonItem [ onClick ShowCreateDisbursementModal ] [ text "Create Disbursement" ]
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



-- TAGS
-- UPDATE


type Msg
    = GotSession Session
    | LoadTransactionsData (Result Http.Error TransactionsData)
    | SortTransactions Transactions.Label
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
    | SubmitCreateContribution
    | SubmitCreateContributionDelay
    | ToggleActionsDropdown Dropdown.State
    | ToggleFiltersDropdown Dropdown.State
    | ToggleGenerateDisclosureModalDownloadDropdown Dropdown.State
    | FileDisclosure
    | FileDisclosureDelayed
    | FilterByContributions
    | FilterByDisbursements
    | NoOp
    | FilterAll
    | HideCreateDisbursementModal
    | ShowCreateDisbursementModal
    | CreateDisbursementModalUpdated CreateDisbursement.Msg
    | AnimateCreateDisbursementModal Modal.Visibility
    | SubmitCreateDisbursement
    | SubmitCreateDisbursementDelay
    | DisbRuleUnverifiedModalHide
    | DisbRuleUnverifiedModalAnimate Modal.Visibility
    | DisbRuleUnverifiedModalUpdate DisbRuleUnverified.Msg
    | DisbRuleUnverifiedSubmit
    | DisbRuleVerifiedModalHide
    | DisbRuleVerifiedModalAnimate Modal.Visibility
    | DisbRuleVerifiedModalUpdate DisbRuleVerified.Msg
    | DisbRuleVerifiedSubmit
    | ShowTxnFormModal Transaction.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowTxnFormModal txn ->
            case TxnForm.fromTxn txn of
                TxnForm.DisbRuleUnverified ->
                    ( { model
                        | disbRuleUnverifiedModalVisibility = Modal.shown
                        , disbRuleUnverifiedModal = DisbRuleUnverified.init model.transactions txn
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
            ( model, Cmd.none )

        DisbRuleUnverifiedModalUpdate subMsg ->
            let
                ( subModel, subCmd ) =
                    DisbRuleUnverified.update subMsg model.disbRuleUnverifiedModal
            in
            ( { model | disbRuleUnverifiedModal = subModel }, Cmd.map DisbRuleUnverifiedModalUpdate subCmd )

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
            ( model, Cmd.none )

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

        SortTransactions label ->
            case label of
                Transactions.EntityName ->
                    ( applyFilter label .entityName model, Cmd.none )

                Transactions.DateTime ->
                    ( applyFilter label .dateProcessed model, Cmd.none )

                Transactions.Amount ->
                    ( applyFilter label .amount model, Cmd.none )

                Transactions.PaymentMethod ->
                    ( applyFilter label .paymentMethod model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        LoadTransactionsData res ->
            case res of
                Ok body ->
                    ( { model
                        | transactions = body.data.transactions
                        , aggregations = body.data.aggregations
                        , committee = body.data.committee
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

        ShowCreateContributionModal ->
            ( { model
                | createContributionModalVisibility = Modal.shown
                , createContributionModal = CreateContribution.init
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
                            ( model, Delay.after 2 Delay.Second SubmitCreateContributionDelay )

                        ValidationFailure errList ->
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
                            ( model, Delay.after 2 Delay.Second SubmitCreateDisbursementDelay )

                        ValidationFailure errList ->
                            ( { model
                                | createDisbursementModal =
                                    CreateDisbursement.setError model.createDisbursementModal <|
                                        Maybe.withDefault "Unexplained error" <|
                                            List.head errList
                                , createDisbursementSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | createDisbursementModal =
                            CreateDisbursement.setError model.createDisbursementModal <|
                                Api.decodeError err
                        , createContributionSubmitting = False
                      }
                    , Cmd.none
                    )

        SubmitCreateContributionDelay ->
            ( { model
                | createContributionModalVisibility = Modal.hidden
                , createContributionSubmitting = False
              }
            , getTransactions model.config model.committeeId LoadTransactionsData model.filterTransactionType
            )

        ToggleActionsDropdown state ->
            ( { model | actionsDropdown = state }, Cmd.none )

        ToggleFiltersDropdown state ->
            ( { model | filtersDropdown = state }, Cmd.none )

        ToggleGenerateDisclosureModalDownloadDropdown state ->
            ( { model | generateDisclosureModalDownloadDropdownState = state }, Cmd.none )

        FilterByContributions ->
            ( { model | filterTransactionType = Just TransactionType.Contribution }
            , getTransactions model.config model.committeeId LoadTransactionsData (Just TransactionType.Contribution)
            )

        FilterByDisbursements ->
            ( { model | filterTransactionType = Just TransactionType.Disbursement }
            , getTransactions model.config model.committeeId LoadTransactionsData (Just TransactionType.Disbursement)
            )

        FilterAll ->
            ( { model | filterTransactionType = Nothing }
            , getTransactions model.config model.committeeId LoadTransactionsData Nothing
            )

        FileDisclosure ->
            ( { model | disclosureSubmitting = True }, Delay.after 2 Delay.Second FileDisclosureDelayed )

        FileDisclosureDelayed ->
            ( { model | disclosureSubmitting = False, disclosureSubmitted = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ShowCreateDisbursementModal ->
            ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none )

        HideCreateDisbursementModal ->
            ( { model | createDisbursementModalVisibility = Modal.hidden }
            , Cmd.none
            )

        SubmitCreateDisbursement ->
            ( { model
                | createDisbursementSubmitting = True
              }
            , createDisbursement model
            )

        AnimateCreateDisbursementModal visibility ->
            ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )

        CreateDisbursementModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateDisbursement.update subMsg model.createDisbursementModal
            in
            ( { model | createDisbursementModal = subModel }, Cmd.map CreateDisbursementModalUpdated subCmd )

        SubmitCreateDisbursementDelay ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
                , createDisbursementSubmitting = False
                , createDisbursementModal = CreateDisbursement.init
              }
            , getTransactions model.config model.committeeId LoadTransactionsData Nothing
            )


applyFilter : Transactions.Label -> (Disbursement.Model -> String) -> Model -> Model
applyFilter label field model =
    model


generateReport : Cmd msg
generateReport =
    Download.string "2021_Q1.pdf" "text/pdf" "2021_Q1"



-- HTTP


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
        , Modal.subscriptions model.createDisbursementModalVisibility AnimateCreateDisbursementModal
        , Modal.subscriptions model.disbRuleUnverifiedModalVisibility DisbRuleUnverifiedModalAnimate
        , Modal.subscriptions model.disbRuleVerifiedModalVisibility DisbRuleVerifiedModalAnimate
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session


optionalFieldString : String -> String -> List ( String, Value )
optionalFieldString key val =
    if val == "" then
        []

    else
        [ ( key, Encode.string val ) ]


optionalFieldStringInt : String -> String -> List ( String, Value )
optionalFieldStringInt key val =
    if val == "" then
        []

    else
        [ ( key, Encode.int <| Maybe.withDefault 1 <| String.toInt val ) ]


optionalFieldNotZero : String -> Int -> List ( String, Value )
optionalFieldNotZero key val =
    if val > 0 then
        [ ( key, Encode.int val ) ]

    else
        []


encodeContribution : Model -> Encode.Value
encodeContribution model =
    let
        contrib =
            model.createContributionModal

        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.committeeId )
                , ( "amount", Encode.int <| Cents.fromDollars contrib.amount )
                , ( "paymentMethod", Encode.string contrib.paymentMethod )
                , ( "firstName", Encode.string contrib.firstName )
                , ( "lastName", Encode.string contrib.lastName )
                , ( "addressLine1", Encode.string contrib.addressLine1 )
                , ( "city", Encode.string contrib.city )
                , ( "state", Encode.string contrib.state )
                , ( "postalCode", Encode.string contrib.postalCode )
                , ( "entityType", Encode.string <| EntityType.fromMaybeToStringWithDefaultInd contrib.maybeEntityType )
                , ( "transactionType", Encode.string <| TransactionType.toString TransactionType.Contribution )
                ]
                    ++ optionalFieldString "emailAddress" contrib.emailAddress
                    ++ optionalFieldNotZero "paymentDate" (dateStringToMillis contrib.paymentDate)
                    ++ optionalFieldString "cardNumber" contrib.cardNumber
                    ++ optionalFieldStringInt "cardExpirationMonth" contrib.expirationMonth
                    ++ optionalFieldStringInt "cardExpirationYear" contrib.expirationYear
                    ++ optionalFieldString "cardCVC" contrib.cvv
                    ++ optionalFieldString "checkNumber" contrib.checkNumber
                    ++ optionalFieldString "entityName" contrib.entityName
                    ++ optionalFieldString "employer" contrib.employer
                    ++ optionalFieldString "occupation" contrib.occupation
                    ++ optionalFieldString "middleName" contrib.middleName
                    ++ optionalFieldString "addressLine2" contrib.addressLine2
                    ++ optionalFieldString "occupation" contrib.occupation
                    ++ optionalFieldString "phoneNumber" contrib.phoneNumber
    in
    encodeQuery contributionMutation variables


createContribution : Model -> Cmd Msg
createContribution model =
    let
        body =
            encodeContribution model |> Http.jsonBody
    in
    Http.send GotCreateContributionResponse <|
        Api.post (Endpoint model.config.apiEndpoint) (Api.Token model.config.token) body <|
            createContributionDecoder


createContributionDecoder : Decode.Decoder MutationResponse
createContributionDecoder =
    Decode.oneOf [ createContributionSuccessDecoder, mutationValidationFailureDecoder ]


createContributionSuccessDecoder : Decode.Decoder MutationResponse
createContributionSuccessDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "createContribution" <|
                Decode.field "id" <|
                    Decode.string


mutationValidationFailureDecoder : Decode.Decoder MutationResponse
mutationValidationFailureDecoder =
    Decode.map ValidationFailure graphQLErrorDecoder


encodeDisbursement : Model -> Encode.Value
encodeDisbursement model =
    let
        d =
            model.createDisbursementModal

        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.committeeId )
                , ( "amount", Encode.int <| Cents.fromDollars d.checkAmount )
                , ( "paymentMethod", Encode.string <| Maybe.withDefault (PaymentMethod.toDataString PaymentMethod.Debit) d.paymentMethod )
                , ( "entityName", Encode.string d.checkRecipient )
                , ( "addressLine1", Encode.string d.addressLine1 )
                , ( "city", Encode.string d.city )
                , ( "state", Encode.string d.state )
                , ( "postalCode", Encode.string d.postalCode )
                , ( "isSubcontracted", Encode.bool <| Maybe.withDefault False d.isSubcontracted )
                , ( "isPartialPayment", Encode.bool <| Maybe.withDefault False d.isPartialPayment )
                , ( "isExistingLiability", Encode.bool <| Maybe.withDefault False d.isExistingLiability )
                , ( "purposeCode", Encode.string <| Maybe.withDefault (PurposeCode.toString PurposeCode.OTHER) d.purposeCode )
                , ( "paymentDate", Encode.int <| dateStringToMillis d.checkDate )
                , ( "transactionType", Encode.string <| TransactionType.toString TransactionType.Disbursement )
                ]
                    ++ optionalFieldString "checkNumber" d.checkNumber
                    ++ optionalFieldString "addressLine2" d.addressLine2
    in
    encodeQuery createDisbursementMutation variables


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    let
        body =
            encodeDisbursement model |> Http.jsonBody
    in
    Http.send GotCreateDisbursementResponse <|
        Api.post (Endpoint model.config.apiEndpoint) (Api.Token model.config.token) body <|
            createDisbursementDecoder


createDisbursementDecoder : Decode.Decoder MutationResponse
createDisbursementDecoder =
    Decode.oneOf [ createDisbursementSuccessDecoder, mutationValidationFailureDecoder ]


createDisbursementSuccessDecoder : Decode.Decoder MutationResponse
createDisbursementSuccessDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "createDisbursement" <|
                Decode.field "id" <|
                    Decode.string
