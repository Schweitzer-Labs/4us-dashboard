module CommitteeId exposing (parse)

import Url
import Url.Parser as Parser
import Url.Parser.Query as Query


parse : Url.Url -> String
parse url =
    url
        |> Parser.parse (Parser.query (Query.string "committeeId"))
        |> Maybe.withDefault (Just "")
        |> Maybe.withDefault ""
