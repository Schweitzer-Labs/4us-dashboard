port module Page.LogIn exposing
    ( Model
    , Msg(..)
    , init
    , setSession
    , subscriptions
    , toConfig
    , toSession
    , update
    , view
    )

import Bootstrap.Form.Input as Form exposing (email, password)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation as Nav
import Config
import Errors
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onInput)
import Route
import Session
import SubmitButton


port sendCredsForLogIn : FlattenedCreds -> Cmd msg


port loginSuccessful : (String -> msg) -> Sub msg


port loginFailed : (String -> msg) -> Sub msg


type alias FlattenedCreds =
    { email : String
    , password : String
    }



-- MODEL


type alias Model =
    { session : Session.Model
    , config : Config.Model
    , serverError : Maybe String
    , redirectRoute : Route.Route
    , email : String
    , password : String
    , loading : Bool
    }


type alias Values =
    { email : String
    , password : String
    }


init : Config.Model -> Session.Model -> Route.Route -> ( Model, Cmd Msg )
init config session route =
    let
        model =
            { session = session
            , config = config
            , serverError = Nothing
            , redirectRoute = route
            , email = ""
            , password = ""
            , loading = False
            }
    in
    ( model
    , Cmd.none
    )


toCreds : Model -> FlattenedCreds
toCreds model =
    { email = model.email, password = model.password }


view : Model -> { title : String, content : Html Msg }
view model =
    let
        authError =
            model.serverError
                |> Maybe.map (\error -> Errors.view [ error ])
                |> Maybe.withDefault []

        content =
            layout [] <|
                [ h1 [] [ text "Log in" ] ]
                    ++ authError
                    ++ [ div
                            []
                            [ div [ Spacing.mb3 ]
                                [ email
                                    [ Form.attrs
                                        [ onInput EmailUpdated, placeholder "Enter Email" ]
                                    ]
                                ]
                            , div [ Spacing.mb3 ]
                                [ password
                                    [ Form.attrs
                                        [ onInput PasswordUpdated, placeholder "Enter Password" ]
                                    ]
                                ]
                            , SubmitButton.block [] "Log In" LogInAttempted model.loading model.loading
                            ]
                       ]
    in
    { title = "Log In", content = content }


layout : List (Attribute Msg) -> List (Html Msg) -> Html Msg
layout _ content =
    Grid.container
        []
        [ Grid.row [] [ Grid.col [ Col.lg5, Col.md6, Col.sm8 ] content ] ]


parseEmail : String -> Result String String
parseEmail s =
    if String.contains "@" s then
        Ok <| s

    else
        Err "Invalid email"


parsePassword : String -> Result String String
parsePassword s =
    if String.length s >= 1 then
        Ok <| s

    else
        Err "Must include a password to authenticate"


type Msg
    = EmailUpdated String
    | PasswordUpdated String
    | LogInAttempted
    | LogInSuccessful String
    | LogInFailed String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailUpdated str ->
            ( { model | email = str }, Cmd.none )

        PasswordUpdated str ->
            ( { model | password = str }, Cmd.none )

        LogInAttempted ->
            ( { model | loading = True }
            , sendCredsForLogIn { email = model.email, password = model.password }
            )

        LogInSuccessful token ->
            let
                newSession =
                    Session.setToken token model.session
            in
            ( { model | session = newSession }
            , Nav.pushUrl
                (Session.toNavKey newSession)
                (Route.routeToString model.redirectRoute)
            )

        LogInFailed error ->
            ( { model | serverError = Just error, loading = False }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ loginSuccessful LogInSuccessful, loginFailed LogInFailed ]



-- EXPORT


toSession : Model -> Session.Model
toSession model =
    model.session


toConfig : Model -> Config.Model
toConfig model =
    model.config


setSession : Session.Model -> Model -> Model
setSession session model =
    { model | session = session }
