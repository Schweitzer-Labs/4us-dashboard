module TxnForm.ContribRuleUnverified exposing (Model, Msg(..), fromError, init, reconcileTxnEncoder, toSubmitDisabled, update, view)

import Api
import Api.CreateContrib as CreateContrib
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.ReconcileTxn as ReconcileTxn
import Asset
import BankData
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
import ContribInfo
import DataTable exposing (DataRow)
import Direction
import EmploymentStatus
import EntityType
import Errors exposing (fromPostalCode)
import Html exposing (Html, div, h6, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import InKindType
import LabelWithData exposing (labelWithContent, labelWithData)
import List exposing (sortBy)
import OrgOrInd
import Owners exposing (Owner, Owners)
import PaymentMethod
import SubmitButton exposing (submitButton)
import Time exposing (utc)
import Timestamp exposing (dateStringToMillis, formDate)
import Transaction
import TransactionType
import Transactions
import Validate exposing (Validator, fromErrors, ifBlank, ifNothing, validate)


type alias Model =
    { bankTxn : Transaction.Model
    , committeeId : String
    , selectedTxns : List Transaction.Model
    , relatedTxns : List Transaction.Model
    , loading : Bool
    , submitting : Bool
    , disabled : Bool
    , errors : List String
    , error : String
    , checkNumber : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
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
    , inKindDesc : String
    , inKindType : Maybe InKindType.Model
    , maybeError : Maybe String
    , config : Config
    , lastCreatedTxnId : String
    , timezone : Time.Zone
    , createContribIsVisible : Bool
    , createContribButtonIsDisabled : Bool
    , createContribIsSubmitting : Bool
    , reconcileButtonIsDisabled : Bool
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns bankTxn =
    { bankTxn = bankTxn
    , committeeId = bankTxn.committeeId
    , selectedTxns = []
    , relatedTxns = getRelatedContrib bankTxn txns
    , submitting = False
    , loading = False
    , disabled = False
    , error = ""
    , errors = []
    , amount = toDollarData bankTxn.amount
    , checkNumber = ""
    , paymentDate = formDate utc bankTxn.paymentDate
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
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , inKindType = Nothing
    , inKindDesc = ""
    , paymentMethod = Nothing
    , createContribIsVisible = False
    , createContribButtonIsDisabled = False
    , createContribIsSubmitting = False
    , reconcileButtonIsDisabled = True
    , maybeError = Nothing
    , config = config
    , timezone = utc
    , lastCreatedTxnId = ""
    }


clearForm : Model -> Model
clearForm model =
    { model
        | amount = toDollarData model.bankTxn.amount
        , checkNumber = ""
        , paymentDate = formDate model.timezone model.bankTxn.paymentDate
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
        , owners = []
        , ownerName = ""
        , ownerOwnership = ""
        , paymentMethod = Nothing
        , createContribIsVisible = False
        , createContribButtonIsDisabled = False
        , createContribIsSubmitting = False
        , maybeError = Nothing
    }


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
            , addContribButtonOrHeading model
            ]
                ++ contribFormRow model
                ++ [ reconcileItemsTable model.relatedTxns model.selectedTxns ]
        ]


contribFormRow : Model -> List (Html Msg)
contribFormRow model =
    if model.createContribIsVisible then
        [ ContribInfo.view
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
            , inKindDesc = ( model.inKindDesc, InKindDescUpdated )
            , inKindType = ( model.inKindType, InKindTypeUpdated )
            , disabled = model.disabled
            , isEditable = False
            , toggleEdit = ToggleEdit
            , maybeError = model.maybeError
            }
        ]
            ++ [ buttonRow CreateContribToggled "Create" "Cancel" CreateContribSubmitted model.createContribIsSubmitting model.createContribButtonIsDisabled ]

    else
        []


type Msg
    = NoOp
    | ToggleEdit
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
    | InKindTypeUpdated (Maybe InKindType.Model)
    | InKindDescUpdated String
      -- Reconcile
    | CreateContribToggled
    | CreateContribSubmitted
    | RelatedTransactionClicked Transaction.Model Bool
    | CreateContribMutResp (Result Http.Error MutationResponse)
    | GetTxnsGotResp (Result Http.Error GetTxns.Model)


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
            ( { model | disabled = not model.disabled }, Cmd.none )

        GetTxnsGotResp res ->
            case res of
                Ok body ->
                    let
                        relatedTxns =
                            getRelatedContrib model.bankTxn <| GetTxns.toTxns body

                        resTxnOrEmpty =
                            Maybe.withDefault [] <| Maybe.map List.singleton <| getTxnById relatedTxns model.lastCreatedTxnId
                    in
                    ( { model
                        | relatedTxns = getRelatedContrib model.bankTxn <| GetTxns.toTxns body
                        , selectedTxns = model.selectedTxns ++ resTxnOrEmpty
                      }
                    , Cmd.none
                    )

                Err _ ->
                    let
                        { cognitoDomain, cognitoClientId, redirectUri } =
                            model.config
                    in
                    ( model, load <| loginUrl cognitoDomain cognitoClientId redirectUri model.committeeId )

        CreateContribToggled ->
            ( { model | createContribIsVisible = not model.createContribIsVisible }, Cmd.none )

        CreateContribSubmitted ->
            case validate validator model of
                Err errors ->
                    let
                        error =
                            Maybe.withDefault "Form error" <| List.head errors
                    in
                    ( fromError model error, Cmd.none )

                Ok val ->
                    ( { model | createContribButtonIsDisabled = True, createContribIsSubmitting = True }
                    , createContrib model
                    )

        RelatedTransactionClicked clickedTxn isChecked ->
            let
                selected =
                    if isChecked then
                        model.selectedTxns ++ [ clickedTxn ]

                    else
                        List.filter (\txn -> txn.id /= clickedTxn.id) model.selectedTxns
            in
            ( { model | selectedTxns = selected, createContribIsVisible = False }, Cmd.none )

        CreateContribMutResp res ->
            case res of
                Ok createContribResp ->
                    case createContribResp of
                        Success id ->
                            let
                                resetFormModel =
                                    clearForm model
                            in
                            ( { resetFormModel
                                | lastCreatedTxnId = id
                              }
                            , getTxns model
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | maybeError = List.head errList
                                , createContribButtonIsDisabled = False
                                , createContribIsSubmitting = False
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | maybeError = Just <| Api.decodeError err
                        , createContribButtonIsDisabled = False
                        , createContribIsSubmitting = False
                      }
                    , Cmd.none
                    )



