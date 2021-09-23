module Owner exposing (Owner, Owners)


type alias Owner =
    { firstName : String
    , lastName : String
    , addressLine1 : String
    , addressLine2 : String
    , city : String
    , state : String
    , postalCode : String
    , percentOwnership : String
    }


type alias Owners =
    List Owner
