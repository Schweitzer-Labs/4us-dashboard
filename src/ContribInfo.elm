module ContribInfo exposing (Config, ContribValidatorModel, requiredFieldValidators, toSubmitDisabled, validateModel, view)

import Address
import AmountDate
import AppInput exposing (inputEmail, inputText)
import Asset
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg exposing (toData, toMsg)
import EmploymentStatus exposing (Model(..), employmentRadioList)
import EntityType
import Errors exposing (fromContribPaymentInfo, fromEmailAddress, fromOrgType, fromOwners, fromPhoneNumber, fromPostalCode)
import Html exposing (Html, div, h5, h6, span, text)
import Html.Attributes as Attr exposing (attribute, class, for)
import Html.Events exposing (onClick)
import InKindType exposing (Model(..))
import MonthSelector
import OrgOrInd
import Owners as Owner
import OwnersView
import PaymentMethod
import Validate exposing (Valid, Validator, fromErrors, ifBlank, ifNothing, validate)
import YearSelector


type alias Config msg =
    { checkNumber : DataMsg.MsgString msg
    , paymentDate : DataMsg.MsgString msg
    , paymentMethod : DataMsg.MsgMaybePaymentMethod msg
    , emailAddress : DataMsg.MsgString msg
    , phoneNumber : DataMsg.MsgString msg
    , firstName : DataMsg.MsgString msg
    , middleName : DataMsg.MsgString msg
    , lastName : DataMsg.MsgString msg
    , addressLine1 : DataMsg.MsgString msg
    , addressLine2 : DataMsg.MsgString msg
    , city : DataMsg.MsgString msg
    , state : DataMsg.MsgString msg
    , postalCode : DataMsg.MsgString msg
    , employmentStatus : DataMsg.MsgMaybeEmploymentStatus msg
    , employer : DataMsg.MsgString msg
    , occupation : DataMsg.MsgString msg
    , entityName : DataMsg.MsgString msg
    , maybeEntityType : DataMsg.MsgMaybeEntityType msg
    , maybeOrgOrInd : DataMsg.MsgMaybeOrgOrInd msg
    , cardNumber : DataMsg.MsgString msg
    , expirationMonth : DataMsg.MsgString msg
    , expirationYear : DataMsg.MsgString msg
    , cvv : DataMsg.MsgString msg
    , amount : DataMsg.MsgString msg
    , ownersViewMsg : OwnersView.Msg -> msg
    , ownersViewModel : OwnersView.Model
    , inKindType : DataMsg.MsgMaybeInKindType msg
    , inKindDesc : DataMsg.MsgString msg
    , disabled : Bool
    , isEditable : Bool
    , toggleEdit : msg
    , maybeError : Maybe String
    , txnId : Maybe String
    , processPayment : Bool
    }


view : Config msg -> Html msg
view c =
    let
        maybeMsg =
            toMsg c.paymentMethod

        msg =
            Just >> maybeMsg
    in
    Grid.containerFluid
        []
    <|
        []
            ++ donorHeadingRow c.toggleEdit c.disabled c.isEditable
            ++ (if c.isEditable == False then
                    amountDateRow c

                else
                    []
               )
            ++ errorRow c.maybeError
            ++ donorInfoRows c
            ++ (case c.isEditable of
                    True ->
                        case toData c.paymentMethod of
                            Just PaymentMethod.InKind ->
                                inKindRow c

                            Just PaymentMethod.Check ->
                                []
                                    ++ labelRow "Check Number"
                                    ++ processingRow c

                            _ ->
                                []

                    False ->
                        []
                            ++ labelRow "Processing Info"
                            ++ PaymentMethod.select c.processPayment msg (toData c.paymentMethod) c.disabled c.txnId
                            ++ processingRow c
               )


donorHeadingRow : msg -> Bool -> Bool -> List (Html msg)
donorHeadingRow toggleMsg disabled isEditable =
    [ div [ Spacing.mt3 ]
        [ h5 [ class "font-weight-bold d-inline" ] [ text "Donor Info" ]
        , if isEditable then
            span [ class "hover-underline hover-pointer align-middle", Spacing.ml2, onClick toggleMsg ]
                [ if disabled == True then
                    Asset.editGlyph []

                  else
                    Asset.redoGlyph []
                ]

          else
            span [] []
        ]
    ]


type alias ContribValidatorModel =
    { checkNumber : String
    , amount : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
    , emailAddress : String
    , isEmailAddressValid : Bool
    , phoneNumber : String
    , isPhoneNumValid : Bool
    , firstName : String
    , middleName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : Maybe EmploymentStatus.Model
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd.Model
    , maybeEntityType : Maybe EntityType.Model
    , inKindType : Maybe InKindType.Model
    , inKindDesc : String
    , owners : Owner.Owners
    }


contribInfoValidator : Validator String ContribValidatorModel
contribInfoValidator =
    Validate.firstError <|
        requiredFieldValidators
            ++ [ postalCodeValidator
               , paymentInfoValidator
               , orgTypeValidator
               , ownersValidator
               ]


