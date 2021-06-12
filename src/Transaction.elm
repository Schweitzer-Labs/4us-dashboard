module Transaction exposing (Model, decoder, init)

import Direction exposing (Direction)
import EntityType exposing (EntityType)
import Json.Decode as Decode exposing (Decoder, bool, int, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (optional, required)
import PaymentMethod exposing (PaymentMethod)
import PurposeCode exposing (PurposeCode)
import TransactionType exposing (TransactionType)


type alias Model =
    { id : String
    , committeeId : String
    , direction : Direction
    , amount : Int
    , paymentMethod : PaymentMethod
    , bankVerified : Bool
    , ruleVerified : Bool
    , initiatedTimestamp : Int
    , bankVerifiedTimestamp : Maybe Int
    , ruleVerifiedTimestamp : Maybe Int
    , purposeCode : Maybe PurposeCode
    , refCode : Maybe String
    , firstName : Maybe String
    , middleName : Maybe String
    , lastName : Maybe String
    , addressLine1 : Maybe String
    , addressLine2 : Maybe String
    , city : Maybe String
    , state : Maybe String
    , postalCode : Maybe String
    , employer : Maybe String
    , occupation : Maybe String
    , entityType : Maybe EntityType
    , companyName : Maybe String
    , phoneNumber : Maybe String
    , emailAddress : Maybe String
    , transactionType : Maybe TransactionType
    , attestsToBeingAnAdultCitizen : Maybe Bool
    , stripePaymentIntentId : Maybe String
    , cardNumberLastFourDigits : Maybe String
    , entityName : Maybe String
    , isSubcontracted : Maybe Bool
    , isPartialPayment : Maybe Bool
    , isExistingLiability : Maybe Bool
    }


init : Model
init =
    { id = ""
    , committeeId = ""
    , direction = Direction.Out
    , amount = 0
    , paymentMethod = PaymentMethod.Other
    , bankVerified = False
    , ruleVerified = False
    , initiatedTimestamp = 0
    , bankVerifiedTimestamp = Nothing
    , ruleVerifiedTimestamp = Nothing
    , purposeCode = Nothing
    , refCode = Nothing
    , firstName = Nothing
    , middleName = Nothing
    , lastName = Nothing
    , addressLine1 = Nothing
    , addressLine2 = Nothing
    , city = Nothing
    , state = Nothing
    , postalCode = Nothing
    , employer = Nothing
    , occupation = Nothing
    , entityType = Nothing
    , companyName = Nothing
    , phoneNumber = Nothing
    , emailAddress = Nothing
    , transactionType = Nothing
    , attestsToBeingAnAdultCitizen = Nothing
    , stripePaymentIntentId = Nothing
    , cardNumberLastFourDigits = Nothing
    , entityName = Nothing
    , isSubcontracted = Nothing
    , isPartialPayment = Nothing
    , isExistingLiability = Nothing
    }


maybeString name =
    optional name (Decode.map Just string) Nothing


maybeInt name =
    optional name (Decode.map Just int) Nothing


maybeBool name =
    optional name (Decode.map Just bool) Nothing


maybePurposeCode name =
    optional name (Decode.map PurposeCode.fromString string) Nothing


maybeEntityType name =
    optional name (Decode.map EntityType.fromString string) Nothing


maybeTransactionType name =
    optional name (Decode.map TransactionType.fromString string) Nothing


decoder : Decode.Decoder Model
decoder =
    Decode.succeed Model
        |> required "id" string
        |> required "committeeId" string
        |> required "direction" Direction.decoder
        |> required "amount" int
        |> required "paymentMethod" PaymentMethod.decoder
        |> required "bankVerified" bool
        |> required "ruleVerified" bool
        |> required "initiatedTimestamp" int
        |> maybeInt "bankVerifiedTimestamp"
        |> maybeInt "ruleVerifiedTimestamp"
        |> maybePurposeCode "purposeCode"
        |> maybeString "refCode"
        |> maybeString "firstName"
        |> maybeString "middleName"
        |> maybeString "lastName"
        |> maybeString "addressLine1"
        |> maybeString "addressLine2"
        |> maybeString "city"
        |> maybeString "state"
        |> maybeString "postalCode"
        |> maybeString "employer"
        |> maybeString "occupation"
        |> maybeEntityType "entityType"
        |> maybeString "companyName"
        |> maybeString "phoneNumber"
        |> maybeString "emailAddress"
        |> maybeTransactionType "transactionType"
        |> maybeBool "attestsToBeingAnAdultCitizen"
        |> maybeString "stripePaymentIntentId"
        |> maybeString "cardNumberLastFourDigits"
        |> maybeString "entityName"
        |> maybeBool "isSubcontracted"
        |> maybeBool "isPartialPayment"
        |> maybeBool "isExistingLiability"
