module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , fromError
    , init
    , update
    , validator
    , view
    )

import Address exposing (postalCodeToErrors)
import Api.GraphQL exposing (MutationResponse(..), mutationValidationFailureDecoder)
import Asset
import BankData
import Bootstrap.Button as Button
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Config exposing (Config)
import CreateDisbursement
import DataTable exposing (DataRow)
import Disbursement as Disbursement
import DisbursementInfo
import Html exposing (Html, div, h6, input, span, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import LabelWithData exposing (labelWithContent, labelWithData)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)
import SubmitButton exposing (submitButton)
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction
import Transactions
import Validate exposing (Validator, fromErrors, ifBlank)


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
    , isCreateDisbDisabled : Bool
    , isSubmitDisabled : Bool
    , maybeError : Maybe String
    , config : Config
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns txn =
    { txns = txns
    , bankTxn = txn
    , committeeId = txn.committeeId
    , selectedTxns = []
    , related = getRelatedDisb txn txns
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
    , paymentMethod = Just txn.paymentMethod
    , checkNumber = ""
    , createDisbIsVisible = False
    , isCreateDisbDisabled = True
    , disabled = True
    , isSubmitDisabled = True
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
        DisbursementInfo.view
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
            , paymentDate = Just ( model.amount, PaymentDateUpdated )
            , paymentMethod = Nothing
            , disabled = False
            , isEditable = False
            , toggleEdit = NoOp
            , maybeError = model.maybeError
            }
            ++ [ buttonRow CreateDisbToggled "Create" "Cancel" NoOp False model.isCreateDisbDisabled ]

    else
        []


buttonRow : msg -> String -> String -> msg -> Bool -> Bool -> Html msg
buttonRow hideMsg displayText exitText msg submitting disabled =
    Grid.row
        [ Row.betweenXs, Row.attrs [ Spacing.m2 ] ]
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
    | EditDisbToggle
    | RelatedTransactionClicked Transaction.Model Bool


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
            ( { model | paymentDate = str, isCreateDisbDisabled = False }, Cmd.none )

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
            ( { model | isInKind = bool, isSubmitDisabled = disableSubmitOnInKind model }, Cmd.none )

        CreateDisbToggled ->
            ( { model | createDisbIsVisible = not model.createDisbIsVisible }, Cmd.none )

        EditDisbToggle ->
            ( { model | disabled = not model.disabled }, Cmd.none )

        RelatedTransactionClicked clickedTxn isChecked ->
            let
                selected =
                    if isChecked then
                        model.selectedTxns ++ [ clickedTxn ]

                    else
                        List.filter (\txn -> txn.id /= clickedTxn.id) model.selectedTxns
            in
            ( { model | selectedTxns = selected, isSubmitDisabled = False }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


isSelected : Transaction.Model -> List Transaction.Model -> Bool
isSelected txn selected =
    List.any (\val -> val.id == txn.id) selected


fromError : Model -> String -> Model
fromError model error =
    { model | maybeError = Just error }


disableSubmitOnInKind : Model -> Bool
disableSubmitOnInKind model =
    if model.isInKind == Just True then
        True

    else if model.paymentMethod /= Nothing then
        False

    else
        model.isSubmitDisabled


validator : Validator String Model
validator =
    Validate.firstError
        [ ifBlank .entityName "Entity name is missing."
        , ifBlank .addressLine1 "Address 1 is missing."
        , ifBlank .city "City is missing."
        , ifBlank .state "State is missing."
        , ifBlank .postalCode "Postal Code is missing."
        , postalCodeValidator
        , amountValidator
        ]


amountValidator : Validator String Model
amountValidator =
    ifBlank .amount "Amount is missing."


postalCodeValidator : Validator String Model
postalCodeValidator =
    fromErrors postalCodeOnModelToErrors


postalCodeOnModelToErrors : Model -> List String
postalCodeOnModelToErrors model =
    postalCodeToErrors model.postalCode
