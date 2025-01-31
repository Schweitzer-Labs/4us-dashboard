module CreateDisbursement exposing
    ( Model
    , Msg(..)
    , fromError
    , init
    , requiredFieldValidators
    , toEncodeModel
    , toSubmitDisabled
    , update
    , validator
    , view
    )

import Api.CreateDisb as CreateDisb
import Bootstrap.Grid as Grid exposing (Column)
import DisbInfo
import Errors exposing (fromDisbPaymentInfo, fromInKind, fromPostalCode)
import Html exposing (Html)
import PaymentMethod
import PurposeCode exposing (PurposeCode)
import Validate exposing (Validator, fromErrors, ifBlank, ifNothing)


type alias Model =
    { committeeId : String
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
    , maybeError : Maybe String
    , isSubmitDisabled : Bool
    }


init : String -> Model
init committeeId =
    { committeeId = committeeId
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
    , paymentMethod = Nothing
    , checkNumber = ""
    , maybeError = Nothing
    , isSubmitDisabled = True
    }


view : Model -> Html Msg
view model =
    Grid.containerFluid
        []
    <|
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
            , paymentDate = Just ( model.paymentDate, PaymentDateUpdated )
            , paymentMethod = Just ( model.paymentMethod, PaymentMethodUpdated )
            , disabled = False
            , isEditable = False
            , toggleEdit = NoOp
            , maybeError = model.maybeError
            , txnID = Nothing
            }


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PurposeCodeUpdated str ->
            ( { model | purposeCode = str }, Cmd.none )

        PaymentMethodUpdated pm ->
            ( { model | paymentMethod = pm, isSubmitDisabled = False }, Cmd.none )

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
            ( { model
                | isInKind = bool
              }
            , Cmd.none
            )


validator : Validator String Model
validator =
    Validate.firstError <|
        requiredFieldValidators
            ++ [ postalCodeValidator
               , amountValidator
               , isInKindValidator
               ]


requiredFieldValidators =
    [ paymentInfoValidator
    , ifBlank .entityName "Entity name is missing."
    , ifBlank .addressLine1 "Address 1 is missing."
    , ifBlank .city "City is missing."
    , ifBlank .state "State is missing."
    , ifBlank .postalCode "Postal Code is missing."
    , ifBlank .paymentDate "Payment Date is missing"
    , ifNothing .paymentMethod "Processing Info is missing"
    , ifNothing .isSubcontracted "Subcontracted Information is missing"
    , ifNothing .isPartialPayment "Partial Payment Information is missing"
    , ifNothing .isExistingLiability "Existing Liability Information is missing"
    ]


toSubmitDisabled =
    Validate.any
        requiredFieldValidators


amountValidator : Validator String Model
amountValidator =
    ifBlank .amount "Amount is missing."


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


paymentInfoValidator : Validator String Model
paymentInfoValidator =
    fromErrors paymentInfoOnModelToErrors


paymentInfoOnModelToErrors : Model -> List String
paymentInfoOnModelToErrors { paymentMethod, checkNumber } =
    fromDisbPaymentInfo paymentMethod checkNumber


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
