module Page.Home exposing
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

import Config
import Html exposing (..)
import Session



-- MODEL


type alias Model =
    { session : Session.Model
    , config : Config.Model
    }


init : Config.Model -> Session.Model -> ( Model, Cmd Msg )
init config session =
    let
        model =
            { session = session
            , config = config
            }
    in
    ( model
    , Cmd.none
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home", content = div [] [ text "this is home" ] }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



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