requiredFieldValidators : List (Validator String ContribValidatorModel)
requiredFieldValidators =
    [ paymentInfoValidator
    , ifBlank .amount "Payment Amount is missing"
    , ifBlank .paymentDate "Payment Date is missing"
    , ifNothing .paymentMethod "Processing Info is missing"
    , ifBlank .firstName "First Name is missing"
    , ifBlank .lastName "Last name is missing"
    , ifBlank .city "City is missing"
    , ifBlank .state "State is missing"
    , ifBlank .postalCode "Postal Code is missing."
    , ifBlank .addressLine1 "Address is missing"
    ]


toSubmitDisabled =
    Validate.any
        requiredFieldValidators


validateModel : (a -> ContribValidatorModel) -> a -> Result (List String) (Valid ContribValidatorModel)
validateModel mapper val =
    let
        model =
            mapper val
    in
    validate contribInfoValidator model


postalCodeValidator : Validator String ContribValidatorModel
postalCodeValidator =
    fromErrors postalCodeOnModelToErrors


paymentInfoValidator : Validator String ContribValidatorModel
paymentInfoValidator =
    fromErrors paymentInfoOnModelToErrors


orgTypeValidator : Validator String ContribValidatorModel
orgTypeValidator =
    fromErrors orgTypeOnModelToErrors


emailValidator : Validator String ContribValidatorModel
emailValidator =
    fromErrors emailAddressOnModelToErrors


ownersValidator : Validator String ContribValidatorModel
ownersValidator =
    fromErrors ownersOnModelToErrors


phoneValidator : Validator String ContribValidatorModel
phoneValidator =
    fromErrors phoneNumberOnModelToErrors


postalCodeOnModelToErrors : ContribValidatorModel -> List String
postalCodeOnModelToErrors model =
    fromPostalCode model.postalCode


emailAddressOnModelToErrors : ContribValidatorModel -> List String
emailAddressOnModelToErrors model =
    fromEmailAddress model.isEmailAddressValid


phoneNumberOnModelToErrors : ContribValidatorModel -> List String
phoneNumberOnModelToErrors { phoneNumber, isPhoneNumValid } =
    fromPhoneNumber phoneNumber isPhoneNumValid


paymentInfoOnModelToErrors : ContribValidatorModel -> List String
paymentInfoOnModelToErrors { paymentMethod, inKindType, inKindDesc, checkNumber } =
    fromContribPaymentInfo paymentMethod inKindType inKindDesc checkNumber


orgTypeOnModelToErrors : ContribValidatorModel -> List String
orgTypeOnModelToErrors { maybeOrgOrInd, maybeEntityType, entityName } =
    fromOrgType maybeOrgOrInd maybeEntityType entityName


ownersOnModelToErrors : ContribValidatorModel -> List String
ownersOnModelToErrors { owners, maybeEntityType } =
    fromOwners owners maybeEntityType


errorRow : Maybe String -> List (Html msg)
errorRow maybeStr =
    case maybeStr of
        Nothing ->
            []

        Just str ->
            [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
                [ Grid.col [] [ span [ class "text-danger" ] [ text str ] ] ]
            ]


labelRow : String -> List (Html msg)
labelRow str =
    [ Grid.row [ Row.attrs [ Spacing.mt4 ] ]
        [ Grid.col [] [ h5 [ class "font-weight-bold" ] [ text str ] ] ]
    ]


amountDateRow : Config msg -> List (Html msg)
amountDateRow { amount, paymentDate, disabled, paymentMethod } =
    AmountDate.view
        { amount = ( toData amount, toMsg amount )
        , paymentDate = ( toData paymentDate, toMsg paymentDate )
        , disabled = disabled
        , label = "Date Received from Donor"
        }


checkRow : Config msg -> List (Html msg)
checkRow { checkNumber, disabled } =
    [ Grid.row [ Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            []
            [ inputText (toMsg checkNumber) (toData checkNumber) disabled "createDisbCheck" "Check Number" ]
        ]
    ]


inKindRow : Config msg -> List (Html msg)
inKindRow { inKindType, inKindDesc, disabled } =
    let
        maybeMsg =
            toMsg inKindType

        msg =
            Just >> maybeMsg
    in
    labelRow "In-kind Info"
        ++ [ Grid.row [ Row.attrs [ Spacing.mt3, class "fade-in" ] ]
                [ Grid.col
                    []
                  <|
                    InKindType.radioList msg (toData inKindType) disabled
                        ++ [ inputText (toMsg inKindDesc) (toData inKindDesc) disabled "createContribDescription" "Description" ]
                ]
           ]


processingRow : Config msg -> List (Html msg)
processingRow c =
    case ( toData c.paymentMethod, c.processPayment ) of
        ( Just PaymentMethod.Credit, True ) ->
            []
                ++ errorRow (Just "Contributions via credit will be processed on submission of this form.")
                ++ creditRow c

        ( Just PaymentMethod.Check, _ ) ->
            checkRow c

        ( Just PaymentMethod.InKind, _ ) ->
            inKindRow c

        _ ->
            []


