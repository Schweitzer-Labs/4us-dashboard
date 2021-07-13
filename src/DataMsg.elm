module DataMsg exposing
    ( MsgMaybeBool
    , MsgMaybePaymentMethod
    , MsgMaybePurposeCode
    , MsgString
    , toData
    , toMsg
    )

import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)


type alias MsgString msg =
    ( String, String -> msg )


type alias MsgMaybePurposeCode msg =
    ( Maybe PurposeCode, Maybe PurposeCode -> msg )


type alias MsgMaybeBool msg =
    ( Maybe Bool, Maybe Bool -> msg )


type alias MsgMaybePaymentMethod msg =
    ( Maybe PaymentMethod, Maybe PaymentMethod -> msg )


toMsg : ( a, b ) -> b
toMsg ( _, msg ) =
    msg


toData : ( a, b ) -> a
toData ( data, _ ) =
    data
