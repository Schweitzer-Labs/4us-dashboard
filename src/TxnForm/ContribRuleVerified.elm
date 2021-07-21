module TxnForm.ContribRuleVerified exposing (Model, Msg(..), fromError, init, loadingInit, update, view)

import Bootstrap.Grid as Grid
import Cents
import ContribInfo
import EntityType exposing (EntityType)
import ExpandableBankData
import Html exposing (Html, div, text)
import Loading
import OrgOrInd exposing (OrgOrInd)
import Owners exposing (Owner, Owners)
import PaymentInfo
import TimeZone exposing (america__new_york)
import Timestamp
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
    , paymentMethod : String
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , middleName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : String
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd
    , maybeEntityType : Maybe EntityType
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerName : String
    , ownerOwnership : String
    , committeeId : String
    , maybeError : Maybe String
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
    , checkNumber = ""
    , paymentDate = Timestamp.format (america__new_york ()) txn.paymentDate
    , emailAddress = Maybe.withDefault "" txn.emailAddress
    , phoneNumber = Maybe.withDefault "" txn.phoneNumber
    , firstName = Maybe.withDefault "" txn.firstName
    , middleName = Maybe.withDefault "" txn.middleName
    , lastName = Maybe.withDefault "" txn.lastName
    , addressLine1 = Maybe.withDefault "" txn.addressLine1
    , addressLine2 = Maybe.withDefault "" txn.addressLine2
    , city = Maybe.withDefault "" txn.city
    , state = Maybe.withDefault "" txn.state
    , postalCode = Maybe.withDefault "" txn.postalCode
    , employmentStatus = Maybe.withDefault "" txn.employmentStatus
    , employer = Maybe.withDefault "" txn.employer
    , occupation = Maybe.withDefault "" txn.occupation
    , entityName = Maybe.withDefault "" txn.entityName
    , maybeEntityType = Just EntityType.Individual
    , maybeOrgOrInd = Nothing
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , paymentMethod = ""
    , committeeId = txn.committeeId
    , maybeError = Nothing
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
        (PaymentInfo.view model.txn
            ++ [ contribFormRow model ]
            ++ bankData
        )


contribFormRow : Model -> Html Msg
contribFormRow model =
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
        , cardNumber = ( model.cardNumber, CardNumberUpdated )
        , expirationMonth = ( model.expirationMonth, CardMonthUpdated )
        , expirationYear = ( model.expirationYear, CardYearUpdated )
        , cvv = ( model.cvv, CVVUpdated )
        , amount = ( model.amount, AmountUpdated )
        , owners = ( model.owners, OwnerAdded )
        , ownerName = ( model.ownerName, OwnerNameUpdated )
        , ownerOwnership = ( model.ownerOwnership, OwnerOwnershipUpdated )
        , disabled = model.disabled
        , isEditable = True
        , toggleEdit = ToggleEdit
        , maybeError = model.maybeError
        }


type Msg
    = NoOp
    | ToggleEdit
    | BankDataToggled
      --- Donor Info
    | OrgOrIndUpdated (Maybe OrgOrInd)
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
    | EmploymentStatusUpdated String
    | EmployerUpdated String
    | OccupationUpdated String
    | EntityNameUpdated String
    | EntityTypeUpdated (Maybe EntityType)
    | FamilyOrIndividualUpdated EntityType
    | OwnerAdded
    | OwnerNameUpdated String
    | OwnerOwnershipUpdated String
      -- Payment info
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | PaymentMethodUpdated String
    | CVVUpdated String
    | AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String


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

        ToggleEdit ->
            ( { model | disabled = not model.disabled }, Cmd.none )

        BankDataToggled ->
            ( { model | showBankData = not model.showBankData }, Cmd.none )


fromError : Model -> String -> Model
fromError model str =
    model
