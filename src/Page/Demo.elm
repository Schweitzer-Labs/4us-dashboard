module Page.Demo exposing (Model, Msg(..), formRow, getTransactions, init, subscriptions, toSession, update, view)

import Aggregations
import Api
import Api.GenDemoCommittee as GenDemoCommittee
import Api.GetTxns as GetTxns
import Api.GraphQL exposing (MutationResponse(..))
import Api.SeedDemoBankRecords as SeedDemoBankRecords
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Navigation exposing (load)
import Cognito exposing (loginUrl)
import Committee
import Config exposing (Config)
import Errors
import Html exposing (..)
import Html.Attributes as SvgA exposing (class, for, href, target)
import Http
import LabelWithData exposing (dataText)
import Session exposing (Session)
import SubmitButton
import Time
import TransactionType exposing (TransactionType)



-- MODEL


type alias Model =
    { session : Session
    , committeeId : String
    , aggregations : Aggregations.Model
    , committee : Committee.Model
    , isSubmitting : Bool
    , config : Config
    , password : String
    , maybeDemoCommitteeId : Maybe String
    , errors : List String
    , loadingProgress : Int
    , eventLogs : List String
    }


init : Config -> Session -> Aggregations.Model -> Committee.Model -> String -> ( Model, Cmd Msg )
init config session aggs committee committeeId =
    let
        initModel =
            { session = session
            , committeeId = committeeId
            , aggregations = aggs
            , committee = committee
            , config = config
            , isSubmitting = False
            , password = ""
            , maybeDemoCommitteeId = Nothing
            , errors = []
            , loadingProgress = 0
            , eventLogs = [ "Bank record seeded", "Transaction Reconciled", "Transaction Reconciled", "Bank record seeded" ]
            }
    in
    ( initModel
    , getTransactions initModel Nothing
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US - Demo"
    , content =
        div [] [ manageDemoView model ]
    }



-- Form


formRow : Model -> Html Msg
formRow model =
    Grid.containerFluid
        [ Spacing.mt3, class "fade-in" ]
    <|
        [ Grid.row []
            [ Grid.col [] [ h2 [] [ text "Generate Demo Committee" ] ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.xs6 ]
              <|
                Errors.view model.errors
                    ++ [ Form.group []
                            [ Form.label [ for "password" ] [ text "Passcode" ]
                            , Input.password [ Input.id "password", Input.onInput PasswordUpdated, Input.value model.password ]
                            , Form.help [] [ text "Or maybe you shouldn't be here..." ]
                            ]
                       ]
                    ++ SubmitButton.blockWithLoadingBar [] "Generate" GenDemoCommitteeClicked model.isSubmitting model.loadingProgress
            ]
        ]
            ++ urlRow model


manageDemoView : Model -> Html Msg
manageDemoView model =
    Grid.containerFluid
        [ Spacing.mt3, class "fade-in" ]
    <|
        [ Grid.row []
            [ Grid.col [] [ dataText "Manage Demo Committee" ]
            ]
        , Grid.row
            []
            [ Grid.col
                [ Col.xs3 ]
              <|
                demoLabel "Committee Link"
                    ++ [ a [ href <| idToCommitteeUrl model.config model.committeeId ] [ text <| idToCommitteeUrl model.config model.committeeId ] ]
                    ++ demoLabel "Actions"
                    ++ [ SubmitButton.block [] "Seed Bank record" SeedDemoBankRecordClicked False False ]
                    ++ [ SubmitButton.block [ Spacing.mt3 ] "Reconcile One" NoOp False False ]
                    ++ [ resetButton ]
                    ++ demoLabel "Event Log"
                    ++ [ eventList model.eventLogs ]
            ]
        ]
            ++ urlRow model


demoLabel : String -> List (Html msg)
demoLabel label =
    [ div [ Spacing.mt3 ] [ text label ] ]


resetButton : Html Msg
resetButton =
    Button.button
        [ Button.outlineDanger
        , Button.onClick NoOp
        , Button.disabled False
        , Button.block
        , Button.attrs [ Spacing.mt3 ]
        ]
        [ text "Reset" ]


eventList : List String -> Html msg
eventList list =
    list
        |> List.map (\e -> li [] [ text e ])
        |> ul []


