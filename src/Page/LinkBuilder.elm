module Page.LinkBuilder exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Banner
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Content
import Html exposing (..)
import Html.Attributes as SvgA exposing (class, for, href, src, style)
import QRCode
import Session exposing (Session)
import Task exposing (Task)
import Url.Builder



-- MODEL


type alias Model =
    { session : Session
    , refCode : String
    , amount : String
    , url : String
    , committeeId : String
    }


init : Session -> String -> ( Model, Cmd Msg )
init session committeeId =
    ( { session = session
      , refCode = ""
      , amount = ""
      , url = ""
      , committeeId = committeeId
      }
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div
            []
            [ Banner.container [] [ h2 [ class "text-center p-1" ] [ text "Link Builder" ] ]
            , Content.container [] [ formRow model ]
            ]
    }



-- Form


formRow : Model -> Html Msg
formRow model =
    Grid.row
        [ Row.attrs [ Spacing.mt3 ] ]
        [ Grid.col
            [ Col.sm5 ]
            [ Form.group []
                [ Form.label [ for "ref-id" ] [ text "Source" ]
                , Input.text [ Input.id "ref-id", Input.onInput RefCodeUpdated ]
                , Form.help [] [ text "This code will be used to track the context of a donation and enable tracking. After sharing a link with a source, navigate to the Contributions view to see which transactions come from which context." ]
                ]
            , Form.group []
                [ Form.label [ for "amount" ] [ text "Amount" ]
                , Input.number [ Input.id "amount", Input.onInput AmountUpdated ]
                , Form.help [] [ text "This amount will be prefilled when the donation form is loaded." ]
                ]
            ]
        , Grid.col
            [ Col.sm5 ]
            [ linkRow model
            ]
        ]



-- Link Card


linkRow : Model -> Html msg
linkRow model =
    let
        url =
            createUrl model.committeeId model.refCode model.amount
    in
    Grid.row
        []
        [ Grid.col
            []
            [ linkCard url
            ]
        ]


linkCard : String -> Html msg
linkCard url =
    Card.config [ Card.attrs [] ]
        |> Card.block []
            [ Block.titleH4 [] [ text "Link" ]
            , Block.text []
                [ a
                    [ href url, class "d-block max-height-80", Spacing.mt1, Spacing.mb3, Spacing.p3 ]
                    [ text url ]
                ]
            , Block.text [] [ qrCodeView url ]
            , Block.custom <|
                Button.button [ Button.primary ] [ text "Download" ]
            ]
        |> Card.view



-- QR Codes


qrCodeView : String -> Html msg
qrCodeView message =
    QRCode.fromString message
        |> Result.map
            (QRCode.toSvg
                [ SvgA.width 300
                , SvgA.height 300
                ]
            )
        |> Result.withDefault (Html.text "Error while encoding to QRCode.")



-- UPDATE


type Msg
    = GotSession Session
    | RefCodeUpdated String
    | AmountUpdated String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        RefCodeUpdated str ->
            ( { model | refCode = str }, Cmd.none )

        AmountUpdated str ->
            ( { model | amount = str }, Cmd.none )


createUrl : String -> String -> String -> String
createUrl committeeId refCode amount =
    let
        committeeIdVal =
            [ Url.Builder.string "committeeId" committeeId ]

        refCodeVal =
            if String.length refCode > 0 then
                [ Url.Builder.string "refCode" refCode ]

            else
                []

        amountVal =
            if String.length amount > 0 then
                [ Url.Builder.string "amount" amount ]

            else
                []
    in
    Url.Builder.crossOrigin "http://localhost:3001" [] <| committeeIdVal ++ refCodeVal ++ amountVal


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session