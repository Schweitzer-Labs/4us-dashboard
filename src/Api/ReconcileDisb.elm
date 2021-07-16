module Api.ReconcileDisb exposing (encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder)
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import TxnForm.DisbRuleUnverified as DisbRuleUnverified


query : String
query =
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


encode : DisbRuleUnverified.Model -> Http.Body
encode model =
    encodeQuery query <|
        Encode.object
            [ ( "selectedTransactions", Encode.list Encode.string <| List.map (\txn -> txn.id) model.selectedTxns )
            , ( "bankTransaction", Encode.string model.bankTxn.id )
            , ( "committeeId", Encode.string model.committeeId )
            ]


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "reconcileDisbursement" <|
                Decode.field "id" <|
                    Decode.string


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