--- HELPERS


withNone model =
    ( model, Cmd.none )


getTxns : Model -> Cmd Msg
getTxns model =
    GetTxns.send GetTxnsGotResp model.config <| GetTxns.encode model.committeeId (Just TransactionType.Contribution)


fromError : Model -> String -> Model
fromError model str =
    { model | maybeError = Just str }


matchesIcon : Bool -> Html msg
matchesIcon val =
    if val then
        Asset.circleCheckGlyph [ class "text-green font-size-large" ]

    else
        Asset.timesGlyph [ class "text-danger font-size-large" ]


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


labelWithBankVerificationIcon : String -> Bool -> Html msg
labelWithBankVerificationIcon label matchesStatus =
    labelWithContent label (matchesIcon matchesStatus)


labels =
    [ "Selected", "Date", "Entity Name", "Amount", "Entity Type" ]


reconcileItemsTable : List Transaction.Model -> List Transaction.Model -> Html Msg
reconcileItemsTable relatedTxns selectedTxns =
    DataTable.view "Awaiting Transactions." labels transactionRowMap <|
        List.map (\d -> ( Just selectedTxns, Nothing, d )) relatedTxns


addContribButtonOrHeading : Model -> Html Msg
addContribButtonOrHeading model =
    if model.createContribIsVisible then
        div [ Spacing.mt4, class "font-size-large", onClick CreateContribToggled ] [ text "Create Contribution" ]

    else
        addContribButton


addContribButton : Html Msg
addContribButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick CreateContribToggled ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle" ] [ text "Add Contribution" ]
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
      , ( "Date", text <| Timestamp.format utc txn.paymentDate )
      , ( "Entity Name", name )
      , ( "Amount", amount )
      , ( "Entity Type", Transactions.getContext txn )
      ]
    )


isSelected : Transaction.Model -> List Transaction.Model -> Bool
isSelected txn selected =
    List.any (\val -> val.id == txn.id) selected


getRelatedContrib : Transaction.Model -> List Transaction.Model -> List Transaction.Model
getRelatedContrib txn txns =
    let
        filteredtxns =
            List.filter (\val -> (val.amount <= txn.amount) && (val.direction == Direction.In) && not val.bankVerified && val.ruleVerified && val.paymentDate <= txn.paymentDate) txns
    in
    sortBy .paymentDate filteredtxns |> List.reverse


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


totalSelectedMatch : Model -> Bool
totalSelectedMatch model =
    if List.foldr (\txn acc -> acc + txn.amount) 0 model.selectedTxns == model.bankTxn.amount then
        False

    else
        True


toSubmitDisabled : Model -> Bool
toSubmitDisabled model =
    model.reconcileButtonIsDisabled && totalSelectedMatch model


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


validator : Validator String Model
validator =
    Validate.all
        [ ifBlank .addressLine1 "Address 1 is missing."
        , ifBlank .city "City is missing."
        , ifBlank .state "State is missing."
        , ifBlank .postalCode "Postal Code is missing."
        , ifBlank .paymentDate "Date is missing."
        , postalCodeValidator
        , amountValidator
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


reconcileTxnEncoder : Model -> ReconcileTxn.EncodeModel
reconcileTxnEncoder model =
    { selectedTxns = model.selectedTxns
    , bankTxn = model.bankTxn
    , committeeId = model.committeeId
    }


createContribEncoder : Model -> CreateContrib.EncodeModel
createContribEncoder model =
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
    , inKindDesc = model.inKindDesc
    , inKindType = model.inKindType
    }


createContrib : Model -> Cmd Msg
createContrib model =
    CreateContrib.send CreateContribMutResp model.config <| CreateContrib.encode createContribEncoder model


dateWithFormat : Model -> String
dateWithFormat model =
    if model.paymentDate == "" then
        formDate utc model.bankTxn.paymentDate

    else
        model.paymentDate
