module Errors exposing (fromInKind, fromInKindDescription, fromMaxAmount, fromMaxDate, fromPostalCode)

import Cents
import Time
import Timestamp


type alias Errors =
    List String


fromInKind : Maybe Bool -> Errors
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


fromPostalCode : String -> Errors
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


fromInKindDescription : String -> String -> Errors
fromInKindDescription payMethod str =
    case payMethod of
        "InKind" ->
            let
                length =
                    String.length <| str
            in
            if length < 3 then
                [ "Description is missing" ]

            else
                []

        _ ->
            []


fromMaxAmount : Int -> String -> Errors
fromMaxAmount maxCents valStr =
    let
        maybeVal =
            Cents.fromMaybeDollars valStr
    in
    case maybeVal of
        Just val ->
            case compare val maxCents of
                GT ->
                    [ "Amount exceeds " ++ Cents.toDollar maxCents ]

                _ ->
                    []

        Nothing ->
            [ "Amount must be a number" ]


fromMaxDate : Time.Zone -> Int -> Int -> Errors
fromMaxDate timezone max val =
    case compare val max of
        GT ->
            [ "Date must be on or before " ++ Timestamp.format timezone max ]

        _ ->
            []
