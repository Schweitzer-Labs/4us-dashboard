module EntityType exposing
    ( Model(..)
    , familyRadioList
    , fromMaybeToStringWithDefaultInd
    , fromString
    , isLLC
    , llc
    , orgView
    , toDataString
    , toDisplayString
    , toGridString
    )

import Bootstrap.Form as Form
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select exposing (Item)
import Html exposing (Html, text)
import Html.Attributes exposing (class, selected, value)


type Model
    = Family
    | Individual
    | SoleProprietorship
    | PartnershipIncludingLLPs
    | Corporation
    | Union
    | Association
    | LimitedLiabilityCompany
    | PoliticalActionCommittee
    | PoliticalCommittee
    | Other


toDataString : Model -> String
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


fromMaybeToStringWithDefaultInd : Maybe Model -> String
fromMaybeToStringWithDefaultInd maybeEntityType =
    toDataString <| Maybe.withDefault Individual maybeEntityType


fromString : String -> Maybe Model
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


toDisplayString : Model -> String
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


toGridString : Model -> String
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


orgView : (Maybe Model -> msg) -> Maybe Model -> Bool -> Html msg
orgView msg currentValue disabled =
    Select.select
        [ Select.id "entityType"
        , Select.onChange (fromString >> msg)
        , Select.disabled disabled
        ]
        [ Select.item [ value "" ] [ text "-- Organization Classification --" ]
        , orgSelect SoleProprietorship currentValue
        , orgSelect PartnershipIncludingLLPs currentValue
        , orgSelect Corporation currentValue
        , orgSelect Union currentValue
        , orgSelect Association currentValue
        , orgSelect LimitedLiabilityCompany currentValue
        , orgSelect PoliticalActionCommittee currentValue
        , orgSelect PoliticalCommittee currentValue
        , orgSelect Other currentValue
        ]


orgSelect : Model -> Maybe Model -> Item msg
orgSelect entityType currentValue =
    Select.item
        [ value <| toDataString entityType
        , selected <| Just entityType == currentValue
        ]
        [ text <| toDisplayString entityType ]


familyRadioList : (Model -> msg) -> Maybe Model -> Bool -> List (Html msg)
familyRadioList msg currentValue disabled =
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList
                    "familyOfCandidate"
                    [ Radio.createCustom
                        [ Radio.id "familyOfCandidate-yes"
                        , Radio.inline
                        , Radio.onClick (msg Family)
                        , Radio.checked (currentValue == Just Family)
                        , Radio.disabled disabled
                        ]
                        "Yes"
                    , Radio.createCustom
                        [ Radio.id "familyOfCandidate-no"
                        , Radio.inline
                        , Radio.onClick (msg Individual)
                        , Radio.checked (currentValue == Just Individual)
                        , Radio.disabled disabled
                        ]
                        "No"
                    ]
                )
            |> Fieldset.view
        ]
    ]


isLLC : Model -> Bool
isLLC contributorType =
    contributorType == LimitedLiabilityCompany


llc : Model
llc =
    LimitedLiabilityCompany
