module CreateContribution exposing (Model, Msg(..), init, setError, update, view)

import Address
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, h3, h5, span, text)
import Html.Attributes exposing (class, for, value)


type alias Model =
    { firstName : String
    , lastName : String
    , checkAmount : String
    , checkNumber : String
    , checkDate : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    , paymentMethod : String
    , cardNumber : String
    , cardMonth : String
    , cardYear : String
    , error : String
    }


init : Model
init =
    { firstName = ""
    , lastName = ""
    , checkAmount = ""
    , checkNumber = ""
    , checkDate = ""
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , paymentMethod = ""
    , error = ""
    , cardNumber = ""
    , cardMonth = ""
    , cardYear = ""
    }


setError : Model -> String -> Model
setError model str =
    { model | error = str }


errorRow : String -> List (Html Msg)
errorRow str =
    if String.length str > 0 then
        [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
            [ Grid.col [] [ span [ class "text-danger" ] [ text str ] ] ]
        ]

    else
        []


labelRow : String -> List (Html Msg)
labelRow str =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col [] [ Form.label [] [ text str ] ] ]
    ]


nameRow : ( String, String -> Msg ) -> ( String, String -> Msg ) -> List (Html Msg)
nameRow ( firstName, firstNameMsg ) ( lastName, lastNameMsg ) =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "first-name"
                , Input.onInput firstNameMsg
                , Input.value firstName
                , Input.placeholder "Donor first name"
                ]
            ]
        , Grid.col
            []
            [ Input.text
                [ Input.id "last-name"
                , Input.onInput lastNameMsg
                , Input.value lastName
                , Input.placeholder "Donor last name"
                ]
            ]
        ]
    ]


amountDateRow : Model -> List (Html Msg)
amountDateRow model =
    [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "amount"
                , Input.onInput CheckAmountUpdated
                , Input.value model.checkAmount
                , Input.placeholder "Enter amount"
                ]
            ]
        , Grid.col
            []
            [ Input.date
                [ Input.id "date"
                , Input.onInput CheckDateUpdated
                , Input.value model.checkDate
                ]
            ]
        ]
    ]


paymentMethodRow : Model -> List (Html Msg)
paymentMethodRow model =
    [ Grid.row []
        [ Grid.col [ Col.xs2 ]
            [ Radio.radio
                [ Radio.id "check"
                , Radio.checked (model.paymentMethod == "check")
                , Radio.onClick (PaymentMethodUpdated "check")
                ]
                "Check"
            ]
        , Grid.col [ Col.xs2 ]
            [ Radio.radio
                [ Radio.id "credit"
                , Radio.checked (model.paymentMethod == "credit")
                , Radio.onClick (PaymentMethodUpdated "credit")
                ]
                "Credit"
            ]
        ]
    ]


checkRow : Model -> List (Html Msg)
checkRow model =
    [ Grid.row [ Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "check-number"
                , Input.onInput CheckNumberUpdated
                , Input.value model.checkNumber
                , Input.placeholder "Enter check number"
                ]
            ]
        , Grid.col
            []
            [ Input.text [ Input.id "amount", Input.onInput NoOp, Input.placeholder "Account number" ]
            ]
        , Grid.col
            []
            [ Input.text [ Input.id "check-number", Input.onInput NoOp, Input.placeholder "Routing number" ]
            ]
        ]
    ]


processingRow : Model -> List (Html Msg)
processingRow model =
    case model.paymentMethod of
        "check" ->
            checkRow model

        "credit" ->
            creditRow model

        _ ->
            []


creditRow : Model -> List (Html Msg)
creditRow model =
    [ Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "card-number"
                , Input.onInput CardNumberUpdated
                , Input.value model.cardNumber
                , Input.placeholder "Card number"
                ]
            ]
        , Grid.col []
            [ Select.select
                [ Select.id "card-month"
                , Select.onChange CardMonthUpdated
                , Select.attrs [ value model.cardMonth ]
                ]
                [ Select.item [ value "" ] [ text "Select month" ]
                , Select.item [ value "1" ] [ text "1 - Jan" ]
                , Select.item [ value "2" ] [ text "2 - Feb" ]
                , Select.item [ value "3" ] [ text "3 - Mar" ]
                , Select.item [ value "4" ] [ text "4 - Apr" ]
                , Select.item [ value "5" ] [ text "5 - May" ]
                , Select.item [ value "6" ] [ text "6 - Jun" ]
                , Select.item [ value "7" ] [ text "7 - Jul" ]
                , Select.item [ value "8" ] [ text "8 - Aug" ]
                , Select.item [ value "9" ] [ text "9 - Sept" ]
                , Select.item [ value "10" ] [ text "10 - Oct" ]
                , Select.item [ value "11" ] [ text "11 - Nov" ]
                , Select.item [ value "12" ] [ text "12 - Dec" ]
                ]
            ]
        , Grid.col []
            [ Select.select
                [ Select.id "card-year"
                , Select.onChange CardYearUpdated
                , Select.attrs [ value model.cardYear ]
                ]
                [ Select.item [ value "" ] [ text "Select year" ]
                , Select.item [ value "2020" ] [ text "2020" ]
                , Select.item [ value "2021" ] [ text "2021" ]
                , Select.item [ value "2022" ] [ text "2022" ]
                , Select.item [ value "2023" ] [ text "2023" ]
                , Select.item [ value "2024" ] [ text "2024" ]
                , Select.item [ value "2025" ] [ text "2025" ]
                , Select.item [ value "2026" ] [ text "2026" ]
                , Select.item [ value "2027" ] [ text "2027" ]
                , Select.item [ value "2028" ] [ text "2028" ]
                , Select.item [ value "2029" ] [ text "2029" ]
                , Select.item [ value "2030" ] [ text "2030" ]
                ]
            ]
        ]
    ]


view : Model -> Html Msg
view model =
    Grid.containerFluid
        []
    <|
        []
            ++ errorRow model.error
            ++ labelRow "Payment Info"
            ++ amountDateRow model
            ++ labelRow "Donor Info"
            ++ nameRow
                ( model.firstName, FirstNameUpdated )
                ( model.lastName, LastNameUpdated )
            ++ Address.row
                ( model.address1, Address1Updated )
                ( model.address2, Address2Updated )
                ( model.city, CityUpdated )
                ( model.state, StateUpdated )
                ( model.postalCode, PostalCodeUpdated )
            ++ labelRow "Processing Info"
            ++ paymentMethodRow model
            ++ processingRow model


type Msg
    = CheckAmountUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
    | Address1Updated String
    | Address2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | FirstNameUpdated String
    | LastNameUpdated String
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | NoOp String
    | PaymentMethodUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp str ->
            ( model, Cmd.none )

        CheckAmountUpdated str ->
            ( { model | checkAmount = str }, Cmd.none )

        FirstNameUpdated str ->
            ( { model | firstName = str }, Cmd.none )

        LastNameUpdated str ->
            ( { model | lastName = str }, Cmd.none )

        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        CheckDateUpdated str ->
            ( { model | checkDate = str }, Cmd.none )

        Address1Updated str ->
            ( { model | address1 = str }, Cmd.none )

        Address2Updated str ->
            ( { model | address2 = str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        CardMonthUpdated str ->
            ( { model | cardMonth = str }, Cmd.none )

        CardNumberUpdated str ->
            ( { model | cardNumber = str }, Cmd.none )

        CardYearUpdated str ->
            ( { model | cardYear = str }, Cmd.none )

        PaymentMethodUpdated str ->
            ( { model | paymentMethod = str }, Cmd.none )
