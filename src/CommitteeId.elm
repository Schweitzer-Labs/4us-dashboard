module CommitteeId exposing (fromMaybe, parse)

import Url
import Url.Parser as Parser
import Url.Parser.Query as Query


parse : Url.Url -> String
parse url =
    url
        |> Parser.parse (Parser.query (Query.string "committeeId"))
        |> Maybe.withDefault (Just "")
        |> Maybe.withDefault ""


fromMaybe : Maybe String -> Maybe String
fromMaybe maybeSlug =
    if maybeSlug == Just "null" then
        Nothing

    else
        maybeSlug
