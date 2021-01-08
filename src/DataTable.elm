module DataTable exposing (view)

import Bootstrap.Table as Table exposing (Cell)
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class)



type alias Actions msg = List (Html msg)

type alias Labels = List String

type alias DataRow msg = (List (String, Html msg))

view : Actions msg -> Labels -> (a -> DataRow msg) -> List a -> Html msg
view actions labels mapper data = Table.table
    { options =
        [ Table.attr <| class "main-table border-left"
        , Table.striped, Table.hover]
    , thead = Table.thead
              [ ] <|
              (if List.isEmpty actions then [] else [actionsRow actions]) ++ [ labelRow labels ]
    , tbody = Table.tbody []
        <| List.map dataRow <| List.map mapper data
    }

stickyTh : String -> Cell msg
stickyTh label = Table.th [Table.cellAttr <| class "sticky-top sticky-th bg-white shadow-sm"] [ text label ]

labelRow : Labels -> Table.Row msg
labelRow labels = Table.tr [] <| List.map stickyTh labels

actionsRow : List (Html msg) -> Table.Row msg
actionsRow content = Table.tr [] [Table.th [] content]


dataRow : List (String, (Html msg)) -> Table.Row msg
dataRow data =
    Table.tr []
        <| List.map (\(label, content) ->
            Table.td [ Table.cellAttr <| Spacing.p3] [ content ]) data


