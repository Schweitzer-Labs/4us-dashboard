module Page.Disbursements exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Asset
import Banner
import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Text as Text
import Browser.Dom as Dom
import Content
import DataTable
import Html exposing (..)
import Html.Attributes exposing (class, for, value)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Json.Encode as Encode
import PaymentMethod exposing (PaymentMethod(..))
import Purpose exposing (Purpose)
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
import Bootstrap.Form.Select as Select



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
    , createDisbursementModalPaymentMethod: Maybe PaymentMethod
    , createDisbursementModalPurpose: Maybe String
    , checkAmount: String
    , checkNumber: String
    , checkRecipient: String
    , checkDate: String
    , committeeId: String
    }



init : Session -> String -> ( Model, Cmd Msg )
init session committeeId =
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
      , createDisbursementModalPaymentMethod = Nothing
      , createDisbursementModalPurpose = Nothing
      -- Here is be dragons
      , checkAmount = ""
      , checkNumber = ""
      , checkRecipient = ""
      , checkDate = ""
      , committeeId = committeeId
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
            [ Banner.container [] <| aggsContainer model
            , Content.container <| [ disbursementsContainer model.disbursements ]
            , createDisbursementModal model
            ]
    }


selectPurpose : Model -> Html Msg
selectPurpose model =
    Form.group
        []
        [ Form.label [for "purpose"] [ text "Purpose"]
        , Select.select
            [ Select.id "purpose"
            , Select.onChange CreateDisbursementModalPurposeUpdated
            , Select.attrs
                [ value
                <| Maybe.withDefault "---" model.createDisbursementModalPurpose
                ]
            ]
            <| (++) [Select.item [] [ text "---" ]]
            <| List.map (
               \(_, codeText, purposeText) -> Select.item [value codeText] [ text <| purposeText ]
            ) Purpose.purposeText
        ]



selectPaymentMethod : Model -> Html Msg
selectPaymentMethod model =
    Form.group
        []
        [ Form.label [for "payment-method"] [ text "Payment Method"]
        , Select.select
            [ Select.id "payment-method"
            , Select.onChange CreateDisbursementModalPaymentMethodUpdated
            , Select.attrs
                [ value
                <| Maybe.withDefault ""
                <| Maybe.map
                    PaymentMethod.paymentMethodToText
                    model.createDisbursementModalPaymentMethod
                ]
            ]
            <| (++) [Select.item [] [ text "---" ]]
            <| List.map
               ( \(valueText, displayText) -> Select.item [value valueText] [ text displayText ]
               )
               PaymentMethod.paymentMethodText
        ]

renderPaymentMethodForm : Model -> Html Msg
renderPaymentMethodForm model =
    case model.createDisbursementModalPaymentMethod of
        Just method ->
            case method of
                 PaymentMethod.Check check ->
                    Grid.containerFluid
                        []
                        [ Grid.row []
                            [ Grid.col
                                  [Col.lg4]
                                  [ Form.label [for "amount"] [ text "Amount"]
                                  , Input.text [ Input.id "amount", Input.onInput CheckAmountUpdated ]
                                  ]
                            , Grid.col
                                [Col.lg4]
                                [ Form.label [for "check-number"] [ text "Check Number"]
                                , Input.text [ Input.id "check-number", Input.onInput CheckNumberUpdated ]
                                ]
                            , Grid.col
                              [Col.lg4]
                              [ Form.label [for "date"] [ text "Date"]
                              , Input.date [ Input.id "date", Input.onInput CheckDateUpdated ]
                              ]
                            ]
                        , Grid.row [ Row.attrs [Spacing.mt2]]
                            [ Grid.col
                              []
                              [ Form.label [for "recipient-name"] [ text "Recipient Name"]
                              , Input.text [ Input.id "recipient-name", Input.onInput CheckRecipientUpdated ]
                              ]
                            ]
                        ]
                 _ -> div [] [text "tbd"]
        Nothing -> span [] []

createDisbursementModal : Model -> Html Msg
createDisbursementModal model =
    Modal.config HideCreateDisbursementModal
        |> Modal.withAnimation AnimateCreateDisbursementModal
        |> Modal.large
        |> Modal.hideOnBackdropClick True
        |> Modal.h3 [] [ text "Create Disbursement" ]
        |> Modal.body
            []
            [ p
                []
                [ selectPurpose model
                , selectPaymentMethod model
                , renderPaymentMethodForm model
                ]
            ]
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
                        , Button.attrs [ onClick SubmitCreateDisbursement, class "text-right" ]
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
            , ("Payment Method", span [class "text-failure font-weight-bold"] [text d.paymentMethod])
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
    | CreateDisbursementModalPurposeUpdated String
    | CreateDisbursementModalPaymentMethodUpdated String
    | CheckAmountUpdated String
    | CheckRecipientUpdated String
    | CheckNumberUpdated String
    | CheckDateUpdated String
    | GotCreateDisbursementReponse (Result Http.Error String)
    | SubmitCreateDisbursement

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )
        ShowCreateDisbursementModal -> ( { model | createDisbursementModalVisibility = Modal.shown }, Cmd.none)
        HideCreateDisbursementModal ->
            ( { model
              | createDisbursementModalVisibility = Modal.hidden
              , createDisbursementModalPaymentMethod = Nothing
              , createDisbursementModalPurpose = Nothing
              }, Cmd.none)
        SubmitCreateDisbursement ->
            ( { model
              | createDisbursementModalVisibility = Modal.hidden
              , createDisbursementModalPaymentMethod = Nothing
              , createDisbursementModalPurpose = Nothing
              }, createDisbursement model)
        AnimateCreateDisbursementModal visibility -> ( { model | createDisbursementModalVisibility = visibility }, Cmd.none )
        CreateDisbursementModalPurposeUpdated str -> ({model | createDisbursementModalPurpose = Just str }, Cmd.none)
        CreateDisbursementModalPaymentMethodUpdated str ->
            let
                paymentMethod = PaymentMethod.init str
            in
                ( {model | createDisbursementModalPaymentMethod = paymentMethod}, Cmd.none)
        CheckAmountUpdated str -> ({model | checkAmount = str}, Cmd.none)
        CheckRecipientUpdated str -> ({model | checkRecipient = str}, Cmd.none)
        CheckNumberUpdated str -> ({model | checkNumber = str}, Cmd.none)
        CheckDateUpdated str -> ({model | checkDate = str}, Cmd.none)
        GotCreateDisbursementReponse res ->
            case res of
              Ok data ->
                  (model, getDisbursementsData model.committeeId)
              Err _ ->
                  ( model, Cmd.none )
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

getDisbursementsData : String -> Cmd Msg
getDisbursementsData committeeId =
  Http.send LoadDisbursementsData
  <| Api.get (Endpoint.disbursements committeeId) Nothing DD.decode


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
        , ( "entityName", Encode.string model.checkRecipient )
        , ( "purposeCode", Encode.string <| Maybe.withDefault "other" model.createDisbursementModalPurpose )
        , ( "amount", Encode.string model.checkAmount )
        , ( "date", Encode.string model.checkDate )
        ]

createDisbursement : Model -> Cmd Msg
createDisbursement model =
    let
       body = encodeDisbursement model |> Http.jsonBody
    in
       Http.send GotCreateDisbursementReponse
       <| Api.post (Endpoint.disbursement) Nothing body Decode.string
















