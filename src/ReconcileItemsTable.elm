module ReconcileItemsTable exposing (Model, view)

import DataTable exposing (DataRow)
import Html exposing (Html, input, text)
import Html.Attributes exposing (type_)
import List exposing (sortBy)
import TimeZone exposing (america__new_york)
import Timestamp
import Transaction
import Transactions


type alias Model =
    List Transaction.Model


type Label
    = Selected
    | Date
    | EntityName
    | Amount
    | PurposeCode


labels : (Label -> msg) -> List ( msg, String )
labels sortMsg =
    [ ( sortMsg Selected, "Selected" )
    , ( sortMsg Date, "Date" )
    , ( sortMsg EntityName, "Entity Name" )
    , ( sortMsg Amount, "Amount" )
    , ( sortMsg PurposeCode, "Purpose Code" )
    ]


transactionRowMap : ( Maybe msg, Transaction.Model ) -> ( Maybe msg, DataRow msg )
transactionRowMap ( maybeMsg, transaction ) =
    let
        name =
            Maybe.withDefault Transactions.missingContent (Maybe.map Transactions.uppercaseText <| Transactions.getEntityName transaction)

        amount =
            Transactions.getAmount transaction
    in
    ( maybeMsg
    , [ ( "Selected", input [ type_ "checkbox" ] [] )
      , ( "Date / Time", text <| Timestamp.format (america__new_york ()) transaction.initiatedTimestamp )
      , ( "Entity Name", name )
      , ( "Amount", amount )
      , ( "Status", Transactions.getStatus transaction )
      ]
    )


view : List String -> List Transaction.Model -> Html msg
view content txns =
    DataTable.view "Awaiting Transactions." content transactionRowMap <|
        List.map (\d -> ( Nothing, d )) <|
            List.reverse (sortBy .initiatedTimestamp txns)
