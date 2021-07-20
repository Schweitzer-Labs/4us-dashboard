module TxnForm.ContribRuleUnverified exposing (Model, Msg(..), fromError, init, loadingInit, update, view)

import Config exposing (Config)
import Html exposing (Html, div, text)
import Transaction


type alias Model =
    { state : String
    , bankTxn : Transaction.Model
    }


init : Config -> List Transaction.Model -> Transaction.Model -> Model
init config txns bankTxn =
    { state = "from init"
    , bankTxn = Transaction.init
    }


loadingInit : Model
loadingInit =
    { state = "from loading init"
    , bankTxn = Transaction.init
    }


view : Model -> Html msg
view model =
    div [] [ text "hello from unverified contrib" ]


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    ( model, Cmd.none )


fromError : Model -> String -> Model
fromError model str =
    model
