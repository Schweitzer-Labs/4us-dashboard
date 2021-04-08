module Page.Transactions exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Aggregations as Aggregations
import Api exposing (Cred, Token)
import Api.Endpoint as Endpoint
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Modal as Modal
import Bootstrap.Utilities.Spacing as Spacing
import Browser.Dom as Dom
import Browser.Navigation exposing (load)
import Cents
import Config.Env exposing (env)
import CreateContribution
import CreateDisbursement
import Delay
import Direction exposing (Direction)
import Disbursement as Disbursement
import Disbursements
import File.Download as Download
import FileDisclosure
import FileFormat exposing (FileFormat)
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
    , currentSort : Disbursements.Label
    , createContributionModalVisibility : Modal.Visibility
    , createContributionModal : CreateContribution.Model
    , createContributionSubmitting : Bool
    , generateDisclosureModalVisibility : Modal.Visibility
    , generateDisclosureModalDownloadDropdownState : Dropdown.State
    , token : Token
    , actionsDropdown : Dropdown.State
    , filtersDropdown : Dropdown.State
    , filterDirection : Maybe Direction
    , disclosureSubmitting : Bool
    , disclosureSubmitted : Bool
    , createDisbursementModalVisibility : Modal.Visibility
    , createDisbursementModal : CreateDisbursement.Model
    , createDisbursementSubmitting : Bool
    }


init : Token -> Session -> Aggregations.Model -> String -> ( Model, Cmd Msg )
init token session aggs committeeId =
    ( { session = session
      , loading = True
      , committeeId = committeeId
      , timeZone = Time.utc
      , transactions = []
      , aggregations = aggs
      , currentSort = Disbursements.Record
      , createContributionModalVisibility = Modal.hidden
      , createContributionModal = CreateContribution.init
      , createContributionSubmitting = False
      , generateDisclosureModalVisibility = Modal.hidden
      , token = token
      , actionsDropdown = Dropdown.initialState
      , filtersDropdown = Dropdown.initialState
      , generateDisclosureModalDownloadDropdownState = Dropdown.initialState
      , filterDirection = Nothing
      , disclosureSubmitting = False
      , disclosureSubmitted = False
      , createDisbursementModalVisibility = Modal.hidden
      , createDisbursementModal = CreateDisbursement.init
      , createDisbursementSubmitting = False
      }
    , getTransactionsData token committeeId Nothing
    )



-- VIEW


loadedView : Model -> Html Msg
loadedView model =
    div [ class "fade-in" ]
        [ dropdowns model
        , Transactions.view SortTransactions [] model.transactions
        , createContributionModal model
        , generateDisclosureModal model
        , createDisbursementModal model
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
            [ Html.map CreateDisbursementModalUpdated <|
                CreateDisbursement.view model.createDisbursementModal
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow "Create Disbursement" SubmitCreateDisbursement model.createDisbursementSubmitting True model.createDisbursementSubmitting ]
            ]
        |> Modal.view model.createDisbursementModalVisibility


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        if model.loading then
            Loading.view

        else
            loadedView model
    }


dropdowns : Model -> Html Msg
dropdowns model =
    Grid.containerFluid
        []
        [ Grid.row
            [ Row.attrs [ class "justify-content-start" ] ]
            [ Grid.col
                [ Col.xs1, Col.attrs [ Spacing.ml0, Spacing.pl0 ] ]
                [ actionsDropdown model ]
            , Grid.col
                [ Col.xs2 ]
                [ filtersDropdown model ]
            , Grid.col
                [ Col.attrs [ class "text-center" ] ]
                [ h2
                    []
                    [ text <|
                        Maybe.withDefault "All Transactions" <|
                            Maybe.map Direction.toDisplayTitle model.filterDirection
                    ]
                ]
            , Grid.col
                [ Col.xs1, Col.attrs [ Spacing.ml0, Spacing.pl0 ] ]
                []
            , Grid.col
                [ Col.xs2 ]
                []
            ]
        ]


actionsDropdown : Model -> Html Msg
actionsDropdown model =
    div [ Spacing.mb2 ]
        [ Dropdown.dropdown
            model.actionsDropdown
            { options = []
            , toggleMsg = ToggleActionsDropdown
            , toggleButton =
                Dropdown.toggle [ Button.success, Button.attrs [ Spacing.pl3, Spacing.pr3 ] ] [ text "Actions" ]
            , items =
                [ Dropdown.buttonItem [ onClick ShowCreateContributionModal ] [ text "Create Contribution" ]
                , Dropdown.buttonItem [ onClick ShowCreateDisbursementModal ] [ text "Create Disbursement" ]
                , Dropdown.buttonItem [ onClick ShowGenerateDisclosureModal ] [ text "File Disclosure" ]
                ]
            }

        -- etc
        ]


