module Page.Transactions exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Delay
import Disbursement as Disbursement
import Disbursements
import EnrichDisbursement
import File.Download as Download
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Loading
import Session exposing (Session)
import SubmitButton exposing (submitButton)
import Task exposing (Task)
import Time
import Transaction.TransactionsData as TransactionsData exposing (TransactionsData)
import Transactions



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , committeeId : String
    , timeZone : Time.Zone
    , transactions : Transactions.Model
    , aggregations : Aggregations.Model
    , enrichDisbursementModalVisibility : Modal.Visibility
    , enrichDisbursementModal : Disbursement.Model
    , currentSort : Disbursements.Label
    , enrichDisbursementSubmitting : Bool
    }


init : Session -> Aggregations.Model -> String -> ( Model, Cmd Msg )
init session aggs committeeId =
    ( { session = session
      , loading = True
      , committeeId = committeeId
      , timeZone = Time.utc
      , transactions = []
      , aggregations = aggs
      , enrichDisbursementModalVisibility = Modal.hidden
      , enrichDisbursementModal = Disbursement.init
      , currentSort = Disbursements.Record
      , enrichDisbursementSubmitting = False
      }
    , getTransactionsData committeeId
    )



-- VIEW


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ exportTransactionsButton
        , crmExportButton
        , Transactions.view SortTransactions [] model.transactions
        , enrichDisbursementModal model
        ]


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        if model.loading then
            Loading.view

        else
            loadedView model
    }


exportTransactionsButton : Html Msg
exportTransactionsButton =
    Button.button
        [ Button.primary
        , Button.attrs []
        , Button.onClick GenerateReport
        , Button.attrs
            [ class "float-right"
            , Spacing.mb3
            , Spacing.ml3
            , Spacing.pl4
            , Spacing.pr4
            ]
        ]
        [ text "Generate Report" ]


crmExportButton : Html Msg
crmExportButton =
    Button.button
        [ Button.primary
        , Button.attrs []
        , Button.onClick GenerateReport
        , Button.attrs
            [ class "float-right"
            , Spacing.mb3
            , Spacing.pl4
            , Spacing.pr4
            ]
        ]
        [ text "CRM Export" ]


enrichDisbursementModal : Model -> Html Msg
enrichDisbursementModal model =
    Modal.config HideEnrichDisbursementModal
        |> Modal.withAnimation AnimateEnrichDisbursementModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Complete Disbursement" ]
        |> Modal.body
            []
            [ Html.map EnrichDisbursementModalUpdated <|
                EnrichDisbursement.view model.enrichDisbursementModal
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow model ]
            ]
        |> Modal.view model.enrichDisbursementModalVisibility


buttonRow : Model -> Html Msg
buttonRow model =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            [ exitButton ]
        , Grid.col
            [ Col.lg3 ]
            [ submitButton "Verify" SubmitEnrichedDisbursement model.enrichDisbursementSubmitting ]
        ]


exitButton : Html Msg
exitButton =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick HideEnrichDisbursementModal ]
        ]
        [ text "Exit" ]



-- TAGS
-- UPDATE


type Msg
    = GotSession Session
    | LoadTransactionsData (Result Http.Error TransactionsData)
    | HideEnrichDisbursementModal
    | ShowEnrichDisbursementModal Disbursement.Model
    | EnrichDisbursementModalUpdated EnrichDisbursement.Msg
    | AnimateEnrichDisbursementModal Modal.Visibility
    | GotEnrichDisbursementResponse (Result Http.Error String)
    | SubmitEnrichedDisbursement
    | SubmitEnrichedDisbursementDelay
    | SortTransactions Transactions.Label
    | GenerateReport


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GenerateReport ->
            ( model, generateReport )

        ShowEnrichDisbursementModal disbursement ->
            ( { model
                | enrichDisbursementModalVisibility = Modal.shown
                , enrichDisbursementModal = disbursement
              }
            , Cmd.none
            )

        HideEnrichDisbursementModal ->
            ( { model | enrichDisbursementModalVisibility = Modal.hidden }
            , Cmd.none
            )

        SubmitEnrichedDisbursement ->
            ( { model
                | enrichDisbursementSubmitting = True
              }
            , sendEnrichedDisbursement model.enrichDisbursementModal
            )

        AnimateEnrichDisbursementModal visibility ->
            ( { model | enrichDisbursementModalVisibility = visibility }, Cmd.none )

        EnrichDisbursementModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    EnrichDisbursement.update subMsg model.enrichDisbursementModal
            in
            ( { model | enrichDisbursementModal = subModel }, Cmd.map EnrichDisbursementModalUpdated subCmd )

        SortTransactions label ->
            case label of
                Transactions.EntityName ->
                    ( applyFilter label .entityName model, Cmd.none )

                Transactions.DateTime ->
                    ( applyFilter label .dateProcessed model, Cmd.none )

                Transactions.Amount ->
                    ( applyFilter label .amount model, Cmd.none )

                Transactions.PaymentMethod ->
                    ( applyFilter label .paymentMethod model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotEnrichDisbursementResponse res ->
            case res of
                Ok data ->
                    ( model, Delay.after 1 Delay.Second SubmitEnrichedDisbursementDelay )

                Err _ ->
                    ( model, Cmd.none )

        SubmitEnrichedDisbursementDelay ->
            ( { model
                | enrichDisbursementModalVisibility = Modal.hidden
                , enrichDisbursementSubmitting = False
              }
            , getTransactionsData model.committeeId
            )

        LoadTransactionsData res ->
            case res of
                Ok data ->
                    ( { model
                        | transactions = data.transactions
                        , aggregations = data.aggregations
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, Cmd.none )


applyFilter : Transactions.Label -> (Disbursement.Model -> String) -> Model -> Model
applyFilter label field model =
    model


generateReport : Cmd msg
generateReport =
    Download.string "2021_Q1.csv" "text/csv" "2021_Q1"



-- HTTP


getTransactionsData : String -> Cmd Msg
getTransactionsData committeeId =
    Http.send LoadTransactionsData <|
        Api.get (Endpoint.transactions committeeId) Nothing TransactionsData.decode


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
        , Modal.subscriptions model.enrichDisbursementModalVisibility AnimateEnrichDisbursementModal
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session


sendEnrichedDisbursement : Disbursement.Model -> Cmd Msg
sendEnrichedDisbursement disb =
    let
        body =
            EnrichDisbursement.encode disb |> Http.jsonBody
    in
    Http.send GotEnrichDisbursementResponse <|
        Api.post Endpoint.verifyDisbursement Nothing body (Decode.field "message" Decode.string)
