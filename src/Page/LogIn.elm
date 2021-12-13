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

import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config
import Form exposing (Form)
import Form.View
import Html exposing (..)
import Html.Attributes exposing (class)
import Session


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
    , formState : Form.View.Model Values
    , serverError : Maybe String
    }


initFormState : Form.View.Model Values
initFormState =
    { email = ""
    , password = ""
    }
        |> Form.View.idle


type alias Values =
    { email : String
    , password : String
    }


init : Config.Model -> Session.Model -> ( Model, Cmd Msg )
init config session =
    let
        model =
            { session = session
            , config = config
            , formState = initFormState
            , serverError = Nothing
            }
    in
    ( model
    , Cmd.none
    )


flattenCreds : Creds -> FlattenedCreds
flattenCreds creds =
    case ( creds.email, creds.password ) of
        ( Email email, Password password ) ->
            { email = email, password = password }


type Email
    = Email String


type Password
    = Password String


type alias InputValues =
    { email : String
    , password : String
    }


type alias Creds =
    { email : Email
    , password : Password
    }



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Log In", content = layout [] [ h1 [] [ text "Log in" ], div [ class "login-form" ] [ formView model ] ] }


layout : List (Attribute Msg) -> List (Html Msg) -> Html Msg
layout _ content =
    Grid.container
        []
        [ Grid.row [] [ Grid.col [ Col.lg5, Col.md6, Col.sm8 ] content ] ]


form : Form InputValues Creds
form =
    Form.succeed
        (\email password ->
            Creds email password
        )
        |> Form.append emailField
        |> Form.append passwordField


formView : Model -> Html Msg
formView model =
    Form.View.asHtml
        { onChange = FormChanged
        , action = "Log in"
        , loading = "Logging in"
        , validation = Form.View.ValidateOnSubmit
        }
        (Form.map LogInAttempted form)
        model.formState


parseEmail s =
    if String.contains "@" s then
        Ok <| Email s

    else
        Err "Invalid email"


emailField : Form InputValues Email
emailField =
    Form.emailField
        { parser = parseEmail
        , value = .email
        , update = \value values -> { values | email = value }
        , attributes =
            { label = "Email"
            , placeholder = "you@example.com"
            }
        }


parsePassword : String -> Result String Password
parsePassword s =
    if String.length s >= 6 then
        Ok <| Password s

    else
        Err "Password must be at least 6 characters"


passwordField : Form InputValues Password
passwordField =
    Form.passwordField
        { parser = parsePassword
        , value = .password
        , update = \value values -> { values | password = value }
        , attributes =
            { label = "Password"
            , placeholder = "Your password"
            }
        }


type Msg
    = FormChanged (Form.View.Model InputValues)
    | LogInAttempted Creds
    | LogInSuccessful String
    | LogInFailed String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormChanged newForm ->
            ( { model | formState = newForm }, Cmd.none )

        LogInAttempted creds ->
            ( model, sendCredsForLogIn <| flattenCreds creds )

        LogInSuccessful token ->
            ( { model | session = Session.setToken token model.session }, Cmd.none )

        LogInFailed error ->
            ( { model | serverError = Just error }, Cmd.none )



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
