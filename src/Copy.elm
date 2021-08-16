module Copy exposing (contribRuleVerifiedInfo, verificationScore)

import Html exposing (Html, text)


verificationScore : String
verificationScore =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."


contribRuleVerifiedInfo : List (Html msg)
contribRuleVerifiedInfo =
    [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    , text "At urna condimentum mattis pellentesque id nibh tortor id aliquet."
    ]
