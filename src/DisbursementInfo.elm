module DisbursementInfo exposing (Config)

import Address
import DataMsg


type alias Config msg =
    { entityName : DataMsg.MsgString msg
    , addressLine1 : DataMsg.MsgString msg
    , addressLine2 : DataMsg.MsgString msg
    , city : DataMsg.MsgString msg
    , state : DataMsg.MsgString msg
    , postalCode : DataMsg.MsgString msg
    , purposeCode : DataMsg.MsgMaybePurposeCode msg
    , isSubcontracted : DataMsg.MsgMaybeBool msg
    , isPartialPayment : DataMsg.MsgMaybeBool msg
    , isExistingLiability : DataMsg.MsgMaybeBool msg
    , amount : Maybe (DataMsg.MsgString msg)
    , paymentMethod : Maybe (DataMsg.MsgMaybePaymentMethod msg)
    , disabled : Bool
    , isEditable : Bool
    }
