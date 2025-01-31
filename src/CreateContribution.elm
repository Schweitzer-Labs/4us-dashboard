port module CreateContribution exposing (Model, Msg(..), fromError, init, setError, subscriptions, toEncodeModel, update, validationMapper, view)

import Api.CreateContrib as CreateContrib
import Browser.Dom as Dom
import ContribInfo exposing (ContribValidatorModel)
import EmploymentStatus
import EntityType
import FormID exposing (Model(..))
import Html exposing (Html)
import InKindType
import Json.Decode as Decode exposing (bool, decodeValue)
import Json.Encode exposing (Value)
import OrgOrInd
import Owners
import OwnersView
import PaymentMethod
import Task



-- PORTS


port sendPhone : String -> Cmd msg


port isValidNumReceiver : (Value -> msg) -> Sub msg


port sendEmail : String -> Cmd msg


port isValidEmailReceiver : (Value -> msg) -> Sub msg


type alias Model =
    { submitting : Bool
    , errors : List String
    , error : String
    , checkNumber : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
    , emailAddress : String
    , isEmailAddressValid : Bool
    , isPhoneNumberValid : Bool
    , phoneNumber : String
    , firstName : String
    , middleName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : Maybe EmploymentStatus.Model
    , employer : String
    , occupation : String
    , entityName : String
    , maybeEntityType : Maybe EntityType.Model
    , maybeOrgOrInd : Maybe OrgOrInd.Model
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , ownersViewModel : OwnersView.Model
    , inKindType : Maybe InKindType.Model
    , inKindDesc : String
    , committeeId : String
    , maybeError : Maybe String
    }


init : String -> Model
init committeeId =
    { submitting = False
    , error = ""
    , errors = []
    , amount = ""
    , checkNumber = ""
    , paymentDate = ""
    , emailAddress = ""
    , isEmailAddressValid = False
    , isPhoneNumberValid = False
    , phoneNumber = ""
    , firstName = ""
    , middleName = ""
    , lastName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , employmentStatus = Nothing
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeEntityType = Nothing
    , maybeOrgOrInd = Nothing
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , ownersViewModel = OwnersView.init [] (Just <| FormID.toString CreateContrib)
    , inKindType = Nothing
    , inKindDesc = ""
    , paymentMethod = Nothing
    , committeeId = committeeId
    , maybeError = Nothing
    }


setError : Model -> String -> Model
setError model str =
    { model | error = str }


view : Model -> Html Msg
view model =
    ContribInfo.view
        { checkNumber = ( model.checkNumber, CheckNumberUpdated )
        , paymentDate = ( model.paymentDate, PaymentDateUpdated )
        , paymentMethod = ( model.paymentMethod, PaymentMethodUpdated )
        , emailAddress = ( model.emailAddress, EmailAddressUpdated )
        , phoneNumber = ( model.phoneNumber, PhoneNumberUpdated )
        , firstName = ( model.firstName, FirstNameUpdated )
        , middleName = ( model.middleName, MiddleNameUpdated )
        , lastName = ( model.lastName, LastNameUpdated )
        , addressLine1 = ( model.addressLine1, AddressLine1Updated )
        , addressLine2 = ( model.addressLine2, AddressLine2Updated )
        , city = ( model.city, CityUpdated )
        , state = ( model.state, StateUpdated )
        , postalCode = ( model.postalCode, PostalCodeUpdated )
        , employmentStatus = ( model.employmentStatus, EmploymentStatusUpdated )
        , employer = ( model.employer, EmployerUpdated )
        , occupation = ( model.occupation, OccupationUpdated )
        , entityName = ( model.entityName, EntityNameUpdated )
        , maybeEntityType = ( model.maybeEntityType, EntityTypeUpdated )
        , maybeOrgOrInd = ( model.maybeOrgOrInd, OrgOrIndUpdated )
        , cardNumber = ( model.cardNumber, CardNumberUpdated )
        , expirationMonth = ( model.expirationMonth, CardMonthUpdated )
        , expirationYear = ( model.expirationYear, CardYearUpdated )
        , cvv = ( model.cvv, CVVUpdated )
        , amount = ( model.amount, AmountUpdated )
        , ownersViewMsg = OwnersViewUpdated
        , ownersViewModel = model.ownersViewModel
        , inKindType = ( model.inKindType, InKindTypeUpdated )
        , inKindDesc = ( model.inKindDesc, InKindDescUpdated )
        , disabled = False
        , isEditable = False
        , toggleEdit = NoOp
        , maybeError = model.maybeError
        , txnId = Nothing
        , processPayment = True
        }


