module DataMsg exposing
    ( MsgMaybeBool
    , MsgMaybeEntityType
    , MsgMaybePaymentMethod
    , MsgMaybePurposeCode
    , MsgOwner
    , MsgString
    , toData
    , toMsg
    )

import EntityType exposing (EntityType)
import Owners exposing (Owner, Owners)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)


type alias MsgString msg =
    ( String, String -> msg )


type alias MsgMaybePurposeCode msg =
    ( Maybe PurposeCode, Maybe PurposeCode -> msg )


type alias MsgMaybeBool msg =
    ( Maybe Bool, Maybe Bool -> msg )


type alias MsgMaybeEntityType msg =
    ( Maybe EntityType, Maybe EntityType -> msg )


type alias MsgMaybePaymentMethod msg =
    ( Maybe PaymentMethod, Maybe PaymentMethod -> msg )


type alias MsgOwner msg =
    ( Owners, msg )


toMsg : ( a, b ) -> b
toMsg ( _, msg ) =
    msg


toData : ( a, b ) -> a
toData ( data, _ ) =
    data
