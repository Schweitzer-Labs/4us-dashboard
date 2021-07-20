module TxnForm.ContribRuleVerified exposing (Model, Msg(..), fromError, init, loadingInit, update, view)

import Html exposing (Html, div, text)
import Transaction


type alias Model =
    { state : String
    }


init : Transaction.Model -> Model
init txn =
    { state = "from init" }


loadingInit : Model
loadingInit =
    { state = "from loading init" }


view : Model -> Html msg
view model =
    div [] [ text "hello from verified contrib" ]


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )


fromError : Model -> String -> Model
fromError model str =
    model
