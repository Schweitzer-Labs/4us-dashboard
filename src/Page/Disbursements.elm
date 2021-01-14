module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Aggregations as Aggregations exposing (Aggregations)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Banner
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Select as Select
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Content
import Disbursements exposing (Disbursement)
import Html exposing (..)
import Html.Attributes exposing (class, for, value)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import PaymentMethod exposing (PaymentMethod(..))
import Purpose exposing (Purpose)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Transaction.DisbursementsData as DD exposing (DisbursementsData)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , disbursements : List Disbursement
    , aggregations : Aggregations
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModalPurpose : Maybe String
    , createDisbursementModalAmount : String
    , createDisbursementModalVendorName : String
    , createDisbursementModalVendorAddress1 : String
    , createDisbursementModalVendorAddress2 : String
    , createDisbursementModalVendorCity : String
    , createDisbursementModalVendorState : String
    , createDisbursementModalVendorPostalCode : String
    , createDisbursementDate : String
    , createDisbursementModalPaymentMethod : Maybe PaymentMethod
    , createDisbursementModalCheckNumber : String
    , committeeId : String
    }


init : Session -> String -> ( Model, Cmd Msg )
init session committeeId =
    ( { session = session
      , committeeId = committeeId
      , timeZone = Time.utc
      , disbursements = []
      , aggregations = Aggregations.init
      , createDisbursementModalVisibility = Modal.hidden
      , createDisbursementModalPurpose = Nothing
      , createDisbursementModalAmount = ""
      , createDisbursementModalVendorName = ""
      , createDisbursementModalVendorAddress1 = ""
      , createDisbursementModalVendorAddress2 = ""
      , createDisbursementModalVendorCity = ""
      , createDisbursementModalVendorState = ""
      , createDisbursementModalVendorPostalCode = ""
      , createDisbursementDate = ""
      , createDisbursementModalPaymentMethod = Nothing
      , createDisbursementModalCheckNumber = ""
      }
    , getDisbursementsData committeeId
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div
            []
            [ Banner.container [] [ Aggregations.view model.aggregations ]
            , Content.container [] [ Disbursements.view [ createDisbursementModalButton ] model.disbursements ]
            , createDisbursementModal model
            ]
    }


selectPurpose : Model -> Html Msg
selectPurpose model =
    Form.group
        []
        [ Form.label [ for "purpose" ] [ text "Purpose" ]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange CreateDisbursementModalPurposeUpdated
            ]
          <|
            (++) [ Select.item [] [ text "---" ] ] <|
                List.map
                    (\( _, codeText, purposeText ) -> Select.item [ value codeText ] [ text <| purposeText ])
                    Purpose.purposeText
        ]


renderPaymentMethodForm : Model -> Html Msg
renderPaymentMethodForm model =
    Grid.containerFluid
        []
        [ Grid.row [ Row.attrs [ Spacing.mt2 ] ]
            [ Grid.col
                []
                [ Form.label [ for "recipient-name" ] [ text "Recipient Name" ]
                , Input.text [ Input.id "recipient-name", Input.onInput CheckRecipientUpdated, Input.placeholder "Enter recipient name" ]
                ]
            ]
        , Grid.row [ Row.attrs [ Spacing.mt2 ] ] [ Grid.col [] [ selectPurpose model ] ]
        , Grid.row []
            [ Grid.col
                [ Col.lg4 ]
                [ Form.label [ for "amount" ] [ text "Amount" ]
                , Input.text [ Input.id "amount", Input.onInput CheckAmountUpdated, Input.placeholder "Enter amount" ]
                ]
            , Grid.col
                [ Col.lg4 ]
                [ Form.label [ for "check-number" ] [ text "Check Number" ]
                , Input.text [ Input.id "check-number", Input.onInput CheckNumberUpdated, Input.placeholder "Enter check number" ]
                ]
            , Grid.col
                [ Col.lg4 ]
                [ Form.label [ for "date" ] [ text "Date" ]
                , Input.date [ Input.id "date", Input.onInput CheckDateUpdated ]
                ]
            ]
        ]


