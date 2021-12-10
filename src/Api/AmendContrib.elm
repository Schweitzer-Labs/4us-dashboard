module Api.AmendContrib exposing (EncodeModel, decoder, encode, query, send, successDecoder)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldNotZero, optionalFieldOwners, optionalFieldString, optionalFieldStringInt)
import Config
import EmploymentStatus
import EntityType exposing (fromMaybeToStringWithDefaultInd)
import Http
import InKindType
import Json.Decode as Decode
import Json.Encode as Encode
import OrgOrInd
import Owners exposing (Owners)
import PaymentMethod
import Session
import Timestamp exposing (dateStringToMillis)
import Transaction


query : String
query =
    """
    mutation(
      $committeeId: String!
      $transactionId: String!
      $amount: Float
      $paymentMethod: PaymentMethod
      $owners: [Owner!]
      $firstName: String
      $lastName: String
      $addressLine1: String
      $city: String
      $state: State
      $postalCode: String
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
          owners: $owners
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


type alias EncodeModel =
    { txn : Transaction.Model
    , checkNumber : String
    , paymentDate : String
    , paymentMethod : PaymentMethod.Model
    , emailAddress : String
    , phoneNumber : String
    , firstName : String
    , middleName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , employmentStatus : Maybe EmploymentStatus.Model
    , employer : String
    , occupation : String
    , entityName : String
    , maybeOrgOrInd : Maybe OrgOrInd.Model
    , maybeEntityType : Maybe EntityType.Model
    , amount : Int
    , owners : Owners.Owners
    , ownerName : String
    , committeeId : String
    , inKindDesc : String
    , inKindType : Maybe InKindType.Model
    }


encode : (a -> EncodeModel) -> a -> Http.Body
encode mapper val =
    let
        model =
            mapper val

        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.txn.committeeId )
                , ( "transactionId", Encode.string model.txn.id )
                , ( "amount", Encode.int model.txn.amount )
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
                    ++ optionalFieldOwners "owners" model.owners
                    ++ optionalFieldString "employer" model.employer
                    ++ optionalFieldString "occupation" model.occupation
                    ++ optionalFieldString "addressLine2" model.addressLine2
                    ++ optionalFieldString "occupation" model.occupation
                    ++ optionalFieldString "phoneNumber" model.phoneNumber
                    ++ optionalFieldString "employmentStatus" (EmploymentStatus.fromMaybeToString model.employmentStatus)
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


send : (Result Http.Error MutationResponse -> msg) -> Config.Model -> Session.Model -> Http.Body -> Cmd msg
send =
    GraphQL.send decoder
