module Purpose exposing(Purpose, purposeText, purposeToString)

type Purpose
    = CMAIL
    | CONSL
    | CONSV
    | CNTRB
    | FUNDR
    | LITER
    | OFFICE
    | OTHER
    | PETIT
    | INT
    | POLLS
    | POSTA
    | PRINT
    | PROFL
    | RADIO
    | REIMB
    | RDET
    | RENTO
    | TVADS
    | VOTER
    | WAGES
    | BKFEE
    | LWNSN


purposeText : List (Purpose, String, String)
purposeText =
    [ (CMAIL, "CMAIL", "Campaign Mailings")
    , (CONSL, "CONSL", "Campaign Consultant")
    , (CONSV, "CONSV", "Constituent Services")
    , (CNTRB, "CNTRB", "Political Contributions")
    , (FUNDR, "FUNDR", "Fundraising")
    , (LITER, "LITER", "Campaign Literature")
    , (OFFICE, "OFFICE", "Office Expenses")
    , (OTHER, "OTHER", "Other")
    , (PETIT, "PETIT", "Petition Expenses")
    , (INT, "INT", "Interest Expense")
    , (POLLS, "POLLS", "Polling Costs")
    , (POSTA, "POSTA", "Postage")
    , (PRINT, "PRINT", "Print Ads")
    , (PROFL, "PROFL", "Professional Services")
    , (RADIO, "RADIO", "Radio Ads")
    , (REIMB, "REIMB", "Reimbursement")
    , (RDET, "RDET", "Reimbursement Detail Item")
    , (TVADS, "TVADS", "Television Ads")
    , (VOTER, "VOTER", "Voter Reg. Material")
    , (WAGES, "WAGES", "Campaign Salaries")
    , (BKFEE, "BKFEE", "Bank Frees")
    , (LWNSN, "LWNSN", "Lawn Signs")
   ]

purposeToString : Purpose -> String
purposeToString purpose =
    let maybePurpose = List.head
            <| List.filter (\(p, _, _) -> p == purpose) purposeText
    in
       case maybePurpose of
           Just (_, val, _) ->  val
           Nothing -> ""
