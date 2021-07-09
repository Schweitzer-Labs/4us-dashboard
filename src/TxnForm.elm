module TxnForm exposing (Model(..), fromTxn)

import Direction exposing (Direction(..))
import Transaction


type Model
    = DisbRuleVerified
    | DisbRuleUnverified
    | NoOp


fromTxn : Transaction.Model -> Model
fromTxn txn =
    case ( txn.direction, txn.ruleVerified, txn.bankVerified ) of
        ( Out, True, False ) ->
            DisbRuleVerified

        ( Out, False, True ) ->
            DisbRuleUnverified

        ( Out, False, False ) ->
            DisbRuleVerified

        _ ->
            NoOp
