module EntityType exposing (EntityType(..), familyRadioList, fromString, isLLC, llc, orgView, toDataString, toDisplayString, toGridString)

import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select exposing (Item)
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)


type EntityType
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


toDataString : EntityType -> String
toDataString entityType =
    case entityType of
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


fromString : String -> Maybe EntityType
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


toDisplayString : EntityType -> String
toDisplayString entityType =
    case entityType of
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


toGridString : EntityType -> String
toGridString entityType =
    case entityType of
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


orgView : (Maybe EntityType -> msg) -> Maybe EntityType -> Html msg
orgView msg currentValue =
    Select.select
        [ Select.id "entityType"
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


orgSelect : EntityType -> Maybe EntityType -> Item msg
orgSelect entityType currentValue =
    Select.item
        [ value <| toDataString entityType
        , selected <| Just entityType == currentValue
        ]
        [ text <| toDisplayString entityType ]


familyRadioList : (EntityType -> msg) -> Maybe EntityType -> List (Html msg)
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


isLLC : EntityType -> Bool
isLLC contributorType =
    contributorType == LimitedLiabilityCompany


llc : EntityType
llc =
    LimitedLiabilityCompany
