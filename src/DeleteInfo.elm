module DeleteInfo exposing (Model(..), deletionAlert)

import Bootstrap.Alert as Alert
import Html exposing (Html, text)
import Html.Attributes exposing (attribute, class)


type Model
    = Confirmed
    | Unconfirmed
    | Uninitialized


deletionAlert : Maybe (Alert.Visibility -> msg) -> Maybe Alert.Visibility -> Html msg
deletionAlert msg visibility =
    case ( msg, visibility ) of
        ( Just alertMsg, Just alertVisibility ) ->
            Alert.config
                |> Alert.danger
                |> Alert.dismissableWithAnimation alertMsg
                |> Alert.children
                    [ Alert.h5 [ class "font-weight-bold" ] [ text "Warning" ]
                    , Alert.h6 [ attribute "data-cy" "deleteInfo" ] [ text "This action is irreversible" ]
                    ]
                |> Alert.view alertVisibility

        _ ->
            text ""
