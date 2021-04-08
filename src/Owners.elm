module Owners exposing (Owner, Owners)


type alias Owner =
    { name : String
    , percentOwnership : String
    }


type alias Owners =
    List Owner
