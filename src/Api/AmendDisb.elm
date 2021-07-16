module Api.AmendDisb exposing (..)

import Api.GraphQL exposing (encodeQuery)
import Json.Encode as Encode exposing (Value)
import TransactionType exposing (TransactionType)
query : String
query =
    """
    mutation(
          $committeeId: String!
          $transactionId: String!
          $entityName: String
          $addressLine1: String
          $addressLine2: String
          $city: String
          $state: String
          $postalCode: String
          $paymentDate: Float
          $checkNumber: String
        ) {
          amendDisbursement(
            amendDisbursementData: {
              committeeId: $committeeId
              transactionId: $transactionId
              entityName: $entityName
              addressLine1: $addressLine1
              addressLine2: $addressLine2
              city: $city
              state: $state
    		  postalCode: $postalCode
              paymentDate: $paymentDate
              checkNumber: $checkNumber
            }
          ) {
            id
          }
        }
    """
