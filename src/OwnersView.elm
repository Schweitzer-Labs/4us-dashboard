module OwnersView exposing (Model, Msg, init, makeOwnersView, update, view)

import Address
import AppInput exposing (inputText)
import Array
import Asset
import Bootstrap.Button as Button
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Copy
import DataMsg exposing (toData, toMsg)
import DataTable exposing (DataRow)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Owners exposing (Owner, Owners)



-- MODEL


type alias Config msg =
    { firstName : DataMsg.MsgString msg
    , lastName : DataMsg.MsgString msg
    , addressLine1 : DataMsg.MsgString msg
    , addressLine2 : DataMsg.MsgString msg
    , city : DataMsg.MsgString msg
    , state : DataMsg.MsgString msg
    , postalCode : DataMsg.MsgString msg
    , percentOwnership : DataMsg.MsgString msg
    , owners : DataMsg.MsgOwner msg
    , disabled : Bool
    , isOwnerEditable : Bool
    }


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



--- VIEW


type alias MakeViewConfig msg subMsg subModel =
    { updateMsg : subMsg -> msg
    , subModel : subModel
    , subView : subModel -> Html subMsg
    }


makeOwnersView : MakeViewConfig msg subMsg model -> Html msg
makeOwnersView config =
    Html.map config.updateMsg <| config.subView config.subModel


view : Model -> Html Msg
view model =
    ownersFormRows
        { firstName = ( model.firstName, OwnerFirstNameUpdated )
        , lastName = ( model.lastName, OwnerLastNameUpdated )
        , addressLine1 = ( model.addressLine1, OwnerAddressLine1Updated )
        , addressLine2 = ( model.addressLine2, OwnerAddressLine2Updated )
        , city = ( model.city, OwnerCityUpdated )
        , state = ( model.state, OwnerStateUpdated )
        , postalCode = ( model.postalCode, OwnerPostalCodeUpdated )
        , owners = ( model.owners, OwnersUpdate )
        , percentOwnership = ( model.percentOwnership, OwnerOwnershipUpdated )
        , disabled = model.disabled
        , isOwnerEditable = model.isOwnerEditable
        }


ownersFormRows : Config msg -> Html msg
ownersFormRows c =
    div [] <|
        []
            ++ [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
                    [ Grid.col [] [ Copy.llcDialogue ]
                    ]
               ]
            ++ [ ownersGrid c ]
            ++ [ Grid.row
                    [ Row.attrs [ Spacing.mt3 ] ]
                    [ Grid.col
                        []
                        [ Input.text
                            [ Input.value <| toData c.firstName
                            , Input.onInput <| toMsg c.firstName
                            , Input.placeholder "First Name"
                            , Input.disabled c.disabled
                            ]
                        ]
                    , Grid.col
                        []
                        [ inputText (toMsg c.lastName) "Last Name" (toData c.lastName) c.disabled ]
                    ]
               ]
            ++ ownerAddressRows c
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


ownerAddressRows : Config msg -> List (Html msg)
ownerAddressRows c =
    Address.view
        { addressLine1 = c.addressLine1
        , addressLine2 = c.addressLine2
        , city = c.city
        , state = c.state
        , postalCode = c.postalCode
        , disabled = c.disabled
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


ownersGrid : Config msg -> Html msg
ownersGrid { owners } =
    let
        ownersList =
            toData owners

        msg =
            Just <| toMsg owners
    in
    Grid.row []
        [ Grid.col []
            [ if List.isEmpty ownersList then
                text ""

              else
                DataTable.view "" ownerLabels ownerRowMap <|
                    List.map (\d -> ( Nothing, msg, d )) <|
                        ownersList
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
