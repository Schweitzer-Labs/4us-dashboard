module ContribInfo exposing (Config, view)

import Address
import AmountDate
import AppInput exposing (inputEmail, inputText)
import Asset
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg exposing (toData, toMsg)
import EntityType exposing (EntityType)
import Html exposing (Html, div, h5, span, text)
import Html.Attributes exposing (class, for)
import Html.Events exposing (onClick)
import MonthSelector
import OrgOrInd exposing (OrgOrInd)
import PaymentMethod
import SelectRadio
import YearSelector


type alias Config msg =
    { checkNumber : DataMsg.MsgString msg
    , paymentDate : DataMsg.MsgString msg
    , paymentMethod : DataMsg.MsgString msg
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
    , employmentStatus : DataMsg.MsgString msg
    , employer : DataMsg.MsgString msg
    , occupation : DataMsg.MsgString msg
    , entityName : DataMsg.MsgString msg
    , maybeEntityType : DataMsg.MsgMaybeEntityType msg
    , cardNumber : DataMsg.MsgString msg
    , expirationMonth : DataMsg.MsgString msg
    , expirationYear : DataMsg.MsgString msg
    , cvv : DataMsg.MsgString msg
    , amount : DataMsg.MsgString msg
    , owners : DataMsg.MsgOwner msg
    , ownerName : DataMsg.MsgString msg
    , ownerOwnership : DataMsg.MsgString msg
    , disabled : Bool
    , isEditable : Bool
    , toggleEdit : msg
    , maybeError : Maybe String
    }


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


processingRow : Config msg -> List (Html msg)
processingRow c =
    case toData c.paymentMethod of
        "Check" ->
            checkRow c

        "Credit" ->
            creditRow c

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


view : Config msg -> Html msg
view c =
    Grid.containerFluid
        []
    <|
        []
            ++ errorRow c.maybeError
            ++ (if c.isEditable then
                    editRow c.toggleEdit

                else
                    labelRow "Payment Info"
               )
            ++ amountDateRow c
            ++ labelRow "Donor Info"
            ++ donorInfoRows c
            ++ (if c.isEditable then
                    []

                else
                    []
                        ++ labelRow "Processing Info"
                        ++ PaymentMethod.select (toMsg c.paymentMethod) (toData c.paymentMethod) c.disabled
                        ++ processingRow c
               )


entityToOrgOrInd : EntityType -> OrgOrInd
entityToOrgOrInd entityType =
    case entityType of
        EntityType.Family ->
            OrgOrInd.Ind

        EntityType.Individual ->
            OrgOrInd.Ind

        _ ->
            OrgOrInd.Org


maybeEntityTypeToMaybeOrgOrInd : Maybe EntityType -> Maybe OrgOrInd
maybeEntityTypeToMaybeOrgOrInd maybeEntityType =
    Maybe.map entityToOrgOrInd maybeEntityType


donorInfoRows : Config msg -> List (Html msg)
donorInfoRows model =
    let
        formRows =
            case maybeEntityTypeToMaybeOrgOrInd <| toData model.maybeEntityType of
                Just OrgOrInd.Org ->
                    orgRows model ++ piiRows model

                Just OrgOrInd.Ind ->
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
--                    [ inputText OwnerNameUpdated "Owner Name" model.ownerName
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
orgRows { maybeEntityType, entityName, disabled } =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ EntityType.orgView (toMsg maybeEntityType) (toData maybeEntityType) ]
        ]
    ]
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ Input.text
                        [ Input.onInput <| toMsg entityName
                        , Input.placeholder "Organization Name"
                        , Input.value <| toData entityName
                        , Input.disabled disabled
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
familyRow { maybeEntityType, disabled } =
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
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
          <|
            EntityType.familyRadioList entityMsg (toData maybeEntityType) disabled
        ]
    ]


attestsToBeingAnAdultCitizenRow : Config msg -> List (Html msg)
attestsToBeingAnAdultCitizenRow { maybeEntityType, disabled } =
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
            EntityType.familyRadioList (Just >> toMsg maybeEntityType) (toData maybeEntityType) disabled
        ]
    ]



-- Maybe OrgOrInd -> msg
-- Maybe EntityType


orgOrIndRow : Config msg -> List (Html msg)
orgOrIndRow { maybeEntityType, disabled } =
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
            [ OrgOrInd.row (toMsg maybeEntityType) (toData maybeEntityType) disabled ]
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
employmentStatusRows { employmentStatus, disabled } =
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
                [ SelectRadio.view (toMsg employmentStatus) "employed" "Employed" (toData employmentStatus) disabled
                , SelectRadio.view (toMsg employmentStatus) "unemployed" "Unemployed" (toData employmentStatus) disabled
                , SelectRadio.view (toMsg employmentStatus) "retired" "Retired" (toData employmentStatus) disabled
                , SelectRadio.view (toMsg employmentStatus) "self_employed" "Self Employed" (toData employmentStatus) disabled
                ]
        ]
    ]
