module Api.CreateContrib exposing (EncodeModel, encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldNotZero, optionalFieldOwners, optionalFieldString, optionalFieldStringInt)
import Cents
import Config exposing (Config)
import Date
import EmploymentStatus
import EntityType
import Http
import InKindType
import Json.Decode as Decode
import Json.Encode as Encode
import Owners
import PaymentMethod
import Timestamp exposing (dateStringToMillis)
import TransactionType


query : String
query =
    """
    mutation(
      $committeeId: String!
      $amount: Float!
      $paymentMethod: PaymentMethod!
      $firstName: String!
      $lastName: String!
      $addressLine1: String!
      $city: String!
      $state: State!
      $postalCode: String!
      $entityType: EntityType!
      $employmentStatus: EmploymentStatus
      $emailAddress: String
      $phoneNumber: String
      $paymentDate: Float!
      $cardNumber: String
      $cardExpirationMonth: Float
      $cardExpirationYear: Float
      $cardCVC: String
      $checkNumber: String
      $entityName: String
      $owners: [Owner!]
      $employer: String
      $occupation: String
      $middleName: String
      $refCode: String
      $inKindDescription: String
      $inKindType: InKindType
      $processPayment: Boolean!
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
        employmentStatus: $employmentStatus
        emailAddress: $emailAddress
        phoneNumber: $phoneNumber
        paymentDate: $paymentDate
        cardNumber: $cardNumber
        cardExpirationMonth: $cardExpirationMonth
        cardExpirationYear: $cardExpirationYear
        cardCVC: $cardCVC
        checkNumber: $checkNumber
        entityName: $entityName
        owners: $owners
        employer: $employer
        occupation: $occupation
        middleName: $middleName
        refCode: $refCode
        inKindDescription: $inKindDescription
        inKindType: $inKindType
        processPayment: $processPayment
      }) {
        id
      }
    }
    """


type alias EncodeModel =
    { committeeId : String
    , amount : String
    , paymentMethod : Maybe PaymentMethod.Model
    , firstName : String
    , lastName : String
    , addressLine1 : String
    , city : String
    , state : String
    , postalCode : String
    , maybeEntityType : Maybe EntityType.Model
    , emailAddress : String
    , paymentDate : String
    , cardNumber : String
    , expirationMonth : String
    , expirationYear : String
    , cvv : String
    , checkNumber : String
    , entityName : String
    , owners : Maybe Owners.Owners
    , employer : String
    , occupation : String
    , middleName : String
    , addressLine2 : String
    , phoneNumber : String
    , employmentStatus : Maybe EmploymentStatus.Model
    , inKindType : Maybe InKindType.Model
    , inKindDesc : String
    , processPayment : Bool
    }


encode : (a -> EncodeModel) -> a -> Http.Body
encode mapper val =
    let
        model =
            mapper val

        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.committeeId )
                , ( "amount", Encode.int <| Cents.fromDollars model.amount )
                , ( "paymentMethod", Encode.string <| PaymentMethod.fromMaybeToString model.paymentMethod )
                , ( "firstName", Encode.string model.firstName )
                , ( "lastName", Encode.string model.lastName )
                , ( "addressLine1", Encode.string model.addressLine1 )
                , ( "city", Encode.string model.city )
                , ( "state", Encode.string model.state )
                , ( "postalCode", Encode.string model.postalCode )
                , ( "entityType", Encode.string <| EntityType.fromMaybeToStringWithDefaultInd model.maybeEntityType )
                , ( "transactionType", Encode.string <| TransactionType.toString TransactionType.Contribution )
                , ( "processPayment", Encode.bool <| model.processPayment )
                ]
                    ++ optionalFieldString "emailAddress" model.emailAddress
                    ++ optionalFieldNotZero "paymentDate" (dateStringToMillis model.paymentDate)
                    ++ optionalFieldString "cardNumber" model.cardNumber
                    ++ optionalFieldStringInt "cardExpirationMonth" model.expirationMonth
                    ++ optionalFieldStringInt "cardExpirationYear" model.expirationYear
                    ++ optionalFieldString "cardCVC" model.cvv
                    ++ optionalFieldString "checkNumber" model.checkNumber
                    ++ optionalFieldString "entityName" model.entityName
                    ++ optionalFieldOwners "owners" (Maybe.withDefault [] model.owners)
                    ++ optionalFieldString "employer" model.employer
                    ++ optionalFieldString "occupation" model.occupation
                    ++ optionalFieldString "middleName" model.middleName
                    ++ optionalFieldString "addressLine2" model.addressLine2
                    ++ optionalFieldString "phoneNumber" model.phoneNumber
                    ++ optionalFieldString "employmentStatus" (EmploymentStatus.fromMaybeToString model.employmentStatus)
                    ++ optionalFieldString "inKindDescription" model.inKindDesc
                    ++ optionalFieldString "inKindType" (Maybe.withDefault "" <| Maybe.map InKindType.toDataString model.inKindType)
    in
    encodeQuery query variables


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "createContribution" <|
                Decode.field "id" <|
                    Decode.string


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
