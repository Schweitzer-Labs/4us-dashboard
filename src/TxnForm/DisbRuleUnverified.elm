module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , fromError
    , init
    , reconcileTxnEncoder
    , toSubmitDisabled
    , totalSelectedMatch
    , update
    , validator
    , view
    )

import Api
import Api.CreateDisb as CreateDisb
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.ReconcileTxn as ReconcileTxn
import Asset
import BankData
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cents exposing (toDollarData)
import Cognito exposing (loginUrl)
import Config exposing (Config)
import Copy
import DataTable exposing (DataRow)
import Direction
import DisbInfo
import Errors exposing (fromInKind, fromPostalCode)
import Html exposing (Html, div, h6, input, span, text)
import Html.Attributes exposing (attribute, class, type_)
import Html.Events exposing (onClick)
import Http
import LabelWithData exposing (labelWithContent, labelWithData)
import PaymentMethod
import PurposeCode exposing (PurposeCode)
import SubmitButton exposing (submitButton)
import Time exposing (utc)
import TimeZone exposing (america__new_york)
import Timestamp exposing (dateStringToMillis, formDate)
import Transaction
import TransactionType exposing (TransactionType)
import Transactions
import Validate exposing (Validator, fromErrors, ifBlank, ifNothing, validate)


type alias Model =
    { bankTxn : Transaction.Model
    , committeeId : String
    , selectedTxns : List Transaction.Model
    , relatedTxns : List Transaction.Model
    , entityName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , purposeCode : Maybe PurposeCode
    , isSubcontracted : Maybe Bool
    , isPartialPayment : Maybe Bool
    , isExistingLiability : Maybe Bool
    , isInKind : Maybe Bool
    , amount : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
    , checkNumber : String
    , createDisbIsVisible : Bool
    , disabled : Bool
    , createDisbButtonIsDisabled : Bool
    , createDisbIsSubmitting : Bool
    , reconcileButtonIsDisabled : Bool
    , maybeError : Maybe String
    , config : Config
    , lastCreatedTxnId : String
    , timezone : Time.Zone
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns bankTxn =
    { bankTxn = bankTxn
    , committeeId = bankTxn.committeeId
    , selectedTxns = []
    , relatedTxns = getRelatedDisb bankTxn txns
    , entityName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , purposeCode = Nothing
    , isSubcontracted = Nothing
    , isPartialPayment = Nothing
    , isExistingLiability = Nothing
    , isInKind = Nothing
    , amount = toDollarData bankTxn.amount
    , paymentDate = formDate (america__new_york ()) bankTxn.paymentDate
    , paymentMethod = Just bankTxn.paymentMethod
    , checkNumber = ""
    , createDisbIsVisible = False
    , createDisbButtonIsDisabled = True
    , createDisbIsSubmitting = False
    , disabled = True
    , reconcileButtonIsDisabled = True
    , maybeError = Nothing
    , config = config
    , lastCreatedTxnId = ""
    , timezone = america__new_york ()
    }


clearForm : Model -> Model
clearForm model =
    { model
        | entityName = ""
        , addressLine1 = ""
        , addressLine2 = ""
        , city = ""
        , state = ""
        , postalCode = ""
        , purposeCode = Nothing
        , isSubcontracted = Nothing
        , isPartialPayment = Nothing
        , isExistingLiability = Nothing
        , isInKind = Nothing
        , amount = toDollarData model.bankTxn.amount
        , paymentDate = formDate model.timezone model.bankTxn.paymentDate
        , checkNumber = ""
        , createDisbIsVisible = False
        , createDisbButtonIsDisabled = True
        , createDisbIsSubmitting = False
        , disabled = True
        , reconcileButtonIsDisabled = True
        , maybeError = Nothing
        , lastCreatedTxnId = ""
    }


getRelatedDisb : Transaction.Model -> List Transaction.Model -> List Transaction.Model
getRelatedDisb txn txns =
    List.filter (\val -> (val.paymentMethod /= PaymentMethod.InKind) && (val.amount <= txn.amount) && (val.direction == Direction.Out) && not val.bankVerified && val.ruleVerified) txns


view : Model -> Html Msg
view model =
    div
        []
        [ dialogueBox
        , BankData.view True model.bankTxn
        , h6 [ Spacing.mt4 ] [ text "Reconcile" ]
        , Grid.containerFluid
            []
          <|
            [ reconcileInfoRow model.bankTxn model.selectedTxns
            , addDisbButtonOrHeading model
            ]
                ++ disbFormRow model
                ++ [ reconcileItemsTable model.relatedTxns model.selectedTxns ]
        ]


dialogueBox : Html Msg
dialogueBox =
    Alert.simpleInfo [] Copy.disbUnverifiedDialogue


labels : List String
labels =
    [ "Selected"
    , "Date"
    , "Entity Name"
    , "Amount"
    , "Purpose Code"
    ]


transactionRowMap : ( Maybe (List Transaction.Model), Maybe msg, Transaction.Model ) -> ( Maybe Msg, DataRow Msg )
transactionRowMap ( maybeSelected, maybeMsg, txn ) =
    let
        name =
            Maybe.withDefault Transactions.missingContent (Maybe.map Transactions.uppercaseText <| Transactions.getEntityName txn)

        amount =
            Transactions.getAmount txn

        selected =
            Maybe.withDefault [] maybeSelected

        isChecked =
            isSelected txn selected
    in
    ( Nothing
    , [ ( "Selected"
        , Checkbox.checkbox
            [ Checkbox.id txn.id
            , Checkbox.checked isChecked
            , Checkbox.onCheck <| RelatedTransactionClicked txn
            ]
            ""
        )
      , ( "Date / Time", text <| Timestamp.format (america__new_york ()) txn.paymentDate )
      , ( "Entity Name", name )
      , ( "Amount", amount )
      , ( "Purpose Code", Transactions.getContext txn )
      ]
    )


reconcileItemsTable : List Transaction.Model -> List Transaction.Model -> Html Msg
reconcileItemsTable relatedTxns selectedTxns =
    DataTable.view "Awaiting Transactions." labels transactionRowMap <|
        List.map (\d -> ( Just selectedTxns, Nothing, d )) relatedTxns


addDisbButtonOrHeading : Model -> Html Msg
addDisbButtonOrHeading model =
    if model.createDisbIsVisible then
        div [ Spacing.mt4, class "font-size-large", onClick NoOp ] [ text "Create Disbursement" ]

    else
        addDisbButton


addDisbButton : Html Msg
addDisbButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick CreateDisbToggled ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle", attribute "data-cy" "addDisbBtn" ] [ text "Add Disbursement" ]
        ]


