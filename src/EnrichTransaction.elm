module EnrichTransaction exposing (Msg, encode, update, view)

import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (value)
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Disbursement as Disbursement
import Disbursement.Forms exposing (yesOrNoRows)
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (class, for)
import Json.Encode as Encode
import PurposeCode
import Transaction


errorBorder : String -> List (Html.Attribute Msg)
errorBorder str =
    if String.length str < 2 then
        [ class "border-danger" ]

    else
        []


view : Transaction.Model -> Html Msg
view model =
    Grid.container
        []
        ([ recipientNameRow model
         , addressRow model
         , cityStateZipRow model
         , selectPurposeRow model
         ]
            ++ questionRows model
        )


recipientNameRow : Transaction.Model -> Html Msg
recipientNameRow model =
    let
        entityNameOrBlank =
            Maybe.withDefault "" model.entityName
    in
    Grid.row
        []
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
            , Input.text
                [ Input.id "recipient-name"
                , Input.onInput EntityNameUpdated
                , Input.placeholder "Enter recipient name"
                , Input.attrs (errorBorder entityNameOrBlank)
                , value entityNameOrBlank
                ]
            ]
        ]


selectPurposeRow : Transaction.Model -> Html Msg
selectPurposeRow model =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]


questionRows : Transaction.Model -> List (Html Msg)
questionRows model =
    yesOrNoRows
        UpdateIsSubcontracted
        model.isSubcontracted
        UpdateIsPartialPayment
        model.isPartialPayment
        UpdateIsExistingLiability
        model.isExistingLiability
        True
        False


maybeWithBlank : Maybe String -> String
maybeWithBlank =
    Maybe.withDefault ""


addressRow : Transaction.Model -> Html Msg
addressRow t =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine1"
                , Input.onInput AddressLine1Updated
                , Input.placeholder "Enter Street Address"
                , Input.attrs (errorBorder <| maybeWithBlank t.addressLine1)
                , Input.value <| maybeWithBlank t.addressLine1
                ]
            ]
        , Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine2"
                , Input.onInput AddressLine2Updated
                , Input.placeholder "Secondary Address"
                , Input.value <| maybeWithBlank t.addressLine2
                ]
            ]
        ]


cityStateZipRow : Transaction.Model -> Html Msg
cityStateZipRow t =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "city"
                , Input.onInput CityUpdated
                , Input.placeholder "Enter city"
                , Input.attrs (errorBorder <| maybeWithBlank t.city)
                , Input.value <| maybeWithBlank t.city
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "state"
                , Input.onInput StateUpdated
                , Input.placeholder "State"
                , Input.attrs (errorBorder <| maybeWithBlank t.state)
                , Input.value <| maybeWithBlank t.state
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "postalCode"
                , Input.onInput PostalCodeUpdated
                , Input.placeholder "Postal Code"
                , Input.attrs (errorBorder <| maybeWithBlank t.postalCode)
                , Input.value <| maybeWithBlank t.postalCode
                ]
            ]
        ]


selectPurpose : Transaction.Model -> Html Msg
selectPurpose t =
    let
        purpleCodeOrBlank =
            maybeWithBlank <| Maybe.map PurposeCode.toString t.purposeCode
    in
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange PurposeCodeUpdated
            , Select.attrs <| [ Attribute.value <| purpleCodeOrBlank ] ++ errorBorder purpleCodeOrBlank
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (purpleCodeOrBlank == "")
                    , Attribute.value ""
                    ]
                    [ text "---" ]
                ]
            <|
                List.map
                    (\( _, codeText, purposeText ) ->
                        Select.item
                            [ Attribute.selected (codeText == PurposeCode.fromMaybeToString t.purposeCode)
                            , Attribute.value codeText
                            ]
                            [ text <| purposeText ]
                    )
                    PurposeCode.purposeCodeText
        ]


type Msg
    = EntityNameUpdated String
    | AddressLine1Updated String
    | AddressLine2Updated String
    | CityUpdated String
    | StateUpdated String
    | PostalCodeUpdated String
    | PurposeCodeUpdated String
    | UpdateIsSubcontracted Bool
    | UpdateIsPartialPayment Bool
    | UpdateIsExistingLiability Bool


update : Msg -> Transaction.Model -> ( Transaction.Model, Cmd Msg )
update msg model =
    case msg of
        EntityNameUpdated str ->
            ( { model | entityName = Just str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | addressLine1 = Just str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | addressLine2 = Just str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = Just str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = Just str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = Just str }, Cmd.none )

        PurposeCodeUpdated code ->
            ( { model | purposeCode = PurposeCode.fromString code }, Cmd.none )

        UpdateIsSubcontracted bool ->
            ( { model | isSubcontracted = Just bool }, Cmd.none )

        UpdateIsPartialPayment bool ->
            ( { model | isPartialPayment = Just bool }, Cmd.none )

        UpdateIsExistingLiability bool ->
            ( { model | isExistingLiability = Just bool }, Cmd.none )


encode : Disbursement.Model -> Encode.Value
encode disb =
    Encode.object
        [ ( "disbursementId", Encode.string disb.disbursementId )
        , ( "committeeId", Encode.string disb.committeeId )
        , ( "entityName", Encode.string disb.entityName )
        , ( "addressLine1", Encode.string disb.addressLine1 )
        , ( "addressLine2", Encode.string disb.addressLine2 )
        , ( "city", Encode.string disb.city )
        , ( "state", Encode.string disb.state )
        , ( "postalCode", Encode.string disb.postalCode )
        , ( "purposeCode", Encode.string disb.purposeCode )
        ]
