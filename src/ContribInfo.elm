module ContribInfo exposing (Config, ContribValidatorModel, validateModel, view)

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
import Errors exposing (fromEmailAddress, fromInKindType, fromOrgType, fromPhoneNumber, fromPostalCode)
import Html exposing (Html, div, h5, h6, span, text)
import Html.Attributes exposing (class, for)
import Html.Events exposing (onClick)
import InKindType exposing (Model(..))
import MonthSelector
import OrgOrInd
import Owners
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
    }


contribInfoValidator : Validator String ContribValidatorModel
contribInfoValidator =
    Validate.firstError
        [ ifBlank .amount "Payment Amount is missing"
        , ifBlank .paymentDate "Payment Date is missing"
        , ifNothing .paymentMethod "Processing Info is missing"
        , ifBlank .firstName "First Name is missing"
        , ifBlank .lastName "Last name is missing"
        , ifBlank .city "City is missing"
        , ifBlank .state "State is missing"
        , ifBlank .postalCode "Postal Code is missing."
        , ifBlank .addressLine1 "Address is missing"
        , postalCodeValidator
        , inKindTypeValidator
        , orgTypeValidator
        , emailValidator
        , phoneValidator
        ]


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


inKindTypeValidator : Validator String ContribValidatorModel
inKindTypeValidator =
    fromErrors inKindTypeOnModelToErrors


orgTypeValidator : Validator String ContribValidatorModel
orgTypeValidator =
    fromErrors orgTypeOnModelToErrors


emailValidator : Validator String ContribValidatorModel
emailValidator =
    fromErrors emailAddressOnModelToErrors


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


inKindTypeOnModelToErrors : ContribValidatorModel -> List String
inKindTypeOnModelToErrors { paymentMethod, inKindType, inKindDesc } =
    fromInKindType paymentMethod inKindType inKindDesc


orgTypeOnModelToErrors : ContribValidatorModel -> List String
orgTypeOnModelToErrors { maybeOrgOrInd, maybeEntityType } =
    fromOrgType maybeOrgOrInd maybeEntityType


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
amountDateRow { amount, paymentDate, disabled } =
    AmountDate.view
        { amount = ( toData amount, toMsg amount )
        , paymentDate = ( toData paymentDate, toMsg paymentDate )
        , disabled = disabled
        }


