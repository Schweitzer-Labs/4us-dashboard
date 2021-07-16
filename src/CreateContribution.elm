module CreateContribution exposing (Model, Msg(..), init, setError, update, view)

import Address
import AmountDate
import AppInput exposing (inputEmail, inputText)
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Table as Table
import Bootstrap.Utilities.Spacing as Spacing
import EntityType exposing (EntityType)
import Html exposing (Html, h3, h5, span, text)
import Html.Attributes exposing (class, for, value)
import MonthSelector
import OrgOrInd exposing (OrgOrInd(..))
import Owners exposing (Owners)
import PaymentMethod
import SelectRadio
import State
import SubmitButton exposing (submitButton)
import YearSelector


type alias Model =
    { submitting : Bool
    , errors : List String
    , error : String
    , checkNumber : String
    , paymentDate : String
    , paymentMethod : String
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , middleName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : String
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd
    , maybeEntityType : Maybe EntityType
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , amount : String
    , owners : Owners
    , ownerName : String
    , ownerOwnership : String
    , committeeId : String
    }


init : String -> Model
init committeeId =
    { submitting = False
    , error = ""
    , errors = []
    , amount = ""
    , checkNumber = ""
    , paymentDate = ""
    , emailAddress = ""
    , phoneNumber = ""
    , firstName = ""
    , middleName = ""
    , lastName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , employmentStatus = ""
    , employer = ""
    , occupation = ""
    , entityName = ""
    , maybeEntityType = Nothing
    , maybeOrgOrInd = Nothing
    , cardNumber = ""
    , expirationMonth = ""
    , expirationYear = ""
    , cvv = ""
    , owners = []
    , ownerName = ""
    , ownerOwnership = ""
    , paymentMethod = ""
    , committeeId = committeeId
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
    AmountDate.view
        { amount = ( model.amount, AmountUpdated )
        , paymentDate = ( model.paymentDate, PaymentDateUpdated )
        }


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
        ]
    ]


processingRow : Model -> List (Html Msg)
processingRow model =
    case model.paymentMethod of
        "Check" ->
            checkRow model

        "Credit" ->
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
            [ MonthSelector.view CardMonthUpdated
            ]
        , Grid.col []
            [ YearSelector.view CardYearUpdated ]
        , Grid.col []
            [ Input.text
                [ Input.id "cvv"
                , Input.onInput CVVUpdated
                , Input.value model.cvv
                , Input.placeholder "CVV"
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
            ++ PaymentMethod.select PaymentMethodUpdated model.paymentMethod
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
                    [ inputText OwnerNameUpdated "Owner Name" model.ownerName
                    ]
                , Grid.col
                    []
                    [ inputText OwnerOwnershipUpdated "Percent Ownership" model.ownerOwnership ]
                ]
           , Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    [ Col.xs6, Col.offsetXs6 ]
                    [ submitButton "Add another member" OwnerAdded False False ]
                ]
           ]


isLLCDonor : Model -> Bool
isLLCDonor model =
    Maybe.withDefault False (Maybe.map EntityType.isLLC model.maybeEntityType)


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
            [ EntityType.orgView OrganizationClassificationUpdated model.maybeEntityType ]
        ]
    ]
        ++ llcRow
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ Input.text
                        [ Input.onInput OrganizationNameUpdated
                        , Input.placeholder "Organization Name"
                        , Input.value model.entityName
                        ]
                    ]
                ]
           ]


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


piiRows : Model -> List (Html Msg)
piiRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputEmail EmailAddressUpdated "Email Address" model.emailAddress ]
        , Grid.col
            []
            [ inputText PhoneNumberUpdated "Phone Number" model.phoneNumber ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText FirstNameUpdated "First Name" model.firstName ]
        , Grid.col
            []
            [ inputText LastNameUpdated "Last Name" model.lastName ]
        ]
    ]
        ++ addressRows model


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
            EntityType.familyRadioList FamilyOrIndividualUpdated model.maybeEntityType
        ]
    ]


attestsToBeingAnAdultCitizenRow : Model -> List (Html Msg)
attestsToBeingAnAdultCitizenRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "Is the donor an American citizen and at least eighteen years of age?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            EntityType.familyRadioList FamilyOrIndividualUpdated model.maybeEntityType
        ]
    ]


