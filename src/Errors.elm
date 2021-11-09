module Errors exposing (fromContribPaymentInfo, fromDisbPaymentInfo, fromEmailAddress, fromFamilyStatus, fromInKind, fromMaxAmount, fromMaxDate, fromOrgType, fromOwners, fromPhoneNumber, fromPostalCode, view)

import Bootstrap.Utilities.Spacing as Spacing
import Cents
import EntityType
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import InKindType
import List exposing (singleton)
import OrgOrInd
import Owners as Owner
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


fromContribPaymentInfo : Maybe PaymentMethod.Model -> Maybe InKindType.Model -> String -> String -> Errors
fromContribPaymentInfo payMethod inKindType desc checkNumber =
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

        Just PaymentMethod.Check ->
            case String.isEmpty checkNumber of
                True ->
                    [ "Check Number is missing" ]

                False ->
                    []

        _ ->
            []


fromDisbPaymentInfo : Maybe PaymentMethod.Model -> String -> Errors
fromDisbPaymentInfo payMethod checkNumber =
    case payMethod of
        Just PaymentMethod.Check ->
            case String.isEmpty checkNumber of
                True ->
                    [ "Check Number is missing" ]

                False ->
                    []

        _ ->
            []


fromOrgType : Maybe OrgOrInd.Model -> Maybe EntityType.Model -> String -> Errors
fromOrgType orgType entity entityName =
    case orgType of
        Just OrgOrInd.Org ->
            case entity of
                Just a ->
                    case String.isEmpty entityName of
                        True ->
                            [ "Entity Name is missing" ]

                        False ->
                            []

                Nothing ->
                    [ "Org Classification is missing" ]

        _ ->
            []


fromFamilyStatus : Maybe OrgOrInd.Model -> Maybe EntityType.Model -> Errors
fromFamilyStatus orgOrInd entityType =
    case orgOrInd of
        Just OrgOrInd.Ind ->
            case entityType of
                Nothing ->
                    [ "Family Status is missing" ]

                _ ->
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


fromEmailAddress : Bool -> List String
fromEmailAddress emailAddressValidated =
    if emailAddressValidated == True then
        []

    else
        [ "Email Address is invalid" ]


fromPhoneNumber : String -> Bool -> List String
fromPhoneNumber phoneNum phoneNumberValidated =
    if String.length phoneNum == 0 then
        []

    else if phoneNumberValidated then
        []

    else
        [ "Phone number is invalid" ]


fromOwners : Owner.Owners -> Maybe EntityType.Model -> List String
fromOwners owners maybeEntity =
    if EntityType.isLLCorLLP maybeEntity then
        let
            totalPercentage =
                Owner.foldOwnership owners
        in
        if totalPercentage /= 100 then
            let
                remainder =
                    String.fromFloat (abs <| 100 - totalPercentage) ++ "%"
            in
            [ "Ownership percentage total must add up to 100%. Total is off by " ++ remainder ++ "." ]

        else
            []

    else
        []


view : Errors -> List (Html msg)
view errors =
    case errors of
        [] ->
            []

        x :: xs ->
            singleton <| div [ Spacing.mt2, Spacing.mb2, class "text-danger" ] [ text x ]
