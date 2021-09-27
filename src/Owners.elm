module Owners exposing (Owner, Owners, decoder, encoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


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
        |> required "addressLine2" string
        |> required "city" string
        |> required "state" string
        |> required "postalCode" string
        |> required "percentOwnership" string


decoder : Decoder (List Owner)
decoder =
    Decode.list ownerDecoder