disbFormRow : Model -> List (Html Msg)
disbFormRow model =
    if model.createDisbIsVisible then
        DisbInfo.view
            { checkNumber = ( model.checkNumber, CheckNumberUpdated )
            , entityName = ( model.entityName, EntityNameUpdated )
            , addressLine1 = ( model.addressLine1, AddressLine1Updated )
            , addressLine2 = ( model.addressLine2, AddressLine2Updated )
            , city = ( model.city, CityUpdated )
            , state = ( model.state, StateUpdated )
            , postalCode = ( model.postalCode, PostalCodeUpdated )
            , purposeCode = ( model.purposeCode, PurposeCodeUpdated )
            , isSubcontracted = ( model.isSubcontracted, IsSubcontractedUpdated )
            , isPartialPayment = ( model.isPartialPayment, IsPartialPaymentUpdated )
            , isExistingLiability = ( model.isExistingLiability, IsExistingLiabilityUpdated )
            , isInKind = ( model.isInKind, IsInKindUpdated )
            , amount = Just ( model.amount, AmountUpdated )
            , paymentDate =
                Just
                    ( dateWithFormat model
                    , PaymentDateUpdated
                    )
            , paymentMethod = Just ( model.paymentMethod, PaymentMethodUpdated )
            , disabled = False
            , isEditable = False
            , toggleEdit = NoOp
            , maybeError = model.maybeError
            , txnID = Just model.bankTxn.id
            }
            ++ [ buttonRow CreateDisbToggled "Create" "Cancel" CreateDisbSubmitted model.createDisbIsSubmitting model.createDisbButtonIsDisabled ]

    else
        []


buttonRow : msg -> String -> String -> msg -> Bool -> Bool -> Html msg
buttonRow hideMsg displayText exitText msg submitting disabled =
    Grid.row
        [ Row.betweenXs
        , Row.attrs
            [ Spacing.mt3
            , Spacing.mb5
            ]
        ]
        [ Grid.col
            [ Col.lg4, Col.attrs [ class "text-left" ] ]
            [ exitButton hideMsg exitText ]
        , Grid.col
            [ Col.lg4 ]
            [ submitButton displayText msg submitting disabled ]
        ]


exitButton : msg -> String -> Html msg
exitButton hideMsg displayText =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick hideMsg ]
        ]
        [ text displayText ]


