module CreateDisbursement exposing (Model, Msg(..), init, selectPurpose, update, view)

import Address
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, text)
import Html.Attributes exposing (for, value)
import Purpose


type alias Model =
    { checkRecipient : String
    , checkAmount : String
    , checkNumber : String
    , checkDate : String
    , purposeCode : Maybe String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    }


init : Model
init =
    { checkRecipient = ""
    , checkAmount = ""
    , checkNumber = ""
    , checkDate = ""
    , purposeCode = Nothing
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    }


selectPurpose : Model -> Html Msg
selectPurpose model =
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange PurposeUpdated
            ]
          <|
            (++) [ Select.item [] [ text "---" ] ] <|
                List.map
                    (\( _, codeText, purposeText ) -> Select.item [ value codeText ] [ text <| purposeText ])
                    Purpose.purposeText
        ]


view : Model -> Html Msg
view model =
    Grid.containerFluid
        []
    <|
        [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]
        , Grid.row [ Row.attrs [ Spacing.mt2 ] ]
            [ Grid.col
                []
                [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
                , Input.text [ Input.id "recipient-name", Input.onInput CheckRecipientUpdated, Input.placeholder "Enter recipient name" ]
                ]
            ]
        ]
            ++ Address.row
                ( model.address1, Address1Updated )
                ( model.address2, Address2Updated )
                ( model.city, CityUpdated )
                ( model.state, StateUpdated )
                ( model.postalCode, PostalCodeUpdated )
            ++ [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
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
    = PurposeUpdated String
    | CheckAmountUpdated String
    | CheckRecipientUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
    | Address1Updated String
    | Address2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PurposeUpdated str ->
            ( { model | purposeCode = Just str }, Cmd.none )

        CheckAmountUpdated str ->
            ( { model | checkAmount = str }, Cmd.none )

        CheckRecipientUpdated str ->
            ( { model | checkRecipient = str }, Cmd.none )

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
