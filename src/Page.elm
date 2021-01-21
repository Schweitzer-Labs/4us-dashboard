module Page exposing (Page(..), view, viewErrors)

import Asset as Asset exposing (Image)
import Bootstrap.Form.Input as Input
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
view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Transactions"
    , body =
        viewHeader page maybeViewer
            :: toolBarContainer page
            :: contentContainer content
            :: []
    }


contentContainer : Html msg -> Html msg
contentContainer content =
    div [] [ content ]


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    div [ class "header" ] [ headerContainer ]


headerContainer : Html msg
headerContainer =
    Grid.containerFluid [] [ headerRow ]


headerRow : Html msg
headerRow =
    Grid.row
        [ Row.attrs [ class "align-items-center" ] ]
        [ Grid.col [ Col.xs3 ] [ infoContainer ]
        , Grid.col [ Col.attrs [ class "text-center" ] ] [ logoContent ]
        , Grid.col [ Col.xs3 ] [ navContainer ]
        ]


infoContainer : Html msg
infoContainer =
    Grid.containerFluid
        []
        [ nameInfoRow, ruleInfoRow ]


nameInfoRow : Html msg
nameInfoRow =
    Grid.row [ Row.centerMd, Row.attrs [ class "text-center" ] ] [ Grid.col [] [ h1 [ class "display-4" ] [ text "Annissa" ] ] ]


ruleInfoRow : Html msg
ruleInfoRow =
    Grid.row
        [ Row.centerXs ]
        [ Grid.col [ Col.xs4, Col.attrs [ class "border-right", class "text-center" ] ] [ text "City Council" ]
        , Grid.col [ Col.xs4 ]
            [ img
                [ Asset.src Asset.wiseLogo, class "header-info-bank-logo" ]
                []
            ]
        ]


logoContent : Html msg
logoContent =
    a [ Route.href Route.Home ]
        [ img [ Asset.src Asset.usLogo, class "header-logo" ] [] ]


zeroSpacing : List (Html.Attribute msg)
zeroSpacing =
    [ Spacing.m0, Spacing.p0 ]


navContainer : Html msg
navContainer =
    Grid.containerFluid
        []
        [ Grid.row
            [ Row.centerXs, Row.attrs [ class "text-center" ] ]
            [ Grid.col [ Col.xs8 ] [ searchBox ]
            , Grid.col [ Col.attrs zeroSpacing ] [ searchButton ]
            , Grid.col [ Col.attrs zeroSpacing ] [ gearButton ]
            ]
        ]


searchBox : Html msg
searchBox =
    Input.text [ Input.attrs [ class "header-search-box" ] ]


searchButton : Html msg
searchButton =
    img [ Asset.src Asset.search, class "nav-icon" ] []


gearButton : Html msg
gearButton =
    img [ Asset.src Asset.gearHires, class "nav-icon" ] []



-- TOOLBAR


sidebarLink : Page -> Route -> List (Html msg) -> Html msg
sidebarLink page route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", pageIsActive page route ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


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


toolBarContainer : Page -> Html msg
toolBarContainer page =
    div [ class "tool-bar-container border-right" ] [ toolBarGrid page ]


toolBarGrid : Page -> Html msg
toolBarGrid page =
    Grid.containerFluid
        [ class "text-center mt-2", Spacing.pl0 ]
        [ toolBarLink (Asset.coinsGlyph [ class "tool-glyph" ]) page Route.Transactions "Transactions"
        , toolBarLink (toolBarAsset <| Asset.genderNeutral <| pageIsActive page Route.Home) page Route.Home "Contributions"
        , toolBarLink (toolBarAsset Asset.house) page Route.Disbursements "Disbursements"
        , toolBarLink (toolBarAsset Asset.binoculars) page Route.NeedsReview "Needs Review"
        , toolBarLink (Asset.linkGlyph [ class "tool-glyph" ]) page Route.LinkBuilder "Link Builder"
        , toolBarItem Asset.documents "Documents"
        ]


toolBarAsset : Image -> Html msg
toolBarAsset image =
    img [ Asset.src image, class "tool-asset" ] []


toolBarLink : Html msg -> Page -> Route -> String -> Html msg
toolBarLink glyph page route label =
    Grid.row
        [ Row.centerXs, Row.attrs [ class "hover-underline" ] ]
        [ Grid.col
            []
            [ a [ Route.href route, class "hover-black" ]
                [ Grid.containerFluid
                    [ class <| "text-center " ++ selected page route
                    ]
                    [ Grid.row
                        [ Row.centerXs ]
                        [ Grid.col [] [ glyph ]
                        , Grid.col [] [ text label ]
                        ]
                    ]
                ]
            ]
        ]


toolBarItem : Image -> String -> Html msg
toolBarItem image label =
    Grid.row
        [ Row.attrs [ class "mt-3" ] ]
        [ Grid.col
            []
            [ Grid.containerFluid
                [ class "text-center" ]
                [ Grid.row
                    [ Row.centerXs ]
                    [ Grid.col [] [ img [ Asset.src image, class "tool-asset text-center" ] [] ] ]
                , Grid.row
                    []
                    [ Grid.col [] [ text label ] ]
                ]
            ]
        ]


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
