module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , encode
    , init
    , update
    , view
    )

import Asset
import BankData
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Disbursement as Disbursement
import DisbursementInfo
import Html exposing (Html, div, h6, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import LabelWithData exposing (labelWithContent, labelWithData)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)
import ReconcileDisbursement
import Transaction


type alias Model =
    { txns : List Transaction.Model
    , txn : Transaction.Model
    , selected : List Transaction.Model
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
    , amount : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod
    , checkNumber : String
    , createDisbIsVisible : Bool
    }


init : List Transaction.Model -> Transaction.Model -> Model
init txns txn =
    { txns = txns
    , txn = txn
    , selected = []
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
    , amount = ""
    , paymentDate = ""
    , paymentMethod = Nothing
    , checkNumber = ""
    , createDisbIsVisible = False
    }


view : Model -> Html Msg
view model =
    div
        [ Spacing.mt4 ]
        [ BankData.view True model.txn
        , h6 [ Spacing.mt4 ] [ text "Reconcile" ]
        , Grid.containerFluid
            []
            [ reconcileInfoRow model.txn model.selected
            , addDisbursementButton
            ]
        ]


addDisbursementButton : Html Msg
addDisbursementButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick NoOp ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle" ] [ text "Add Disbursement" ]
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
    | AmountUpdated String
    | PaymentDateUpdated String
    | PaymentMethodUpdated (Maybe PaymentMethod)
    | CheckNumberUpdated String


disbFormRow : Model -> List (Html Msg)
disbFormRow model =
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
        , amount = Nothing
        , paymentDate = Nothing
        , paymentMethod = Nothing
        , disabled = True
        , isEditable = True
        }


matchesIcon : Bool -> Html msg
matchesIcon val =
    if val then
        Asset.circleCheckGlyph [ class "text-success font-size-large" ]

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

        NoOp ->
            ( model, Cmd.none )


encode : Disbursement.Model -> Encode.Value
encode disb =
    Encode.object
        [ ( "disbursementId", Encode.string disb.disbursementId )
        , ( "committeeId", Encode.string disb.committeeId )
        , ( "entityName", Encode.string disb.entityName )
        , ( "addressLine1", Encode.string disb.addressLine1 )
        , ( "addressLine2", Encode.string disb.addressLine2 )
        , ( "city", Encode.string disb.city )
        , ( "state", Encode.string disb.state )
        , ( "postalCode", Encode.string disb.postalCode )
        , ( "purposeCode", Encode.string disb.purposeCode )
        ]
