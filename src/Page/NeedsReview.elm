module Page.NeedsReview exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations
import Api exposing (Cred, Token)
import Api.Endpoint as Endpoint
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Browser.Dom as Dom
import Browser.Navigation exposing (load)
import Committee
import Config exposing (Config)
import Config.Env exposing (loginUrl)
import Delay
import Disbursement as Disbursement
import Disbursements
import EnrichDisbursement
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
import Transaction.DisbursementsData as DD exposing (DisbursementsData)



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , committeeId : String
    , timeZone : Time.Zone
    , disbursements : List Disbursement.Model
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , enrichDisbursementModalVisibility : Modal.Visibility
    , enrichDisbursementModal : Disbursement.Model
    , enrichDisbursementSubmitting : Bool
    , currentSort : Disbursements.Label
    , config : Config
    }


init : Config -> Session -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
init config session aggs committee committeeId =
    ( { session = session
      , loading = True
      , committeeId = committeeId
      , timeZone = Time.utc
      , disbursements = []
      , aggregations = aggs
      , committee = committee
      , enrichDisbursementModalVisibility = Modal.hidden
      , enrichDisbursementModal = Disbursement.init
      , enrichDisbursementSubmitting = False
      , config = config
      , currentSort = Disbursements.Record
      }
      --, getDisbursementsData token committeeId
    , Cmd.none
    )



-- VIEW


contentView : Model -> Html Msg
contentView model =
    div [ class "fade-in" ]
        [ Disbursements.viewInteractive SortDisbursements ShowEnrichDisbursementModal [] model.disbursements
        , enrichDisbursementModal model
        ]


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        if model.loading then
            Loading.view

        else
            contentView model
    }


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
            [ submitButton "Verify" SubmitEnrichedDisbursement model.enrichDisbursementSubmitting False ]
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
      --| LoadDisbursementsData (Result Http.Error DisbursementsData)
    | HideEnrichDisbursementModal
    | ShowEnrichDisbursementModal Disbursement.Model
    | EnrichDisbursementModalUpdated EnrichDisbursement.Msg
    | AnimateEnrichDisbursementModal Modal.Visibility
    | GotEnrichDisbursementResponse (Result Http.Error String)
    | SubmitEnrichedDisbursement
    | SubmitEnrichedDisbursementDelay
    | SortDisbursements Disbursements.Label


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

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

        GotEnrichDisbursementResponse res ->
            case res of
                Ok data ->
                    ( model, Delay.after 1 Delay.Second SubmitEnrichedDisbursementDelay )

                Err _ ->
                    ( model, Cmd.none )

        SubmitEnrichedDisbursement ->
            ( model, Cmd.none )

        SubmitEnrichedDisbursementDelay ->
            ( model, Cmd.none )

        --SubmitEnrichedDisbursement ->
        --    ( { model
        --        | enrichDisbursementSubmitting = True
        --      }
        --    , sendEnrichedDisbursement model.token model.enrichDisbursementModal
        --    )
        AnimateEnrichDisbursementModal visibility ->
            ( { model | enrichDisbursementModalVisibility = visibility }, Cmd.none )

        EnrichDisbursementModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    EnrichDisbursement.update subMsg model.enrichDisbursementModal
            in
            ( { model | enrichDisbursementModal = subModel }, Cmd.map EnrichDisbursementModalUpdated subCmd )

        SortDisbursements label ->
            case label of
                Disbursements.Record ->
                    ( applyFilter label .recordNumber model, Cmd.none )

                Disbursements.EntityName ->
                    ( applyFilter label .entityName model, Cmd.none )

                Disbursements.DateTime ->
                    ( applyFilter label .dateProcessed model, Cmd.none )

                Disbursements.Amount ->
                    ( applyFilter label .amount model, Cmd.none )

                Disbursements.Purpose ->
                    ( applyFilter label .purposeCode model, Cmd.none )

                Disbursements.PaymentMethod ->
                    ( applyFilter label .paymentMethod model, Cmd.none )

                _ ->
                    ( model, Cmd.none )



--SubmitEnrichedDisbursementDelay ->
--    ( { model
--        | enrichDisbursementModalVisibility = Modal.hidden
--        , enrichDisbursementSubmitting = False
--      }
--    , getDisbursementsData model.token model.committeeId
--    )
--
--LoadDisbursementsData res ->
--    case res of
--        Ok data ->
--            ( { model
--                | disbursements = data.disbursements
--                , aggregations = data.aggregations
--                , loading = False
--              }
--            , Cmd.none
--            )
--
--        Err _ ->
--            ( model, load <| loginUrl model.committeeId )


applyFilter : Disbursements.Label -> (Disbursement.Model -> String) -> Model -> Model
applyFilter label field model =
    if model.currentSort == label then
        { model | disbursements = List.reverse model.disbursements }

    else
        { model
            | disbursements = List.sortBy field model.disbursements
            , currentSort = label
        }



-- HTTP
--getDisbursementsData : Token -> String -> Cmd Msg
--getDisbursementsData token committeeId =
--    Http.send LoadDisbursementsData <|
--        Api.get (Endpoint.needsReviewDisbursements committeeId) token DD.decode


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
        [ Modal.subscriptions model.enrichDisbursementModalVisibility AnimateEnrichDisbursementModal
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session



--sendEnrichedDisbursement : Token -> Disbursement.Model -> Cmd Msg
--sendEnrichedDisbursement token disb =
--    let
--        body =
--            EnrichDisbursement.encode disb |> Http.jsonBody
--    in
--    Http.send GotEnrichDisbursementResponse <|
--        Api.post (Endpoint.verifyDisbursement disb.committeeId) token body (Decode.field "message" Decode.string)
