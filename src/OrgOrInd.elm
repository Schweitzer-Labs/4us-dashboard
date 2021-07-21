module OrgOrInd exposing (Model(..), fromEntityType, row)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import EntityType
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, id)


type Model
    = Org
    | Ind


toString : Model -> String
toString orgOrInd =
    case orgOrInd of
        Org ->
            "Organization"

        Ind ->
            "Individual"


row : (Maybe Model -> msg) -> Maybe Model -> Bool -> Html msg
row msg currentValue disabled =
    Grid.row
        []
        [ Grid.col
            []
            [ selectButton msg (toString Ind) (Just Ind) currentValue disabled ]
        , Grid.col
            []
            [ selectButton msg (toString Org) (Just Org) currentValue disabled ]
        ]


selectButton : (a -> msg) -> String -> a -> a -> Bool -> Html msg
selectButton msg displayText value currentVal disabled =
    let
        selected =
            currentVal == value

        color =
            if selected then
                Button.success

            else
                Button.outlineSuccess
    in
    -- @Todo added div to change the structure for diffing.
    div
        []
        [ Button.button
            [ color
            , Button.attrs [ id displayText ]
            , Button.block
            , Button.attrs [ class "font-weight-bold border-round" ]
            , Button.onClick (msg value)
            , Button.disabled disabled
            ]
            [ text <| displayText ]
        ]


fromEntityType : EntityType.Model -> Model
fromEntityType entityType =
    case entityType of
        EntityType.Individual ->
            Ind

        EntityType.Family ->
            Ind

        _ ->
            Org
