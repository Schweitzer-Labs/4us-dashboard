module Page exposing (Page(..), view)

import Aggregations
import Asset as Asset exposing (Image)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import Config exposing (Config)
import Html exposing (Html, a, button, div, footer, h1, h2, h3, i, img, li, nav, p, span, text, ul)
import Html.Attributes as Attr exposing (class, classList, href, style)
import Route exposing (Route)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type Page
    = Other
    | Home
    | LinkBuilder
    | NeedsReview
    | Transactions


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Config -> Aggregations.Model -> Page -> { title : String, content : Html msg } -> Document msg
view config aggregations page { title, content } =
    { title = title ++ " - Transactions"
    , body =
        sidebar page :: mainContainer aggregations content :: []
    }


mainContainer : Aggregations.Model -> Html msg -> Html msg
mainContainer aggregations content =
    div [ class "app-container" ]
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
                [ warningBell (String.fromInt aggregations.needsReviewCount)
                , a [ Route.href Route.NeedsReview, Spacing.ml4 ] [ Asset.userGlyph [ class "account-control-icon" ] ]
                ]
            ]
        ]



-- @ToDo fix decoders to account for or clause


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
        [ Grid.col [] [ h1 [ class "display-5" ] [ text "Safford" ] ] ]


ruleInfoRow : Html msg
ruleInfoRow =
    Grid.row
        [ Row.centerXs ]
        [ Grid.col [ Col.xs6, Col.attrs [ class "border-right border-blue", class "text-right" ] ] [ text "Supervisor" ]
        , Grid.col [ Col.xs6 ]
            [ img
                [ Asset.src Asset.chaseBankLogo, class "header-info-bank-logo" ]
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
        [ navRow True (Asset.coinsGlyph [ class "tool-glyph" ]) page Route.Transactions "Transactions"
        , navRow False (Asset.searchDollarGlyph [ class "tool-glyph" ]) page Route.NeedsReview "Needs Review"
        , navRow False (Asset.linkGlyph [ class "tool-glyph" ]) page Route.LinkBuilder "Link Builder"
        ]


toolBarAsset : Image -> Html msg
toolBarAsset image =
    img [ Asset.src image, class "tool-asset" ] []


navRow : Bool -> Html msg -> Page -> Route -> String -> Html msg
navRow enabled glyph page route label =
    Grid.row
        [ Row.centerXs
        , Row.attrs [ class "hover-underline hover-black" ]
        , Row.attrs [ Spacing.mb5 ]
        ]
        [ Grid.col
            []
            [ a [ class "hover-black text-muted" ]
                [ Grid.containerFluid
                    [ class <| "" ++ selected page route
                    ]
                    [ Grid.row
                        [ Row.aroundXs ]
                        [ Grid.col [ Col.xs3, Col.attrs [ class "text-center" ] ] [ glyph ]
                        , Grid.col [ Col.attrs [ class "font-size-18" ] ] [ text label ]
                        ]
                    ]
                ]
            ]
        ]
