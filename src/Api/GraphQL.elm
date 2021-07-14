module Api.GraphQL exposing
    ( MutationResponse(..)
    , contributionMutation
    , createDisbursementMutation
    , encodeQuery
    , getTransaction
    , getTransactions
    , graphQLErrorDecoder
    , mutationValidationFailureDecoder
    , reconcileDisbMutation
    , transactionQuery
    )

import Api
import Api.Endpoint exposing (Endpoint(..))
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Transaction.TransactionData as TransactionData exposing (TransactionData)
import Transaction.TransactionsData as TransactionsData exposing (TransactionsData)
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
            committee(committeeId: $committeeId) {
              candidateLastName
              officeType
              bankName
            }
    """


transactionsQuery : String
transactionsQuery =
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


transactionQuery : String
transactionQuery =
    """
        query TransactionQuery($committeeId: String!, $id: String) {
          transaction(committeeId: $committeeId, id: $id) {
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
            isSubcontracted
            isPartialPayment
            isExistingLiability
          }
        }
    """


contributionMutation : String
contributionMutation =
    """
    mutation(
      $committeeId: String!
      $amount: Float!
      $paymentMethod: PaymentMethod!
      $firstName: String!
      $lastName: String!
      $addressLine1: String!
      $city: String!
      $state: String!
      $postalCode: String!
      $entityType: EntityType!
      $emailAddress: String
      $paymentDate: Float
      $cardNumber: String
      $cardExpirationMonth: Float
      $cardExpirationYear: Float
      $cardCVC: String
      $checkNumber: String
      $entityName: String
      $employer: String
      $occupation: String
      $middleName: String
      $refCode: String
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
        entityType: $entityType
        emailAddress: $emailAddress
        paymentDate: $paymentDate
        cardNumber: $cardNumber
        cardExpirationMonth: $cardExpirationMonth
        cardExpirationYear: $cardExpirationYear
        cardCVC: $cardCVC
        checkNumber: $checkNumber
        entityName: $entityName
        employer: $employer
        occupation: $occupation
        middleName: $middleName
        refCode: $refCode
      }) {
        id
      }
    }
    """


reconcileDisbMutation : String
reconcileDisbMutation =
    """
    mutation(
      $committeeId: String!,
      $selectedTransactions: [String!]!,
      $bankTransaction: String!
    ) {
      reconcileDisbursement(
        reconcileDisbursementData: {
            selectedTransactions: $selectedTransactions,
            bankTransaction: $bankTransaction,
            committeeId: $committeeId
        }
      ) {
        id
      }
    }
    """


createDisbursementMutation : String
createDisbursementMutation =
    """
    mutation(
      $committeeId: String!
      $amount: Float!
      $paymentMethod: PaymentMethod!
      $entityName: String!
      $addressLine1: String!
      $city: String!
      $state: String!
      $postalCode: String!
      $isSubcontracted: Boolean!
      $isPartialPayment: Boolean!
      $isExistingLiability: Boolean!
      $purposeCode: PurposeCode!
      $paymentDate: Float!
      $checkNumber: String
      $addressLine2: String
    ) {
      createDisbursement(createDisbursementData: {
        committeeId: $committeeId
        amount: $amount
        paymentMethod: $paymentMethod
        entityName: $entityName
        addressLine1: $addressLine1
        city: $city
        state: $state
        postalCode: $postalCode
        isSubcontracted: $isSubcontracted
        isPartialPayment: $isPartialPayment
        isExistingLiability: $isExistingLiability
        purposeCode: $purposeCode
        paymentDate: $paymentDate
        checkNumber: $checkNumber
        addressLine2: $addressLine2
      }) {
        id
      }
    }
    """


encodeQuery : String -> Value -> Value
encodeQuery query variables =
    Encode.object
        [ ( "query", Encode.string query )
        , ( "variables", variables )
        ]


encodeTransactionsQuery : String -> String -> Maybe TransactionType -> Value
encodeTransactionsQuery query committeeId maybeTxnType =
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


graphQLErrorDecoder : Decode.Decoder (List String)
graphQLErrorDecoder =
    Decode.field "errors" <|
        Decode.list <|
            Decode.field "message" <|
                Decode.string


type MutationResponse
    = Success String
    | ResValidationFailure (List String)


getTransactions :
    Config
    -> String
    -> (Result Http.Error TransactionsData -> msg)
    -> Maybe TransactionType
    -> Cmd msg
getTransactions config committeeId updateMsg maybeTxnType =
    let
        body =
            encodeTransactionsQuery transactionsQuery committeeId maybeTxnType |> Http.jsonBody
    in
    Http.send updateMsg <|
        Api.post (Endpoint config.apiEndpoint) (Api.Token config.token) body <|
            TransactionsData.decode


getTransactionVariables : String -> String -> List ( String, Value )
getTransactionVariables committeeId txnId =
    [ ( "committeeId", Encode.string committeeId )
    , ( "id", Encode.string txnId )
    ]


getTransaction :
    Config
    -> (Result Http.Error TransactionData -> msg)
    -> String
    -> String
    -> Cmd msg
getTransaction config updateMsg committeeId txnId =
    let
        body =
            Http.jsonBody <|
                encodeQuery transactionQuery <|
                    Encode.object <|
                        getTransactionVariables committeeId txnId
    in
    Http.send updateMsg <|
        Api.post (Endpoint config.apiEndpoint) (Api.Token config.token) body <|
            TransactionData.decode


mutationValidationFailureDecoder : Decode.Decoder MutationResponse
mutationValidationFailureDecoder =
    Decode.map ResValidationFailure graphQLErrorDecoder
