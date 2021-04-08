module CreateContribution exposing (Model, Msg(..), init, setError, update, view)

import Address
import AppInput exposing (inputEmail, inputText)
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Table as Table
import Bootstrap.Utilities.Spacing as Spacing
import ContributorType exposing (ContributorType)
import Html exposing (Html, h3, h5, span, text)
import Html.Attributes exposing (class, for, value)
import OrgOrInd exposing (OrgOrInd(..))
import Owners exposing (Owners)
import SelectRadio
import State
import SubmitButton exposing (submitButton)


type alias Model =
    { submitting : Bool
    , errors : List String
    , error : String
    , checkAmount : String
    , checkNumber : String
    , checkDate : String
    , paymentMethod : String
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , lastName : String
    , address1 : String
    , address2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : String
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd
    , maybeContributorType : Maybe ContributorType
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerName : String
    , ownerOwnership : String
    }


init : Model
init =
    { submitting = False
    , error = ""
    , errors = []
    , checkAmount = ""
    , checkNumber = ""
    , checkDate = ""
    , emailAddress = ""
    , phoneNumber = ""
    , firstName = ""
    , lastName = ""
    , address1 = ""
    , address2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , employmentStatus = ""
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeContributorType = Nothing
    , maybeOrgOrInd = Nothing
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , amount = ""
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , paymentMethod = ""
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
    [ Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ h5 [ class "font-weight-bold" ] [ text str ] ] ]
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
    Radio.radioList
        "Payment Method"
        [ SelectRadio.view UpdatePaymentMethod "check" "Check" model.paymentMethod
        , SelectRadio.view UpdatePaymentMethod "credit" "Credit" model.paymentMethod
        , SelectRadio.view UpdatePaymentMethod "in-kind" "In Kind" model.paymentMethod
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
            ++ donorInfoRows model
            ++ labelRow "Processing Info"
            ++ paymentMethodRow model
            ++ processingRow model


donorInfoRows : Model -> List (Html Msg)
donorInfoRows model =
    let
        formRows =
            case model.maybeOrgOrInd of
                Just Org ->
                    orgRows model ++ piiRows model

                Just Ind ->
                    piiRows model ++ employmentRows model ++ familyRow model

                Nothing ->
                    []
    in
    orgOrIndRow model ++ formRows


needEmployerName : String -> Bool
needEmployerName status =
    case status of
        "employed" ->
            True

        "self_employed" ->
            True

        _ ->
            False


employmentRows : Model -> List (Html Msg)
employmentRows model =
    let
        employerRowOrEmpty =
            if needEmployerName model.employmentStatus then
                [ employerOccupationRow model ]

            else
                []
    in
    employmentStatusRows model ++ employerRowOrEmpty


manageOwnerRows : Model -> List (Html Msg)
manageOwnerRows model =
    let
        tableBody =
            Table.tbody [] <|
                List.map
                    (\owner ->
                        Table.tr []
                            [ Table.td [] [ text owner.name ]
                            , Table.td [] [ text owner.percentOwnership ]
                            ]
                    )
                    model.owners

        tableHead =
            Table.simpleThead
                [ Table.th [] [ text "Name" ]
                , Table.th [] [ text "Percent Ownership" ]
                ]

        capTable =
            if List.length model.owners > 0 then
                [ Table.simpleTable ( tableHead, tableBody ) ]

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
        [ Grid.col
            []
            [ text "Please specify the current ownership breakdown of your company."
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mb3 ] ]
        [ Grid.col
            []
            [ text "*Total percent ownership must equal 100%"
            ]
        ]
    ]
        ++ capTable
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText UpdateOwnerName "Owner Name" model.ownerName
                    ]
                , Grid.col
                    []
                    [ inputText UpdateOwnerOwnership "Percent Ownership" model.ownerOwnership ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    [ Col.xs6, Col.offsetXs6 ]
                    [ submitButton "Add another member" AddOwner False False ]
                ]
           ]


isLLCDonor : Model -> Bool
isLLCDonor model =
    Maybe.withDefault False (Maybe.map ContributorType.isLLC model.maybeContributorType)


orgRows : Model -> List (Html Msg)
orgRows model =
    let
        llcRow =
            if isLLCDonor model then
                manageOwnerRows model

            else
                []
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ ContributorType.orgView UpdateOrganizationClassification model.maybeContributorType ]
        ]
    ]
        ++ llcRow
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ Input.text
                        [ Input.onInput UpdateOrganizationName
                        , Input.placeholder "Organization Name"
                        , Input.value model.entityName
                        ]
                    ]
                ]
           ]


