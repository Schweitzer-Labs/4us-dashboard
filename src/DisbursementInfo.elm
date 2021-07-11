module DisbursementInfo exposing (Config, view)

import Address
import AmountDate
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg exposing (toData, toMsg)
import Html exposing (Html, div, text)
import Html.Attributes exposing (for)
import PaymentMethod
import PurposeCode
import YesOrNo


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
    , paymentDate : Maybe (DataMsg.MsgString msg)
    , paymentMethod : Maybe (DataMsg.MsgMaybePaymentMethod msg)
    , disabled : Bool
    , isEditable : Bool
    }


view : Config msg -> List (Html msg)
view { entityName, addressLine1, addressLine2, city, state, postalCode, purposeCode, isSubcontracted, isPartialPayment, isExistingLiability, amount, paymentDate, paymentMethod, disabled, isEditable } =
    [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
            , Input.text
                [ Input.id "recipient-name"
                , Input.onInput (toMsg entityName)
                , Input.placeholder "Enter recipient name"
                , Input.value (toData entityName)
                , Input.disabled disabled
                ]
            ]
        ]
    ]
        ++ Address.view
            { addressLine1 = addressLine1
            , addressLine2 = addressLine2
            , city = city
            , state = state
            , postalCode = postalCode
            , disabled = disabled
            }
        ++ [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ PurposeCode.select (toData purposeCode) (toMsg purposeCode) disabled ] ]
           ]
        ++ YesOrNo.view
            { isSubcontracted = isSubcontracted
            , isPartialPayment = isPartialPayment
            , isExistingLiability = isExistingLiability
            , disabled = disabled
            }
        ++ (case ( amount, paymentDate, paymentMethod ) of
                ( Just a, Just p, Just pm ) ->
                    AmountDate.view { amount = a, paymentDate = p }
                        ++ [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] (PaymentMethod.dropdown (toData pm) (toMsg pm)) ]
                           ]

                _ ->
                    []
           )