checkRow : Config msg -> List (Html msg)
checkRow { checkNumber, disabled } =
    [ Grid.row [ Row.attrs [ Spacing.mt3, class "fade-in" ] ]
        [ Grid.col
            []
            [ Input.text
                [ Input.id "check-number"
                , Input.onInput <| toMsg checkNumber
                , Input.value <| toData checkNumber
                , Input.placeholder "Enter check number"
                , Input.disabled disabled
                ]
            ]
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
                        ++ [ inputText (toMsg inKindDesc) "Description" (toData inKindDesc) disabled ]
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
                , Input.value <| toData cardNumber
                , Input.placeholder "Card number"
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


editRow : msg -> List (Html msg)
editRow msg =
    [ Grid.row [ Row.attrs [ class "fade-in" ] ]
        [ Grid.col
            []
            [ text "Edit Info"
            , span [ class "hover-underline hover-pointer", Spacing.ml2, onClick msg ]
                [ Asset.editGlyph []
                ]
            ]
        ]
    ]


entityToOrgOrInd : EntityType.Model -> OrgOrInd.Model
entityToOrgOrInd entityType =
    case entityType of
        EntityType.Family ->
            OrgOrInd.Ind

        EntityType.Individual ->
            OrgOrInd.Ind

        _ ->
            OrgOrInd.Org


donorInfoRows : Config msg -> List (Html msg)
donorInfoRows model =
    let
        formRows =
            case toData model.maybeOrgOrInd of
                Just OrgOrInd.Org ->
                    orgRows model ++ piiRows model

                Just OrgOrInd.Ind ->
                    piiRows model ++ employmentRows model ++ familyRow model

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



--manageOwnerRows : Config msg -> List (Html msg)
--manageOwnerRows c =
--    let
--        tableBody =
--            Table.tbody [] <|
--                List.map
--                    (\owner ->
--                        Table.tr []
--                            [ Table.td [] [ text <| toData c.ownerName ]
--                            , Table.td [] [ text <| toData c.ownerOwnership ]
--                            ]
--                    )
--                    <| toData c.owners
--
--        tableHead =
--            Table.simpleThead
--                [ Table.th [] [ text "Name" ]
--                , Table.th [] [ text "Percent Ownership" ]
--                ]
--
--        capTable =
--            if List.length (toData c.owners) > 0 then
--                [ Table.simpleTable ( tableHead, tableBody ) ]
--
--            else
--                []
--    in
--    [ Grid.row
--        [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
--        [ Grid.col
--            []
--            [ text "Please specify the current ownership breakdown of your company."
--            ]
--        ]
--    , Grid.row
--        [ Row.attrs [ Spacing.mb3 ] ]
--        [ Grid.col
--            []
--            [ text "*Total percent ownership must equal 100%"
--            ]
--        ]
--    ]
--        ++ capTable
--        ++ [ Grid.row
--                [ Row.attrs [ Spacing.mt3 ] ]
--                [ Grid.col
--                    []
--                    [ inputText OwnerNameUpdated "Owners Name" model.ownerName
--                    ]
--                , Grid.col
--                    []
--                    [ inputText OwnerOwnershipUpdated "Percent Ownership" model.ownerOwnership ]
--                ]
--           , Grid.row
--                [ Row.attrs [ Spacing.mt3 ] ]
--                [ Grid.col
--                    [ Col.xs6, Col.offsetXs6 ]
--                    [ submitButton "Add another member" OwnerAdded False False ]
--                ]
--           ]
--isLLCDonor : Config msg -> Bool
--isLLCDonor con =
--    Maybe.withDefault False (Maybe.map EntityType.isLLC model.maybeEntityType)


orgRows : Config msg -> List (Html msg)
orgRows c =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ EntityType.orgView (toMsg c.maybeEntityType) (toData c.maybeEntityType) c.disabled ]
        ]
    ]
        ++ (if toData c.maybeEntityType == Just EntityType.LimitedLiabilityCompany then
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
                    [ Input.text
                        [ Input.onInput <| toMsg c.entityName
                        , Input.placeholder "Organization Name"
                        , Input.value <| toData c.entityName
                        , Input.disabled c.disabled
                        ]
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
        }


piiRows : Config msg -> List (Html msg)
piiRows c =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputEmail (toMsg c.emailAddress) "Email Address" (toData c.emailAddress) c.disabled ]
        , Grid.col
            []
            [ inputText (toMsg c.phoneNumber) "Phone Number" (toData c.phoneNumber) c.disabled ]
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ inputText (toMsg c.firstName) "First Name" (toData c.firstName) c.disabled ]
        , Grid.col
            []
            [ inputText (toMsg c.lastName) "Last Name" (toData c.lastName) c.disabled ]
        ]
    ]
        ++ addressRows c



-- Maybe EntityType -> Msg
-- EntityType -> Msg
-- a -> b, b -> c


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


attestsToBeingAnAdultCitizenRow : Config msg -> List (Html msg)
attestsToBeingAnAdultCitizenRow { maybeEntityType, disabled, txnId } =
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
            EntityType.familyRadioList (Just >> toMsg maybeEntityType) (toData maybeEntityType) disabled txnId
        ]
    ]



-- Maybe OrgOrInd -> msg
-- Maybe EntityType


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
            [ inputText (toMsg employer) "Employer Name" (toData employer) disabled ]
        , Grid.col
            []
            [ inputText (toMsg occupation) "Occupation" (toData occupation) disabled ]
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
