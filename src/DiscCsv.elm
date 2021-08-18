module DiscCsv exposing (Disclosure, decoder)

import Csv.Decode as Decode exposing (Decoder, FieldNames(..))


type alias Disclosure =
    { filerId : String
    , filingPeriodId : String
    , filingCatId : String
    , electId : String
    , resigTermTypeId : String
    , rFilingDate : String
    , filingSchedId : String
    , loanLibNumber : String
    , transNumber : String
    , transMapping : String
    , schedDate : String
    , orgDate : String
    , cntrbrTypeId : String
    , cntrbnTypeId : String
    , transferTypeId : String
    , receiptTypeId : String
    , receiptCodeId : String
    , purposeCodeId : String
    , isExpenditureSubcontracted : String
    , isExpenditureAPartialPayment : String
    , isThisExistingLiability : String
    , isLiabilityAPartialForgiven : String
    , flngEntName : String
    , flngEntFirstName : String
    , flngEntMiddleName : String
    , flngEntLastName : String
    , flngEntAdd1 : String
    , flngEntCity : String
    , flngEntZip : String
    , flngEntCountry : String
    , paymentTypeId : String
    , payNumber : String
    , owedAmt : String
    , orgAmt : String
    , transExplntn : String
    , loanOtherId : String
    , rItemized : String
    , rLiability : String
    , electionDate : String
    , electionType : String
    , electionYear : String
    , treasId : String
    , treasOccupation : String
    , treasEmployer : String
    , treasAdd1 : String
    , treasCity : String
    , treasState : String
    , treasZip : String
    , partFlngEntId : String
    , officeId : String
    , district : String
    , distOffCandBalProp : String
    , ieCntrbrOcc : String
    , ieContrbrEmp : String
    , ieDesc : String
    , rIeSupported : String
    , rIeIncluded : String
    , rParent : String
    }


decoder : Decoder Disclosure
decoder =
    Decode.into Disclosure
        |> Decode.pipeline (Decode.field "FILER_ID" Decode.string)
        |> Decode.pipeline (Decode.field "FILING_PERIOD_ID" Decode.string)
        |> Decode.pipeline (Decode.field "FILING_CAT_ID" Decode.string)
        |> Decode.pipeline (Decode.field "RESIG_TERM_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "R_FILING_DATE" Decode.string)
        |> Decode.pipeline (Decode.field "FILING_SCHED_ID" Decode.string)
        |> Decode.pipeline (Decode.field "LOAN_LIB_NUMBER" Decode.string)
        |> Decode.pipeline (Decode.field "TRANS_NUMBER" Decode.string)
        |> Decode.pipeline (Decode.field "TRANS_MAPPING" Decode.string)
        |> Decode.pipeline (Decode.field "SCHED_DATE" Decode.string)
        |> Decode.pipeline (Decode.field "ORG_DATE" Decode.string)
        |> Decode.pipeline (Decode.field "CNTRBR_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "CNTRBN_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "TRANSFER_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "RECEIPT_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "RECEIPT_CODE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "PURPOSE_CODE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "Is Expenditure Subcontracted?" Decode.string)
        |> Decode.pipeline (Decode.field "Is Expenditure a Partial Payment?" Decode.string)
        |> Decode.pipeline (Decode.field "Is this existing Liability?" Decode.string)
        |> Decode.pipeline (Decode.field "Is Liability a Partial Forgiven?" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_NAME" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_FIRST_NAME" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_MIDDLE_NAME" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_LAST_NAME" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_ADD1" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_CITY" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_STATE" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_ZIP" Decode.string)
        |> Decode.pipeline (Decode.field "FLNG_ENT_COUNTRY" Decode.string)
        |> Decode.pipeline (Decode.field "PAYMENT_TYPE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "PAY_NUMBER" Decode.string)
        |> Decode.pipeline (Decode.field "OWED_AMT" Decode.string)
        |> Decode.pipeline (Decode.field "ORG_AMT" Decode.string)
        |> Decode.pipeline (Decode.field "TRANS_EXPLNTN" Decode.string)
        |> Decode.pipeline (Decode.field "LOAN_OTHER_ID" Decode.string)
        |> Decode.pipeline (Decode.field "R_ITEMIZED" Decode.string)
        |> Decode.pipeline (Decode.field "R_LIABILITY" Decode.string)
        |> Decode.pipeline (Decode.field "ELECTION_DATE" Decode.string)
        |> Decode.pipeline (Decode.field "ELECTION_TYPE" Decode.string)
        |> Decode.pipeline (Decode.field "ELECTION_YEAR" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_ID" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_OCCUPATION" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_EMPLOYER" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_ADD1" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_CITY" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_STATE" Decode.string)
        |> Decode.pipeline (Decode.field "TREAS_ZIP" Decode.string)
        |> Decode.pipeline (Decode.field "PART_FLNG_ENT_ID" Decode.string)
        |> Decode.pipeline (Decode.field "OFFICE_ID" Decode.string)
        |> Decode.pipeline (Decode.field "DISTRICT" Decode.string)
        |> Decode.pipeline (Decode.field "DIST_OFF_CAND_BAL_PROP" Decode.string)
        |> Decode.pipeline (Decode.field "IE_CNTRBR_OCC" Decode.string)
        |> Decode.pipeline (Decode.field "IE_CNTRBR_EMP" Decode.string)
        |> Decode.pipeline (Decode.field "IE_DESC" Decode.string)
        |> Decode.pipeline (Decode.field "R_IE_SUPPORTED" Decode.string)
        |> Decode.pipeline (Decode.field "R_IE_INCLUDED" Decode.string)
        |> Decode.pipeline (Decode.field "R_PARENT" Decode.string)
