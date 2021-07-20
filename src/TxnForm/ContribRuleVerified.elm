module TxnForm.ContribRuleVerified exposing (Model, Msg(..), fromError, init, update, view)

import ContribInfo
import DataMsg
import EntityType exposing (EntityType)
import Html exposing (Html, div, text)
import OrgOrInd exposing (OrgOrInd)
import Owners exposing (Owner, Owners)
import PaymentMethod exposing (PaymentMethod)
import Transaction


type alias Model =
    { txn : Transaction.Model

    --, loading: Bool
    , submitting : Bool
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



--
--loadingInit : Model
--loadingInit =
--    let
--        state =
--            init Transaction.init
--    in
--    { state | loading = True }


init : Transaction.Model -> Model
init txn =
    { txn = txn
    , submitting = False
    , error = ""
    , errors = []
    , amount = ""
    , checkNumber = ""
    , paymentDate = ""
    , emailAddress = ""
    , phoneNumber = ""
    , firstName = ""
    , middleName = ""
    , lastName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , employmentStatus = ""
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeEntityType = Nothing
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


view : Model -> Html msg
view model =
    div [] [ text "hello from verified contrib" ]


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
        , disabled = False
        , isEditable = False
        , toggleEdit = NoOp
        , maybeError = model.maybeError
        }


type Msg
    = AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String
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
    | NoOp
    | PaymentMethodUpdated String
    | CVVUpdated String


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


fromError : Model -> String -> Model
fromError model str =
    model
