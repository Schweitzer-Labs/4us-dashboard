module Errors exposing (fromEmailAddress, fromInKind, fromInKindType, fromMaxAmount, fromMaxDate, fromOrgType, fromOwners, fromPhoneNumber, fromPostalCode, view)

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


fromOwners : Owner.Owners -> List String
fromOwners owners =
    let
        totalPercentage =
            Owner.foldOwnership owners
    in
    if totalPercentage < 100 then
        let
            remainder =
                String.fromFloat (100 - totalPercentage) ++ "%"
        in
        [ "A list of ownership percentages adding up to 100 is required " ++ "please add the remaining " ++ remainder ]

    else
        []


view : Errors -> List (Html msg)
view errors =
    case errors of
        [] ->
            []

        x :: xs ->
            singleton <| div [ Spacing.mt2, Spacing.mb2, class "text-danger" ] [ text x ]
