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
import Html.Attributes exposing (class)
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
    , isOwnerEditable : Bool
    , currentOwner : Owner
    , errors : List String
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
    | ToggleEditOwner Owner
    | AddOwner
    | NoOp



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
                        ( { model | errors = [ "Ownership percentage total must add up to 100%. Please add " ++ remainder ++ "% instead." ] }, Cmd.none )

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
            ( { stateWithClearForm | isOwnerEditable = False }, Cmd.none )

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

        ToggleEditOwner owner ->
            let
                state =
                    setEditOwner model owner
            in
            ( state, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


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
    , isOwnerEditable = False
    , errors = []
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
    div [] <|
        []
            ++ errorMessages model.errors
            ++ [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
                    [ Grid.col [] [ Copy.llcDialogue ]
                    ]
               ]
            ++ [ capTable model ]
            ++ (if model.disabled then
                    []

                else
                    [ Grid.row
                        [ Row.attrs [ Spacing.mt3 ] ]
                        [ Grid.col
                            []
                            [ inputText OwnerFirstNameUpdated "First Name" model.firstName model.disabled "createOwnerFirstName"
                            ]
                        , Grid.col
                            []
                            [ inputText OwnerLastNameUpdated "Last Name" model.lastName model.disabled "createContribLastName" ]
                        ]
                    ]
                        ++ ownerAddressRows model
                        ++ [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
                                [ Grid.col []
                                    [ inputNumber OwnerOwnershipUpdated "Percent Ownership" model.percentOwnership model.disabled "createOwnerEmail"
                                    ]
                                ]
                           ]
               )
            ++ (case model.isOwnerEditable of
                    False ->
                        if model.disabled then
                            []

                        else
                            [ Grid.row
                                [ Row.attrs [ Spacing.mt3, Spacing.mr4 ] ]
                                [ Grid.col
                                    [ Col.xs4, Col.offsetXs9 ]
                                    [ Button.button
                                        [ Button.success
                                        , Button.onClick AddOwner
                                        , Button.disabled model.disabled
                                        ]
                                        [ text "Add Another Member" ]
                                    ]
                                ]
                            ]

                    True ->
                        [ Grid.row
                            [ Row.attrs [ Spacing.mt3 ] ]
                            [ Grid.col
                                [ Col.offsetXs10 ]
                                [ Button.button
                                    [ Button.success
                                    , Button.onClick OwnersUpdate
                                    , Button.disabled model.disabled
                                    ]
                                    [ text "Save" ]
                                ]
                            ]
                        ]
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
                                [ onClick <| ToggleEditOwner owner
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
        , isOwnerEditable = True
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
        , isOwnerEditable = False
    }
