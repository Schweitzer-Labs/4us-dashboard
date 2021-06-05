module EnrichDisbursement exposing (Msg, encode, update, view)

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


errorBorder : String -> List (Html.Attribute Msg)
errorBorder str =
    if String.length str < 2 then
        [ class "border-danger" ]

    else
        []


view : Disbursement.Model -> Html Msg
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


recipientNameRow : Disbursement.Model -> Html Msg
recipientNameRow model =
    Grid.row
        []
        [ Grid.col
            []
            [ Form.label [ for "recipient-name" ] [ text "Recipient Info" ]
            , Input.text
                [ Input.id "recipient-name"
                , Input.onInput EntityNameUpdated
                , Input.placeholder "Enter recipient name"
                , Input.attrs (errorBorder model.entityName)
                , value model.entityName
                ]
            ]
        ]


selectPurposeRow : Disbursement.Model -> Html Msg
selectPurposeRow model =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]


questionRows : Disbursement.Model -> List (Html Msg)
questionRows model =
    yesOrNoRows
        UpdateIsSubcontracted
        model.isSubcontracted
        UpdateIsPartialPayment
        model.isPartialPayment
        UpdateIsExistingLiability
        model.isExistingLiability
        True


addressRow : Disbursement.Model -> Html Msg
addressRow d =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine1"
                , Input.onInput AddressLine1Updated
                , Input.placeholder "Enter Street Address"
                , Input.attrs (errorBorder d.addressLine1)
                , Input.value d.addressLine1
                ]
            ]
        , Grid.col
            [ Col.lg6 ]
            [ Input.text
                [ Input.id "addressLine2"
                , Input.onInput AddressLine2Updated
                , Input.placeholder "Secondary Address"
                , Input.value d.addressLine2
                ]
            ]
        ]


cityStateZipRow : Disbursement.Model -> Html Msg
cityStateZipRow d =
    Grid.row [ Row.attrs [ Spacing.mt2 ] ]
        [ Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "city"
                , Input.onInput CityUpdated
                , Input.placeholder "Enter city"
                , Input.attrs (errorBorder d.city)
                , Input.value d.city
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "state"
                , Input.onInput StateUpdated
                , Input.placeholder "State"
                , Input.attrs (errorBorder d.state)
                , Input.value d.state
                ]
            ]
        , Grid.col
            [ Col.lg4 ]
            [ Input.text
                [ Input.id "postalCode"
                , Input.onInput PostalCodeUpdated
                , Input.placeholder "Postal Code"
                , Input.attrs (errorBorder d.postalCode)
                , Input.value d.postalCode
                ]
            ]
        ]


selectPurpose : Disbursement.Model -> Html Msg
selectPurpose d =
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange PurposeCodeUpdated
            , Select.attrs <| [ Attribute.value d.purposeCode ] ++ errorBorder d.purposeCode
            ]
          <|
            (++)
                [ Select.item
                    [ Attribute.selected (d.purposeCode == "")
                    , Attribute.value ""
                    ]
                    [ text "---" ]
                ]
            <|
                List.map
                    (\( _, codeText, purposeText ) ->
                        Select.item
                            [ Attribute.selected (codeText == d.purposeCode)
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
    | UpdateIsSubcontracted String
    | UpdateIsPartialPayment String
    | UpdateIsExistingLiability String


update : Msg -> Disbursement.Model -> ( Disbursement.Model, Cmd Msg )
update msg model =
    case msg of
        EntityNameUpdated str ->
            ( { model | entityName = str }, Cmd.none )

        AddressLine1Updated str ->
            ( { model | addressLine1 = str }, Cmd.none )

        AddressLine2Updated str ->
            ( { model | addressLine2 = str }, Cmd.none )

        CityUpdated str ->
            ( { model | city = str }, Cmd.none )

        StateUpdated str ->
            ( { model | state = str }, Cmd.none )

        PostalCodeUpdated str ->
            ( { model | postalCode = str }, Cmd.none )

        PurposeCodeUpdated str ->
            ( { model | purposeCode = str }, Cmd.none )

        UpdateIsSubcontracted str ->
            ( { model | isSubcontracted = str }, Cmd.none )

        UpdateIsPartialPayment str ->
            ( { model | isPartialPayment = str }, Cmd.none )

        UpdateIsExistingLiability str ->
            ( { model | isExistingLiability = str }, Cmd.none )


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
