module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Aggregations
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
import Config.Env exposing (env)
import Contribution as Contribution
import Contributions
import CreateContribution
import Delay
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
import Transaction.ContributionsData as ContributionsData exposing (ContributionsData)



-- MODEL


type alias Model =
    { session : Session
    , loading : Bool
    , timeZone : Time.Zone
    , contributions : List Contribution.Model
    , aggregations : Aggregations.Model
    , committeeId : String
    , createContributionModalVisibility : Modal.Visibility
    , createContributionModal : CreateContribution.Model
    , createContributionSubmitting : Bool
    , token : Token
    }


init : Token -> Session -> Aggregations.Model -> String -> ( Model, Cmd Msg )
init token session aggs committeeId =
    ( { session = session
      , loading = True
      , timeZone = Time.utc
      , contributions = []
      , aggregations = aggs
      , committeeId = committeeId
      , createContributionModalVisibility = Modal.hidden
      , createContributionModal = CreateContribution.init
      , createContributionSubmitting = False
      , token = token
      }
    , getContributionsData token committeeId
    )



-- VIEW


contentView : Model -> Html Msg
contentView model =
    div [ class "fade-in" ]
        [ createContributionModalButton
        , Contributions.view SortContributions [] model.contributions
        , createContributionModal model
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


createContributionModal : Model -> Html Msg
createContributionModal model =
    Modal.config HideCreateContributionModal
        |> Modal.withAnimation AnimateCreateContributionModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Create Contribution" ]
        |> Modal.body
            []
            [ Html.map CreateContributionModalUpdated <|
                CreateContribution.view model.createContributionModal
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow model ]
            ]
        |> Modal.view model.createContributionModalVisibility


buttonRow : Model -> Html Msg
buttonRow model =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            [ exitButton ]
        , Grid.col
            [ Col.lg3 ]
            [ submitButton "Submit" SubmitCreateContribution model.createContributionSubmitting ]
        ]


exitButton : Html Msg
exitButton =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick HideCreateContributionModal ]
        ]
        [ text "Exit" ]


createContributionModalButton : Html Msg
createContributionModalButton =
    Button.button
        [ Button.primary
        , Button.attrs [ onClick <| ShowCreateContributionModal ]
        , Button.attrs [ class "float-right", Spacing.mb3 ]
        ]
        [ text "Create Contribution" ]



-- TAGS
-- UPDATE


type ContributionId
    = ContributionId String


type Msg
    = GotSession Session
    | LoadContributionsData (Result Http.Error ContributionsData)
    | SortContributions Contributions.Label
    | HideCreateContributionModal
    | ShowCreateContributionModal
    | CreateContributionModalUpdated CreateContribution.Msg
    | AnimateCreateContributionModal Modal.Visibility
    | GotCreateContributionResponse (Result Http.Error String)
    | SubmitCreateContribution
    | SubmitCreateContributionDelay


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        LoadContributionsData res ->
            case res of
                Ok data ->
                    ( { model
                        | contributions = data.contributions
                        , aggregations = data.aggregations
                        , loading = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| env.loginUrl model.committeeId )

        SortContributions label ->
            case label of
                Contributions.Record ->
                    ( { model
                        | contributions = model.contributions
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ShowCreateContributionModal ->
            ( { model
                | createContributionModalVisibility = Modal.shown
                , createContributionModal = CreateContribution.init
              }
            , Cmd.none
            )

        HideCreateContributionModal ->
            ( { model
                | createContributionModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        SubmitCreateContribution ->
            ( { model
                | createContributionSubmitting = True
              }
            , createContribution model
            )

        AnimateCreateContributionModal visibility ->
            ( { model | createContributionModalVisibility = visibility }, Cmd.none )

        CreateContributionModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateContribution.update subMsg model.createContributionModal
            in
            ( { model | createContributionModal = subModel }, Cmd.map CreateContributionModalUpdated subCmd )

        GotCreateContributionResponse res ->
            case res of
                Ok data ->
                    ( model, Delay.after 1 Delay.Second SubmitCreateContributionDelay )

                Err err ->
                    ( { model
                        | createContributionModal =
                            CreateContribution.setError model.createContributionModal <|
                                Api.decodeError err
                        , createContributionSubmitting = False
                      }
                    , Cmd.none
                    )

        SubmitCreateContributionDelay ->
            ( { model
                | createContributionModalVisibility = Modal.hidden
                , createContributionSubmitting = False
              }
            , getContributionsData model.token model.committeeId
            )



-- HTTP


getContributionsData : Token -> String -> Cmd Msg
getContributionsData token committeeId =
    Http.send LoadContributionsData <|
        Api.get (Endpoint.contributions committeeId) token ContributionsData.decode


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
        [ Modal.subscriptions model.createContributionModalVisibility AnimateCreateContributionModal
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session


encodeContribution : Model -> Encode.Value
encodeContribution model =
    let
        contrib =
            model.createContributionModal
    in
    Encode.object
        [ ( "committeeId", Encode.string model.committeeId )
        , ( "firstName", Encode.string contrib.firstName )
        , ( "lastName", Encode.string contrib.lastName )
        , ( "amount", Encode.int <| amountToInt contrib.checkAmount )
        , ( "date", Encode.string contrib.checkDate )
        , ( "addressLine1", Encode.string contrib.address1 )
        , ( "addressLine2", Encode.string contrib.address2 )
        , ( "city", Encode.string contrib.city )
        , ( "state", Encode.string contrib.state )
        , ( "postalCode", Encode.string contrib.postalCode )
        , ( "paymentMethod", Encode.string contrib.paymentMethod )
        ]


amountToInt : String -> Int
amountToInt str =
    Maybe.withDefault 0 <| String.toInt str


createContribution : Model -> Cmd Msg
createContribution model =
    let
        body =
            encodeContribution model |> Http.jsonBody
    in
    Http.send GotCreateContributionResponse <|
        Api.post Endpoint.contribute model.token body <|
            Decode.field "message" string
