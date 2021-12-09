module Page.Home exposing
    ( Model
    , Msg(..)
    , init
    , subscriptions
    , toSession
    , update
    , view
    )

import Config exposing (Config)
import Html exposing (..)
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , config : Config
    }


init : Config -> Session -> ( Model, Cmd Msg )
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


toSession : Model -> Session
toSession model =
    model.session
