module EntityType exposing
    ( Model(..)
    , familyRadioList
    , fromMaybeToStringWithDefaultInd
    , fromString
    , isLLCorLLP
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
import Bootstrap.Utilities.Spacing as Spacing
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, selected, value)


type Model
    = Family
    | Individual
    | SoleProprietorship
    | PartnershipIncludingLLPs
    | Corporation
    | Candidate
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

        Candidate ->
            "Can"

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

        "Can" ->
            Just Candidate

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

        Candidate ->
            "Candidate"

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

        Candidate ->
            "Candidate"

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


familyRadioList : (Model -> msg) -> Maybe Model -> Bool -> Maybe String -> List (Html msg)
familyRadioList msg currentValue disabled txnId =
    let
        id =
            Maybe.withDefault "" txnId
    in
    [ Form.form []
        [ Fieldset.config
            |> Fieldset.asGroup
            |> Fieldset.legend [] []
            |> Fieldset.children
                (Radio.radioList "candidateRelationship"
                    [ Radio.createCustom
                        [ Radio.id <| id ++ "ind"
                        , Radio.inline
                        , Radio.disabled disabled
                        , Radio.onClick (msg Individual)
                        , Radio.checked (currentValue == Just Individual)
                        ]
                        "Not Related"
                    , Radio.createCustom
                        [ Radio.id <| id ++ "can"
                        , Radio.inline
                        , Radio.disabled disabled
                        , Radio.onClick (msg Candidate)
                        , Radio.checked (currentValue == Just Candidate)
                        ]
                        "The candidate or spouse of the candidate"
                    , Radio.createCustomAdvanced
                        [ Radio.id <| id ++ "fam"
                        , Radio.inline
                        , Radio.disabled disabled
                        , Radio.onClick (msg Family)
                        , Radio.checked (currentValue == Just Family)
                        ]
                        (Radio.label []
                            [ text "Family member* of the candidate"
                            , div [ Spacing.mt1, Spacing.ml2 ] [ text "*Defined as the candidate's child, parent, grandparent, brother, or sister of any such persons " ]
                            ]
                        )
                    ]
                )
            |> Fieldset.view
        ]
    ]


isLLCorLLP : Maybe Model -> Bool
isLLCorLLP contributorType =
    case contributorType of
        Just LimitedLiabilityCompany ->
            True

        Just PartnershipIncludingLLPs ->
            True

        _ ->
            False


llc : Model
llc =
    LimitedLiabilityCompany
