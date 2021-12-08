module Errors exposing (fromAmendContribPaymentInfo, fromContribPaymentInfo, fromCreditCardInfo, fromDisbPaymentInfo, fromEmailAddress, fromFamilyStatus, fromInKind, fromMaxAmount, fromMaxDate, fromOrgType, fromOwners, fromPhoneNumber, fromPostalCode, fromPurposeCodeOther, view)

import Bootstrap.Utilities.Spacing as Spacing
import Cents
import EntityType
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import InKindType
import List exposing (singleton)
import OrgOrInd
import Owners as Owner
import Payment.CreditCard.Validation as CardValidation
import PaymentMethod
import PurposeCode exposing (PurposeCode(..))
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



--cardNumber, expirationMonth, expirationYear, cvv


type alias ContribPaymentInfoConfig =
    { paymentMethod : Maybe PaymentMethod.Model
    , inKindType : Maybe InKindType.Model
    , inKindDescription : String
    , checkNumber : String
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    }


fromContribPaymentInfo : ContribPaymentInfoConfig -> Errors
fromContribPaymentInfo config =
    case config.paymentMethod of
        Just PaymentMethod.InKind ->
            case config.inKindType of
                Just a ->
                    case String.isEmpty config.inKindDescription of
                        True ->
                            [ "In-Kind Description is missing" ]

                        False ->
                            []

                Nothing ->
                    [ "In-Kind Info is missing" ]

        Just PaymentMethod.Check ->
            case String.isEmpty config.checkNumber of
                True ->
                    [ "Check Number is missing" ]

                False ->
                    []

        Just PaymentMethod.Credit ->
            if String.isEmpty config.cardNumber then
                [ "Card Number is missing" ]

            else if String.isEmpty config.expirationMonth then
                [ "Expiration Month is missing" ]

            else if String.isEmpty config.expirationYear then
                [ "Expiration Year is missing" ]

            else if String.isEmpty config.cvv then
                [ "CCV is missing" ]

            else
                []

        _ ->
            []


fromCreditCardInfo : Maybe PaymentMethod.Model -> String -> Errors
fromCreditCardInfo paymentMethod cardNumber =
    case paymentMethod of
        Just PaymentMethod.Credit ->
            if String.length cardNumber < 13 then
                [ "Credit Card number is too short" ]

            else if not <| CardValidation.isValid cardNumber then
                [ "Invalid Credit Card" ]

            else
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


fromAmendContribPaymentInfo : Maybe PaymentMethod.Model -> String -> Errors
fromAmendContribPaymentInfo paymentMethod checkNumber =
    case paymentMethod of
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


fromPurposeCodeOther : Maybe PurposeCode -> String -> List String
fromPurposeCodeOther code explanation =
    case code of
        Just OTHER ->
            case String.isEmpty explanation of
                True ->
                    [ "Explanation is missing" ]

                False ->
                    []

        Nothing ->
            []

        _ ->
            []


view : Errors -> List (Html msg)
view errors =
    case errors of
        [] ->
            []

        x :: xs ->
            singleton <| div [ Spacing.mt2, Spacing.mb2, class "text-danger" ] [ text x ]
