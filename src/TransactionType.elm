module TransactionType exposing (TransactionType(..), fromString, toDisplayString, toString)


type TransactionType
    = Contribution
    | Disbursement
    | Deposit


fromString : String -> Maybe TransactionType
fromString str =
    case str of
        "contribution" ->
            Just Contribution

        "disbursement" ->
            Just Disbursement

        "deposit" ->
            Just Deposit

        _ ->
            Nothing


toString : TransactionType -> String
toString txnType =
    case txnType of
        Contribution ->
            "contribution"

        Disbursement ->
            "disbursement"

        Deposit ->
            "deposit"


toDisplayString : TransactionType -> String
toDisplayString txnType =
    case txnType of
        Contribution ->
            "Contribution"

        Disbursement ->
            "Disbursement"

        Deposit ->
            "Deposit"
