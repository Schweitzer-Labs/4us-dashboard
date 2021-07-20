module OrgOrInd exposing (OrgOrInd(..), row)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import EntityType exposing (EntityType)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, id)


type OrgOrInd
    = Org
    | Ind


toString : OrgOrInd -> String
toString orgOrInd =
    case orgOrInd of
        Org ->
            "Organization"

        Ind ->
            "Individual"


row : (Maybe EntityType -> msg) -> Maybe EntityType -> Html msg
row msg maybeEntityType =
    let
        orgOrIndStr =
            Maybe.withDefault "" <| Maybe.map EntityType.toOrgOrIndData maybeEntityType
    in
    Grid.row
        []
        [ Grid.col
            []
            [ selectButton msg "Individual" "Ind" orgOrIndStr ]
        , Grid.col
            []
            [ selectButton msg "Organization" "Org" orgOrIndStr ]
        ]


selectButton : (Maybe EntityType -> msg) -> String -> String -> String -> Html msg
selectButton msg displayText value currentVal =
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
            , Button.onClick (msg <| Just EntityType.Individual)
            ]
            [ text <| displayText ]
        ]
