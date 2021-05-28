module Api.Query exposing (getTransactions)

import Api exposing (Token)
import Api.Endpoint as Endpoint
import Http exposing (Body, Expect)
import Json.Encode as Encode exposing (Value)
import Transaction.TransactionsData as TransactionsData



--getTransactions : String -> Maybe String -> Maybe Bool -> Maybe Bool -> String
--getTransactions committeeId maybeTxnType maybeRuleVerified maybeBankVerified =


getTransactionsQuery : String
getTransactionsQuery =
    """
      committee(committeeId: "pat-miller"){
        committeeName
        candidateFirstName
      }
      aggregations(committeeId: "pat-miller"){
        balance
      }
      transactions(committeeId: "pat-miller"){
        amount,
        initiatedTimestamp,
        firstName,
      }
    """


getTransactions : Token -> Cmd msg
getTransactions token =
    let
        body =
            encodeGraphQL model |> Http.jsonBody
    in
    Http.send GotCreateContributionResponse <|
        Api.post Endpoint.graphql token body <|
            TransactionsData.decode


encodeGraphQL : String -> Value
encodeGraphQL query =
    Encode.object
        [ ( "query", Encode.string query )
        ]
