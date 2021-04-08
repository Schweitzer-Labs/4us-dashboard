module FileDisclosure exposing (aggregateCol, aggregateRows, downloadRows, titleRows, view, warningRows)

import Aggregations
import AppDialogue
import Asset
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import File.Download as Download
import FileFormat exposing (FileFormat)
import Html exposing (Html, a, div, h2, h3, h4, h5, h6, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Route



--view : Html msg


type alias DropdownConfig msg =
    ( Dropdown.State -> msg, Dropdown.State )


view : Aggregations.Model -> DropdownConfig msg -> (FileFormat -> msg) -> Bool -> Html msg
view aggs dropdownConfig downloadMsg submitted =
    let
        summary =
            warningRows aggs ++ titleRows ++ aggregateRows aggs ++ downloadRows dropdownConfig downloadMsg

        rows =
            if submitted then
                successRows

            else
                summary
    in
    Grid.containerFluid
        []
        rows


successRows : List (Html msg)
successRows =
    [ h2 [ class "align-middle text-green", Spacing.p3 ] [ Asset.circleCheckGlyph [], span [ class "align-middle text-green", Spacing.ml3 ] [ text "Disclosure Submitted!" ] ]
    ]


warningRows : Aggregations.Model -> List (Html msg)
warningRows aggs =
    if aggs.needReviewCount == "0" then
        []

    else
        let
            transactionsAre =
                if aggs.needReviewCount == "1" then
                    " transaction is "

                else
                    " transactions are "

            errorMessage =
                aggs.needReviewCount ++ transactionsAre ++ " missing required disclosure fields"
        in
        [ Grid.row
            [ Row.attrs [] ]
            [ Grid.col
                []
                [ a [ Route.href Route.NeedsReview ] [ AppDialogue.warning <| text errorMessage ]
                ]
            ]
        ]


titleRows : List (Html msg)
titleRows =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            []
            [ h4 [] [ text "Summary for Current Period" ] ]
        ]
    ]


aggregateRows : Aggregations.Model -> List (Html msg)
aggregateRows aggs =
    [ Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ aggregateCol "Beginning Cash Balance" (Cents.toDollar "0")
        , aggregateCol "Ending Cash Balance" (Cents.toDollar aggs.balance)
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ aggregateCol "Total Contributions Received" (Cents.toDollar aggs.totalRaised)
        , aggregateCol "Total Expenditures" (Cents.toDollar aggs.totalSpent)
        ]
    ]


aggregateCol : String -> String -> Column msg
aggregateCol name data =
    Grid.col
        [ Col.attrs [ Spacing.mt3 ] ]
        [ div [ class "text-secondary font-weight-bold" ] [ text name ]
        , h5 [ class "font-weight-bold", Spacing.mt1 ] [ text data ]
        ]


downloadRows : DropdownConfig msg -> (FileFormat -> msg) -> List (Html msg)
downloadRows ( dropdownToggleMsg, dropdownState ) downloadMsg =
    let
        pdfMsg =
            downloadMsg FileFormat.PDF

        csvMsg =
            downloadMsg FileFormat.CSV
    in
    [ Grid.row
        [ Row.attrs [] ]
        [ Grid.col
            []
            [ Dropdown.dropdown
                dropdownState
                { options = []
                , toggleMsg = dropdownToggleMsg
                , toggleButton =
                    Dropdown.toggle [ Button.outlineSuccess, Button.attrs [ Spacing.mb3, Spacing.mt4 ] ] [ text "Download as " ]
                , items =
                    [ Dropdown.buttonItem [ onClick csvMsg ] [ text "CSV" ]
                    , Dropdown.buttonItem [ onClick pdfMsg ] [ text "PDF" ]
                    ]
                }
            ]
        ]
    ]
