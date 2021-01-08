module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Asset
import Banner
import Bootstrap.Button as Button
import Bootstrap.Text as Text
import Browser.Dom as Dom
import Content
import DataTable
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Session exposing (Session)
import Task exposing (Task)
import Time
import Bootstrap.Grid as Grid exposing (Column)
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Modal as Modal
import Http
import Task exposing (Task)
import Transaction.DisbursementsData as DD exposing (Disbursement, DisbursementsData)
import Bootstrap.Spinner as Spinner



-- MODEL


type alias Model =
    { session : Session
    , timeZone : Time.Zone
    , disbursements: List Disbursement
    , balance: String
    , totalRaised: String
    , totalSpent: String
    , totalDonors: String
    , qualifyingDonors: String
    , qualifyingFunds: String
    , totalTransactions: String
    , totalInProcessing: String
    , createDisbursementModalVisibility: Modal.Visibility
    }



init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , timeZone = Time.utc
      , disbursements = []
      , balance = ""
      , totalRaised = ""
      , totalSpent = ""
      , totalDonors = ""
      , qualifyingDonors = ""
      , qualifyingFunds = ""
      , totalTransactions = ""
      , totalInProcessing = ""
      , createDisbursementModalVisibility = Modal.hidden
      }
    , send
    )



-- VIEW

view : Model -> { title : String, content : Html Msg }
view model =
    { title = "4US"
    , content =
        div
            []
            [ Banner.container [] <| aggsContainer model
            , Content.container <| [ disbursementsContainer model.disbursements ]
            , createVendorModal model
            ]
    }

createVendorModal : Model -> Html Msg
createVendorModal model =
    Modal.config HideCreateDisbursementModal
        |> Modal.withAnimation AnimateCreateDisbursementModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Send Funds" ]
        |> Modal.body [] [ p [] [ text "Form lives here"] ]
        |> Modal.footer []
            [ Grid.containerFluid
                []
                [ Grid.row
                    [ Row.aroundXs ]
                    [ Grid.col
                        [ Col.attrs [class "text-left"]]
                        [ Button.button
                          [ Button.outlinePrimary
                          , Button.large
                          , Button.attrs [ onClick HideCreateDisbursementModal ]
                          ]
                          [ text "Exit" ]
                        ]
                    , Grid.col
                      [ Col.attrs [class "text-right"] ]
                      [ Button.button
                        [ Button.primary
                        , Button.large
                        , Button.attrs [ onClick HideCreateDisbursementModal, class "text-right" ]
                        ]
                        [ text "Submit" ]
                      ]
                    ]
                ]
            ]

        |> Modal.view model.createDisbursementModalVisibility

aggsContainer : Model -> Html msg
aggsContainer model =
    Grid.row
        [ Row.attrs [class "align-items-center"] ]
        [ Grid.col [Col.xs2] [aggsTitleContainer]
        , Grid.col [Col.attrs [Spacing.pr0]] [aggsDataContainer model]
        ]


aggsTitleContainer : Html msg
aggsTitleContainer = Grid.containerFluid
    []
    [ Grid.row
        [Row.centerXs, Row.attrs [class "text-center text-xl"]]
        [ Grid.col [Col.xs4, Col.attrs [class "bg-ruby"]] [text "LIVE"]
        , Grid.col [Col.xs5] [text "Transactions"]
        ]
     ]

aggsDataContainer : Model -> Html msg
aggsDataContainer model = Grid.containerFluid
    []
    [ Grid.row []
        <| List.map agg
           [ ("Balance", dollar model.balance)
           , ("Total pending", dollar model.totalInProcessing)
           , ("Total raised", dollar model.totalRaised)
           , ("Total spent", dollar model.totalSpent)
           , ("Total donors", model.totalDonors)
           , ("Qualifying donors", model.qualifyingDonors)
           , ("Qualifying funds", dollar model.qualifyingFunds)
           ]
    ]

