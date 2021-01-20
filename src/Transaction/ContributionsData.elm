module Transaction.ContributionsData exposing (ContributionsData, decode)

import Aggregations exposing (Aggregations)
import Contribution as Contribution
import Contributions
import Json.Decode as Decode exposing (Decoder)


type alias ContributionsData =
    { contributions : List Contribution.Model
    , aggregations : Aggregations
    }


decode : Decode.Decoder ContributionsData
decode =
    Decode.map2
        ContributionsData
        (Decode.field "transactions" Contributions.decoder)
        (Decode.field "aggregates" Aggregations.decoder)
