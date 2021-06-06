module Api.GraphQL exposing (contributionMutation, encodeQuery, encodeTransactionQuery, transactionQuery)

import Json.Encode as Encode exposing (Value)
import TransactionType exposing (TransactionType)


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
    """


transactionQuery : String
transactionQuery =
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
          purposeCode
          refCode
          firstName
          middleName
          lastName
          addressLine1
          addressLine2
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
        }
      }
    """


contributionMutation : String
contributionMutation =
    """
    mutation(
      $committeeId: String!
      $paymentMethod: PaymentMethod!
      $amount: Float!
      $firstName: String!
      $lastName: String!
      $addressLine1: String!
      $city: String!
      $state: String!
      $postalCode: String!
      $entityType: EntityType!
      $paymentDate: Float
    ) {
      createContribution(createContributionData: {
        committeeId: $committeeId
        amount: $amount
        paymentMethod: $paymentMethod
        firstName: $firstName
        lastName: $lastName
        addressLine1: $addressLine1
        city: $city
        state: $state
        postalCode: $postalCode
        entityType: $entityType,
        paymentDate: $paymentDate
        
      }) {
        amount
      }
    }
    
    """


encodeQuery : String -> Value -> Value
encodeQuery query variables =
    Encode.object
        [ ( "query", Encode.string query )
        , ( "variables", variables )
        ]


encodeTransactionQuery : String -> String -> Maybe TransactionType -> Value
encodeTransactionQuery query committeeId maybeTxnType =
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
    encodeQuery
        query
        variables



--encodeContributionMutation : String -> String -> Maybe TransactionType -> Value
--encodeContributionMutation query committeeId maybeTxnType =
--    let
--        txnTypeFilter =
--            case maybeTxnType of
--                Just txnType ->
--                    [ ( "transactionType", Encode.string <| TransactionType.toString txnType ) ]
--
--                Nothing ->
--                    []
--    in
--    Encode.object
--        [ ( "query", Encode.string query )
--        , ( "variables"
--          , Encode.object <|
--                [ ( "committeeId", Encode.string committeeId )
--                ]
--                    ++ txnTypeFilter
--          )
--        ]