filtersDropdown : Model -> Html Msg
filtersDropdown model =
    div [ Spacing.mb2 ]
        [ Dropdown.dropdown
            model.filtersDropdown
            { options = []
            , toggleMsg = ToggleFiltersDropdown
            , toggleButton =
                Dropdown.toggle [ Button.success, Button.attrs [ Spacing.pl3, Spacing.pr3 ] ] [ text "Filters" ]
            , items =
                [ Dropdown.buttonItem [ onClick FilterByContributions ] [ text "Contributions" ]
                , Dropdown.buttonItem [ onClick FilterByDisbursements ] [ text "Disbursements" ]
                , Dropdown.buttonItem [ onClick FilterAll ] [ text "All Transactions" ]
                ]
            }

        -- etc
        ]


generateDisclosureModal : Model -> Html Msg
generateDisclosureModal model =
    Modal.config HideGenerateDisclosureModal
        |> Modal.withAnimation AnimateGenerateDisclosureModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "File Disclosure" ]
        |> Modal.body
            []
            [ FileDisclosure.view
                model.aggregations
                ( ToggleGenerateDisclosureModalDownloadDropdown
                , model.generateDisclosureModalDownloadDropdownState
                )
                GenerateReport
                model.disclosureSubmitted
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ buttonRow "File" FileDisclosure model.disclosureSubmitting False model.disclosureSubmitted ]
            ]
        |> Modal.view model.generateDisclosureModalVisibility


createContributionModal : Model -> Html Msg
createContributionModal model =
    Modal.config HideCreateContributionModal
        |> Modal.withAnimation AnimateCreateContributionModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.scrollableBody True
        |> Modal.h3 [] [ text "Create Contribution" ]
        |> Modal.body
            []
            [ Html.map CreateContributionModalUpdated <|
                CreateContribution.view model.createContributionModal
            ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ createContributionButtonRow model ]
            ]
        |> Modal.view model.createContributionModalVisibility


createContributionButtonRow : Model -> Html Msg
createContributionButtonRow model =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            [ createContributionExitButton ]
        , Grid.col
            [ Col.lg3 ]
            [ submitButton "Submit" SubmitCreateContribution model.createContributionSubmitting False ]
        ]


createContributionExitButton : Html Msg
createContributionExitButton =
    Button.button
        [ Button.outlineSuccess
        , Button.block
        , Button.attrs [ onClick HideCreateContributionModal ]
        ]
        [ text "Exit" ]


buttonRow : String -> Msg -> Bool -> Bool -> Bool -> Html Msg
buttonRow displayText msg submitting enableExit disabled =
    Grid.row
        [ Row.betweenXs ]
        [ Grid.col
            [ Col.lg3, Col.attrs [ class "text-left" ] ]
            (if enableExit then
                [ exitButton ]

             else
                []
            )
        , Grid.col
            [ Col.lg3 ]
            [ submitButton displayText msg submitting disabled ]
        ]


exitButton : Html Msg
exitButton =
    Button.button
        [ Button.outlinePrimary
        , Button.block
        , Button.attrs [ onClick HideCreateContributionModal ]
        ]
        [ text "Exit" ]



-- TAGS
-- UPDATE


