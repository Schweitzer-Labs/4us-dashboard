module TransactionType exposing (TransactionType(..), fromString, toDisplayString, toString)


type TransactionType
    = Contribution
    | Disbursement
    | Deposit


fromString : String -> Maybe TransactionType
fromString str =
    case str of
        "Contribution" ->
            Just Contribution

        "Disbursement" ->
            Just Disbursement

        "Deposit" ->
            Just Deposit

        _ ->
            Nothing


toString : TransactionType -> String
toString txnType =
    case txnType of
        Contribution ->
            "Contribution"

        Disbursement ->
            "Disbursement"

        Deposit ->
            "Deposit"


toDisplayString : TransactionType -> String
toDisplayString txnType =
    case txnType of
        Contribution ->
            "Contribution"

        Disbursement ->
            "Disbursement"

        Deposit ->
            "Deposit"
