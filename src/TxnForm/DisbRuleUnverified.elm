module TxnForm.DisbRuleUnverified exposing
    ( Model
    , Msg(..)
    , addressRow
    , cityStateZipRow
    , encode
    , errorBorder
    , init
    , maybeWithBlank
    , recipientNameRow
    , selectPurpose
    , selectPurposeRow
    , update
    , view
    )

import BankData
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (value)
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Disbursement as Disbursement
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (class, for)
import Json.Encode as Encode
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)
import Transaction


errorBorder : String -> List (Html.Attribute Msg)
errorBorder str =
    if String.length str < 2 then
        [ class "border-danger" ]

    else
        []


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


createDisbursementForm : Model -> List (Html Msg)
createDisbursementForm model =
    [ recipientNameRow model
    , addressRow model
    , cityStateZipRow model
    , selectPurposeRow model
    ]


recipientNameRow : Model -> Html Msg
recipientNameRow model =
    let
        entityNameOrBlank =
            Maybe.withDefault "" model.formEntityName
    in
    Grid.row
        []
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
            , Input.text
                [ Input.id "recipient-name"
                , Input.onInput EntityNameUpdated
                , Input.placeholder "Enter recipient name"
                , Input.attrs (errorBorder entityNameOrBlank)
                , value entityNameOrBlank
                ]
            ]
        ]


selectPurposeRow : Model -> Html Msg
selectPurposeRow model =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]


maybeWithBlank : Maybe String -> String
maybeWithBlank =
    Maybe.withDefault ""


addressRow : Model -> Html Msg
addressRow { txn } =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine1"
                , Input.onInput AddressLine1Updated
                , Input.placeholder "Enter Street Address"
                , Input.attrs (errorBorder <| maybeWithBlank txn.addressLine1)
                , Input.value <| maybeWithBlank txn.addressLine1
                ]
            ]
        , Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine2"
                , Input.onInput AddressLine2Updated
                , Input.placeholder "Secondary Address"
                , Input.value <| maybeWithBlank txn.addressLine2
                ]
            ]
        ]


cityStateZipRow : Model -> Html Msg
cityStateZipRow model =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "city"
                , Input.onInput CityUpdated
                , Input.placeholder "Enter city"
                , Input.attrs (errorBorder <| maybeWithBlank model.formCity)
                , Input.value <| maybeWithBlank model.formCity
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "state"
                , Input.onInput StateUpdated
                , Input.placeholder "State"
                , Input.attrs (errorBorder <| maybeWithBlank model.formState)
                , Input.value <| maybeWithBlank model.formState
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "postalCode"
                , Input.onInput PostalCodeUpdated
                , Input.placeholder "Postal Code"
                , Input.attrs (errorBorder <| maybeWithBlank model.formPostalCode)
                , Input.value <| maybeWithBlank model.formPostalCode
                ]
            ]
        ]


selectPurpose : Model -> Html Msg
selectPurpose model =
    let
        purpleCodeOrBlank =
            maybeWithBlank <| Maybe.map PurposeCode.toString model.formPurposeCode
    in
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange PurposeCodeUpdated
            , Select.attrs <| [ Attribute.value <| purpleCodeOrBlank ] ++ errorBorder purpleCodeOrBlank
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (purpleCodeOrBlank == "")
                    , Attribute.value ""
                    ]
                    [ text "---" ]
                ]
            <|
                List.map
                    (\( _, codeText, purposeText ) ->
                        Select.item
                            [ Attribute.selected (codeText == PurposeCode.fromMaybeToString model.formPurposeCode)
                            , Attribute.value codeText
                            ]
                            [ text <| purposeText ]
                    )
                    PurposeCode.purposeCodeText
        ]


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
