module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , fromError
    , init
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
import Asset
import BankData
import Bootstrap.Button as Button
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cents
import Cognito exposing (loginUrl)
import Config exposing (Config)
import DataTable exposing (DataRow)
import DisbInfo
import Errors exposing (fromInKind, fromPostalCode)
import Html exposing (Html, div, h6, input, span, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import LabelWithData exposing (labelWithContent, labelWithData)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)
import SubmitButton exposing (submitButton)
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction
import TransactionType exposing (TransactionType)
import Transactions
import Validate exposing (Validator, fromErrors, ifBlank, ifNothing, validate)


type alias Model =
    { txns : List Transaction.Model
    , bankTxn : Transaction.Model
    , committeeId : String
    , selectedTxns : List Transaction.Model
    , related : List Transaction.Model
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
    , paymentMethod : Maybe PaymentMethod
    , checkNumber : String
    , createDisbIsVisible : Bool
    , disabled : Bool
    , isCreateDisbButtonDisabled : Bool
    , isReconcileButtonDisabled : Bool
    , maybeError : Maybe String
    , config : Config
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns bankTxn =
    { txns = txns
    , bankTxn = bankTxn
    , committeeId = bankTxn.committeeId
    , selectedTxns = []
    , related = getRelatedDisb bankTxn txns
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
    , amount = ""
    , paymentDate = ""
    , paymentMethod = Just bankTxn.paymentMethod
    , checkNumber = ""
    , createDisbIsVisible = False
    , isCreateDisbButtonDisabled = True
    , disabled = True
    , isReconcileButtonDisabled = True
    , maybeError = Nothing
    , config = config
    }


getRelatedDisb : Transaction.Model -> List Transaction.Model -> List Transaction.Model
getRelatedDisb txn txns =
    List.filter (\val -> (val.paymentMethod == txn.paymentMethod) && (val.amount <= txn.amount) && not val.bankVerified && val.ruleVerified) txns


view : Model -> Html Msg
view model =
    div
        [ Spacing.mt4 ]
        [ BankData.view True model.bankTxn
        , h6 [ Spacing.mt4 ] [ text "Reconcile" ]
        , Grid.containerFluid
            []
          <|
            [ reconcileInfoRow model.bankTxn model.selectedTxns
            , addDisbButtonOrHeading model
            ]
                ++ disbFormRow model
                ++ [ reconcileItemsTable model.related model.selectedTxns ]
        ]


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
        div [ Spacing.mt4, class "font-size-large", onClick CreateDisbToggled ] [ text "Create Disbursement" ]

    else
        addDisbButton


addDisbButton : Html Msg
addDisbButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick CreateDisbToggled ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle" ] [ text "Add Disbursement" ]
        ]


disbFormRow : Model -> List (Html Msg)
disbFormRow model =
    if model.createDisbIsVisible then
        DisbInfo.view
            { entityName = ( model.entityName, EntityNameUpdated )
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
            , paymentDate = Just ( model.paymentDate, PaymentDateUpdated )
            , paymentMethod = Nothing
            , disabled = False
            , isEditable = False
            , toggleEdit = NoOp
            , maybeError = model.maybeError
            }
            ++ [ buttonRow CreateDisbToggled "Create" "Cancel" CreateDisbSubmitted False model.isCreateDisbButtonDisabled ]

    else
        []


buttonRow : msg -> String -> String -> msg -> Bool -> Bool -> Html msg
buttonRow hideMsg displayText exitText msg submitting disabled =
    Grid.row
        [ Row.betweenXs
        , Row.attrs
            [ Spacing.mt3
            , Spacing.mb3
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
    | PaymentMethodUpdated (Maybe PaymentMethod)
    | CheckNumberUpdated String
    | CreateDisbToggled
    | CreateDisbSubmitted
    | RelatedTransactionClicked Transaction.Model Bool
    | CreateDisbGotResp (Result Http.Error MutationResponse)
    | GetTxnsGotResp (Result Http.Error GetTxns.Model)


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
            ( { model | paymentDate = str, isCreateDisbButtonDisabled = False }, Cmd.none )

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
            ( { model | isInKind = bool }, Cmd.none )

        CreateDisbToggled ->
            ( { model | createDisbIsVisible = not model.createDisbIsVisible }, Cmd.none )

        CreateDisbSubmitted ->
            case validate validator model of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( fromError model error, Cmd.none )

                Ok val ->
                    ( model
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
                            ( { model
                                | createDisbIsVisible = False
                                , isCreateDisbButtonDisabled = False
                              }
                            , getTxns model
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | maybeError = List.head errList
                                , isCreateDisbButtonDisabled = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | maybeError = Just <| Api.decodeError err
                        , isCreateDisbButtonDisabled = False
                      }
                    , Cmd.none
                    )

        GetTxnsGotResp res ->
            case res of
                Ok body ->
                    ( { model
                        | txns = getRelatedDisb model.bankTxn <| GetTxns.toTxns body
                      }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        { cognitoDomain, cognitoClientId, redirectUri } =
                            model.config
                    in
                    ( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )

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
    Validate.firstError
        [ ifBlank .entityName "Entity name is missing."
        , ifBlank .addressLine1 "Address 1 is missing."
        , ifBlank .city "City is missing."
        , ifBlank .state "State is missing."
        , ifBlank .postalCode "Postal Code is missing."
        , ifNothing .isSubcontracted "Subcontracted Information is missing"
        , ifNothing .isPartialPayment "Partial Payment Information is missing"
        , ifNothing .isExistingLiability "Existing Liability Information is missing"
        , postalCodeValidator
        , amountValidator
        , isInKindValidator
        ]


amountValidator : Validator String Model
amountValidator =
    ifBlank .amount "Amount is missing."


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
    model.isReconcileButtonDisabled && totalSelectedMatch model


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
    GetTxns.send GetTxnsGotResp model.config <| GetTxns.encode model.committeeId (Just TransactionType.Disbursement)
