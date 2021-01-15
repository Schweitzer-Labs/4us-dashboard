module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations exposing (Aggregations)
import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Banner
import Bootstrap.Button as Button
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Browser.Dom as Dom
import Content
import CreateDisbursementModal
import Disbursements exposing (Disbursement)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
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
    , createDisbursementModal : CreateDisbursementModal.Model
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
      , createDisbursementModal = CreateDisbursementModal.init
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
                CreateDisbursementModal.view model.createDisbursementModal
            ]
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
    | CreateDisbursementModalUpdated CreateDisbursementModal.Msg
    | AnimateCreateDisbursementModal Modal.Visibility
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
            ( { model | createDisbursementModalVisibility = Modal.hidden }
            , Cmd.none
            )

        SubmitCreateDisbursement ->
            ( { model
                | createDisbursementModalVisibility = Modal.hidden
              }
            , createDisbursement model
            )

        AnimateCreateDisbursementModal visibility ->
            ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )

        CreateDisbursementModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateDisbursementModal.update subMsg model.createDisbursementModal
            in
            ( { model | createDisbursementModal = subModel }, Cmd.map CreateDisbursementModalUpdated subCmd )

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
        Api.post Endpoint.disbursement Nothing body Decode.string
