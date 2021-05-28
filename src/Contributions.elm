module Contributions exposing (Label(..), decoder, view)

import Asset
import Cents
import Contribution as Contribution
import DataTable
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode
import PaymentMethod


view : (Label -> msg) -> List (Html msg) -> List Contribution.Model -> Html msg
view sortMsg content contributions =
    DataTable.view "Awaiting Contributions." content (labels sortMsg) contributionRowMap <|
        List.map (\d -> ( Nothing, d )) contributions


contributionRowMap : ( Maybe msg, Contribution.Model ) -> ( Maybe msg, List ( String, Html msg ) )
contributionRowMap ( maybeMsg, c ) =
    let
        ruleVerified =
            if c.ruleVerified then
                Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]

        bankVerified =
            if c.bankVerified then
                Asset.circleCheckGlyph [ class "text-success data-icon-size" ]

            else
                Asset.minusCircleGlyph [ class "text-warning data-icon-size" ]

        refCode =
            text <|
                (\n ->
                    if n == "" then
                        "home"

                    else
                        n
                )
                <|
                    Maybe.withDefault "dashboard" c.refCode
    in
    ( Nothing
    , [ ( "Date / Time", text c.datetime )
      , ( "Entity name", text c.entityName )
      , ( "Amount", span [ class "text-success text-right" ] [ text <| Cents.stringToDollar c.amount ] )
      , ( "Rule", text c.rule )
      , ( "Verified", ruleVerified )
      , ( "Payment Method", text <| PaymentMethod.toDisplayString c.paymentMethod )
      , ( "Processor", processor c.paymentMethod )
      , ( "Status", bankVerified )
      , ( "Source", refCode )
      ]
    )


processor : String -> Html msg
processor method =
    if method == "credit" then
        img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] []

    else
        img [ Asset.src Asset.chaseBankLogo, class "tbd-logo" ] []


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg DateTime, "Date / Time" )
    , ( sortMsg EntityName, "Entity name" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg Rule, "Rule" )
    , ( sortMsg Verified, "Verified" )
    , ( sortMsg PaymentMethod, "Payment Method" )
    , ( sortMsg Processor, "Processor" )
    , ( sortMsg Status, "Status" )
    , ( sortMsg ReferenceCode, "Source" )
    ]


type Label
    = Record
    | DateTime
    | Rule
    | EntityName
    | Amount
    | PaymentMethod
    | Processor
    | Status
    | Verified
    | ReferenceCode


stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" ->
            True

        _ ->
            False


decoder : Decode.Decoder (List Contribution.Model)
decoder =
    Decode.list Contribution.decoder
