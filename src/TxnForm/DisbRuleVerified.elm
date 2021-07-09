module TxnForm.DisbRuleVerified exposing
    ( Model
    , Msg(..)
    , addressRow
    , cityStateZipRow
    , encode
    , errorBorder
    , init
    , maybeWithBlank
    , questionRows
    , recipientNameRow
    , selectPurpose
    , selectPurposeRow
    , update
    , view
    )

import Asset
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (value)
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Disbursement as Disbursement
import Disbursement.Forms exposing (yesOrNoRows)
import ExpandableBankData
import Html exposing (Html, div, span, text)
import Html.Attributes as Attribute exposing (class, for)
import Json.Encode as Encode
import PaymentInfo
import PurposeCode exposing (PurposeCode)
import Transaction


errorBorder : String -> List (Html.Attribute Msg)
errorBorder str =
    if String.length str < 2 then
        [ class "" ]

    else
        []


type alias Model =
    { txn : Transaction.Model
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
    , showBankData : Bool
    }


init : Transaction.Model -> Model
init txn =
    { txn = txn
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
    , showBankData = False
    }


view : Model -> Html Msg
view model =
    Grid.container
        []
        ([ PaymentInfo.view model.txn ]
            ++ createDisbursementForm model
         --++ [ ExpandableBankData.view model.showBankData model.txn <| ToggleBankData ]
        )


createDisbursementForm : Model -> List (Html Msg)
createDisbursementForm model =
    [ recipientNameRow model
    , addressRow model
    , cityStateZipRow model
    , selectPurposeRow model
    ]
        ++ questionRows model


recipientNameRow : Model -> Html Msg
recipientNameRow model =
    let
        entityNameOrBlank =
            Maybe.withDefault "" model.formEntityName
    in
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ span [ class "align-middle" ] [ span [ class "align-middle" ] [ text "Recipient Info" ], Asset.editGlyph [ Spacing.ml2, class "align-middle" ] ] ]
            , Input.text
                [ Input.id "recipient-name"
                , Input.onInput EntityNameUpdated
                , Input.placeholder "Enter recipient name"
                , Input.attrs (errorBorder entityNameOrBlank)
                , value entityNameOrBlank
                , Input.disabled True
                ]
            ]
        ]


selectPurposeRow : Model -> Html Msg
selectPurposeRow model =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]


questionRows : Model -> List (Html Msg)
questionRows model =
    yesOrNoRows
        UpdateIsSubcontracted
        model.formIsSubcontracted
        UpdateIsPartialPayment
        model.formIsPartialPayment
        UpdateIsExistingLiability
        model.formIsExistingLiability
        True
        True


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
                , Input.disabled True
                ]
            ]
        , Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine2"
                , Input.onInput AddressLine2Updated
                , Input.placeholder "Secondary Address"
                , Input.value <| maybeWithBlank txn.addressLine2
                , Input.disabled True
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
                , Input.disabled True
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
                , Input.disabled True
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
                , Input.disabled True
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
            , Select.disabled True
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
    | ToggleBankData


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

        ToggleBankData ->
            ( { model | showBankData = not model.showBankData }, Cmd.none )


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
