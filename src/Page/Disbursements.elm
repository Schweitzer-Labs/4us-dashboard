module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations exposing (Aggregations)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Browser.Dom as Dom
import CreateDisbursement
import Delay
import Disbursement as Disbursement
import Disbursements exposing (Label(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (string)
import Json.Encode as Encode
import Session exposing (Session)
import SubmitButton exposing (submitButton)
import Task exposing (Task)
import Time
import Transaction.DisbursementsData as DD exposing (DisbursementsData)



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , disbursements : List Disbursement.Model
    , aggregations : Aggregations
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModal : CreateDisbursement.Model
    , committeeId : String
    , createDisbursementSubmitting : Bool
    }


init : Session -> String -> ( Model, Cmd Msg )
init session committeeId =
    ( { session = session
      , committeeId = committeeId
      , timeZone = Time.utc
      , disbursements = []
      , aggregations = Aggregations.init
      , createDisbursementModalVisibility = Modal.hidden
      , createDisbursementModal = CreateDisbursement.init
      , createDisbursementSubmitting = False
      }
    , getDisbursementsData committeeId
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div []
            [ Disbursements.view SortDisbursements [ createDisbursementModalButton ] model.disbursements
            , createDisbursementModal model
            ]
    }


createDisbursementModal : Model -> Html Msg
createDisbursementModal model =
    Modal.config HideCreateDisbursementModal
        |> Modal.withAnimation AnimateCreateDisbursementModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Create Disbursement" ]
        |> Modal.body
            []
            [ Html.map CreateDisbursementModalUpdated <|
                CreateDisbursement.view model.createDisbursementModal
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow model ]
            ]
        |> Modal.view model.createDisbursementModalVisibility


buttonRow : Model -> Html Msg
buttonRow model =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            [ exitButton ]
        , Grid.col
            [ Col.lg3 ]
            [ submitButton "Submit" SubmitCreateDisbursement model.createDisbursementSubmitting ]
        ]


exitButton : Html Msg
exitButton =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick HideCreateDisbursementModal ]
        ]
        [ text "Exit" ]


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
    | CreateDisbursementModalUpdated CreateDisbursement.Msg
    | AnimateCreateDisbursementModal Modal.Visibility
    | GotCreateDisbursementResponse (Result Http.Error String)
    | SubmitCreateDisbursement
    | SubmitCreateDisbursementDelay
    | SortDisbursements Disbursements.Label


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        ShowCreateDisbursementModal ->
            ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none )

        HideCreateDisbursementModal ->
            ( { model | createDisbursementModalVisibility = Modal.hidden }
            , Cmd.none
            )

        SubmitCreateDisbursement ->
            ( { model
                | createDisbursementSubmitting = True
              }
            , createDisbursement model
            )

        AnimateCreateDisbursementModal visibility ->
            ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )

        CreateDisbursementModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateDisbursement.update subMsg model.createDisbursementModal
            in
            ( { model | createDisbursementModal = subModel }, Cmd.map CreateDisbursementModalUpdated subCmd )

        GotCreateDisbursementResponse res ->
            case res of
                Ok data ->
                    ( model, Delay.after 2 Delay.Second SubmitCreateDisbursementDelay )

                Err _ ->
                    ( model, Cmd.none )

        SubmitCreateDisbursementDelay ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
                , createDisbursementSubmitting = False
              }
            , getDisbursementsData model.committeeId
            )

        SortDisbursements label ->
            case label of
                Disbursements.Record ->
                    ( { model
                        | disbursements =
                            List.reverse <|
                                List.sortBy (\d -> d.recordNumber) model.disbursements
                      }
                    , Cmd.none
                    )

                _ ->
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
        Api.get (Endpoint.disbursements committeeId []) Nothing DD.decode


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


encodeDisbursement : Model -> Encode.Value
encodeDisbursement model =
    let
        disb =
            model.createDisbursementModal
    in
    Encode.object
        [ ( "committeeId", Encode.string model.committeeId )
        , ( "entityName", Encode.string disb.checkRecipient )
        , ( "purposeCode", Encode.string <| Maybe.withDefault "other" disb.purposeCode )
        , ( "amount", Encode.string disb.checkAmount )
        , ( "date", Encode.string disb.checkDate )
        ]


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    let
        body =
            encodeDisbursement model |> Http.jsonBody
    in
    Http.send GotCreateDisbursementResponse <|
        Api.post Endpoint.disbursement Nothing body <|
            Decode.field "message" string
