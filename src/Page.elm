module Page exposing (Page(..), view)

import Aggregations
import Asset as Asset exposing (Image)
import Bank
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document)
import Committee
import Config exposing (Config)
import Html exposing (Html, a, div, h1, img, text, ul)
import Html.Attributes as Attr exposing (class, classList)
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
    | Transactions
    | Demo


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Config -> Aggregations.Model -> Committee.Model -> Page -> { title : String, content : Html msg } -> Document msg
view config aggregations committee page { title, content } =
    { title = title ++ " - Transactions"
    , body =
        sidebar page committee :: mainContainer aggregations content :: []
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
                , a [ Spacing.ml4 ] [ Asset.userGlyph [ class "account-control-icon" ] ]
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
    a []
        [ Asset.bellGlyph
            [ classList
                [ ( "account-control-icon", True ), ( "warning", shouldWarn ) ]
            ]
        ]



-- Sidebar


nameInfoRow : String -> Html msg
nameInfoRow name =
    Grid.row
        [ Row.aroundXs, Row.attrs [ class "text-center" ] ]
        [ Grid.col [] [ h1 [ class "display-5" ] [ text name ] ] ]


ruleInfoRow : Committee.Model -> Html msg
ruleInfoRow committee =
    Grid.row
        [ Row.centerXs ]
        [ Grid.col [ Col.xs6, Col.attrs [ class "border-right border-blue text-center align-self-center", class "text-right text-capitalize" ] ] [ text committee.officeType ]
        , Grid.col [ Col.xs6 ]
            [ Bank.stringToLogo committee.bankName
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


committeeInfoContainer : Committee.Model -> Html msg
committeeInfoContainer committee =
    Grid.containerFluid
        []
        [ nameInfoRow committee.candidateLastName
        , ruleInfoRow committee
        ]


sidebar : Page -> Committee.Model -> Html msg
sidebar page committee =
    div [ class "sidebar-container border-right border-blue", Spacing.pl0 ]
        [ committeeInfoContainer committee
        , navContainer page
        , logo
        ]


navContainer : Page -> Html msg
navContainer page =
    Grid.containerFluid
        [ Spacing.mt5 ]
        [ navRow True (Asset.coinsGlyph [ class "tool-glyph" ]) page Route.Transactions "Transactions"
        , navRow True (Asset.linkGlyph [ class "tool-glyph" ]) page Route.LinkBuilder "Link Builder"
        ]


navRow : Bool -> Html msg -> Page -> Route -> String -> Html msg
navRow enabled glyph page route label =
    let
        activeText =
            if enabled then
                ""

            else
                "text-muted"

        activeRoute =
            if enabled then
                [ Route.href route ]

            else
                []
    in
    Grid.row
        [ Row.centerXs
        , Row.attrs [ class "hover-underline hover-black" ]
        , Row.attrs [ Spacing.mb5 ]
        ]
        [ Grid.col
            []
            [ a ([ class <| "hover-black " ++ activeText ] ++ activeRoute)
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