piiRows : Model -> List (Html Msg)
piiRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputEmail UpdateEmailAddress "Email Address" model.emailAddress ]
        , Grid.col
            []
            [ inputText UpdatePhoneNumber "Phone Number" model.phoneNumber ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateFirstName "First Name" model.firstName ]
        , Grid.col
            []
            [ inputText UpdateLastName "Last Name" model.lastName ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateAddress1 "Address 1" model.address1
            ]
        , Grid.col
            []
            [ inputText UpdateAddress2 "Address 2" model.address2
            ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateCity "City" model.city ]
        , Grid.col
            []
            [ State.view UpdateState model.state ]
        , Grid.col
            []
            [ inputText UpdatePostalCode "Zip" model.postalCode
            ]
        ]
    ]


familyRow : Model -> List (Html Msg)
familyRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "Is the donor a family member of the candidate that will receive this contribution?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            ContributorType.familyRadioList UpdateFamilyOrIndividual model.maybeContributorType
        ]
    ]


orgOrIndRow : Model -> List (Html Msg)
orgOrIndRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ text "Will you be donating as an individual or on behalf of an organization?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ OrgOrInd.row ChooseOrgOrInd model.maybeOrgOrInd ]
        ]
    ]


employerOccupationRow : Model -> Html Msg
employerOccupationRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText UpdateEmployer "Employer Name" model.employer ]
        , Grid.col
            []
            [ inputText UpdateOccupation "Occupation" model.occupation ]
        ]


employmentStatusRows : Model -> List (Html Msg)
employmentStatusRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "What is your employment status?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            Radio.radioList "employmentStatus"
                [ SelectRadio.view UpdateEmploymentStatus "employed" "Employed" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "unemployed" "Unemployed" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "retired" "Retired" model.employmentStatus
                , SelectRadio.view UpdateEmploymentStatus "self_employed" "Self Employed" model.employmentStatus
                ]
        ]
    ]


type Msg
    = CheckAmountUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
      --- Donor Info
    | ChooseOrgOrInd (Maybe OrgOrInd)
    | UpdateEmailAddress String
    | UpdatePhoneNumber String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateAddress1 String
    | UpdateAddress2 String
    | UpdateCity String
    | UpdateState String
    | UpdatePostalCode String
    | UpdateEmploymentStatus String
    | UpdateEmployer String
    | UpdateOccupation String
    | UpdateOrganizationName String
    | UpdateOrganizationClassification (Maybe ContributorType)
    | UpdateFamilyOrIndividual ContributorType
    | AddOwner
    | UpdateOwnerName String
    | UpdateOwnerOwnership String
      -- Payment info
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | NoOp String
    | UpdatePaymentMethod String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp str ->
            ( model, Cmd.none )

        CheckAmountUpdated str ->
            ( { model | checkAmount = str }, Cmd.none )

        -- Donor Info
        ChooseOrgOrInd maybeOrgOrInd ->
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeContributorType = Nothing, errors = [] }, Cmd.none )

        UpdateOrganizationName entityName ->
            ( { model | entityName = entityName }, Cmd.none )

        UpdateOrganizationClassification maybeContributorType ->
            ( { model | maybeContributorType = maybeContributorType }, Cmd.none )

        AddOwner ->
            let
                newOwner =
                    Owners.Owner model.ownerName model.ownerOwnership
            in
            ( { model | owners = model.owners ++ [ newOwner ], ownerOwnership = "", ownerName = "" }, Cmd.none )

        UpdateOwnerName str ->
            ( { model | ownerName = str }, Cmd.none )

        UpdateOwnerOwnership str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        UpdatePhoneNumber str ->
            ( { model | phoneNumber = str }, Cmd.none )

        UpdateEmailAddress str ->
            ( { model | emailAddress = str }, Cmd.none )

        UpdateFirstName str ->
            ( { model | firstName = str }, Cmd.none )

        UpdateLastName str ->
            ( { model | lastName = str }, Cmd.none )

        UpdateAddress1 str ->
            ( { model | address1 = str }, Cmd.none )

        UpdateAddress2 str ->
            ( { model | address2 = str }, Cmd.none )

        UpdatePostalCode str ->
            ( { model | postalCode = str }, Cmd.none )

        UpdateCity str ->
            ( { model | city = str }, Cmd.none )

        UpdateState str ->
            ( { model | state = str }, Cmd.none )

        UpdateFamilyOrIndividual contributorType ->
            ( { model | maybeContributorType = Just contributorType }, Cmd.none )

        UpdateEmploymentStatus str ->
            ( { model | employmentStatus = str }, Cmd.none )

        UpdateEmployer str ->
            ( { model | employer = str }, Cmd.none )

        UpdateOccupation str ->
            ( { model | occupation = str }, Cmd.none )

        -- Payment Info
        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        CheckDateUpdated str ->
            ( { model | checkDate = str }, Cmd.none )

        CardMonthUpdated str ->
            ( { model | expirationMonth = str }, Cmd.none )

        CardNumberUpdated str ->
            ( { model | cardNumber = str }, Cmd.none )

        CardYearUpdated str ->
            ( { model | expirationYear = str }, Cmd.none )

        UpdatePaymentMethod str ->
            ( { model | paymentMethod = str }, Cmd.none )
