module TxnForm.ContribRuleUnverified exposing (Model, Msg(..), fromError, init, update, view)

import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse)
import Asset
import BankData
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cents
import Cognito exposing (loginUrl)
import Config exposing (Config)
import ContribInfo
import DataTable exposing (DataRow)
import EntityType
import Html exposing (Html, div, h6, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import LabelWithData exposing (labelWithContent, labelWithData)
import Loading
import OrgOrInd
import Owners exposing (Owner, Owners)
import PaymentInfo
import Time
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction
import TransactionType
import Transactions exposing (labels)


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
    , maybeError : Maybe String
    , config : Config
    , lastCreatedTxnId : String
    , timezone : Time.Zone
    , createContribIsVisible : Bool
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns bankTxn =
    { bankTxn = bankTxn
    , committeeId = bankTxn.committeeId
    , selectedTxns = []
    , relatedTxns = getRelatedContrib bankTxn txns
    , submitting = False
    , loading = False
    , disabled = True
    , error = ""
    , errors = []
    , amount = Cents.stringToDollar <| String.fromInt bankTxn.amount
    , checkNumber = ""
    , paymentDate = Timestamp.format (america__new_york ()) bankTxn.paymentDate
    , emailAddress = Maybe.withDefault "" bankTxn.emailAddress
    , phoneNumber = Maybe.withDefault "" bankTxn.phoneNumber
    , firstName = Maybe.withDefault "" bankTxn.firstName
    , middleName = Maybe.withDefault "" bankTxn.middleName
    , lastName = Maybe.withDefault "" bankTxn.lastName
    , addressLine1 = Maybe.withDefault "" bankTxn.addressLine1
    , addressLine2 = Maybe.withDefault "" bankTxn.addressLine2
    , city = Maybe.withDefault "" bankTxn.city
    , state = Maybe.withDefault "" bankTxn.state
    , postalCode = Maybe.withDefault "" bankTxn.postalCode
    , employmentStatus = Maybe.withDefault "" bankTxn.employmentStatus
    , employer = Maybe.withDefault "" bankTxn.employer
    , occupation = Maybe.withDefault "" bankTxn.occupation
    , entityName = Maybe.withDefault "" bankTxn.entityName
    , maybeEntityType = Just EntityType.Individual
    , maybeOrgOrInd = Maybe.map OrgOrInd.fromEntityType bankTxn.entityType
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , paymentMethod = ""
    , maybeError = Nothing
    , config = config
    , lastCreatedTxnId = ""
    , timezone = america__new_york ()
    , createContribIsVisible = False
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
            , addDisbButtonOrHeading model
            ]
                ++ [ contribFormRow model ]
                ++ [ reconcileItemsTable model.relatedTxns model.selectedTxns ]
        ]


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
        , maybeOrgOrInd = ( model.maybeOrgOrInd, OrgOrIndUpdated )
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
    | EmploymentStatusUpdated String
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
    | PaymentMethodUpdated String
    | CVVUpdated String
    | AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String
      -- Reconcile
    | CreateContribToggled
    | CreateContribSubmitted
    | RelatedTransactionClicked Transaction.Model Bool
    | CreateContribGotResp (Result Http.Error MutationResponse)
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
            withNone model

        CreateContribSubmitted ->
            withNone model

        RelatedTransactionClicked a bool ->
            withNone model

        CreateContribGotResp result ->
            withNone model



--- HELPERS


withNone model =
    ( model, Cmd.none )


getTxns : Model -> Cmd Msg
getTxns model =
    GetTxns.send GetTxnsGotResp model.config <| GetTxns.encode model.committeeId (Just TransactionType.Contribution)


fromError : Model -> String -> Model
fromError model str =
    model


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


matchesIcon : Bool -> Html msg
matchesIcon val =
    if val then
        Asset.circleCheckGlyph [ class "text-green font-size-large" ]

    else
        Asset.timesGlyph [ class "text-danger font-size-large" ]


labelWithBankVerificationIcon : String -> Bool -> Html msg
labelWithBankVerificationIcon label matchesStatus =
    labelWithContent label (matchesIcon matchesStatus)


reconcileItemsTable : List Transaction.Model -> List Transaction.Model -> Html Msg
reconcileItemsTable relatedTxns selectedTxns =
    DataTable.view "Awaiting Transactions." labels transactionRowMap <|
        List.map (\d -> ( Just selectedTxns, Nothing, d )) relatedTxns


addDisbButtonOrHeading : Model -> Html Msg
addDisbButtonOrHeading model =
    if model.createContribIsVisible then
        div [ Spacing.mt4, class "font-size-large", onClick CreateContribToggled ] [ text "Create Disbursement" ]

    else
        addDisbButton


addDisbButton : Html Msg
addDisbButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick CreateContribToggled ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle" ] [ text "Add Disbursement" ]
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


isSelected : Transaction.Model -> List Transaction.Model -> Bool
isSelected txn selected =
    List.any (\val -> val.id == txn.id) selected


getRelatedContrib : Transaction.Model -> List Transaction.Model -> List Transaction.Model
getRelatedContrib txn txns =
    List.filter (\val -> (val.paymentMethod == txn.paymentMethod) && (val.amount <= txn.amount) && not val.bankVerified && val.ruleVerified) txns


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
