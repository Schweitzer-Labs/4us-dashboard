module OwnersView exposing (Model, Msg, init, toMaybeOwners, update, view)

import Address
import AppInput exposing (inputText)
import Asset
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Copy
import DataTable exposing (DataRow)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Owners exposing (Owner, Owners)



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
    | OwnerDeleted String
    | ToggleEditOwner Owner



--- UPDATE


update msg model =
    case msg of
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
                    case model.isOwnerEditable of
                        True ->
                            editOwnerInfo newOwner model

                        False ->
                            { model | owners = model.owners ++ [ newOwner ] }
            in
            ( state, Cmd.none )

        OwnerOwnershipUpdated str ->
            ( { model | percentOwnership = str }, Cmd.none )

        OwnerDeleted str ->
            let
                newOwnersList =
                    List.filter (\o -> str == getOwnerFullName o) model.owners
            in
            ( { model | owners = newOwnersList }, Cmd.none )

        ToggleEditOwner owner ->
            let
                state =
                    setEditOwner model owner
            in
            ( state, Cmd.none )


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
    , disabled = False
    , isOwnerEditable = False
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
            ++ [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
                    [ Grid.col [] [ Copy.llcDialogue ]
                    ]
               ]
            ++ [ ownersGrid model ]
            ++ [ Grid.row
                    [ Row.attrs [ Spacing.mt3 ] ]
                    [ Grid.col
                        []
                        [ Input.text
                            [ Input.value <| model.firstName
                            , Input.onInput <| OwnerFirstNameUpdated
                            , Input.placeholder "First Name"
                            , Input.disabled model.disabled
                            ]
                        ]
                    , Grid.col
                        []
                        [ inputText OwnerLastNameUpdated "Last Name" model.lastName model.disabled ]
                    ]
               ]
            ++ ownerAddressRows model
            ++ ownerPercentOwnershipRow



--
--
--++ [ Grid.row
--        [ Row.attrs [ Spacing.mt3, Spacing.mr4 ] ]
--        [ Grid.col
--            [ Col.xs4, Col.offsetXs9 ]
--            [ Button.button [ Button.success, Button.onClick (toMsg c.owners) ] [ text "Add Another Member" ] ]
--        ]


ownerPercentOwnershipRow : List (Html msg)
ownerPercentOwnershipRow =
    [ Grid.row [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col []
            [ Input.text
                [ Input.placeholder "Percent Ownership"
                , Input.disabled False
                ]
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
        }


ownerLabels : List String
ownerLabels =
    [ "Name"
    , "Percent Ownership"
    ]


ownerRowMap : ( Maybe a, Maybe msg, Owner ) -> ( Maybe msg, DataRow msg )
ownerRowMap ( _, maybeMsg, o ) =
    ( maybeMsg
    , [ ( "", text (getOwnerFullName o) )
      , ( "", text o.percentOwnership )
      , ( "", Asset.editGlyph [] )
      , ( "", Asset.deleteGlyph [ class "text-danger" ] )
      ]
    )


ownersGrid : Model -> Html Msg
ownersGrid model =
    Grid.row []
        [ Grid.col []
            [ if List.isEmpty model.owners then
                text ""

              else
                DataTable.view "" ownerLabels ownerRowMap <|
                    List.map (\d -> ( Nothing, Just OwnersUpdate, d )) <|
                        model.owners
            ]
        ]


getOwnerFullName : Owner -> String
getOwnerFullName owner =
    owner.firstName ++ " " ++ owner.lastName


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
    }


editOwnerInfo : Owner -> Model -> Model
editOwnerInfo newOwnerInfo model =
    let
        newOwnerName =
            getOwnerFullName newOwnerInfo
    in
    { model
        | owners =
            List.map
                (\owner ->
                    if getOwnerFullName owner == newOwnerName then
                        newOwnerInfo

                    else
                        owner
                )
                model.owners
        , isOwnerEditable = False
    }
