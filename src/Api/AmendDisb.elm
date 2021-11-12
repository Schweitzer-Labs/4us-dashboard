module Api.AmendDisb exposing (EncodeModel, encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldNotZero, optionalFieldString, optionalFieldStringInt)
import Cents
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import PaymentMethod
import PurposeCode exposing (PurposeCode)
import Timestamp exposing (dateStringToMillis)
import Transaction


query : String
query =
    """
    mutation (
      $committeeId: String!
      $transactionId: String!
      $amount: Float
      $entityName: String
      $addressLine1: String
      $addressLine2: String
      $city: String
      $state: State
      $postalCode: String
      $paymentDate: Float
      $checkNumber: String
      $purposeCode: PurposeCode
      $isExistingLiability: Boolean
      $isPartialPayment: Boolean
      $isSubContracted: Boolean
    ) {
      amendDisbursement(
        amendDisbursementData: {
          committeeId: $committeeId
          transactionId: $transactionId
          amount: $amount
          entityName: $entityName
          addressLine1: $addressLine1
          addressLine2: $addressLine2
          city: $city
          state: $state
          postalCode: $postalCode
          paymentDate: $paymentDate
          checkNumber: $checkNumber
          purposeCode: $purposeCode
          isExistingLiability: $isExistingLiability
          isPartialPayment: $isPartialPayment
          isSubcontracted: $isSubContracted
        }
      ) {
        id
      }
    }
    """


type alias EncodeModel =
    { txn : Transaction.Model
    , entityName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , purposeCode : Maybe PurposeCode
    , isSubcontracted : Maybe Bool
    , isPartialPayment : Maybe Bool
    , isExistingLiability : Maybe Bool
    , isInKind : Maybe Bool
    , amount : String
    , paymentDate : String
    , paymentMethod : Maybe PaymentMethod.Model
    , checkNumber : String
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
                , ( "amount", Encode.int <| Cents.fromDollars model.amount )
                ]
                    ++ optionalFieldString "entityName" model.entityName
                    ++ optionalFieldString "addressLine1" model.addressLine1
                    ++ optionalFieldString "addressLine2" model.addressLine2
                    ++ optionalFieldString "city" model.city
                    ++ optionalFieldString "state" model.state
                    ++ optionalFieldString "postalCode" model.postalCode
                    ++ optionalFieldNotZero "paymentDate" (dateStringToMillis model.paymentDate)
                    ++ optionalFieldString "checkNumber" model.checkNumber
                    ++ (optionalFieldString "purposeCode" <| PurposeCode.fromMaybeToString model.purposeCode)
                    ++ [ ( "isExistingLiability", Encode.bool <| Maybe.withDefault False model.isExistingLiability ) ]
                    ++ [ ( "isPartialPayment", Encode.bool <| Maybe.withDefault False model.isPartialPayment ) ]
                    ++ [ ( "isSubContracted", Encode.bool <| Maybe.withDefault False model.isSubcontracted ) ]
    in
    encodeQuery query variables


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "amendDisbursement" <|
                Decode.field "id" <|
                    Decode.string


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
