module OrgOrInd exposing (OrgOrInd(..), row)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
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


row : (Maybe OrgOrInd -> msg) -> Maybe OrgOrInd -> Html msg
row msg currentValue =
    Grid.row
        []
        [ Grid.col
            []
            [ selectButton msg (toString Ind) (Just Ind) currentValue ]
        , Grid.col
            []
            [ selectButton msg (toString Org) (Just Org) currentValue ]
        ]


selectButton : (a -> msg) -> String -> a -> a -> Html msg
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
            , Button.onClick (msg value)
            ]
            [ text <| displayText ]
        ]
