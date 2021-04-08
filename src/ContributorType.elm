module ContributorType exposing (ContributorType, familyRadioList, fromString, isLLC, llc, orgView, toDataString, toDisplayString, toGridString)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select exposing (Item)
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)


type ContributorType
    = Family
    | Individual
    | SoleProprietorship
    | PartnershipIncludingLLPs
    | Corporation
    | Committee
    | Union
    | Association
    | LimitedLiabilityCompany
    | PoliticalActionCommittee
    | PoliticalCommittee
    | Other


toDataString : ContributorType -> String
toDataString contributorType =
    case contributorType of
        Family ->
            "fam"

        Individual ->
            "ind"

        SoleProprietorship ->
            "solep"

        PartnershipIncludingLLPs ->
            "part"

        Corporation ->
            "corp"

        Committee ->
            "comm"

        Union ->
            "union"

        Association ->
            "assoc"

        LimitedLiabilityCompany ->
            "llc"

        PoliticalActionCommittee ->
            "pac"

        PoliticalCommittee ->
            "plc"

        Other ->
            "oth"


fromString : String -> Maybe ContributorType
fromString str =
    case str of
        "fam" ->
            Just Family

        "ind" ->
            Just Individual

        "solep" ->
            Just SoleProprietorship

        "part" ->
            Just PartnershipIncludingLLPs

        "corp" ->
            Just Corporation

        "comm" ->
            Just Committee

        "union" ->
            Just Union

        "assoc" ->
            Just Association

        "llc" ->
            Just LimitedLiabilityCompany

        "pac" ->
            Just PoliticalActionCommittee

        "plc" ->
            Just PoliticalCommittee

        "oth" ->
            Just Other

        _ ->
            Nothing


toDisplayString : ContributorType -> String
toDisplayString contributorType =
    case contributorType of
        Family ->
            "Family"

        Individual ->
            "Individual"

        SoleProprietorship ->
            "Sole Proprietorship"

        PartnershipIncludingLLPs ->
            "Partnership including LLPs"

        Corporation ->
            "Corporation"

        Committee ->
            "Committee"

        Union ->
            "Union"

        Association ->
            "Association"

        LimitedLiabilityCompany ->
            "Professional/Limited Liability Company"

        PoliticalActionCommittee ->
            "Political Action Committee"

        PoliticalCommittee ->
            "Political Committee"

        Other ->
            "Other"


toGridString : ContributorType -> String
toGridString contributorType =
    case contributorType of
        Family ->
            "Family"

        Individual ->
            "Individual"

        SoleProprietorship ->
            "Sole Prop"

        PartnershipIncludingLLPs ->
            "Partnership"

        Corporation ->
            "Corporation"

        Committee ->
            "Committee"

        Union ->
            "Union"

        Association ->
            "Assoc"

        LimitedLiabilityCompany ->
            "LLC"

        PoliticalActionCommittee ->
            "PAC"

        PoliticalCommittee ->
            "Committee"

        Other ->
            "Other"


orgView : (Maybe ContributorType -> msg) -> Maybe ContributorType -> Html msg
orgView msg currentValue =
    Select.select
        [ Select.id "contributorType"
        , Select.onChange (fromString >> msg)
        ]
        [ Select.item [ value "" ] [ text "-- Organization Classification --" ]
        , orgSelect SoleProprietorship currentValue
        , orgSelect PartnershipIncludingLLPs currentValue
        , orgSelect Corporation currentValue
        , orgSelect Committee currentValue
        , orgSelect Union currentValue
        , orgSelect Association currentValue
        , orgSelect LimitedLiabilityCompany currentValue
        , orgSelect PoliticalActionCommittee currentValue
        , orgSelect PoliticalCommittee currentValue
        , orgSelect Other currentValue
        ]


orgSelect : ContributorType -> Maybe ContributorType -> Item msg
orgSelect contributorType currentValue =
    Select.item
        [ value <| toDataString contributorType
        , selected <| Just contributorType == currentValue
        ]
        [ text <| toDisplayString contributorType ]


familyRadioList : (ContributorType -> msg) -> Maybe ContributorType -> List (Html msg)
familyRadioList msg currentValue =
    Radio.radioList "familyOfCandidate"
        [ Radio.createCustom
            [ Radio.id "yes"
            , Radio.inline
            , Radio.onClick (msg Family)
            , Radio.checked (currentValue == Just Family)
            ]
            "Yes"
        , Radio.createCustom
            [ Radio.id "no"
            , Radio.inline
            , Radio.onClick (msg Individual)
            , Radio.checked (currentValue == Just Individual)
            ]
            "No"
        ]


isLLC : ContributorType -> Bool
isLLC contributorType =
    contributorType == LimitedLiabilityCompany


llc : ContributorType
llc =
    LimitedLiabilityCompany
