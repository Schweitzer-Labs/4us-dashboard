module DisbInfo exposing (Config, view)

import Address
import AmountDate
import AppInput exposing (inputText)
import Asset
import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import DataMsg exposing (toData, toMsg)
import Html exposing (Html, div, span, text)
import Html.Attributes as Attr exposing (attribute, class, for)
import Html.Events exposing (onClick)
import PaymentMethod
import PurposeCode exposing (PurposeCode(..))
import YesOrNo exposing (yesOrNo)


type alias Config msg =
    { checkNumber : DataMsg.MsgString msg
    , entityName : DataMsg.MsgString msg
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
    , explanation : DataMsg.MsgString msg
    , disabled : Bool
    , isEditable : Bool
    , toggleEdit : msg
    , maybeError : Maybe String
    , txnID : Maybe String
    , cyId : String
    }


view : Config msg -> List (Html msg)
view { checkNumber, entityName, addressLine1, addressLine2, city, state, postalCode, purposeCode, explanation, isSubcontracted, isPartialPayment, isExistingLiability, isInKind, amount, paymentDate, paymentMethod, disabled, isEditable, toggleEdit, maybeError, txnID, cyId } =
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
                        [ text "*Recipient Info"
                        , if isEditable then
                            span [ class "hover-underline hover-pointer", Spacing.ml2, onClick toggleEdit ]
                                [ if disabled == True then
                                    Asset.editGlyph []

                                  else
                                    Asset.redoGlyph []
                                ]

                          else
                            span [] []
                        ]
                    , Input.text
                        [ Input.id "recipient-name"
                        , Input.onInput (toMsg entityName)
                        , Input.value (toData entityName)
                        , Input.disabled disabled
                        , Input.attrs [ attribute "data-cy" (cyId ++ "recipientName"), class <| AppInput.inputStyle disabled ]
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
            , id = "createDisb"
            }
        ++ [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ PurposeCode.select cyId (toData purposeCode) (toMsg purposeCode) disabled ] ]
           ]
        ++ explanationRow (toData purposeCode) explanation disabled
        ++ [ Grid.row []
                [ yesOrNo (cyId ++ "isSubcontracted") "Is expenditure subcontracted?" isSubcontracted txnID disabled
                , yesOrNo (cyId ++ "isPartialPayment") "Is expenditure a partial payment?" isPartialPayment txnID disabled
                , yesOrNo (cyId ++ "isExistingLiability") "Is this an existing Liability?" isExistingLiability txnID disabled
                , yesOrNo (cyId ++ "isInKind") "Is this an In-Kind payment?" isInKind txnID disabled
                ]
           ]
        ++ (case ( amount, paymentDate, paymentMethod ) of
                ( Just a, Just p, Just pm ) ->
                    AmountDate.view { amount = a, paymentDate = p, disabled = disabled, label = "*Payment Date", cyId = cyId }
                        ++ [ Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] (PaymentMethod.dropdown cyId (toData pm) (toMsg pm) True) ]
                           ]
                        ++ (if toData pm == Just PaymentMethod.Check then
                                [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
                                    [ Grid.col []
                                        [ inputText (toMsg checkNumber) (toData checkNumber) False "createDisbCheck" "*Check Number" ]
                                    ]
                                ]

                            else
                                []
                           )

                ( Just a, Just p, _ ) ->
                    AmountDate.view { amount = a, paymentDate = p, disabled = disabled, label = "*Payment Date", cyId = cyId }

                _ ->
                    []
           )


explanationRow : Maybe PurposeCode -> DataMsg.MsgString msg -> Bool -> List (Html msg)
explanationRow code explanation disabled =
    case code of
        Just OTHER ->
            [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
                [ Grid.col []
                    [ inputText (toMsg explanation) (toData explanation) disabled "createDisbExpl" "*Explanation" ]
                ]
            ]

        _ ->
            []
