module DiscCsv exposing (Model, decoder, disclosureRowMap, labels)

import Csv.Decode as Decode exposing (Decoder, FieldNames(..))
import DataTable exposing (DataRow)
import Html exposing (text)


type alias Model =
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


labels : List String
labels =
    [ "FILER_ID"
    , "FILING_PERIOD_ID"
    , "FILING_CAT_ID"
    , "RESIG_TERM_TYPE_ID"
    , "R_FILING_DATE"
    , "FILING_SCHED_ID"
    , "LOAN_LIB_NUMBER"
    , "TRANS_NUMBER"
    , "TRANS_MAPPING"
    , "SCHED_DATE"
    , "ORG_DATE"
    , "CNTRBR_TYPE_ID"
    , "CNTRBN_TYPE_ID"
    , "TRANSFER_TYPE_ID"
    , "RECEIPT_TYPE_ID"
    , "RECEIPT_CODE_ID"
    , "PURPOSE_CODE_ID"
    , "Is Expenditure Subcontracted?"
    , "Is Expenditure a Partial Payment?"
    , "Is this existing Liability?"
    , "Is Liability a Partial Forgiven?"
    , "FLNG_ENT_NAME"
    , "FLNG_ENT_FIRST_NAME"
    , "FLNG_ENT_MIDDLE_NAME"
    , "FLNG_ENT_LAST_NAME"
    , "FLNG_ENT_ADD1"
    , "FLNG_ENT_CITY"
    , "FLNG_ENT_STATE"
    , "FLNG_ENT_ZIP"
    , "FLNG_ENT_COUNTRY"
    , "PAYMENT_TYPE_ID"
    , "PAY_NUMBER"
    , "OWED_AMT"
    , "ORG_AMT"
    , "TRANS_EXPLNTN"
    , "LOAN_OTHER_ID"
    , "R_ITEMIZED"
    , "R_LIABILITY"
    , "ELECTION_DATE"
    , "ELECTION_TYPE"
    , "ELECTION_YEAR"
    , "TREAS_ID"
    , "TREAS_OCCUPATION"
    , "TREAS_EMPLOYER"
    , "TREAS_ADD1"
    , "TREAS_CITY"
    , "TREAS_STATE"
    , "TREAS_ZIP"
    , "PART_FLNG_ENT_ID"
    , "OFFICE_ID"
    , "DISTRICT"
    , "DIST_OFF_CAND_BAL_PROP"
    , "IE_CNTRBR_OCC"
    , "IE_CNTRBR_EMP"
    , "IE_DESC"
    , "R_IE_SUPPORTED"
    , "R_IE_INCLUDED"
    , "R_PARENT"
    ]


decoder : Decoder Model
decoder =
    Decode.into Model
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


disclosureRowMap : ( Maybe a, Maybe msg, Model ) -> ( Maybe msg, DataRow msg )
disclosureRowMap ( _, maybeMsg, d ) =
    ( maybeMsg
    , [ ( "", text d.filerId )
      , ( "", text d.filingPeriodId )
      , ( "", text d.filingCatId )
      , ( "", text d.electId )
      , ( "", text d.resigTermTypeId )
      , ( "", text d.rFilingDate )
      , ( "", text d.filingSchedId )
      , ( "", text d.loanLibNumber )
      , ( "", text d.transNumber )
      , ( "", text d.transMapping )
      , ( "", text d.schedDate )
      , ( "", text d.orgDate )
      , ( "", text d.cntrbrTypeId )
      , ( "", text d.cntrbnTypeId )
      , ( "", text d.transferTypeId )
      , ( "", text d.receiptTypeId )
      , ( "", text d.receiptCodeId )
      , ( "", text d.purposeCodeId )
      , ( "", text d.isExpenditureSubcontracted )
      , ( "", text d.isExpenditureAPartialPayment )
      , ( "", text d.isThisExistingLiability )
      , ( "", text d.isLiabilityAPartialForgiven )
      , ( "", text d.flngEntName )
      , ( "", text d.flngEntFirstName )
      , ( "", text d.flngEntMiddleName )
      , ( "", text d.flngEntLastName )
      , ( "", text d.flngEntAdd1 )
      , ( "", text d.flngEntCity )
      , ( "", text d.flngEntZip )
      , ( "", text d.flngEntCountry )
      , ( "", text d.paymentTypeId )
      , ( "", text d.payNumber )
      , ( "", text d.owedAmt )
      , ( "", text d.orgAmt )
      , ( "", text d.transExplntn )
      , ( "", text d.loanOtherId )
      , ( "", text d.rItemized )
      , ( "", text d.rLiability )
      , ( "", text d.electionDate )
      , ( "", text d.electionType )
      , ( "", text d.electionYear )
      , ( "", text d.treasId )
      , ( "", text d.treasOccupation )
      , ( "", text d.treasEmployer )
      , ( "", text d.treasAdd1 )
      , ( "", text d.treasCity )
      , ( "", text d.treasState )
      , ( "", text d.treasZip )
      , ( "", text d.partFlngEntId )
      , ( "", text d.officeId )
      , ( "", text d.district )
      , ( "", text d.distOffCandBalProp )
      , ( "", text d.ieCntrbrOcc )
      , ( "", text d.ieContrbrEmp )
      , ( "", text d.ieDesc )
      , ( "", text d.rIeSupported )
      , ( "", text d.rIeIncluded )
      , ( "", text d.rParent )
      ]
    )