matchesIcon : Bool -> Html msg
matchesIcon val =
    if val then
        Asset.circleCheckGlyph [ class "text-green font-size-large" ]

    else
        Asset.timesGlyph [ class "text-danger font-size-large" ]


labelWithBankVerificationIcon : String -> Bool -> Html msg
labelWithBankVerificationIcon label matchesStatus =
    labelWithContent label (matchesIcon matchesStatus)


reconcileInfoRow : Transaction.Model -> List Transaction.Model -> Html msg
reconcileInfoRow bankTxn selectedTxns =
    let
        selectedTotal =
            List.foldr (\txn acc -> acc + txn.amount) 0 selectedTxns

        matches =
            selectedTotal == bankTxn.amount
    in
    Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [ Col.md4 ] [ labelWithData "Amount" <| Cents.toDollar bankTxn.amount ]
        , Grid.col [ Col.md4 ] [ labelWithData "Total Selected" <| Cents.toDollar selectedTotal ]
        , Grid.col [ Col.md4 ] [ labelWithBankVerificationIcon "Matches" matches ]
        ]


type Msg
    = NoOp
    | EntityNameUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | PurposeCodeUpdated (Maybe PurposeCode)
    | IsSubcontractedUpdated (Maybe Bool)
    | IsPartialPaymentUpdated (Maybe Bool)
    | IsExistingLiabilityUpdated (Maybe Bool)
    | IsInKindUpdated (Maybe Bool)
    | AmountUpdated String
    | PaymentDateUpdated String
    | PaymentMethodUpdated (Maybe PaymentMethod.Model)
    | CheckNumberUpdated String
    | CreateDisbToggled
    | CreateDisbSubmitted
    | RelatedTransactionClicked Transaction.Model Bool
    | CreateDisbGotResp (Result Http.Error MutationResponse)
    | GetTxnsGotResp (Result Http.Error GetTxns.Model)


