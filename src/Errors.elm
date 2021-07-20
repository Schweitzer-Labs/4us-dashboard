module Errors exposing (fromInKind, fromPostalCode)


fromInKind : Maybe Bool -> List String
fromInKind isInKind =
    case isInKind of
        Just bool ->
            case bool of
                True ->
                    [ "In-Kind option is currently not supported" ]

                False ->
                    []

        Nothing ->
            []


fromPostalCode : String -> List String
fromPostalCode postalCode =
    let
        length =
            String.length <| postalCode
    in
    if length < 5 then
        [ "ZIP code is too short." ]

    else if length > 9 then
        [ "ZIP code is too long." ]

    else
        []
