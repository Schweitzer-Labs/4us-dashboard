module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , encode
    , init
    , update
    , view
    )

import BankData
import Bootstrap.Grid as Grid
import Disbursement as Disbursement
import Html exposing (Html)
import Json.Encode as Encode
import PurposeCode exposing (PurposeCode)
import Transaction


type alias Model =
    { txns : List Transaction.Model
    , txn : Transaction.Model
    , formEntityName : Maybe String
    , formAddressLine1 : Maybe String
    , formAddressLine2 : Maybe String
    , formCity : Maybe String
    , formState : Maybe String
    , formPostalCode : Maybe String
    , formPurposeCode : Maybe PurposeCode
    , formIsSubcontracted : Maybe Bool
    , formIsPartialPayment : Maybe Bool
    , formIsExistingLiability : Maybe Bool
    }


init : List Transaction.Model -> Transaction.Model -> Model
init txns txn =
    { txns = txns
    , txn = txn
    , formEntityName = txn.entityName
    , formAddressLine1 = Nothing
    , formAddressLine2 = Nothing
    , formCity = Nothing
    , formState = Nothing
    , formPostalCode = Nothing
    , formPurposeCode = Nothing
    , formIsSubcontracted = Nothing
    , formIsPartialPayment = Nothing
    , formIsExistingLiability = Nothing
    }


view : Model -> Html Msg
view model =
    Grid.container
        []
        [ BankData.view True model.txn ]


type Msg
    = EntityNameUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | PurposeCodeUpdated String
    | UpdateIsSubcontracted Bool
    | UpdateIsPartialPayment Bool
    | UpdateIsExistingLiability Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EntityNameUpdated str ->
            ( { model | formEntityName = Just str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | formAddressLine1 = Just str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | formAddressLine2 = Just str }, Cmd.none )

        CityUpdated str ->
            ( { model | formCity = Just str }, Cmd.none )

        StateUpdated str ->
            ( { model | formState = Just str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | formPostalCode = Just str }, Cmd.none )

        PurposeCodeUpdated code ->
            ( { model | formPurposeCode = PurposeCode.fromString code }, Cmd.none )

        UpdateIsSubcontracted bool ->
            ( { model | formIsSubcontracted = Just bool }, Cmd.none )

        UpdateIsPartialPayment bool ->
            ( { model | formIsPartialPayment = Just bool }, Cmd.none )

        UpdateIsExistingLiability bool ->
            ( { model | formIsExistingLiability = Just bool }, Cmd.none )


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