getTxnById : List Transaction.Model -> String -> Maybe Transaction.Model
getTxnById txns id =
    let
        matches =
            List.filter (\t -> t.id == id) txns
    in
    case matches of
        [ match ] ->
            Just match

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PurposeCodeUpdated str ->
            ( { model | purposeCode = str }, Cmd.none )

        PaymentMethodUpdated pm ->
            ( { model | paymentMethod = pm }, Cmd.none )

        AmountUpdated str ->
            ( { model | amount = str }, Cmd.none )

        EntityNameUpdated str ->
            ( { model | entityName = str }, Cmd.none )

        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        PaymentDateUpdated str ->
            ( { model | paymentDate = str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | addressLine1 = str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | addressLine2 = str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        IsSubcontractedUpdated bool ->
            ( { model | isSubcontracted = bool }, Cmd.none )

        IsPartialPaymentUpdated bool ->
            ( { model | isPartialPayment = bool }, Cmd.none )

        IsExistingLiabilityUpdated bool ->
            ( { model | isExistingLiability = bool }, Cmd.none )

        IsInKindUpdated bool ->
            ( { model | isInKind = bool, createDisbButtonIsDisabled = False }, Cmd.none )

        CreateDisbToggled ->
            ( let
                resetFormModel =
                    clearForm model
              in
              { resetFormModel | createDisbIsVisible = not model.createDisbIsVisible }
            , Cmd.none
            )

        CreateDisbSubmitted ->
            case validate validator model of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( fromError model error, Cmd.none )

                Ok val ->
                    ( { model | createDisbButtonIsDisabled = True, createDisbIsSubmitting = True }
                    , createDisb model
                    )

        RelatedTransactionClicked clickedTxn isChecked ->
            let
                selected =
                    if isChecked then
                        model.selectedTxns ++ [ clickedTxn ]

                    else
                        List.filter (\txn -> txn.id /= clickedTxn.id) model.selectedTxns
            in
            ( { model | selectedTxns = selected, createDisbIsVisible = False }, Cmd.none )

        CreateDisbGotResp res ->
            case res of
                Ok createDisbResp ->
                    case createDisbResp of
                        Success id ->
                            let
                                resetFormModel =
                                    clearForm model
                            in
                            ( { resetFormModel
                                | createDisbIsVisible = False
                                , createDisbButtonIsDisabled = False
                                , createDisbIsSubmitting = False
                                , lastCreatedTxnId = id
                              }
                            , getTxns model
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | maybeError = List.head errList
                                , createDisbButtonIsDisabled = False
                                , createDisbIsSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | maybeError = Just <| Api.decodeError err
                        , createDisbButtonIsDisabled = False
                        , createDisbIsSubmitting = False
                      }
                    , Cmd.none
                    )

        GetTxnsGotResp res ->
            case res of
                Ok body ->
                    let
                        relatedTxns =
                            getRelatedDisb model.bankTxn <| GetTxns.toTxns body

                        resTxnOrEmpty =
                            Maybe.withDefault [] <| Maybe.map List.singleton <| getTxnById relatedTxns model.lastCreatedTxnId
                    in
                    ( { model
                        | relatedTxns = getRelatedDisb model.bankTxn <| GetTxns.toTxns body
                        , selectedTxns = model.selectedTxns ++ resTxnOrEmpty
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.config model.committeeId )

        NoOp ->
            ( model, Cmd.none )


isSelected : Transaction.Model -> List Transaction.Model -> Bool
isSelected txn selected =
    List.any (\val -> val.id == txn.id) selected


fromError : Model -> String -> Model
fromError model error =
    { model | maybeError = Just error }


validator : Validator String Model
validator =
    Validate.all
        [ ifBlank .entityName "Entity name is missing."
        , ifBlank .addressLine1 "Address 1 is missing."
        , ifBlank .city "City is missing."
        , ifBlank .state "State is missing."
        , ifBlank .postalCode "Postal Code is missing."
        , ifBlank .paymentDate "Payment Date is missing"
        , ifNothing .isSubcontracted "Subcontracted Information is missing"
        , ifNothing .isPartialPayment "Partial Payment Information is missing"
        , ifNothing .isExistingLiability "Existing Liability Information is missing"
        , postalCodeValidator
        , amountValidator
        , isInKindValidator
        , fromErrors dateMaxToErrors
        ]


amountValidator : Validator String Model
amountValidator =
    Validate.all
        [ ifBlank .amount "Amount is missing."
        , fromErrors amountMaxToErrors
        ]


dateMaxToErrors : Model -> List String
dateMaxToErrors model =
    Errors.fromMaxDate model.timezone
        model.bankTxn.paymentDate
        (dateStringToMillis model.paymentDate)


amountMaxToErrors : Model -> List String
amountMaxToErrors model =
    Errors.fromMaxAmount model.bankTxn.amount model.amount


postalCodeValidator : Validator String Model
postalCodeValidator =
    fromErrors postalCodeOnModelToErrors


postalCodeOnModelToErrors : Model -> List String
postalCodeOnModelToErrors model =
    fromPostalCode model.postalCode


isInKindValidator : Validator String Model
isInKindValidator =
    fromErrors isInKindOnModelToErrors


isInKindOnModelToErrors : Model -> List String
isInKindOnModelToErrors model =
    fromInKind model.isInKind


totalSelectedMatch : Model -> Bool
totalSelectedMatch model =
    if List.foldr (\txn acc -> acc + txn.amount) 0 model.selectedTxns == model.bankTxn.amount then
        False

    else
        True


toSubmitDisabled : Model -> Bool
toSubmitDisabled model =
    model.reconcileButtonIsDisabled && totalSelectedMatch model


toEncodeModel : Model -> CreateDisb.EncodeModel
toEncodeModel model =
    { committeeId = model.committeeId
    , entityName = model.entityName
    , addressLine1 = model.addressLine1
    , addressLine2 = model.addressLine2
    , city = model.city
    , state = model.state
    , postalCode = model.postalCode
    , purposeCode = model.purposeCode
    , isSubcontracted = model.isSubcontracted
    , isPartialPayment = model.isPartialPayment
    , isExistingLiability = model.isExistingLiability
    , isInKind = model.isInKind
    , amount = model.amount
    , paymentDate = model.paymentDate
    , paymentMethod = model.paymentMethod
    , checkNumber = model.checkNumber
    }


createDisb : Model -> Cmd Msg
createDisb model =
    CreateDisb.send CreateDisbGotResp model.config <| CreateDisb.encode toEncodeModel model


getTxns : Model -> Cmd Msg
getTxns model =
    GetTxns.send GetTxnsGotResp model.config <| GetTxns.encode model.committeeId (Just TransactionType.Disbursement) Nothing Nothing


reconcileTxnEncoder : Model -> ReconcileTxn.EncodeModel
reconcileTxnEncoder model =
    { selectedTxns = model.selectedTxns
    , bankTxn = model.bankTxn
    , committeeId = model.committeeId
    }


dateWithFormat : Model -> String
dateWithFormat model =
    if model.paymentDate == "" then
        formDate (america__new_york ()) model.bankTxn.paymentDate

    else
        model.paymentDate