orgOrIndRow : Model -> List (Html Msg)
orgOrIndRow model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ text "Will the donor be contributing as an individual or on behalf of an organization?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ OrgOrInd.row OrgOrIndUpdated model.maybeOrgOrInd ]
        ]
    ]


employerOccupationRow : Model -> Html Msg
employerOccupationRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText EmployerUpdated "Employer Name" model.employer ]
        , Grid.col
            []
            [ inputText OccupationUpdated "Occupation" model.occupation ]
        ]


employmentStatusRows : Model -> List (Html Msg)
employmentStatusRows model =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "What is the donor's employment status?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            Radio.radioList "employmentStatus"
                [ SelectRadio.view EmploymentStatusUpdated "employed" "Employed" model.employmentStatus
                , SelectRadio.view EmploymentStatusUpdated "unemployed" "Unemployed" model.employmentStatus
                , SelectRadio.view EmploymentStatusUpdated "retired" "Retired" model.employmentStatus
                , SelectRadio.view EmploymentStatusUpdated "self_employed" "Self Employed" model.employmentStatus
                ]
        ]
    ]


type Msg
    = AmountUpdated String
    | CheckNumberUpdated String
    | PaymentDateUpdated String
      --- Donor Info
    | OrgOrIndUpdated (Maybe OrgOrInd)
    | EmailAddressUpdated String
    | PhoneNumberUpdated String
    | FirstNameUpdated String
    | LastNameUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | EmploymentStatusUpdated String
    | EmployerUpdated String
    | OccupationUpdated String
    | OrganizationNameUpdated String
    | OrganizationClassificationUpdated (Maybe EntityType)
    | FamilyOrIndividualUpdated EntityType
    | OwnerAdded
    | OwnerNameUpdated String
    | OwnerOwnershipUpdated String
      -- Payment info
    | CardYearUpdated String
    | CardMonthUpdated String
    | CardNumberUpdated String
    | NoOp String
    | PaymentMethodUpdated String
    | CVVUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp str ->
            ( model, Cmd.none )

        AmountUpdated str ->
            ( { model | amount = str }, Cmd.none )

        -- Donor Info
        OrgOrIndUpdated maybeOrgOrInd ->
            ( { model | maybeOrgOrInd = maybeOrgOrInd, maybeEntityType = Nothing, errors = [] }, Cmd.none )

        OrganizationNameUpdated entityName ->
            ( { model | entityName = entityName }, Cmd.none )

        OrganizationClassificationUpdated maybeEntityType ->
            ( { model | maybeEntityType = maybeEntityType }, Cmd.none )

        OwnerAdded ->
            let
                newOwner =
                    Owners.Owner model.ownerName model.ownerOwnership
            in
            ( { model | owners = model.owners ++ [ newOwner ], ownerOwnership = "", ownerName = "" }, Cmd.none )

        OwnerNameUpdated str ->
            ( { model | ownerName = str }, Cmd.none )

        OwnerOwnershipUpdated str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        PhoneNumberUpdated str ->
            ( { model | phoneNumber = str }, Cmd.none )

        EmailAddressUpdated str ->
            ( { model | emailAddress = str }, Cmd.none )

        FirstNameUpdated str ->
            ( { model | firstName = str }, Cmd.none )

        LastNameUpdated str ->
            ( { model | lastName = str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | addressLine1 = str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | addressLine2 = str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = str }, Cmd.none )

        FamilyOrIndividualUpdated entityType ->
            ( { model | maybeEntityType = Just entityType }, Cmd.none )

        EmploymentStatusUpdated str ->
            ( { model | employmentStatus = str }, Cmd.none )

        EmployerUpdated str ->
            ( { model | employer = str }, Cmd.none )

        OccupationUpdated str ->
            ( { model | occupation = str }, Cmd.none )

        -- Payment Info
        CheckNumberUpdated str ->
            ( { model | checkNumber = str }, Cmd.none )

        PaymentDateUpdated str ->
            ( { model | paymentDate = str }, Cmd.none )

        CardMonthUpdated str ->
            ( { model | expirationMonth = str }, Cmd.none )

        CardNumberUpdated str ->
            ( { model | cardNumber = str }, Cmd.none )

        CVVUpdated str ->
            ( { model | cvv = str }, Cmd.none )

        CardYearUpdated str ->
            ( { model | expirationYear = str }, Cmd.none )

        PaymentMethodUpdated str ->
            ( { model | paymentMethod = str }, Cmd.none )