type Msg
    = GotSession Session
    | LoadTransactionsData (Result Http.Error TransactionsData)
    | SortTransactions Transactions.Label
    | GenerateReport FileFormat
    | HideCreateContributionModal
    | ShowCreateContributionModal
    | HideGenerateDisclosureModal
    | ShowGenerateDisclosureModal
    | AnimateGenerateDisclosureModal Modal.Visibility
    | CreateContributionModalUpdated CreateContribution.Msg
    | AnimateCreateContributionModal Modal.Visibility
    | GotCreateContributionResponse (Result Http.Error String)
    | SubmitCreateContribution
    | SubmitCreateContributionDelay
    | ToggleActionsDropdown Dropdown.State
    | ToggleFiltersDropdown Dropdown.State
    | ToggleGenerateDisclosureModalDownloadDropdown Dropdown.State
    | FileDisclosure
    | FileDisclosureDelayed
    | FilterByContributions
    | FilterByDisbursements
    | NoOp
    | FilterAll
    | HideCreateDisbursementModal
    | ShowCreateDisbursementModal
    | CreateDisbursementModalUpdated CreateDisbursement.Msg
    | AnimateCreateDisbursementModal Modal.Visibility
    | GotCreateDisbursementResponse (Result Http.Error String)
    | SubmitCreateDisbursement
    | SubmitCreateDisbursementDelay


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )

        GenerateReport format ->
            case format of
                FileFormat.PDF ->
                    ( model, Download.string "2021-periodic-report-july.pdf" "text/pdf" "2021-periodic-report-july" )

                FileFormat.CSV ->
                    ( model, Download.string "2021-periodic-report-july.csv" "text/csv" "2021-periodic-report-july" )

        AnimateGenerateDisclosureModal visibility ->
            ( { model | generateDisclosureModalVisibility = visibility }, Cmd.none )

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
                    ( model, load <| env.loginUrl model.committeeId )

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

        ShowGenerateDisclosureModal ->
            ( { model
                | generateDisclosureModalVisibility = Modal.shown
              }
            , Cmd.none
            )

        HideGenerateDisclosureModal ->
            ( { model
                | generateDisclosureModalVisibility = Modal.hidden
              }
            , Cmd.none
            )

        CreateContributionModalUpdated subMsg ->
            let
                ( subModel, subCmd ) =
                    CreateContribution.update subMsg model.createContributionModal
            in
            ( { model | createContributionModal = subModel }, Cmd.map CreateContributionModalUpdated subCmd )

        GotCreateContributionResponse res ->
            case res of
                Ok data ->
                    ( model, Delay.after 2 Delay.Second SubmitCreateContributionDelay )

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
            , getTransactionsData model.token model.committeeId model.filterDirection
            )

        ToggleActionsDropdown state ->
            ( { model | actionsDropdown = state }, Cmd.none )

        ToggleFiltersDropdown state ->
            ( { model | filtersDropdown = state }, Cmd.none )

        ToggleGenerateDisclosureModalDownloadDropdown state ->
            ( { model | generateDisclosureModalDownloadDropdownState = state }, Cmd.none )

        FilterByContributions ->
            ( { model | filterDirection = Just Direction.In }
            , getTransactionsData model.token model.committeeId (Just Direction.In)
            )

        FilterByDisbursements ->
            ( { model | filterDirection = Just Direction.Out }
            , getTransactionsData model.token model.committeeId (Just Direction.Out)
            )

        FilterAll ->
            ( { model | filterDirection = Nothing }
            , getTransactionsData model.token model.committeeId Nothing
            )

        FileDisclosure ->
            ( { model | disclosureSubmitting = True }, Delay.after 2 Delay.Second FileDisclosureDelayed )

        FileDisclosureDelayed ->
            ( { model | disclosureSubmitting = False, disclosureSubmitted = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

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
                , createDisbursementModal = CreateDisbursement.init
              }
            , getTransactionsData model.token model.committeeId Nothing
            )



-- load <| env.loginUrl model.committeeId )


applyFilter : Transactions.Label -> (Disbursement.Model -> String) -> Model -> Model
applyFilter label field model =
    model


generateReport : Cmd msg
generateReport =
    Download.string "2021_Q1.pdf" "text/pdf" "2021_Q1"



-- HTTP


getTransactionsData : Token -> String -> Maybe Direction -> Cmd Msg
getTransactionsData token committeeId maybeDirection =
    Http.send LoadTransactionsData <|
        Api.get (Endpoint.transactions committeeId maybeDirection) token TransactionsData.decode


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
        , Modal.subscriptions model.generateDisclosureModalVisibility AnimateGenerateDisclosureModal
        , Dropdown.subscriptions model.actionsDropdown ToggleActionsDropdown
        , Dropdown.subscriptions model.filtersDropdown ToggleFiltersDropdown
        , Dropdown.subscriptions model.generateDisclosureModalDownloadDropdownState ToggleGenerateDisclosureModalDownloadDropdown
        , Modal.subscriptions model.createDisbursementModalVisibility AnimateCreateDisbursementModal
        ]



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session


amountToInt : String -> Int
amountToInt str =
    Maybe.withDefault 0 <| String.toInt str


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
        , ( "amount", Encode.int <| Cents.fromDollars contrib.checkAmount )
        , ( "date", Encode.string contrib.checkDate )
        , ( "addressLine1", Encode.string contrib.address1 )
        , ( "addressLine2", Encode.string contrib.address2 )
        , ( "city", Encode.string contrib.city )
        , ( "state", Encode.string contrib.state )
        , ( "postalCode", Encode.string contrib.postalCode )
        , ( "paymentMethod", Encode.string contrib.paymentMethod )
        , ( "contributorType", Encode.string "ind" )

        --, ( "creditCardNumber", Encode.string contrib.cardNumber )
        --, ( "expirationMonth", Encode.int contrib.cardMonth )
        --, ( "expirationYear", Encode.string contrib.cardYear )
        ]


createContribution : Model -> Cmd Msg
createContribution model =
    let
        body =
            encodeContribution model |> Http.jsonBody
    in
    Http.send GotCreateContributionResponse <|
        Api.post Endpoint.contribute model.token body <|
            Decode.field "message" string


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
        , ( "amount", Encode.string <| String.fromInt <| Cents.fromDollars disb.checkAmount )
        , ( "date", Encode.string "2021-04-07" )
        , ( "address1", Encode.string disb.address1 )
        , ( "address2", Encode.string disb.address2 )
        , ( "city", Encode.string disb.city )
        , ( "state", Encode.string disb.state )
        , ( "postalCode", Encode.string disb.postalCode )
        , ( "paymentMethod", Encode.string "credit" )
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
