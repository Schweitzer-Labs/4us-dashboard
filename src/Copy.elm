module Copy exposing (contribUnverifiedDialogue, contribVerifiedDialogue, disbUnverifiedDialogue, disbVerifiedDialogue, llcDialogue, verificationScore)

import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, br, div, span, text)
import Html.Attributes exposing (class)


verificationScore : String
verificationScore =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."


disbUnverifiedDialogue : List (Html msg)
disbUnverifiedDialogue =
    [ span [ class "font-weight-bold" ] [ text "Instructions: " ]
    , text " 4US has confirmed a payment left your bank account."
    , text " Below you’ll see what information  was pulled from your bank statement."
    , text " Please reconcile this transaction with the list of disbursements you pre-populated, or create a new record with the required data."
    , text " This transaction will not show up on your disclosure report until the required compliance data is provided."
    , div [ Spacing.mt3 ] [ text " If you run into any issues please email us at support@4US.net. Our team is ready to help." ]
    ]


contribUnverifiedDialogue : List (Html msg)
contribUnverifiedDialogue =
    [ span [ class "font-weight-bold" ] [ text "Instructions: " ]
    , text " 4US has confirmed a payment came into your bank account."
    , text " Below you’ll see what information was pulled from your bank statement."
    , text " Please reconcile this transaction with the list of contributions you pre-populated, or create a new record with the required data."
    , text " This transaction will not show up on your disclosure report until the required compliance data is provided."
    , div [ Spacing.mt3 ] [ text " If you run into any issues please email us at support@4US.net. Our team is ready to help." ]
    ]


contribVerifiedDialogue : List (Html msg)
contribVerifiedDialogue =
    [ text "You are editing a record that has already been ID verified, reconciled and recorded."
    ]


disbVerifiedDialogue : List (Html msg)
disbVerifiedDialogue =
    [ text "You are editing a record that has already been ID verified, reconciled and recorded."
    ]


llcDialogue : Bool -> Html msg
llcDialogue disabled =
    if disabled then
        text "Ownership Breakdown"

    else
        text "Please specify the current ownership breakdown of your company."
