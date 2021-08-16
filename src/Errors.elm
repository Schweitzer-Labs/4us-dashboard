module Errors exposing (fromInKind, fromInKindType, fromMaxAmount, fromMaxDate, fromOrgType, fromPostalCode)

import Cents
import EntityType
import InKindType
import OrgOrInd
import PaymentMethod
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


fromInKindType : Maybe PaymentMethod.Model -> Maybe InKindType.Model -> String -> Errors
fromInKindType payMethod inKindType desc =
    case payMethod of
        Just PaymentMethod.InKind ->
            case inKindType of
                Just a ->
                    case desc of
                        "" ->
                            [ "In-Kind Description is missing" ]

                        _ ->
                            []

                Nothing ->
                    [ "In-Kind Info is missing" ]

        _ ->
            []


fromOrgType : Maybe OrgOrInd.Model -> Maybe EntityType.Model -> Errors
fromOrgType orgType entity =
    case orgType of
        Just OrgOrInd.Org ->
            case entity of
                Just a ->
                    []

                Nothing ->
                    [ "Org Classification is missing" ]

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
