module TxnForm.DisbRuleVerified exposing
    ( Model
    , Msg(..)
    , fromError
    , init
    , loadingInit
    , update
    , validator
    , view
    )

import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Popover as Popover
import DisbInfo
import Errors exposing (fromInKind, fromPostalCode)
import ExpandableBankData
import Html exposing (Html)
import Loading
import PaymentInfo
import PaymentMethod
import PurposeCode exposing (PurposeCode)
import Transaction
import Validate exposing (Validator, fromErrors, ifBlank, ifNothing)


type alias Model =
    { txn : Transaction.Model
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
    , showBankData : Bool
    , loading : Bool
    , isSubmitDisabled : Bool
    , maybeError : Maybe String
    , formDisabled : Bool
    , popoverState : Popover.State
    }


loadingInit : Model
loadingInit =
    let
        state =
            init Transaction.init
    in
    { state | loading = True }


init : Transaction.Model -> Model
init txn =
    { txn = txn
    , entityName = Maybe.withDefault "" txn.entityName
    , addressLine1 = Maybe.withDefault "" txn.addressLine1
    , addressLine2 = Maybe.withDefault "" txn.addressLine2
    , city = Maybe.withDefault "" txn.city
    , state = Maybe.withDefault "" txn.state
    , postalCode = Maybe.withDefault "" txn.postalCode
    , purposeCode = txn.purposeCode
    , isSubcontracted = txn.isSubcontracted
    , isPartialPayment = txn.isPartialPayment
    , isExistingLiability = txn.isExistingLiability
    , isInKind = Nothing
    , amount = ""
    , paymentDate = ""
    , paymentMethod = Nothing
    , checkNumber = ""
    , showBankData = False
    , loading = False
    , formDisabled = True
    , isSubmitDisabled = True
    , maybeError = Nothing
    , popoverState = Popover.initialState
    }


view : Model -> Html Msg
view model =
    if model.loading then
        loadingView

    else
        loadedView model


loadingView : Html msg
loadingView =
    Loading.view


loadedView : Model -> Html Msg
loadedView model =
    let
        bankData =
            if model.txn.bankVerified then
                ExpandableBankData.view model.showBankData model.txn BankDataToggled

            else
                []
    in
    Grid.container
        []
        ([]
            ++ PaymentInfo.view model.txn
            ++ disbFormRow model
            ++ bankData
        )


disbFormRow : Model -> List (Html Msg)
disbFormRow model =
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
        , isInKind = ( Just False, IsInKindUpdated )
        , amount = Nothing
        , paymentDate = Nothing
        , paymentMethod = Nothing
        , disabled = model.formDisabled
        , isEditable = True
        , toggleEdit = EditFormToggled
        , maybeError = model.maybeError
        , txnID = Just model.txn.id
        }


type Msg
    = NoOp
    | PopoverMsg Popover.State
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
    | EditFormToggled
    | BankDataToggled


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
            ( { model | isInKind = bool }, Cmd.none )

        BankDataToggled ->
            ( { model | showBankData = not model.showBankData }, Cmd.none )

        EditFormToggled ->
            case model.formDisabled of
                True ->
                    ( { model | formDisabled = False, isSubmitDisabled = False }, Cmd.none )

                False ->
                    let
                        state =
                            init model.txn
                    in
                    ( { state | formDisabled = True, isSubmitDisabled = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        PopoverMsg state ->
            ( { model | popoverState = state }, Cmd.none )


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
        , isInKindValidator
        ]


postalCodeValidator : Validator String Model
postalCodeValidator =
    fromErrors postalCodeOnModelToErrors


postalCodeOnModelToErrors : Model -> List String
postalCodeOnModelToErrors model =
    fromPostalCode model.postalCode


fromError : Model -> String -> Model
fromError model error =
    { model | maybeError = Just error }


isInKindValidator : Validator String Model
isInKindValidator =
    fromErrors isInKindOnModelToErrors


isInKindOnModelToErrors : Model -> List String
isInKindOnModelToErrors model =
    fromInKind model.isInKind