agg : (String, String) -> Column msg
agg (name, number) = Grid.col
    [Col.attrs [class "border-left text-center"]]
    [ Grid.row [Row.attrs [Spacing.pt1, Spacing.pb1]] [Grid.col [] [text name]]
    , Grid.row [Row.attrs [class "border-top", Spacing.pt1, Spacing.pb1]] [Grid.col [] [text number]]
    ]



-- Disbursements

disbursementsContainer : List Disbursement -> Html Msg
disbursementsContainer disbursements =
        Grid.row
            []
            [ Grid.col [] [disbursementsTable disbursements ]
            ]

dollar : String -> String
dollar str = "$" ++ str

-- Disbursements

labels : List String
labels =
    [ "Record"
    , "Date / Time"
    , "Entity Name"
    , "Amount"
    , "Purpose"
    , "Payment Method"
    , "Status"
    , "Verified"
    ]

createDisbursementModalButton : Html Msg
createDisbursementModalButton =
        Button.button
           [ Button.outlineSuccess , Button.attrs [ onClick <| ShowCreateDisbursementModal ] ]
           [ text "Create Disbursement" ]

disbursementsTable : List Disbursement -> Html Msg
disbursementsTable c
    = DataTable.view [createDisbursementModalButton] labels disbursementRowMap c

stringToBool : String -> Bool
stringToBool str =
    case str of
        "true" -> True
        _ -> False


oneLineAddressFromDisbursement : Disbursement -> String
oneLineAddressFromDisbursement d
    = d.addressLine1
    ++ ", "
    ++ d.addressLine2
    ++ ", "
    ++ d.city
    ++ ", "
    ++ d.state
    ++ " "
    ++ d.postalCode

disbursementRowMap : Disbursement -> (List (String, (Html msg)))
disbursementRowMap d =
        let
            status =
               if (stringToBool d.verified)
               then Asset.circleCheckGlyph [class "text-success data-icon-size"]
               else Asset.minusCircleGlyph [class "text-warning data-icon-size"]
        in
            [ ("Record", text d.recordNumber)
            , ("Date / Time", text d.date)
            , ("Entity Name", text d.entityName)
            , ("Amount", span [class "text-failure font-weight-bold"] [text <| dollar d.amount])
            , ("Purpose", text d.purposeCode)
            , ("Payment Method", span [class "text-failure font-weight-bold"] [text "ACH"])
            , ("Status",  status)
            , ("Verified", Asset.circleCheckGlyph [class "text-success data-icon-size"])
            ]




-- TAGS

-- UPDATE


type ContributionId = ContributionId String

type Msg
    = GotSession Session
    | LoadDisbursementsData (Result Http.Error DisbursementsData)
    | HideCreateDisbursementModal
    | ShowCreateDisbursementModal
    | AnimateCreateDisbursementModal Modal.Visibility

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )
        ShowCreateDisbursementModal -> ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none)
        HideCreateDisbursementModal -> ( { model | createDisbursementModalVisibility = Modal.hidden }, Cmd.none)
        AnimateCreateDisbursementModal visibility -> ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )
        LoadDisbursementsData res ->
            case res of
                  Ok data ->
                      let aggregates = data.aggregations
                      in
                      (
                        { model
                        | disbursements = data.disbursements
                        , balance = aggregates.balance
                        , totalRaised = aggregates.totalRaised
                        , totalSpent = aggregates.totalSpent
                        , totalDonors = aggregates.totalDonors
                        , qualifyingDonors = aggregates.qualifyingDonors
                        , qualifyingFunds = aggregates.qualifyingFunds
                        , totalTransactions = aggregates.totalTransactions
                        , totalInProcessing = aggregates.totalInProcessing
                        }
                      , Cmd.none
                      )
                  Err _ ->
                      ( model, Cmd.none )


-- HTTP

getDisbursementsData : Http.Request DisbursementsData
getDisbursementsData =
  Api.get (Endpoint.disbursements Session.committeeId) Nothing DD.decode

send : Cmd Msg
send =
  Http.send LoadDisbursementsData getDisbursementsData

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
