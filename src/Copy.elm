module Copy exposing (contribUnverifiedDialogue, disbUnverifiedDialogue, verificationScore)

import Html exposing (Html, text)


verificationScore : String
verificationScore =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."


disbUnverifiedDialogue : List (Html msg)
disbUnverifiedDialogue =
    [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    , text "At urna condimentum mattis pellentesque id nibh tortor id aliquet."
    ]


contribUnverifiedDialogue : List (Html msg)
contribUnverifiedDialogue =
    [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
    , text "At urna condimentum mattis pellentesque id nibh tortor id aliquet."
    ]
