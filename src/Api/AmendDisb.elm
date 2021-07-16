module Api.AmendDisb exposing (encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder, optionalFieldNotZero, optionalFieldString, optionalFieldStringInt)
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Timestamp exposing (dateStringToMillis)
import TxnForm.DisbRuleVerified as DisbRuleVerified


query : String
query =
    """
    mutation (
      $committeeId: String!, 
      $transactionId: String!, 
      $entityName: String, 
      $addressLine1: String, 
      $addressLine2: String, 
      $city: String, 
      $state: String, 
      $postalCode: String, 
      $paymentDate: Float, 
      $checkNumber: String
    ) {
      amendDisbursement(
        amendDisbursementData: {
          committeeId: $committeeId, 
          transactionId: $transactionId, 
          entityName: $entityName, 
          addressLine1: $addressLine1, 
          addressLine2: $addressLine2, 
          city: $city, 
          state: $state, 
          postalCode: $postalCode, 
          paymentDate: $paymentDate, 
          checkNumber: $checkNumber
        }
      ) {
        id
      }
    }
    """


encode : DisbRuleVerified.Model -> Http.Body
encode model =
    let
        variables =
            Encode.object <|
                [ ( "committeeId", Encode.string model.txn.committeeId )
                , ( "transactionId", Encode.string model.txn.id )
                ]
                    ++ optionalFieldString "entityName" model.entityName
                    ++ optionalFieldString "addressLine1" model.addressLine1
                    ++ optionalFieldString "addressLine2" model.addressLine2
                    ++ optionalFieldString "city" model.city
                    ++ optionalFieldString "state" model.state
                    ++ optionalFieldString "postalCode" model.postalCode
                    ++ optionalFieldNotZero "paymentDate" (dateStringToMillis model.paymentDate)
                    ++ optionalFieldString "checkNumber" model.postalCode
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
