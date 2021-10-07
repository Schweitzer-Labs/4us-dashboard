module Owners exposing (Owner, Owners, decoder, encoder, foldOwnership, getOwnerFullName, ownershipToFloat, toHash, validator)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Validate exposing (Validator, ifBlank, ifFalse, isFloat)


type alias Owner =
    { firstName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , percentOwnership : String
    }


type alias Owners =
    List Owner


encoder : Owner -> Encode.Value
encoder owner =
    Encode.object
        [ ( "firstName", Encode.string owner.firstName )
        , ( "lastName", Encode.string owner.lastName )
        , ( "addressLine1", Encode.string owner.addressLine1 )
        , ( "addressLine2", Encode.string owner.addressLine2 )
        , ( "city", Encode.string owner.city )
        , ( "state", Encode.string owner.state )
        , ( "postalCode", Encode.string owner.postalCode )
        , ( "percentOwnership", Encode.string owner.percentOwnership )
        ]


ownerDecoder : Decoder Owner
ownerDecoder =
    Decode.succeed Owner
        |> required "firstName" string
        |> required "lastName" string
        |> required "addressLine1" string
        |> optional "addressLine2" string ""
        |> required "city" string
        |> required "state" string
        |> required "postalCode" string
        |> required "percentOwnership" string


decoder : Decoder (List Owner)
decoder =
    Decode.list ownerDecoder


toHash : Owner -> String
toHash owner =
    owner.firstName
        ++ "-"
        ++ owner.lastName
        ++ "-"
        ++ owner.addressLine1
        ++ "-"
        ++ owner.city
        ++ "-"
        ++ owner.state
        ++ "-"
        ++ owner.postalCode


foldOwnership : Owners -> Float
foldOwnership owners =
    List.foldl (+) 0 <|
        List.map (Maybe.withDefault 0 << String.toFloat << .percentOwnership) owners


validator : Validator String Owner
validator =
    Validate.firstError
        [ ifBlank .percentOwnership "Ownership percentage must be a valid a number."
        , ifBlank .firstName "Owner First name is missing."
        , ifBlank .lastName "Owner Last name is missing."
        , ifBlank .addressLine1 "Owner Address 1 is missing."
        , ifBlank .city "Owner City is missing."
        , ifBlank .state "Owner State is missing."
        , ifBlank .postalCode "Owner Postal Code is missing."
        ]


ifNotFloat : (subject -> String) -> error -> Validator error subject
ifNotFloat subjectToString error =
    ifFalse (\subject -> isFloat (subjectToString subject)) error


getOwnerFullName : Owner -> String
getOwnerFullName owner =
    owner.firstName ++ " " ++ owner.lastName


ownershipToFloat : Owner -> Float
ownershipToFloat newOwner =
    Maybe.withDefault 0 <| String.toFloat newOwner.percentOwnership
