module EntityType exposing (EntityType(..), familyRadioList, fromMaybeToStringWithDefaultInd, fromString, isLLC, llc, orgView, toDataString, toDisplayString, toGridString)

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
            "Fam"

        Individual ->
            "Ind"

        SoleProprietorship ->
            "Solep"

        PartnershipIncludingLLPs ->
            "Part"

        Corporation ->
            "Corp"

        Committee ->
            "Comm"

        Union ->
            "Union"

        Association ->
            "Assoc"

        LimitedLiabilityCompany ->
            "Llc"

        PoliticalActionCommittee ->
            "Pac"

        PoliticalCommittee ->
            "Plc"

        Other ->
            "Oth"


fromMaybeToStringWithDefaultInd : Maybe EntityType -> String
fromMaybeToStringWithDefaultInd maybeEntityType =
    toDataString <| Maybe.withDefault Individual maybeEntityType


fromString : String -> Maybe EntityType
fromString str =
    case str of
        "Fam" ->
            Just Family

        "Ind" ->
            Just Individual

        "Solep" ->
            Just SoleProprietorship

        "Part" ->
            Just PartnershipIncludingLLPs

        "Corp" ->
            Just Corporation

        "Comm" ->
            Just Committee

        "Union" ->
            Just Union

        "Assoc" ->
            Just Association

        "Llc" ->
            Just LimitedLiabilityCompany

        "Pac" ->
            Just PoliticalActionCommittee

        "Plc" ->
            Just PoliticalCommittee

        "Oth" ->
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
