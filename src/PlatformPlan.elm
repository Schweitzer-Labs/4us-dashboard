module PlatformPlan exposing (Model(..), decoder)

import Json.Decode as Decode exposing (Decoder)


type Model
    = Policapital
    | FourUs


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Policapital" ->
                        Decode.succeed Policapital

                    "FourUs" ->
                        Decode.succeed FourUs

                    _ ->
                        Decode.fail <| "Unknown committee plan"
            )
