module DataMsg exposing
    ( MsgMaybeBool
    , MsgMaybeEntityType
    , MsgMaybeOrgOrInd
    , MsgMaybePaymentMethod
    , MsgMaybePurposeCode
    , MsgOwner
    , MsgString
    , toData
    , toMsg
    )

import EntityType
import OrgOrInd
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
    ( Maybe EntityType.Model, Maybe EntityType.Model -> msg )


type alias MsgMaybePaymentMethod msg =
    ( Maybe PaymentMethod, Maybe PaymentMethod -> msg )


type alias MsgMaybeOrgOrInd msg =
    ( Maybe OrgOrInd.Model, Maybe OrgOrInd.Model -> msg )


type alias MsgOwner msg =
    ( Owners, msg )


toMsg : ( a, b ) -> b
toMsg ( _, msg ) =
    msg


toData : ( a, b ) -> a
toData ( data, _ ) =
    data
