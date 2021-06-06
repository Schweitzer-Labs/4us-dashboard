module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Cred, Token)
import Api.Endpoint as Endpoint
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Browser.Navigation exposing (load)
import Config.Env exposing (loginUrl)
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
    , timeZone : Time.Zone
    , disbursements : List Disbursement.Model
    , aggregations : Aggregations.Model
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModal : CreateDisbursement.Model
    , createDisbursementSubmitting : Bool
    , committeeId : String
    , token : Token
    }


init : Token -> Session -> Aggregations.Model -> String -> ( Model, Cmd Msg )
init token session aggs committeeId =
    ( { session = session
      , loading = True
      , committeeId = committeeId
      , timeZone = Time.utc
      , disbursements = []
      , aggregations = aggs
      , createDisbursementModalVisibility = Modal.hidden
      , createDisbursementModal = CreateDisbursement.init
      , createDisbursementSubmitting = False
      , token = token
      }
    , getDisbursementsData token committeeId
    )



-- VIEW


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ createDisbursementModalButton
        , Disbursements.view SortDisbursements [] model.disbursements
        , createDisbursementModal model
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
            [ submitButton "Submit" SubmitCreateDisbursement model.createDisbursementSubmitting False ]
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
        [ Button.primary
        , Button.attrs [ onClick <| ShowCreateDisbursementModal ]
        , Button.attrs [ class "float-right", Spacing.mb3 ]
        ]
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
                    ( model, Delay.after 1 Delay.Second SubmitCreateDisbursementDelay )

                Err _ ->
                    ( model, Cmd.none )

        SubmitCreateDisbursementDelay ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
                , createDisbursementSubmitting = False
              }
            , getDisbursementsData model.token model.committeeId
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
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.committeeId )



-- HTTP


getDisbursementsData : Token -> String -> Cmd Msg
getDisbursementsData token committeeId =
    Http.send LoadDisbursementsData <|
        Api.get (Endpoint.disbursements committeeId []) token DD.decode


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
        [ Modal.subscriptions model.createDisbursementModalVisibility AnimateCreateDisbursementModal
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
        , ( "address1", Encode.string disb.address1 )
        , ( "address2", Encode.string disb.address2 )
        , ( "city", Encode.string disb.city )
        , ( "state", Encode.string disb.state )
        , ( "postalCode", Encode.string disb.postalCode )
        ]


createDisbursement : Model -> Cmd Msg
createDisbursement model =
    let
        body =
            encodeDisbursement model |> Http.jsonBody
    in
    Http.send GotCreateDisbursementResponse <|
        Api.post (Endpoint.disbursement model.committeeId) model.token body <|
            Decode.field "message" string
