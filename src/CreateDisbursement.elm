module CreateDisbursement exposing (Model, Msg(..), init, setError, update, view)

import Address
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, text)
import Html.Attributes exposing (for, value)
import PaymentMethod
import PurposeCode


type alias Model =
    { checkRecipient : String
    , checkAmount : String
    , checkNumber : String
    , checkDate : String
    , purposeCode : Maybe String
    , paymentMethod : Maybe String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , isSubcontracted : Maybe Bool
    , isPartialPayment : Maybe Bool
    , isExistingLiability : Maybe Bool
    , error : String
    }


init : Model
init =
    { checkRecipient = ""
    , checkAmount = ""
    , checkNumber = ""
    , checkDate = ""
    , purposeCode = Nothing
    , paymentMethod = Nothing
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , isSubcontracted = Nothing
    , isPartialPayment = Nothing
    , isExistingLiability = Nothing
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
        recipientNameRows model
            ++ addressRows model
            ++ purposeCodeRows model
            --++ yesOrNoRows
            --    UpdateIsSubcontracted
            --    model.isSubcontracted
            --    UpdateIsPartialPayment
            --    model.isPartialPayment
            --    UpdateIsExistingLiability
            --    model.isExistingLiability
            --    False
            --    False
            ++ paymentMethodSelectRows
            ++ paymentMethodCheckRows model


purposeCodeRows : Model -> List (Html Msg)
purposeCodeRows model =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ PurposeCode.select PurposeUpdated ] ] ]


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


recipientNameRows : Model -> List (Html Msg)
recipientNameRows model =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
            , Input.text [ Input.id "recipient-name", Input.onInput CheckRecipientUpdated, Input.placeholder "Enter recipient name" ]
            ]
        ]
    ]


paymentMethodSelectRows : List (Html Msg)
paymentMethodSelectRows =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ PaymentMethod.dropdown PaymentMethodUpdated
            ]
        ]
    ]


paymentMethodCheckRows : Model -> List (Html Msg)
paymentMethodCheckRows model =
    [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "amount" ] [ text "Amount" ]
            , Input.text [ Input.id "amount", Input.onInput CheckAmountUpdated, Input.placeholder "Enter amount" ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "check-number" ] [ text "Check Number" ]
            , Input.text [ Input.id "check-number", Input.onInput CheckNumberUpdated, Input.placeholder "Enter check number" ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Form.label [ for "date" ] [ text "Date" ]
            , Input.date [ Input.id "date", Input.onInput CheckDateUpdated ]
            ]
        ]
    ]


type Msg
    = NoOp
    | PurposeUpdated String
    | CheckAmountUpdated String
    | CheckRecipientUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | IsSubcontractedUpdated (Maybe Bool)
    | IsPartialPaymentUpdated (Maybe Bool)
    | IsExistingLiabilityUpdated (Maybe Bool)
    | PaymentMethodUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PurposeUpdated str ->
            ( { model | purposeCode = Just str }, Cmd.none )

        PaymentMethodUpdated str ->
            ( { model | paymentMethod = Just str }, Cmd.none )

        CheckAmountUpdated str ->
            ( { model | checkAmount = str }, Cmd.none )

        CheckRecipientUpdated str ->
            ( { model | checkRecipient = str }, Cmd.none )

        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        CheckDateUpdated str ->
            ( { model | checkDate = str }, Cmd.none )

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
