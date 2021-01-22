module Page exposing (Page(..), view)

import Aggregations
import Asset as Asset exposing (Image)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import Html exposing (Html, a, button, div, footer, h1, h2, h3, i, img, li, nav, p, span, text, ul)
import Html.Attributes as Attr exposing (class, classList, href, style)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Username exposing (Username)
import Viewer exposing (Viewer)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type Page
    = Other
    | Home
    | LinkBuilder
    | Disbursements
    | NeedsReview
    | Transactions
    | Login
    | Register
    | Settings
    | Profile Username
    | NewArticle


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Maybe Viewer -> Aggregations.Model -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer aggregations page { title, content } =
    { title = title ++ " - Transactions"
    , body =
        sidebar page :: mainContainer aggregations content :: []
    }


mainContainer : Aggregations.Model -> Html msg -> Html msg
mainContainer aggregations content =
    div [ class "main-container" ]
        [ header aggregations
        , contentContainer content
        ]


contentContainer : Html msg -> Html msg
contentContainer content =
    div [ Spacing.p5 ] [ content ]


header : Aggregations.Model -> Html msg
header aggregations =
    Grid.containerFluid
        [ Spacing.pt3, Spacing.pb3, class "header-container border-bottom border-blue align-middle" ]
        [ Grid.row [ Row.attrs [ class "align-middle align-items-center" ] ]
            [ Grid.col [ Col.xs10 ]
                [ Aggregations.view aggregations ]
            , Grid.col [ Col.attrs [ class "text-right" ] ]
                [ warningBell aggregations.needReviewCount
                , a [ Route.href Route.NeedsReview, Spacing.ml4 ] [ Asset.userGlyph [ class "account-control-icon" ] ]
                ]
            ]
        ]


warningBell : String -> Html msg
warningBell str =
    let
        shouldWarn =
            if str == "0" || str == "" then
                False

            else
                True
    in
    a [ Route.href Route.NeedsReview ]
        [ Asset.bellGlyph
            [ classList
                [ ( "account-control-icon", True ), ( "warning", shouldWarn ) ]
            ]
        ]



-- Sidebar


nameInfoRow : Html msg
nameInfoRow =
    Grid.row
        [ Row.aroundXs, Row.attrs [ class "text-center" ] ]
        [ Grid.col [] [ h1 [ class "display-5" ] [ text "Arthur" ] ] ]


ruleInfoRow : Html msg
ruleInfoRow =
    Grid.row
        [ Row.centerXs ]
        [ Grid.col [ Col.xs6, Col.attrs [ class "border-right border-blue", class "text-right" ] ] [ text "Mayor" ]
        , Grid.col [ Col.xs6 ]
            [ img
                [ Asset.src Asset.wiseLogo, class "header-info-bank-logo" ]
                []
            ]
        ]


logo : Html msg
logo =
    div [ class "text-center" ]
        [ a [ Route.href Route.Home ]
            [ img [ Asset.src Asset.usLogo, class "header-logo" ] [] ]
        ]


pageIsActive : Page -> Route -> Bool
pageIsActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Disbursements, Route.Disbursements ) ->
            True

        ( NeedsReview, Route.NeedsReview ) ->
            True

        ( LinkBuilder, Route.LinkBuilder ) ->
            True

        ( Transactions, Route.Transactions ) ->
            True

        _ ->
            False


selected : Page -> Route -> String
selected page route =
    if pageIsActive page route then
        "color-selected"

    else
        ""


committeeInfoContainer : Html msg
committeeInfoContainer =
    Grid.containerFluid
        []
        [ nameInfoRow
        , ruleInfoRow
        ]


sidebar : Page -> Html msg
sidebar page =
    div [ class "sidebar-container border-right border-blue", Spacing.pl0 ]
        [ committeeInfoContainer
        , navContainer page
        , logo
        ]


navContainer : Page -> Html msg
navContainer page =
    Grid.containerFluid
        [ Spacing.mt5 ]
        [ navRow (Asset.coinsGlyph [ class "tool-glyph" ]) page Route.Transactions "Transactions"
        , navRow (toolBarAsset <| Asset.genderNeutral <| pageIsActive page Route.Home) page Route.Home "Contributions"
        , navRow (toolBarAsset Asset.house) page Route.Disbursements "Disbursements"
        , navRow (toolBarAsset Asset.binoculars) page Route.NeedsReview "Needs Review"
        , navRow (Asset.linkGlyph [ class "tool-glyph" ]) page Route.LinkBuilder "Link Builder"

        --, navRow (toolBarAsset Asset.documents) page Route. "Documents"
        ]


toolBarAsset : Image -> Html msg
toolBarAsset image =
    img [ Asset.src image, class "tool-asset" ] []


navRow : Html msg -> Page -> Route -> String -> Html msg
navRow glyph page route label =
    Grid.row
        [ Row.centerXs
        , Row.attrs [ class "hover-underline hover-black" ]
        , Row.attrs [ Spacing.mb5 ]
        ]
        [ Grid.col
            []
            [ a [ Route.href route, class "hover-black" ]
                [ Grid.containerFluid
                    [ class <| "" ++ selected page route
                    ]
                    [ Grid.row
                        [ Row.aroundXs ]
                        [ Grid.col [ Col.xs3, Col.attrs [ class "text-center" ] ] [ glyph ]
                        , Grid.col [ Col.attrs [ class "font-weight-bolder font-size-18" ] ] [ text label ]
                        ]
                    ]
                ]
            ]
        ]
