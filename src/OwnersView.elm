module OwnersView exposing (Model, Msg, init, toMaybeOwners, update, view)

import Address
import AppInput exposing (inputNumber, inputText)
import Asset
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Table as Table exposing (Cell, TBody, THead)
import Bootstrap.Utilities.Spacing as Spacing
import Copy
import DataTable exposing (DataRow)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Owners as Owner exposing (Owner, Owners)
import Validate exposing (validate)



-- MODEL


type alias Model =
    { firstName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , percentOwnership : String
    , owners : Owners
    , disabled : Bool
    , isFormEnabled : Bool
    , currentOwner : Owner
    , errors : List String
    , formType : Maybe FormType
    }


type Msg
    = OwnerFirstNameUpdated String
    | OwnerLastNameUpdated String
    | OwnerAddressLine1Updated String
    | OwnerAddressLine2Updated String
    | OwnerCityUpdated String
    | OwnerStateUpdated String
    | OwnerPostalCodeUpdated String
    | OwnerOwnershipUpdated String
    | OwnersUpdate
    | OwnerDeleted Owner
    | EditOwner Owner
    | AddOwner
    | ToggleOwnerForm (Maybe FormType)
    | NoOp


type FormType
    = EditingOwner
    | CreatingOwner



--- UPDATE


