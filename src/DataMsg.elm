module DataMsg exposing (MsgMaybeBool, MsgMaybePaymentMethod, MsgMaybePurposeCode, MsgString)

import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)


type alias MsgString msg =
    ( String, String -> msg )


type alias MsgMaybePurposeCode msg =
    ( String, Maybe PurposeCode -> msg )


type alias MsgMaybeBool msg =
    ( String, Maybe Bool -> msg )


type alias MsgMaybePaymentMethod msg =
    ( String, Maybe PaymentMethod -> msg )
