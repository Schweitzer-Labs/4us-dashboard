module DataTable exposing (DataRow, view)

import Bootstrap.Table as Table exposing (Cell)
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, img, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type alias Actions msg =
    List (Html msg)


type alias Labels msg =
    List ( msg, String )


type alias DataRow msg =
    List ( String, Html msg )


view :
    Actions msg
    -> Labels msg
    -> (( Maybe msg, a ) -> ( Maybe msg, DataRow msg ))
    -> List ( Maybe msg, a )
    -> Html msg
view actions labels mapper data =
    Table.table
        { options =
            [ Table.attr <| class "main-table border-left"
            , Table.striped
            , Table.hover
            ]
        , thead =
            Table.thead
                []
            <|
                (if List.isEmpty actions then
                    []

                 else
                    [ actionsRow actions ]
                )
                    ++ [ labelRow labels ]
        , tbody =
            Table.tbody [] <| List.map dataRow <| List.map mapper data
        }


stickyTh : ( msg, String ) -> Cell msg
stickyTh ( msg, str ) =
    Table.th
        [ Table.cellAttr <| class "bg-white shadow-sm hover-underline hover-pointer"
        , Table.cellAttr <| onClick msg
        ]
        [ text str ]


labelRow : Labels msg -> Table.Row msg
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
