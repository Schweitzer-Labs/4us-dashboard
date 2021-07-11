module CreateDisbursement exposing (Model, Msg(..), init, setError, update, view)

import Address
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DisbursementInfo
import Html exposing (Html, div, text)
import Html.Attributes exposing (for, value)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)


type alias Model =
    { entityName : String
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
    , error : String
    }


init : Model
init =
    { entityName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , purposeCode = Nothing
    , isSubcontracted = Nothing
    , isPartialPayment = Nothing
    , isExistingLiability = Nothing
    , amount = ""
    , paymentDate = ""
    , paymentMethod = Nothing
    , checkNumber = ""
    , error = ""
    }


setError : Model -> String -> Model
setError model str =
    { model | error = str }


view : Model -> Html Msg
view model =
    Grid.containerFluid
        []
    <|
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
            , amount = Just ( model.amount, AmountUpdated )
            , paymentDate = Just ( model.paymentDate, PaymentDateUpdated )
            , paymentMethod = Just ( model.paymentMethod, PaymentMethodUpdated )
            , disabled = False
            , isEditable = True
            }


addressRows : Model -> List (Html Msg)
addressRows model =
    Address.view
        { addressLine1 = ( model.addressLine1, AddressLine1Updated )
        , addressLine2 = ( model.addressLine2, AddressLine2Updated )
        , city = ( model.city, CityUpdated )
        , state = ( model.state, StateUpdated )
        , postalCode = ( model.postalCode, PostalCodeUpdated )
        , disabled = False
        }


paymentMethodCheckRows : Model -> List (Html Msg)
paymentMethodCheckRows model =
    [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "amount" ] [ text "Amount" ]
            , Input.text [ Input.id "amount", Input.onInput AmountUpdated, Input.placeholder "Enter amount" ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "check-number" ] [ text "Check Number" ]
            , Input.text [ Input.id "check-number", Input.onInput CheckNumberUpdated, Input.placeholder "Enter check number" ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "date" ] [ text "Date" ]
            , Input.date [ Input.id "date", Input.onInput PaymentDateUpdated ]
            ]
        ]
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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

        IsSubcontractedUpdated str ->
            ( { model | isSubcontracted = Nothing }, Cmd.none )

        IsPartialPaymentUpdated str ->
            ( { model | isPartialPayment = Nothing }, Cmd.none )

        IsExistingLiabilityUpdated str ->
            ( { model | isExistingLiability = Nothing }, Cmd.none )
