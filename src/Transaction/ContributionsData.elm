module Transaction.ContributionsData exposing (Contribution, ContributionsData, decode)

import Json.Decode as Decode exposing (Decoder)

type alias Contribution =
    { record : String
    , datetime: String
    , rule: String
    , entityName: String
    , amount: String
    , paymentMethod: String
    , verified: String
    , refCode: Maybe String
    }

type alias Aggregations =
    { balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    , totalInProcessing: String
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
    (Decode.field "aggregates" aggregationsDecoder)


aggregationsDecoder : Decode.Decoder Aggregations
aggregationsDecoder =
    Decode.map8
        Aggregations
        (Decode.field "balance" Decode.string)
        (Decode.field "totalRaised" Decode.string)
        (Decode.field "totalSpent" Decode.string)
        (Decode.field "totalDonors" Decode.string)
        (Decode.field "qualifyingDonors" Decode.string)
        (Decode.field "qualifyingFunds" Decode.string)
        (Decode.field "totalTransactions" Decode.string)
        (Decode.field "totalInProcessing" Decode.string)


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