idToCommitteeUrl : Config -> String -> String
idToCommitteeUrl config id =
    config.redirectUri ++ "/committee/" ++ id


urlRow : Model -> List (Html Msg)
urlRow model =
    case model.maybeDemoCommitteeId of
        Just id ->
            List.singleton <|
                Grid.row
                    []
                    [ Grid.col []
                        [ h5 [ Spacing.mt5 ] [ text "Committee Link" ]
                        , a
                            [ href <| idToCommitteeUrl model.config id, class "d-block max-height-80", target "_blank", Spacing.mt3 ]
                            [ text <| idToCommitteeUrl model.config id ]
                        ]
                    ]

        Nothing ->
            []



-- UPDATE


type Msg
    = GotSession Session
    | PasswordUpdated String
    | GenDemoCommitteeGotResp (Result Http.Error MutationResponse)
    | GotTransactionsData (Result Http.Error GetTxns.Model)
    | GenDemoCommitteeClicked
    | Tick Time.Posix
    | SeedDemoBankRecordGotResp (Result Http.Error MutationResponse)
    | SeedDemoBankRecordClicked
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick time ->
            case model.isSubmitting of
                True ->
                    ( { model | loadingProgress = model.loadingProgress + 7 }, Cmd.none )

                False ->
                    ( model, Cmd.none )

        PasswordUpdated str ->
            ( { model | password = str }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GotTransactionsData res ->
            case res of
                Ok body ->
                    ( { model
                        | aggregations = body.data.aggregations
                        , committee = body.data.committee
                        , errors = []
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( model, load <| loginUrl model.config model.committeeId )

        GenDemoCommitteeClicked ->
            ( { model | isSubmitting = True, errors = [] }, genDemoCommittee model )

        GenDemoCommitteeGotResp res ->
            case res of
                Ok createContribResp ->
                    case createContribResp of
                        Success id ->
                            ( { model
                                | isSubmitting = False
                                , maybeDemoCommitteeId = Just id
                                , errors = []
                                , loadingProgress = 0
                              }
                            , Cmd.none
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                                , isSubmitting = False
                                , loadingProgress = 0
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = [ Api.decodeError err ]
                        , isSubmitting = False
                        , loadingProgress = 0
                      }
                    , Cmd.none
                    )

        SeedDemoBankRecordClicked ->
            ( { model | isSubmitting = True, errors = [] }, seedDemoBankRecord model )

        SeedDemoBankRecordGotResp res ->
            case res of
                Ok seedDemoResp ->
                    case seedDemoResp of
                        Success id ->
                            ( { model
                                | errors = []
                              }
                            , Cmd.none
                            )

                        ResValidationFailure errList ->
                            ( { model
                                | errors =
                                    List.singleton <|
                                        Maybe.withDefault "Unexpected API response" <|
                                            List.head errList
                              }
                            , Cmd.none
                            )

                Err err ->
                    ( { model
                        | errors = [ Api.decodeError err ]
                        , isSubmitting = False
                        , loadingProgress = 0
                      }
                    , Cmd.none
                    )

        NoOp ->
            ( model, Cmd.none )



-- HTTP


getTransactions : Model -> Maybe TransactionType -> Cmd Msg
getTransactions model maybeTxnType =
    GetTxns.send GotTransactionsData model.config <| GetTxns.encode model.committeeId maybeTxnType Nothing Nothing


genDemoCommittee : Model -> Cmd Msg
genDemoCommittee model =
    GenDemoCommittee.send GenDemoCommitteeGotResp model.config <| GenDemoCommittee.encode toGenDemoCommittee model


toGenDemoCommittee : Model -> GenDemoCommittee.EncodeModel
toGenDemoCommittee model =
    { password = model.password, demoType = "Clean" }


toSeedDemoBankRecord : Model -> SeedDemoBankRecords.EncodeModel
toSeedDemoBankRecord model =
    { password = "f4jp1i"
    , committeeId = model.committeeId
    , transactionType = "Contribution"
    }


seedDemoBankRecord : Model -> Cmd Msg
seedDemoBankRecord model =
    SeedDemoBankRecords.send GenDemoCommitteeGotResp model.config <| SeedDemoBankRecords.encode toSeedDemoBankRecord model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
