module TxnForm.ContribRuleVerified exposing
    ( Model
    , Msg(..)
    , amendTxnEncoder
    , fromError
    , init
    , loadingInit
    , toTxn
    , update
    , validationMapper
    , view
    )

import Api.AmendContrib as AmendContrib
import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Popover as Popover
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import ContribInfo exposing (ContribValidatorModel)
import Copy
import EmploymentStatus
import EntityType
import ExpandableBankData
import Html exposing (Html, p, span, text)
import Html.Attributes exposing (class)
import InKindType
import Loading
import OrgOrInd
import Owners exposing (Owner, Owners)
import PaymentInfo
import PaymentMethod
import Time exposing (utc)
import Timestamp exposing (formDate)
import Transaction


type alias Model =
    { txn : Transaction.Model
    , loading : Bool
    , submitting : Bool
    , disabled : Bool
    , showBankData : Bool
    , errors : List String
    , error : String
    , checkNumber : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
    , emailAddress : String
    , isEmailAddressValid : Bool
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
    , maybeOrgOrInd : Maybe OrgOrInd.Model
    , maybeEntityType : Maybe EntityType.Model
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerName : String
    , ownerOwnership : String
    , inKindType : Maybe InKindType.Model
    , inKindDesc : String
    , committeeId : String
    , isSubmitDisabled : Bool
    , maybeError : Maybe String
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
    , submitting = False
    , loading = False
    , disabled = True
    , showBankData = False
    , error = ""
    , errors = []
    , amount = Cents.stringToDollar <| String.fromInt txn.amount
    , checkNumber = Maybe.withDefault "" txn.checkNumber
    , paymentDate = Timestamp.formDate utc txn.paymentDate
    , emailAddress = Maybe.withDefault "" txn.emailAddress
    , isEmailAddressValid = True
    , phoneNumber = Maybe.withDefault "" txn.phoneNumber
    , firstName = Maybe.withDefault "" txn.firstName
    , middleName = Maybe.withDefault "" txn.middleName
    , lastName = Maybe.withDefault "" txn.lastName
    , addressLine1 = Maybe.withDefault "" txn.addressLine1
    , addressLine2 = Maybe.withDefault "" txn.addressLine2
    , city = Maybe.withDefault "" txn.city
    , state = Maybe.withDefault "" txn.state
    , postalCode = Maybe.withDefault "" txn.postalCode
    , employmentStatus = txn.employmentStatus
    , employer = Maybe.withDefault "" txn.employer
    , occupation = Maybe.withDefault "" txn.occupation
    , entityName = Maybe.withDefault "" txn.entityName
    , maybeEntityType = txn.entityType
    , maybeOrgOrInd = Maybe.map OrgOrInd.fromEntityType txn.entityType
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , inKindType = txn.inKindType
    , inKindDesc = Maybe.withDefault "" txn.inKindDescription
    , paymentMethod = Just txn.paymentMethod
    , committeeId = txn.committeeId
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
            if model.txn.bankVerified && model.txn.paymentMethod /= PaymentMethod.InKind then
                ExpandableBankData.view model.showBankData model.txn BankDataToggled

            else
                []
    in
    Grid.container
        []
        ([]
            ++ PaymentInfo.view model.txn
            ++ [ contribFormRow model ]
            ++ bankData
        )


contribFormRow : Model -> Html Msg
contribFormRow model =
    ContribInfo.view
        { checkNumber = ( model.checkNumber, CheckNumberUpdated )
        , paymentDate = ( dateWithFormat model, PaymentDateUpdated )
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
        , owners = ( model.owners, OwnerAdded )
        , ownerName = ( model.ownerName, OwnerNameUpdated )
        , ownerOwnership = ( model.ownerOwnership, OwnerOwnershipUpdated )
        , inKindType = ( model.inKindType, InKindTypeUpdated )
        , inKindDesc = ( model.inKindDesc, InKindDescUpdated )
        , disabled = model.disabled
        , isEditable = True
        , toggleEdit = ToggleEdit
        , maybeError = model.maybeError
        , txnId = Just model.txn.id
        , processPayment = False
        }


errorRow : Maybe String -> List (Html msg)
errorRow maybeStr =
    case maybeStr of
        Nothing ->
            []

        Just str ->
            [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
                [ Grid.col [] [ span [ class "text-danger" ] [ text str ] ] ]
            ]


type Msg
    = NoOp
    | ToggleEdit
    | BankDataToggled
    | PopoverMsg Popover.State
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
    | OwnerAdded
    | OwnerNameUpdated String
    | OwnerOwnershipUpdated String
      -- Payment info
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | PaymentMethodUpdated (Maybe PaymentMethod.Model)
    | CVVUpdated String
    | AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String
    | InKindDescUpdated String
    | InKindTypeUpdated (Maybe InKindType.Model)


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

        OwnerAdded ->
            let
                newOwner =
                    Owners.Owner model.ownerName model.ownerOwnership
            in
            ( { model | owners = model.owners ++ [ newOwner ], ownerOwnership = "", ownerName = "" }, Cmd.none )

        OwnerNameUpdated str ->
            ( { model | ownerName = str }, Cmd.none )

        OwnerOwnershipUpdated str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        PhoneNumberUpdated str ->
            ( { model | phoneNumber = str }, Cmd.none )

        EmailAddressUpdated str ->
            ( { model | emailAddress = str }, Cmd.none )

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

        InKindDescUpdated desc ->
            ( { model | inKindDesc = desc }, Cmd.none )

        InKindTypeUpdated t ->
            ( { model | inKindType = t }, Cmd.none )

        ToggleEdit ->
            case model.disabled of
                True ->
                    ( { model | disabled = False, isSubmitDisabled = False }, Cmd.none )

                False ->
                    let
                        state =
                            init model.txn
                    in
                    ( { state | disabled = True, isSubmitDisabled = True }, Cmd.none )

        BankDataToggled ->
            ( { model | showBankData = not model.showBankData }, Cmd.none )

        PopoverMsg state ->
            ( { model | popoverState = state }, Cmd.none )


fromError : Model -> String -> Model
fromError model error =
    { model | maybeError = Just error }


amendTxnEncoder : Model -> AmendContrib.EncodeModel
amendTxnEncoder model =
    { txn = model.txn
    , checkNumber = model.checkNumber
    , paymentDate = model.paymentDate
    , paymentMethod = model.txn.paymentMethod
    , emailAddress = model.emailAddress
    , phoneNumber = model.phoneNumber
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
    , amount = model.txn.amount
    , owners = model.owners
    , ownerName = model.ownerName
    , ownerOwnership = model.ownerOwnership
    , committeeId = model.committeeId
    , inKindType = model.inKindType
    , inKindDesc = model.inKindDesc
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
    , owners = model.owners
    , ownerName = model.ownerName
    , ownerOwnership = model.ownerOwnership
    , inKindDesc = model.inKindDesc
    , inKindType = model.inKindType
    }


toTxn : Model -> Transaction.Model
toTxn model =
    model.txn


dateWithFormat : Model -> String
dateWithFormat model =
    if model.paymentDate == "" then
        formDate utc model.txn.paymentDate

    else
        model.paymentDate
