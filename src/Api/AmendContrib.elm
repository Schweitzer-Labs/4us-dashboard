module Api.AmendContrib exposing (..)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldNotZero, optionalFieldString, optionalFieldStringInt)
import Cents
import Config exposing (Config)
import EntityType exposing (fromMaybeToStringWithDefaultInd)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import PaymentMethod
import Timestamp exposing (dateStringToMillis)
import TxnForm.ContribRuleVerified as ContribRuleVerified


query : String
query =
    """
    mutation(
      $committeeId: String!
      $transactionId: String!
      $amount: Float!
      $paymentMethod: PaymentMethod!
      $firstName: String!
      $lastName: String!
      $addressLine1: String!
      $city: String!
      $state: String!
      $postalCode: String!
      $entityType: EntityType
      $emailAddress: String
      $paymentDate: Float
      $checkNumber: String
      $entityName: String
      $employer: String
      $occupation: String
      $middleName: String
      $refCode: String
      $addressLine2: String
      $companyName: String
      $phoneNumber: String
      $attestsToBeingAnAdultCitizen: Boolean
      $employmentStatus: EmploymentStatus
    ) {
      amendContribution(
        amendContributionData: {
          committeeId: $committeeId
          transactionId: $transactionId
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
          checkNumber: $checkNumber
          entityName: $entityName
          employer: $employer
          occupation: $occupation
          middleName: $middleName
          refCode: $refCode
          addressLine2: $addressLine2
          companyName: $companyName
          phoneNumber: $phoneNumber
          attestsToBeingAnAdultCitizen: $attestsToBeingAnAdultCitizen
          employmentStatus: $employmentStatus
        }
      ) {
        id
      }
    }
    """


encode : ContribRuleVerified.Model -> Http.Body
encode model =
    let
        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.txn.committeeId )
                , ( "transactionId", Encode.string model.txn.id )
                , ( "amount", Encode.int <| Cents.fromDollars <| String.fromInt model.txn.amount )
                , ( "paymentMethod", Encode.string (PaymentMethod.toDataString model.txn.paymentMethod) )
                , ( "firstName", Encode.string model.firstName )
                , ( "lastName", Encode.string model.lastName )
                , ( "addressLine1", Encode.string model.addressLine1 )
                , ( "city", Encode.string model.city )
                , ( "state", Encode.string model.state )
                , ( "postalCode", Encode.string model.postalCode )
                ]
                    ++ optionalFieldString "entityType" (fromMaybeToStringWithDefaultInd model.maybeEntityType)
                    ++ optionalFieldString "emailAddress" model.emailAddress
                    ++ optionalFieldNotZero "paymentDate" (dateStringToMillis model.paymentDate)
                    ++ optionalFieldString "checkNumber" model.checkNumber
                    ++ optionalFieldString "entityName" model.entityName
                    ++ optionalFieldString "employer" model.employer
                    ++ optionalFieldString "occupation" model.occupation
                    ++ optionalFieldString "addressLine2" model.addressLine2
                    ++ optionalFieldString "occupation" model.occupation
                    ++ optionalFieldString "phoneNumber" model.phoneNumber
                    ++ optionalFieldString "employmentStatus" model.employmentStatus
    in
    encodeQuery query variables


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "amendContribution" <|
                Decode.field "id" <|
                    Decode.string


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
