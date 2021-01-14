module Transaction.ContributionsData exposing (Contribution, ContributionsData, decode)

import Aggregations exposing (Aggregations)
import Json.Decode as Decode exposing (Decoder)


type alias Contribution =
    { record : String
    , datetime : String
    , rule : String
    , entityName : String
    , amount : String
    , paymentMethod : String
    , verified : String
    , refCode : Maybe String
    }


type alias ContributionsData =
    { contributions : List Contribution
    , aggregations : Aggregations
    }


decode : Decode.Decoder ContributionsData
decode =
    Decode.map2
        ContributionsData
        (Decode.field "transactions" listOfContributionsDecoder)
        (Decode.field "aggregates" Aggregations.decoder)


contributionDecoder : Decode.Decoder Contribution
contributionDecoder =
    Decode.map8
        Contribution
        (Decode.field "record" Decode.string)
        (Decode.field "datetime" Decode.string)
        (Decode.field "rule" Decode.string)
        (Decode.field "entityName" Decode.string)
        (Decode.field "amount" Decode.string)
        (Decode.field "paymentMethod" Decode.string)
        (Decode.field "verified" Decode.string)
        (Decode.maybe <| Decode.field "refCode" Decode.string)


listOfContributionsDecoder : Decode.Decoder (List Contribution)
listOfContributionsDecoder =
    Decode.list contributionDecoder
