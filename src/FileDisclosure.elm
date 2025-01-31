module FileDisclosure exposing (aggregateCol, aggregateRows, downloadRows, titleRows, view, warningRows)

import Aggregations
import AppDialogue
import Asset
import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Cents
import Csv.Decode as Decode exposing (FieldNames(..), string)
import DataTable exposing (DataRow)
import DiscCsv
import File.Download as Download
import FileFormat exposing (FileFormat)
import Html exposing (Html, a, div, h2, h3, h4, h5, h6, p, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Route
import SubmitButton



--view : Html msg


type alias DropdownConfig msg =
    ( Dropdown.State -> msg, Dropdown.State )


view : Aggregations.Model -> DropdownConfig msg -> DropdownConfig msg -> (FileFormat -> Bool -> msg) -> msg -> Bool -> Maybe String -> msg -> Html msg
view aggs dropdownDownloadConfig dropdownPreviewConfig downloadMsg goToNeedsReviewMsg submitted preview backMsg =
    case preview of
        Just a ->
            let
                decodedCsv =
                    Decode.decodeCsv Decode.FieldNamesFromFirstRow DiscCsv.decoder a
            in
            case decodedCsv of
                Ok value ->
                    Grid.row []
                        [ Grid.col []
                            [ Grid.row [ Row.attrs [ Spacing.mb2 ] ]
                                [ Grid.col [ Col.sm2 ] [ backButton backMsg ]
                                ]
                            , Grid.row [] [ Grid.col [] [ DataTable.view "" DiscCsv.labels DiscCsv.disclosureRowMap <| List.map (\d -> ( Nothing, Nothing, d )) value ] ]
                            ]
                        ]

                Err error ->
                    text "Awaiting Verified Transactions"

        Nothing ->
            let
                summary =
                    warningRows goToNeedsReviewMsg aggs ++ titleRows ++ aggregateRows aggs ++ downloadRows dropdownDownloadConfig dropdownPreviewConfig downloadMsg

                rows =
                    if submitted then
                        successRows

                    else
                        summary
            in
            Grid.containerFluid
                []
                rows


backButton : msg -> Html msg
backButton backMsg =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick backMsg ]
        ]
        [ text "Back" ]


successRows : List (Html msg)
successRows =
    [ h2 [ class "align-middle text-green", Spacing.p3 ] [ Asset.circleCheckGlyph [], span [ class "align-middle text-green", Spacing.ml3 ] [ text "Disclosure Submitted!" ] ]
    ]


warningRows : msg -> Aggregations.Model -> List (Html msg)
warningRows goToNeedsReviewMsg aggs =
    if aggs.needsReviewCount == 0 then
        []

    else
        let
            transactionsAre =
                if aggs.needsReviewCount == 1 then
                    " transaction needs "

                else
                    " transactions need "

            errorMessage =
                String.fromInt aggs.needsReviewCount ++ transactionsAre ++ " to be reviewed."
        in
        [ Grid.row
            [ Row.attrs [] ]
            [ Grid.col
                []
                [ span [ onClick goToNeedsReviewMsg, class "hover-underline-red hover-pointer" ] [ AppDialogue.warning <| text errorMessage ]
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
        [ aggregateCol "Beginning Cash Balance" (Cents.stringToDollar "0")
        , aggregateCol "Ending Cash Balance" (Cents.stringToDollar (String.fromInt aggs.balance))
        ]
    , Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ aggregateCol "Total Contributions Received" (Cents.stringToDollar (String.fromInt aggs.totalRaised))
        , aggregateCol "Total Expenditures" (Cents.stringToDollar (String.fromInt aggs.totalSpent))
        ]
    ]


aggregateCol : String -> String -> Column msg
aggregateCol name data =
    Grid.col
        [ Col.attrs [ Spacing.mt3 ] ]
        [ div [ class "text-secondary font-weight-bold" ] [ text name ]
        , h5 [ class "font-weight-bold", Spacing.mt1 ] [ text data ]
        ]


downloadRows : DropdownConfig msg -> DropdownConfig msg -> (FileFormat -> Bool -> msg) -> List (Html msg)
downloadRows ( dropdownToggleDownloadMsg, dropdownDownloadState ) ( dropdownTogglePreviewMsg, dropdownTogglePreviewState ) downloadMsg =
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
                dropdownDownloadState
                { options = []
                , toggleMsg = dropdownToggleDownloadMsg
                , toggleButton =
                    Dropdown.toggle [ Button.outlineSuccess, Button.attrs [ Spacing.mb3, Spacing.mt4 ] ] [ text "Download as " ]
                , items =
                    [ Dropdown.buttonItem [ onClick (csvMsg False) ] [ text "CSV" ]

                    --, Dropdown.buttonItem [ onClick pdfMsg ] [ text "PDF" ]
                    ]
                }
            , Dropdown.dropdown
                dropdownTogglePreviewState
                { options = []
                , toggleMsg = dropdownTogglePreviewMsg
                , toggleButton =
                    Dropdown.toggle [ Button.outlineSuccess, Button.attrs [ Spacing.mb3, Spacing.mt4, Spacing.ml2 ] ] [ text "Preview" ]
                , items =
                    [ Dropdown.buttonItem [ onClick (csvMsg True) ] [ text "CSV" ]

                    --, Dropdown.buttonItem [ onClick pdfMsg ] [ text "PDF" ]
                    ]
                }
            ]
        ]
    ]
