module Transaction exposing (Model, decoder, init)

import Direction exposing (Direction)
import EmploymentStatus
import EntityType
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
    , paymentDate : Int
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
    , employmentStatus : Maybe EmploymentStatus.Model
    , occupation : Maybe String
    , entityType : Maybe EntityType.Model
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
    , finicityCategory : Maybe String
    , finicityBestRepresentation : Maybe String
    , finicityPostedDate : Maybe Int
    , finicityTransactionDate : Maybe Int
    , finicityNormalizedPayeeName : Maybe String
    , finicityDescription : Maybe String
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
    , paymentDate = 0
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
    , employmentStatus = Nothing
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
    , finicityCategory = Nothing
    , finicityBestRepresentation = Nothing
    , finicityPostedDate = Nothing
    , finicityTransactionDate = Nothing
    , finicityNormalizedPayeeName = Nothing
    , finicityDescription = Nothing
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


maybeEmploymentStatus name =
    optional name (Decode.map EmploymentStatus.fromString string) Nothing


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
        |> required "paymentDate" int
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
        |> maybeEmploymentStatus "employmentStatus"
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
        |> maybeString "finicityCategory"
        |> maybeString "finicityBestRepresentation"
        |> maybeInt "finicityPostedDate"
        |> maybeInt "finicityTransactionDate"
        |> maybeString "finicityNormalizedPayeeName"
        |> maybeString "finicityDescription"