creditRow : Config msg -> List (Html msg)
creditRow { cardNumber, expirationMonth, expirationYear, cvv, disabled } =
    [ Grid.row [ Row.centerLg, Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "card-number"
                , Input.onInput <| toMsg cardNumber
                , Input.placeholder "Card Number"
                , Input.value <| toData cardNumber
                , Input.disabled disabled
                ]
            ]
        , Grid.col []
            [ MonthSelector.view <| toMsg expirationMonth
            ]
        , Grid.col []
            [ YearSelector.view <| toMsg expirationYear
            ]
        , Grid.col []
            [ Input.text
                [ Input.id "cvv"
                , Input.onInput <| toMsg cvv
                , Input.value <| toData cvv
                , Input.placeholder "CVV"
                , Input.disabled disabled
                ]
            ]
        ]
    ]


donorInfoRows : Config msg -> List (Html msg)
donorInfoRows model =
    let
        formRows =
            case toData model.maybeOrgOrInd of
                Just OrgOrInd.Org ->
                    orgRows model ++ piiRows model

                Just OrgOrInd.Ind ->
                    piiRows model ++ familyRow model

                Nothing ->
                    []
    in
    orgOrIndRow model ++ formRows


needEmployerName : Maybe EmploymentStatus.Model -> Bool
needEmployerName status =
    case status of
        Just Employed ->
            True

        Just SelfEmployed ->
            True

        _ ->
            False


employmentRows : Config msg -> List (Html msg)
employmentRows c =
    let
        employerRowOrEmpty =
            if needEmployerName <| toData c.employmentStatus then
                [ employerOccupationRow c ]

            else
                []
    in
    employmentStatusRows c ++ employerRowOrEmpty


orgRows : Config msg -> List (Html msg)
orgRows c =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ EntityType.orgView (toMsg c.maybeEntityType) (toData c.maybeEntityType) c.disabled ]
        ]
    ]
        ++ (if EntityType.isLLCorLLP (toData c.maybeEntityType) then
                let
                    viewModel =
                        c.ownersViewModel

                    state =
                        { viewModel | disabled = c.disabled }
                in
                [ Html.map c.ownersViewMsg <|
                    OwnersView.view state
                ]
                    ++ [ Grid.row []
                            [ Grid.col [ Col.md4 ] [ h6 [ class "font-weight-bold d-inline" ] [ text "Company Contact Info" ] ] ]
                       ]

            else
                []
           )
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText
                        (toMsg c.entityName)
                        (toData c.entityName)
                        c.disabled
                        "contribOwnerName"
                        "Organization Name"
                    ]
                ]
           ]


addressRows : Config msg -> List (Html msg)
addressRows c =
    Address.view
        { addressLine1 = c.addressLine1
        , addressLine2 = c.addressLine2
        , city = c.city
        , state = c.state
        , postalCode = c.postalCode
        , disabled = c.disabled
        , id = "createContrib"
        }


piiRows : Config msg -> List (Html msg)
piiRows c =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputEmail (toMsg c.emailAddress) (toData c.emailAddress) c.disabled "createContribEmail" "Email Address" ]
        , Grid.col
            []
            [ inputText (toMsg c.phoneNumber) (toData c.phoneNumber) c.disabled "createContribPhoneNumber" "Phone Number" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt1 ] ]
        [ Grid.col
            []
            [ inputText (toMsg c.firstName) (toData c.firstName) c.disabled "createContribFirstName" "First Name" ]
        , Grid.col
            []
            [ inputText (toMsg c.lastName) (toData c.lastName) c.disabled "createContribLastName" "Last Name" ]
        ]
    ]
        ++ addressRows c


familyRow : Config msg -> List (Html msg)
familyRow { maybeEntityType, disabled, txnId } =
    let
        maybeEntityMsg =
            toMsg maybeEntityType

        entityMsg =
            Just >> maybeEntityMsg
    in
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ text "Is the donor a family member of the candidate that will receive this contribution?" ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.xs8 ]
          <|
            EntityType.familyRadioList entityMsg (toData maybeEntityType) disabled txnId
        ]
    ]


orgOrIndRow : Config msg -> List (Html msg)
orgOrIndRow { maybeOrgOrInd, disabled } =
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
            [ OrgOrInd.row (toMsg maybeOrgOrInd) (toData maybeOrgOrInd) disabled ]
        ]
    ]


employerOccupationRow : Config msg -> Html msg
employerOccupationRow { occupation, employer, disabled } =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText (toMsg employer) (toData employer) disabled "createContribEmployerName" "Employer Name" ]
        , Grid.col
            []
            [ inputText (toMsg occupation) (toData occupation) disabled "createContribOccupation" "Occupation" ]
        ]


employmentStatusRows : Config msg -> List (Html msg)
employmentStatusRows { employmentStatus, disabled, txnId } =
    let
        maybeEmploymentMsg =
            toMsg employmentStatus

        employmentMsg =
            Just >> maybeEmploymentMsg
    in
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
            employmentRadioList employmentMsg (toData employmentStatus) disabled txnId
        ]
    ]
