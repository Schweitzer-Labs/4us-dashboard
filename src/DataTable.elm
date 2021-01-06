module DataTable exposing (view)

import Bootstrap.Table as Table exposing (Cell)
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class)



view : List String -> (a -> (List (String, Html msg))) -> List a -> Html msg
view labels mapper data = Table.table
    { options =
        [ Table.attr <| class "main-table border-left"
        , Table.striped, Table.hover]
    , thead = Table.thead
              []
              <| List.singleton
              <| Table.tr []
              <| List.map stickyTh
                  labels
    , tbody = Table.tbody []
        <| List.map dataRow <| List.map mapper data
    }

stickyTh : String -> Cell msg
stickyTh label = Table.th [Table.cellAttr <| class "sticky-top sticky-th bg-white shadow-sm"] [ text label ]

dataRow : List (String, (Html msg)) -> Table.Row msg
dataRow data =
    Table.tr []
        <| List.map (\(label, content) ->
            Table.td [ Table.cellAttr <| Spacing.p3] [ content ]) data