update msg model =
    case msg of
        AddOwner ->
            let
                newOwner =
                    { firstName = model.firstName
                    , lastName = model.lastName
                    , addressLine1 = model.addressLine1
                    , addressLine2 = model.addressLine2
                    , city = model.city
                    , state = model.state
                    , postalCode = model.postalCode
                    , percentOwnership = model.percentOwnership
                    }
            in
            case validate Owner.validator newOwner of
                Err messages ->
                    ( { model | errors = messages }, Cmd.none )

                _ ->
                    let
                        totalPercentage =
                            Owner.foldOwnership model.owners + Owner.ownershipToFloat newOwner
                    in
                    if totalPercentage > 100 then
                        let
                            remainder =
                                String.fromFloat <| Owner.ownershipToFloat newOwner - (totalPercentage - 100)
                        in
                        ( { model | errors = [ "Ownership percentage total must add up to 100%. You have " ++ remainder ++ "% left to attribute." ] }, Cmd.none )

                    else
                        ( { model
                            | owners = model.owners ++ [ newOwner ]
                            , percentOwnership = ""
                            , firstName = ""
                            , lastName = ""
                            , addressLine1 = ""
                            , addressLine2 = ""
                            , city = ""
                            , state = ""
                            , postalCode = ""
                            , errors = []
                            , isFormEnabled = False
                          }
                        , Cmd.none
                        )

        OwnerFirstNameUpdated str ->
            ( { model | firstName = str }, Cmd.none )

        OwnerLastNameUpdated str ->
            ( { model | lastName = str }, Cmd.none )

        OwnerAddressLine1Updated str ->
            ( { model | addressLine1 = str }, Cmd.none )

        OwnerAddressLine2Updated str ->
            ( { model | addressLine2 = str }, Cmd.none )

        OwnerPostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        OwnerCityUpdated str ->
            ( { model | city = str }, Cmd.none )

        OwnerStateUpdated str ->
            ( { model | state = str }, Cmd.none )

        OwnersUpdate ->
            let
                newOwner =
                    { firstName = model.firstName
                    , lastName = model.lastName
                    , addressLine1 = model.addressLine1
                    , addressLine2 = model.addressLine2
                    , city = model.city
                    , state = model.state
                    , postalCode = model.postalCode
                    , percentOwnership = model.percentOwnership
                    }

                state =
                    editOwnerInfo newOwner model

                stateWithClearForm =
                    clearForm state
            in
            ( { stateWithClearForm | isFormEnabled = False }, Cmd.none )

        OwnerOwnershipUpdated str ->
            ( { model | percentOwnership = str }, Cmd.none )

        OwnerDeleted deletedOwner ->
            let
                newOwners =
                    List.filter (\owner -> Owner.toHash owner /= Owner.toHash deletedOwner) model.owners

                state =
                    clearForm model
            in
            ( { state | owners = newOwners }, Cmd.none )

        EditOwner owner ->
            let
                state =
                    setEditOwner model owner
            in
            ( { state | formType = Just EditingOwner }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ToggleOwnerForm form ->
            let
                state =
                    clearForm model
            in
            ( { state | isFormEnabled = not model.isFormEnabled, formType = form }, Cmd.none )


init : Owners -> Model
init owners =
    { firstName = ""
    , lastName = ""
    , addressLine1 = ""
    , addressLine2 = ""
    , city = ""
    , state = ""
    , postalCode = ""
    , percentOwnership = ""
    , owners = owners
    , currentOwner =
        { firstName = ""
        , lastName = ""
        , addressLine1 = ""
        , addressLine2 = ""
        , city = ""
        , state = ""
        , postalCode = ""
        , percentOwnership = ""
        }
    , disabled = False
    , isFormEnabled = False
    , errors = []
    , formType = Nothing
    }


clearForm : Model -> Model
clearForm model =
    { model
        | firstName = ""
        , lastName = ""
        , addressLine1 = ""
        , addressLine2 = ""
        , city = ""
        , state = ""
        , postalCode = ""
        , percentOwnership = ""
    }


toMaybeOwners : Model -> Maybe Owners
toMaybeOwners model =
    if model.owners == [] then
        Nothing

    else
        Just model.owners



--- VIEW


view : Model -> Html Msg
view model =
    div [ Spacing.mt3, Spacing.mb4, class "border rounded", Spacing.p2, Spacing.pl4, Spacing.pr4 ] <|
        []
            ++ errorMessages model.errors
            ++ [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
                    [ Grid.col [] [ Copy.llcDialogue model.disabled ]
                    ]
               ]
            ++ (if model.disabled then
                    []

                else
                    [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
                        [ Grid.col [] [ addOwnerButton ]
                        ]
                    ]
               )
            ++ [ capTable model ]
            ++ (if model.isFormEnabled then
                    [ Grid.row
                        [ Row.attrs [ Spacing.mt3 ] ]
                        [ Grid.col
                            []
                            [ inputText OwnerFirstNameUpdated model.firstName model.disabled "createOwnerFirstName" "First Name" ]
                        , Grid.col
                            []
                            [ inputText OwnerLastNameUpdated model.lastName model.disabled "createOwnerLastName" "Last Name" ]
                        ]
                    ]
                        ++ ownerAddressRows model
                        ++ [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
                                [ Grid.col []
                                    [ inputNumber
                                        OwnerOwnershipUpdated
                                        model.percentOwnership
                                        model.disabled
                                        "createOwnerPercent"
                                        "Percent Ownership"
                                    ]
                                ]
                           ]

                else
                    []
               )
            ++ (case model.isFormEnabled of
                    False ->
                        []

                    True ->
                        case model.formType of
                            Just EditingOwner ->
                                [ Grid.row
                                    [ Row.betweenXs, Row.attrs [ Spacing.mt3 ] ]
                                    [ Grid.col [ Col.xs4, Col.attrs [ Spacing.mb3 ] ]
                                        (cancelButton (ToggleOwnerForm Nothing) False "Cancel")
                                    , Grid.col [ Col.xs2, Col.attrs [ Spacing.mb3 ] ]
                                        (saveButton OwnersUpdate model model.disabled "Save")
                                    ]
                                ]

                            Just CreatingOwner ->
                                [ Grid.row
                                    [ Row.betweenXs, Row.attrs [ Spacing.mt3 ] ]
                                    [ Grid.col [ Col.xs4, Col.attrs [ Spacing.mb3 ] ]
                                        (cancelButton (ToggleOwnerForm Nothing) False "Cancel")
                                    , Grid.col [ Col.xs3, Col.attrs [ Spacing.mb3 ] ]
                                        (ownersSubmitButton AddOwner "Add Member")
                                    ]
                                ]

                            Nothing ->
                                []
               )


errorMessages : List String -> List (Html Msg)
errorMessages errors =
    if List.length errors == 0 then
        []

    else
        [ Grid.containerFluid
            []
            [ Grid.row
                []
                [ Grid.col
                    []
                  <|
                    List.map (\error -> div [ class "text-danger list-unstyled mt-2" ] [ text error ]) errors
                ]
            ]
        ]


ownerAddressRows : Model -> List (Html Msg)
ownerAddressRows model =
    Address.view
        { addressLine1 = ( model.addressLine1, OwnerAddressLine1Updated )
        , addressLine2 = ( model.addressLine2, OwnerAddressLine2Updated )
        , city = ( model.city, OwnerCityUpdated )
        , state = ( model.state, OwnerStateUpdated )
        , postalCode = ( model.postalCode, OwnerPostalCodeUpdated )
        , disabled = model.disabled
        , id = "createOwner"
        }


capTable : Model -> Html Msg
capTable model =
    if List.length model.owners > 0 then
        div [] [ Table.simpleTable ( tableHead, tableBody model ) ]

    else
        div [] []


tableHead : THead msg
tableHead =
    Table.simpleThead
        [ Table.th [] [ text "Name" ]
        , Table.th [] [ text "Percent Ownership" ]
        , emptyTableHead
        , emptyTableHead
        ]


tableBody : Model -> TBody Msg
tableBody model =
    Table.tbody [] <|
        List.map
            (\owner ->
                Table.tr []
                    [ Table.td [] [ text <| Owner.getOwnerFullName owner ]
                    , Table.td [] [ text owner.percentOwnership ]
                    , Table.td []
                        [ if model.disabled then
                            text ""

                          else
                            span
                                [ onClick <| EditOwner owner
                                ]
                                [ Asset.editGlyph [ class "hover-pointer" ] ]
                        ]
                    , Table.td []
                        [ if model.disabled then
                            text ""

                          else
                            span
                                [ onClick <| OwnerDeleted owner
                                ]
                                [ Asset.deleteGlyph [ class "text-danger hover-pointer" ] ]
                        ]
                    ]
            )
            model.owners


emptyTableHead : Cell msg
emptyTableHead =
    Table.th [] [ text "" ]


setEditOwner : Model -> Owner -> Model
setEditOwner model owner =
    { model
        | firstName = owner.firstName
        , lastName = owner.lastName
        , addressLine1 = owner.addressLine1
        , addressLine2 = owner.addressLine2
        , city = owner.city
        , state = owner.state
        , postalCode = owner.postalCode
        , owners = model.owners
        , percentOwnership = owner.percentOwnership
        , isFormEnabled = True
        , currentOwner = owner
    }


editOwnerInfo : Owner -> Model -> Model
editOwnerInfo newOwnerInfo model =
    { model
        | owners =
            List.map
                (\owner ->
                    if Owner.toHash owner == Owner.toHash model.currentOwner then
                        newOwnerInfo

                    else
                        owner
                )
                model.owners
        , isFormEnabled = False
    }


ownersSubmitButton : Msg -> String -> List (Html Msg)
ownersSubmitButton msg btnName =
    [ Button.button
        [ Button.success
        , Button.onClick msg
        , Button.disabled False
        , Button.block
        ]
        [ text btnName ]
    ]


saveButton : Msg -> Model -> Bool -> String -> List (Html Msg)
saveButton msg model disabled btnName =
    let
        totalOwnership =
            Owner.foldOwnership model.owners + (Maybe.withDefault 0 <| String.toFloat model.percentOwnership)

        disabledSave =
            (totalOwnership - Owner.ownershipToFloat model.currentOwner) > 100
    in
    [ Button.button
        [ Button.success
        , Button.onClick msg
        , Button.disabled (disabled || disabledSave)
        ]
        [ text btnName ]
    ]


cancelButton : Msg -> Bool -> String -> List (Html Msg)
cancelButton msg disabled btnName =
    [ Button.button
        [ Button.success
        , Button.onClick msg
        , Button.disabled disabled
        , Button.outlinePrimary
        ]
        [ text btnName ]
    ]


addOwnerButton : Html Msg
addOwnerButton =
    div [ Spacing.mt4, class "text-slate-blue font-size-medium hover-underline hover-pointer", onClick (ToggleOwnerForm (Just CreatingOwner)) ]
        [ Asset.plusCircleGlyph [ class "text-slate-blue font-size-22" ]
        , span [ Spacing.ml1, class "align-middle", attribute "data-cy" "addOwner" ] [ text "Add Owner" ]
        ]
