module FormID exposing (Model(..), fromString, toString)


type Model
    = CreateDisb
    | CreateContrib
    | ReconcileDisb
    | ReconcileContrib
    | AmendDisb
    | AmendContrib


toString : Model -> String
toString formID =
    case formID of
        CreateDisb ->
            "create-disb"

        CreateContrib ->
            "create-contrib"

        ReconcileDisb ->
            "reconcile-disb"

        ReconcileContrib ->
            "reconcile-contrib"

        AmendDisb ->
            "amend-disb"

        AmendContrib ->
            "amend-contrib"


fromString : String -> Maybe Model
fromString str =
    case str of
        "create-disb" ->
            Just CreateDisb

        "create-contrib" ->
            Just CreateContrib

        "reconcile-disb" ->
            Just ReconcileDisb

        "reconcile-contrib" ->
            Just ReconcileContrib

        "amend-disb" ->
            Just AmendDisb

        "amend-contrib" ->
            Just AmendContrib

        _ ->
            Nothing
