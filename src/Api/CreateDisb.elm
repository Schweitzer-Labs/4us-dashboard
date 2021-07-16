module Api.CreateDisb exposing (encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldString)
import Bootstrap.Modal exposing (Body)
import Cents
import Config exposing (Config)
import CreateDisbursement
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import PaymentMethod
import PurposeCode
import Timestamp exposing (dateStringToMillis)
import TransactionType


query : String
query =
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


encode : CreateDisbursement.Model -> Http.Body
encode model =
    let
        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.committeeId )
                , ( "amount", Encode.int <| Cents.fromDollars model.amount )
                , ( "paymentMethod", Encode.string <| PaymentMethod.fromMaybeToString model.paymentMethod )
                , ( "entityName", Encode.string model.entityName )
                , ( "addressLine1", Encode.string model.addressLine1 )
                , ( "city", Encode.string model.city )
                , ( "state", Encode.string model.state )
                , ( "postalCode", Encode.string model.postalCode )
                , ( "isSubcontracted", Encode.bool <| Maybe.withDefault False model.isSubcontracted )
                , ( "isPartialPayment", Encode.bool <| Maybe.withDefault False model.isPartialPayment )
                , ( "isExistingLiability", Encode.bool <| Maybe.withDefault False model.isExistingLiability )
                , ( "purposeCode", Encode.string <| PurposeCode.toString <| Maybe.withDefault PurposeCode.OTHER model.purposeCode )
                , ( "paymentDate", Encode.int <| dateStringToMillis model.paymentDate )
                , ( "transactionType", Encode.string <| TransactionType.toString TransactionType.Disbursement )
                ]
                    ++ optionalFieldString "checkNumber" model.checkNumber
                    ++ optionalFieldString "addressLine2" model.addressLine2
    in
    encodeQuery query variables


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "createDisbursement" <|
                Decode.field "id" <|
                    Decode.string


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send =
    GraphQL.send decoder
