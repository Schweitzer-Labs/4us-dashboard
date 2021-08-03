module InKind exposing (Model(..))

import Json.Decode as Decode exposing (Decoder)


type Model
    = ServicesFacilitiesProvided
    | CampaignExpensesPaid
    | PropertyGiven


fromString : String -> Maybe Model
fromString str =
    case str of
        "Services/Facilities Provided" ->
            Just ServicesFacilitiesProvided

        "Campaign Expenses Paid" ->
            Just CampaignExpensesPaid

        "Property Given" ->
            Just PropertyGiven

        _ ->
            Nothing


toDataString : Model -> String
toDataString src =
    case src of
        ServicesFacilitiesProvided ->
            "Services/FacilitiesProvided"

        CampaignExpensesPaid ->
            "CampaignExpensesPaid"

        PropertyGiven ->
            "PropertyGiven"


fromMaybeToString : Maybe Model -> String
fromMaybeToString =
    Maybe.withDefault "" << Maybe.map toDataString


decoder : Decoder Model
decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "Services/FacilitiesProvided" ->
                        Decode.succeed ServicesFacilitiesProvided

                    "CampaignExpensesPaid" ->
                        Decode.succeed CampaignExpensesPaid

                    "PropertyGiven" ->
                        Decode.succeed PropertyGiven

                    badVal ->
                        Decode.fail <| "Unknown InKind status: " ++ badVal
            )