createDisbursementModal : Model -> Html Msg
createDisbursementModal model =
    Modal.config HideCreateDisbursementModal
        |> Modal.withAnimation AnimateCreateDisbursementModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Create Disbursement" ]
        |> Modal.body
            []
            [ renderPaymentMethodForm model ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ Grid.row
                    [ Row.aroundXs ]
                    [ Grid.col
                        [ Col.attrs [ class "text-left" ] ]
                        [ Button.button
                            [ Button.outlinePrimary
                            , Button.large
                            , Button.attrs [ onClick HideCreateDisbursementModal ]
                            ]
                            [ text "Exit" ]
                        ]
                    , Grid.col
                        [ Col.attrs [ class "text-right" ] ]
                        [ Button.button
                            [ Button.primary
                            , Button.large
                            , Button.attrs [ onClick SubmitCreateDisbursement, class "text-right" ]
                            ]
                            [ text "Submit" ]
                        ]
                    ]
                ]
            ]
        |> Modal.view model.createDisbursementModalVisibility


createDisbursementModalButton : Html Msg
createDisbursementModalButton =
    Button.button
        [ Button.outlineSuccess, Button.attrs [ onClick <| ShowCreateDisbursementModal ] ]
        [ text "Create Disbursement" ]



-- TAGS
-- UPDATE


type Msg
    = GotSession Session
    | LoadDisbursementsData (Result Http.Error DisbursementsData)
    | HideCreateDisbursementModal
    | ShowCreateDisbursementModal
    | AnimateCreateDisbursementModal Modal.Visibility
    | CreateDisbursementModalPurposeUpdated String
    | CreateDisbursementModalPaymentMethodUpdated String
    | CheckAmountUpdated String
    | CheckRecipientUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
    | GotCreateDisbursementResponse (Result Http.Error String)
    | SubmitCreateDisbursement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        ShowCreateDisbursementModal ->
            ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none )

        HideCreateDisbursementModal ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
                , createDisbursementModalPaymentMethod = Nothing
                , createDisbursementModalPurpose = Nothing
              }
            , Cmd.none
            )

        SubmitCreateDisbursement ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
                , createDisbursementModalPaymentMethod = Nothing
                , createDisbursementModalPurpose = Nothing
              }
            , createDisbursement model
            )

        AnimateCreateDisbursementModal visibility ->
            ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )

        CreateDisbursementModalPurposeUpdated str ->
            ( { model | createDisbursementModalPurpose = Just str }, Cmd.none )

        CreateDisbursementModalPaymentMethodUpdated str ->
            let
                paymentMethod =
                    PaymentMethod.init str
            in
            ( { model | createDisbursementModalPaymentMethod = paymentMethod }, Cmd.none )

        CheckAmountUpdated str ->
            ( { model | createDisbursementModalAmount = str }, Cmd.none )

        CheckRecipientUpdated str ->
            ( { model | createDisbursementModalVendorName = str }, Cmd.none )

        CheckNumberUpdated str ->
            ( { model | createDisbursementModalCheckNumber = str }, Cmd.none )

        CheckDateUpdated str ->
            ( { model | createDisbursementDate = str }, Cmd.none )

        GotCreateDisbursementResponse res ->
            case res of
                Ok data ->
                    ( model, getDisbursementsData model.committeeId )

                Err _ ->
                    ( model, Cmd.none )

        LoadDisbursementsData res ->
            case res of
                Ok data ->
                    ( { model
                        | disbursements = data.disbursements
                        , aggregations = data.aggregations
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )



-- HTTP


getDisbursementsData : String -> Cmd Msg
getDisbursementsData committeeId =
    Http.send LoadDisbursementsData <|
        Api.get (Endpoint.disbursements committeeId) Nothing DD.decode


scrollToTop : Task x ()
scrollToTop =
    Dom.setViewport 0 0
        -- It's not worth showing the user anything special if scrolling fails.
        -- If anything, we'd log this to an error recording service.
        |> Task.onError (\_ -> Task.succeed ())



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession (Session.navKey model.session)
        , Modal.subscriptions model.createDisbursementModalVisibility AnimateCreateDisbursementModal
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



-- Http


encodeDisbursement : Model -> Encode.Value
encodeDisbursement model =
    Encode.object
        [ ( "committeeId", Encode.string model.committeeId )
        , ( "entityName", Encode.string model.createDisbursementModalVendorName )
        , ( "purposeCode", Encode.string <| Maybe.withDefault "other" model.createDisbursementModalPurpose )
        , ( "amount", Encode.string model.createDisbursementModalAmount )
        , ( "date", Encode.string model.createDisbursementDate )
        ]


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    let
        body =
            encodeDisbursement model |> Http.jsonBody
    in
    Http.send GotCreateDisbursementResponse <|
        Api.post Endpoint.disbursement Nothing body Decode.string



-- Nest view update
