module Api.ReconcileTxn exposing (EncodeModel, encode, send)

import Api.GraphQL as GraphQL exposing (MutationResponse(..), encodeQuery, mutationValidationFailureDecoder)
import Config exposing (Config)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Transaction


query : String
query =
    """
    mutation(
      $committeeId: String!,
      $selectedTransactions: [String!]!,
      $bankTransaction: String!
    ) {
      reconcileTransaction(
        reconcileTransactionData: {
            selectedTransactions: $selectedTransactions,
            bankTransaction: $bankTransaction,
            committeeId: $committeeId
        }
      ) {
        id
      }
    }
    """


type alias EncodeModel =
    { selectedTxns : List Transaction.Model
    , bankTxn : Transaction.Model
    , committeeId : String
    }


encode : (a -> EncodeModel) -> a -> Http.Body
encode mapper val =
    let
        model =
            mapper val

        variables =
            Encode.object <|
                [ ( "selectedTransactions", Encode.list Encode.string <| List.map (\txn -> txn.id) model.selectedTxns )
                , ( "bankTransaction", Encode.string model.bankTxn.id )
                , ( "committeeId", Encode.string model.committeeId )
                ]
    in
    encodeQuery query variables


successDecoder : Decode.Decoder MutationResponse
successDecoder =
    Decode.map Success <|
        Decode.field "data" <|
            Decode.field "reconcileTransaction" <|
                Decode.field "id" <|
                    Decode.string


decoder : Decode.Decoder MutationResponse
decoder =
    Decode.oneOf [ successDecoder, mutationValidationFailureDecoder ]


send : (Result Http.Error MutationResponse -> msg) -> Config -> Http.Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
