module DisbursementInfo exposing (Config, view)

import Address
import AmountDate
import Asset
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg exposing (toData, toMsg)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, for)
import Html.Events exposing (onClick)
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
    , isInKind : DataMsg.MsgMaybeBool msg
    , amount : Maybe (DataMsg.MsgString msg)
    , paymentDate : Maybe (DataMsg.MsgString msg)
    , paymentMethod : Maybe (DataMsg.MsgMaybePaymentMethod msg)
    , disabled : Bool
    , isEditable : Bool
    , toggleEdit : msg
    , maybeError : Maybe String
    }


view : Config msg -> List (Html msg)
view { entityName, addressLine1, addressLine2, city, state, postalCode, purposeCode, isSubcontracted, isPartialPayment, isExistingLiability, isInKind, amount, paymentDate, paymentMethod, disabled, isEditable, toggleEdit, maybeError } =
    let
        errorContent =
            case maybeError of
                Just error ->
                    [ Grid.row [ Row.attrs [ Spacing.mt2, class "text-danger" ] ] [ Grid.col [] [ text error ] ] ]

                Nothing ->
                    []
    in
    errorContent
        ++ [ Grid.row [ Row.attrs [ Spacing.mt2, class "fade-in" ] ]
                [ Grid.col
                    []
                    [ Form.label [ for "recipient-name" ]
                        [ text "Recipient Info"
                        , if isEditable then
                            span [ class "hover-underline hover-pointer", Spacing.ml2, onClick toggleEdit ] [ Asset.editGlyph [] ]

                          else
                            span [] []
                        ]
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
            , isInKind = isInKind
            , disabled = disabled
            }
        ++ (case ( amount, paymentDate, paymentMethod ) of
                ( Just a, Just p, Just pm ) ->
                    AmountDate.view { amount = a, paymentDate = p }
                        ++ [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] (PaymentMethod.dropdown (toData pm) (toMsg pm)) ]
                           ]

                ( Just a, Just p, _ ) ->
                    AmountDate.view { amount = a, paymentDate = p }

                _ ->
                    []
           )
