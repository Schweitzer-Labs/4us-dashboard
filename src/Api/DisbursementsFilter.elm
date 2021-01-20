module Api.DisbursementsFilter exposing (DisbursementsFilter(..), toQueryParam)

import Url.Builder exposing (QueryParameter, string)


type DisbursementsFilter
    = RuleProcessed Bool
    | BankProcessed Bool


toQueryParam : DisbursementsFilter -> QueryParameter
toQueryParam filter =
    case filter of
        RuleProcessed bool ->
            string "ruleVerified" <|
                if bool then
                    "true"

                else
                    "false"

        BankProcessed bool ->
            string "bankVerified" <|
                if bool then
                    "true"

                else
                    "false"
