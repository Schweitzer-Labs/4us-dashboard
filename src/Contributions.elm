module Contributions exposing (Label(..), decoder, view)

import Asset
import Contribution as Contribution
import DataTable
import Html exposing (Html, img, span, text)
import Html.Attributes exposing (class)
import Json.Decode as Decode


view : (Label -> msg) -> List (Html msg) -> List Contribution.Model -> Html msg
view sortMsg content contributions =
    DataTable.view content (labels sortMsg) contributionRowMap <|
        List.map (\d -> ( Nothing, d )) contributions


contributionRowMap : ( Maybe msg, Contribution.Model ) -> ( Maybe msg, List ( String, Html msg ) )
contributionRowMap ( maybeMsg, c ) =
    let
        status =
            if stringToBool c.verified then
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
                    Maybe.withDefault "Home" c.refCode
    in
    ( Nothing
    , [ ( "Record", text c.record )
      , ( "Date / Time", text c.datetime )
      , ( "Rule", text c.rule )
      , ( "Entity name", text c.entityName )
      , ( "Amount", span [ class "text-success font-weight-bold" ] [ text <| dollar c.amount ] )
      , ( "Payment Method", text c.paymentMethod )
      , ( "Processor", img [ Asset.src Asset.stripeLogo, class "stripe-logo" ] [] )
      , ( "Status", status )
      , ( "Verified", Asset.circleCheckGlyph [ class "text-success data-icon-size" ] )
      , ( "Source", refCode )
      ]
    )


dollar : String -> String
dollar str =
    "$" ++ str


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg Record, "Record" )
    , ( sortMsg DateTime, "Date / Time" )
    , ( sortMsg Rule, "Rule" )
    , ( sortMsg EntityName, "Entity name" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg PaymentMethod, "Payment Method" )
    , ( sortMsg Processor, "Processor" )
    , ( sortMsg Status, "Status" )
    , ( sortMsg Verified, "Verified" )
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