type Msg
    = AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String
      --- Donor Info
    | OrgOrIndUpdated (Maybe OrgOrInd.Model)
    | EmailAddressUpdated String
    | PhoneNumberUpdated String
    | FirstNameUpdated String
    | MiddleNameUpdated String
    | LastNameUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | EmploymentStatusUpdated (Maybe EmploymentStatus.Model)
    | EmployerUpdated String
    | OccupationUpdated String
    | EntityNameUpdated String
    | EntityTypeUpdated (Maybe EntityType.Model)
    | FamilyOrIndividualUpdated EntityType.Model
    | OwnersViewUpdated OwnersView.Msg
      -- Payment info
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | NoOp
    | PaymentMethodUpdated (Maybe PaymentMethod.Model)
    | CVVUpdated String
    | InKindTypeUpdated (Maybe InKindType.Model)
    | InKindDescUpdated String
      -- Ports
    | GotEmailValidationRes Decode.Value
    | GotPhoneValidationRes Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AmountUpdated str ->
            ( { model | amount = str }, Cmd.none )

        -- Donor Info
        OrgOrIndUpdated maybeOrgOrInd ->
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeEntityType = Nothing, errors = [] }, Cmd.none )

        EntityNameUpdated entityName ->
            ( { model | entityName = entityName }, Cmd.none )

        EntityTypeUpdated maybeEntityType ->
            ( { model | maybeEntityType = maybeEntityType }, Cmd.none )

        OwnersViewUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    OwnersView.update subMsg model.ownersViewModel
            in
            ( { model | ownersViewModel = subModel }, Cmd.map OwnersViewUpdated subCmd )

        PhoneNumberUpdated str ->
            ( { model | phoneNumber = str }, sendPhone str )

        EmailAddressUpdated str ->
            ( { model | emailAddress = str }, sendEmail str )

        FirstNameUpdated str ->
            ( { model | firstName = str }, Cmd.none )

        MiddleNameUpdated str ->
            ( { model | middleName = str }, Cmd.none )

        LastNameUpdated str ->
            ( { model | lastName = str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | addressLine1 = str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | addressLine2 = str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = str }, Cmd.none )

        FamilyOrIndividualUpdated entityType ->
            ( { model | maybeEntityType = Just entityType }, Cmd.none )

        EmploymentStatusUpdated str ->
            ( { model | employmentStatus = str }, Cmd.none )

        EmployerUpdated str ->
            ( { model | employer = str }, Cmd.none )

        OccupationUpdated str ->
            ( { model | occupation = str }, Cmd.none )

        -- Payment Info
        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        PaymentDateUpdated str ->
            ( { model | paymentDate = str }, Cmd.none )

        CardMonthUpdated str ->
            ( { model | expirationMonth = str }, Cmd.none )

        CardNumberUpdated str ->
            ( { model | cardNumber = str }, Cmd.none )

        CVVUpdated str ->
            ( { model | cvv = str }, Cmd.none )

        CardYearUpdated str ->
            ( { model | expirationYear = str }, Cmd.none )

        PaymentMethodUpdated str ->
            ( { model | paymentMethod = str }, Cmd.none )

        InKindTypeUpdated t ->
            ( { model | inKindType = t }, Cmd.none )

        InKindDescUpdated t ->
            ( { model | inKindDesc = t }, Cmd.none )

        -- Ports
        GotEmailValidationRes value ->
            case decodeValue bool value of
                Ok data ->
                    ( { model | isEmailAddressValid = data }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        GotPhoneValidationRes value ->
            case decodeValue bool value of
                Ok data ->
                    ( { model | isPhoneNumberValid = data }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )


toEncodeModel : Model -> CreateContrib.EncodeModel
toEncodeModel model =
    { committeeId = model.committeeId
    , amount = model.amount
    , paymentMethod = model.paymentMethod
    , firstName = model.firstName
    , lastName = model.lastName
    , addressLine1 = model.addressLine1
    , city = model.city
    , state = model.state
    , postalCode = model.postalCode
    , maybeEntityType = model.maybeEntityType
    , emailAddress = model.emailAddress
    , paymentDate = model.paymentDate
    , cardNumber = model.cardNumber
    , expirationMonth = model.expirationMonth
    , expirationYear = model.expirationYear
    , cvv = model.cvv
    , checkNumber = model.checkNumber
    , entityName = model.entityName
    , employer = model.employer
    , occupation = model.occupation
    , middleName = model.middleName
    , addressLine2 = model.addressLine2
    , phoneNumber = model.phoneNumber
    , employmentStatus = model.employmentStatus
    , inKindType = model.inKindType
    , inKindDesc = model.inKindDesc
    , owners = OwnersView.toMaybeOwners model.ownersViewModel
    , processPayment = True
    }


validationMapper : Model -> ContribValidatorModel
validationMapper model =
    { checkNumber = model.checkNumber
    , amount = model.amount
    , paymentDate = model.paymentDate
    , paymentMethod = model.paymentMethod
    , emailAddress = model.emailAddress
    , isEmailAddressValid = model.isEmailAddressValid
    , phoneNumber = model.phoneNumber
    , isPhoneNumValid = model.isPhoneNumberValid
    , firstName = model.firstName
    , middleName = model.middleName
    , lastName = model.lastName
    , addressLine1 = model.addressLine1
    , addressLine2 = model.addressLine2
    , city = model.city
    , state = model.state
    , postalCode = model.postalCode
    , employmentStatus = model.employmentStatus
    , employer = model.employer
    , occupation = model.occupation
    , entityName = model.entityName
    , maybeOrgOrInd = model.maybeOrgOrInd
    , maybeEntityType = model.maybeEntityType
    , inKindDesc = model.inKindDesc
    , inKindType = model.inKindType
    , owners = model.ownersViewModel.owners
    , cardNumber = model.cardNumber
    , expirationMonth = model.expirationMonth
    , expirationYear = model.expirationYear
    , cvv = model.cvv
    }


fromError : Model -> String -> Model
fromError model error =
    { model | maybeError = Just error }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ isValidNumReceiver GotPhoneValidationRes, isValidEmailReceiver GotEmailValidationRes ]
