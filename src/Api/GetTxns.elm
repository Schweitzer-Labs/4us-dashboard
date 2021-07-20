module Api.GetTxns exposing (Model, encode, send, toAggs, toCommittee, toTxns)

import Aggregations
import Api.GraphQL as GraphQL exposing (encodeQuery)
import Committee
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import TransactionType exposing (TransactionType)
import Transactions


committeeQuery : String
committeeQuery =
    """
    query CommitteeQuery($committeeId: String!, $transactionType: String) {
            aggregations(committeeId: $committeeId) {
              balance
              totalSpent
              totalRaised
              totalDonors
              needsReviewCount
              totalTransactions
              totalContributionsInProcessing
              totalDisbursementsInProcessing
            }
            committee(committeeId: $committeeId) {
              candidateLastName
              officeType
              bankName
            }
    """


query : String
query =
    committeeQuery
        ++ """
        transactions(committeeId: $committeeId, transactionType: $transactionType) {
          id
          committeeId
          direction
          amount
          paymentMethod
          bankVerified
          ruleVerified
          initiatedTimestamp
          paymentDate
          purposeCode
          refCode
          firstName
          middleName
          lastName
          addressLine1
          addressLine2
          entityName
          city
          state
          postalCode
          employer
          occupation
          entityType
          companyName
          phoneNumber
          emailAddress
          transactionType
          attestsToBeingAnAdultCitizen
          stripePaymentIntentId
          cardNumberLastFourDigits
          finicityCategory
          finicityBestRepresentation
          finicityPostedDate
          finicityTransactionDate
          finicityNormalizedPayeeName
          finicityDescription
        }
      }
    """


encode : String -> Maybe TransactionType -> Http.Body
encode committeeId maybeTxnType =
    let
        txnTypeFilter =
            case maybeTxnType of
                Just txnType ->
                    [ ( "transactionType", Encode.string <| TransactionType.toString txnType ) ]

                Nothing ->
                    []

        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string committeeId )
                ]
                    ++ txnTypeFilter
    in
    encodeQuery query variables


type alias Model =
    { data : TransactionsObject
    }


type alias TransactionsObject =
    { transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    }


toTxns : Model -> Transactions.Model
toTxns model =
    model.data.transactions


toAggs : Model -> Aggregations.Model
toAggs model =
    model.data.aggregations


toCommittee : Model -> Committee.Model
toCommittee model =
    model.data.committee


decodeObject : Decode.Decoder TransactionsObject
decodeObject =
    Decode.map3
        TransactionsObject
        (Decode.field "transactions" Transactions.decoder)
        (Decode.field "aggregations" Aggregations.decoder)
        (Decode.field "committee" Committee.decoder)


decode : Decode.Decoder Model
decode =
    Decode.map
        Model
        (Decode.field "data" decodeObject)


send : (Result Http.Error Model -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decode msg config