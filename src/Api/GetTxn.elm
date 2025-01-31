module Api.GetTxn exposing (Model, encode, send, toTxn)

import Api.GraphQL as GraphQL exposing (encodeQuery)
import Config exposing (Config)
import Http exposing (Body)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Transaction


query : String
query =
    """
        query TransactionQuery($committeeId: String!, $id: String!) {
          transaction(committeeId: $committeeId, id: $id) {
            id
            committeeId
            direction
            amount
            paymentMethod
            bankVerified
            ruleVerified
            initiatedTimestamp
            source
            paymentDate
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
            employmentStatus
            occupation
            entityType
            companyName
            owners {
              firstName
              lastName
              addressLine1
              addressLine2
              city
              state
              postalCode
              percentOwnership
            }
            phoneNumber
            emailAddress
            transactionType
            attestsToBeingAnAdultCitizen
            stripePaymentIntentId
            cardNumberLastFourDigits
            checkNumber
            finicityCategory
            finicityBestRepresentation
            finicityPostedDate
            finicityTransactionDate
            finicityNormalizedPayeeName
            finicityDescription
            isSubcontracted
            isPartialPayment
            isExistingLiability
            inKindDescription
            inKindType
            finicityPaymentMethod
            donorVerificationScore
          }
        }
    """


encode : String -> String -> Body
encode committeeId txnId =
    encodeQuery query <|
        Encode.object <|
            [ ( "committeeId", Encode.string committeeId )
            , ( "id", Encode.string txnId )
            ]


type alias Model =
    { data : TransactionObject
    }


type alias TransactionObject =
    { transaction : Transaction.Model
    }


decoder : Decode.Decoder Model
decoder =
    Decode.map
        Model
        (Decode.field "data" decodeTransactionObject)


decodeTransactionObject : Decode.Decoder TransactionObject
decodeTransactionObject =
    Decode.map
        TransactionObject
        (Decode.field "transaction" Transaction.decoder)


toTxn : Model -> Transaction.Model
toTxn model =
    model.data.transaction



-- We want to compose this function i.e encode >> send


send : (Result Http.Error Model -> msg) -> Config -> Body -> Cmd msg
send msg config =
    GraphQL.send decoder msg config
