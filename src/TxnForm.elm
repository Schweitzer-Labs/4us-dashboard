module TxnForm exposing (Model(..), fromTxn)

import Direction exposing (Direction(..))
import Transaction


type Model
    = DisbRuleVerified
    | DisbRuleUnverified
    | ContribRuleVerified
    | ContribRuleUnverified
    | ContribUnverified
    | NoOp


fromTxn : Transaction.Model -> Model
fromTxn txn =
    case ( txn.direction, txn.ruleVerified, txn.bankVerified ) of
        -- Disb
        ( Out, True, False ) ->
            DisbRuleVerified

        ( Out, True, True ) ->
            DisbRuleVerified

        ( Out, False, True ) ->
            DisbRuleUnverified

        -- Contrib
        ( In, True, False ) ->
            ContribRuleVerified

        ( In, True, True ) ->
            ContribRuleVerified

        ( In, False, True ) ->
            ContribRuleUnverified

        ( In, False, False ) ->
            ContribUnverified

        _ ->
            NoOp
