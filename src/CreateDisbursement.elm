module CreateDisbursement exposing (Model, Msg(..), init, selectPurpose, update, view)

import Address
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Disbursement.Forms exposing (yesOrNoRows)
import Html exposing (Html, div, text)
import Html.Attributes exposing (for, value)
import PurposeCode


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
    , isSubcontracted : String
    , isPartialPayment : String
    , isExistingLiability : String
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
    , isSubcontracted = ""
    , isPartialPayment = ""
    , isExistingLiability = ""
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
                    PurposeCode.purposeCodeText
        ]


view : Model -> Html Msg
view model =
    Grid.containerFluid
        []
    <|
        recipientNameRows model
            ++ addressRows model
            ++ purposeCodeRows model
            ++ yesOrNoRows
                UpdateIsSubcontracted
                model.isSubcontracted
                UpdateIsPartialPayment
                model.isPartialPayment
                UpdateIsExistingLiability
                model.isExistingLiability
                False
            ++ paymentMethodSelectRows
            ++ paymentMethodCheckRows model


purposeCodeRows : Model -> List (Html Msg)
purposeCodeRows model =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ] ]


addressRows : Model -> List (Html Msg)
addressRows model =
    Address.row
        ( model.address1, Address1Updated )
        ( model.address2, Address2Updated )
        ( model.city, CityUpdated )
        ( model.state, StateUpdated )
        ( model.postalCode, PostalCodeUpdated )


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
            [ Form.label [ for "paymentMethodSelect" ] [ text "Select Payment Method" ]
            , Select.select [ Select.id "paymentMethodSelect" ]
                [ Select.item [] [ text "-- Payment Method --" ]
                , Select.item [] [ text "Check" ]
                , Select.item [] [ text "Credit Card" ]
                , Select.item [] [ text "Debit Card" ]
                , Select.item [] [ text "Online Processor" ]
                , Select.item [] [ text "Wire Transfer" ]
                , Select.item [] [ text "Cash" ]
                , Select.item [] [ text "Other" ]
                ]
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

        --, Grid.col
        --    [ Col.lg4 ]
        --    [ Form.label [ for "check-number" ] [ text "Check Number" ]
        --    , Input.text [ Input.id "check-number", Input.onInput CheckNumberUpdated, Input.placeholder "Enter check number" ]
        --    ]
        --, Grid.col
        --    [ Col.lg4 ]
        --    [ Form.label [ for "date" ] [ text "Date" ]
        --    , Input.date [ Input.id "date", Input.onInput CheckDateUpdated ]
        --    ]
        --]
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
    | UpdateIsSubcontracted String
    | UpdateIsPartialPayment String
    | UpdateIsExistingLiability String


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

        UpdateIsSubcontracted str ->
            ( { model | isSubcontracted = str }, Cmd.none )

        UpdateIsPartialPayment str ->
            ( { model | isPartialPayment = str }, Cmd.none )

        UpdateIsExistingLiability str ->
            ( { model | isExistingLiability = str }, Cmd.none )
