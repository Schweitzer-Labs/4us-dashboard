module DataTable exposing (DataRow, view)

import Bootstrap.Table as Table exposing (Cell)
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Actions msg =
    List (Html msg)


type alias Labels =
    List String


type alias DataRow msg =
    List ( String, Html msg )


view :
    String
    -> List String
    -> (( Maybe b, Maybe msg, a ) -> ( Maybe msg, DataRow msg ))
    -> List ( Maybe b, Maybe msg, a )
    -> Html msg
view emptyCopy labels mapper data =
    let
        table =
            Table.table
                { options =
                    [ Table.attr <| class "main-table"
                    , Table.striped
                    , Table.hover
                    ]
                , thead =
                    Table.thead
                        []
                        [ labelRow labels ]
                , tbody =
                    Table.tbody [] <| List.map dataRow <| List.map mapper data
                }
    in
    if List.length data > 0 then
        table

    else
        div [] [ table, emptyText emptyCopy ]


emptyText : String -> Html msg
emptyText copy =
    div [ class "text-center", Spacing.mt5 ] [ text copy ]


stickyTh : String -> Cell msg
stickyTh str =
    Table.th
        [ Table.cellAttr <| class "bg-white shadow-sm"
        ]
        [ text str ]


labelRow : Labels -> Table.Row msg
labelRow labels =
    Table.tr [] <| List.map stickyTh labels


actionsRow : List (Html msg) -> Table.Row msg
actionsRow content =
    Table.tr [] [ Table.th [] content ]


dataRow : ( Maybe msg, DataRow msg ) -> Table.Row msg
dataRow ( maybeMsg, data ) =
    let
        actionAttr =
            case maybeMsg of
                Just action ->
                    [ Table.rowAttr <| onClick action, Table.rowAttr <| class "hover-pointer" ]

                Nothing ->
                    []
    in
    Table.tr actionAttr <|
        List.map
            (\( _, content ) ->
                Table.td
                    [ Table.cellAttr <| Spacing.p3 ]
                    [ content ]
            )
            data
