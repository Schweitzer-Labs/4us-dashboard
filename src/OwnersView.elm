module OwnersView exposing (Model, Msg, init, view)

import Address
import AppInput exposing (inputText)
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
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Owner exposing (Owner, Owners)



-- MODEL


type alias Config msg =
    { ownerFirstName : DataMsg.MsgString msg
    , ownerLastName : DataMsg.MsgString msg
    , ownerAddressLine1 : DataMsg.MsgString msg
    , ownerAddressLine2 : DataMsg.MsgString msg
    , ownerCity : DataMsg.MsgString msg
    , ownerState : DataMsg.MsgString msg
    , ownerPostalCode : DataMsg.MsgString msg
    , owners : DataMsg.MsgOwner msg
    , ownerOwnership : DataMsg.MsgString msg
    , disabled : Bool
    }


type alias Model =
    { ownerFirstName : String
    , ownerLastName : String
    , ownerAddressLine1 : String
    , ownerAddressLine2 : String
    , ownerCity : String
    , ownerState : String
    , ownerPostalCode : String
    , owners : Owners
    , ownerOwnership : String
    , disabled : Bool
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
                    , percentOwnership = model.ownerOwnership
                    }
            in
            ( { model | owners = model.owners ++ [ newOwner ] }, Cmd.none )

        OwnerOwnershipUpdated str ->
            ( { model | ownerOwnership = str }, Cmd.none )

        OwnerDeleted str ->
            let
                newOwnersList =
                    List.filter (\o -> str == getOwnerFullName o) model.owners
            in
            ( { model | owners = newOwnersList }, Cmd.none )


init : Owners -> Model
init owners =
    { ownerFirstName = ""
    , ownerLastName = ""
    , ownerAddressLine1 = ""
    , ownerAddressLine2 = ""
    , ownerCity = ""
    , ownerState = ""
    , ownerPostalCode = ""
    , owners = owners
    , ownerOwnership = ""
    , disabled = False
    }



--- VIEW


view : Model -> List (Html Msg)
view model =
    ownersForm
        { ownerFirstName = ( model.ownerFirstName, OwnerFirstNameUpdated )
        , ownerLastName = ( model.ownerLastName, OwnerLastNameUpdated )
        , ownerAddressLine1 = ( model.ownerAddressLine1, OwnerAddressLine1Updated )
        , ownerAddressLine2 = ( model.ownerAddressLine2, OwnerAddressLine2Updated )
        , ownerCity = ( model.ownerCity, OwnerCityUpdated )
        , ownerState = ( model.ownerState, OwnerStateUpdated )
        , ownerPostalCode = ( model.ownerPostalCode, OwnerPostalCodeUpdated )
        , owners = ( model.owners, OwnersUpdate )
        , disabled = model.disabled
        , ownerOwnership = ( model.ownerOwnership, OwnerOwnershipUpdated )
        }


ownersForm : Config msg -> List (Html msg)
ownersForm c =
    [ Grid.row [ Row.attrs [ Spacing.mt3, Spacing.mb3 ] ]
        [ Grid.col [] [ Copy.llcDialogue ]
        ]
    ]
        ++ [ ownersGrid c ]
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3 ] ]
                [ Grid.col
                    []
                    [ inputText (toMsg c.ownerFirstName) "First Name" (toData c.ownerFirstName) c.disabled ]
                , Grid.col
                    []
                    [ inputText (toMsg c.ownerLastName) "Last Name" (toData c.ownerLastName) c.disabled ]
                ]
           ]
        ++ ownerAddressRows c
        ++ ownerPercentOwnershipRow
        ++ [ Grid.row
                [ Row.attrs [ Spacing.mt3, Spacing.mr4 ] ]
                [ Grid.col
                    [ Col.xs4, Col.offsetXs9 ]
                    [ Button.button [ Button.success, Button.onClick (toMsg c.owners) ] [ text "Add Another Member" ] ]
                ]
           ]


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
        { addressLine1 = c.ownerAddressLine1
        , addressLine2 = c.ownerAddressLine2
        , city = c.ownerCity
        , state = c.ownerState
        , postalCode = c.ownerPostalCode
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
