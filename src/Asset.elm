module Asset exposing
    ( Image
    , adirondackTrustCompanyLogo
    , amalgamatedLogo
    , angleDownGlyph
    , angleUpGlyph
    , bellGlyph
    , binoculars
    , blockchainDiamond
    , calendar
    , chartLineGlyph
    , chaseBankLogo
    , chaseSquare
    , circleCheckGlyph
    , citizensBankLogo
    , coinsGlyph
    , contributionsByRefcodeChart
    , defaultAvatar
    , documents
    , donorByRefcodeChart
    , editGlyph
    , eightX
    , error
    , exclamationCircleGlyph
    , gearHires
    , genderNeutral
    , house
    , linkGlyph
    , loading
    , minusCircleGlyph
    , monthlyContributionsByReferenceCode
    , person
    , plusCircleGlyph
    , sackDollarGlyph
    , search
    , searchDollarGlyph
    , src
    , stripeLogo
    , tbdBankLogo
    , timesGlyph
    , universityGlyph
    , usLogo
    , userGlyph
    , wiseLogo
    )

{-| Assets, such as images, videos, and audio. (We only have images for now.)

We should never expose asset URLs directly; this module should be in charge of
all of them. One source of truth!

-}

import Html exposing (Attribute, Html, i)
import Html.Attributes as Attr exposing (class)


type Image
    = Image String



-- IMAGES


error : Image
error =
    image "error.jpg"


amalgamatedLogo : Image
amalgamatedLogo =
    image "amalgamated-bank-logo.png"


wiseLogo : Image
wiseLogo =
    image "wise-bank-logo.png"


usLogo : Image
usLogo =
    image "logo-hires-wing.png"


blockchainDiamond : Image
blockchainDiamond =
    image "blockchain-diamond.png"


gearHires : Image
gearHires =
    image "gear-hires.png"


search : Image
search =
    image "search.png"


calendar : Image
calendar =
    image "calendar.png"


person : Image
person =
    image "person.png"


house : Image
house =
    image "house.png"


eightX : Image
eightX =
    image "eight-x.png"


binoculars : Image
binoculars =
    image "binoculars.png"


stripeLogo : Image
stripeLogo =
    image "stripe-logo.png"


documents : Image
documents =
    image "documents.png"


loading : Image
loading =
    image "loading.svg"


adirondackTrustCompanyLogo : Image
adirondackTrustCompanyLogo =
    image "adirondack-trust-company.png"


defaultAvatar : Image
defaultAvatar =
    image "smiley-cyrus.jpg"


chaseBankLogo : Image
chaseBankLogo =
    image "chase-logo-header.png"


citizensBankLogo : Image
citizensBankLogo =
    image "citizens-bank-logo.png"


genderNeutral : Bool -> Image
genderNeutral selected =
    if selected then
        image "gender-neutral-selected.svg"

    else
        image "gender-neutral.svg"


chaseSquare : Image
chaseSquare =
    image "chase-square.png"


tbdBankLogo : Image
tbdBankLogo =
    image "tbd-bank-logo.svg"


image : String -> Image
image filename =
    Image ("/assets/images/" ++ filename)


contributionsByRefcodeChart : Image
contributionsByRefcodeChart =
    image "contributions-by-ref-code.svg"


monthlyContributionsByReferenceCode : Image
monthlyContributionsByReferenceCode =
    image "monthly-contributions-by-reference-code.svg"


donorByRefcodeChart : Image
donorByRefcodeChart =
    image "donor-by-ref-code.svg"



-- USING IMAGES


src : Image -> Attribute msg
src (Image url) =
    Attr.src url



-- USING GLYPHS


type Glyph
    = Glyph String


glyph : String -> List (Attribute msg) -> Html msg
glyph name more =
    i ([ class "align-middle fa", class name ] ++ more) []


circleCheckGlyph : List (Attribute msg) -> Html msg
circleCheckGlyph =
    glyph "fa-check-circle"


sackDollarGlyph : List (Attribute msg) -> Html msg
sackDollarGlyph =
    glyph "fa-sack-dollar"


editGlyph : List (Attribute msg) -> Html msg
editGlyph =
    glyph "fas fa-edit"


minusCircleGlyph : List (Attribute msg) -> Html msg
minusCircleGlyph =
    glyph "fa-minus-circle"


linkGlyph : List (Attribute msg) -> Html msg
linkGlyph =
    glyph "fa-link"


coinsGlyph : List (Attribute msg) -> Html msg
coinsGlyph =
    glyph "fal fa-coins"


bellGlyph : List (Attribute msg) -> Html msg
bellGlyph =
    glyph "fas fa-bell"


userGlyph : List (Attribute msg) -> Html msg
userGlyph =
    glyph "fas fa-user"


universityGlyph : List (Attribute msg) -> Html msg
universityGlyph =
    glyph "fas fa-store-alt"


searchDollarGlyph : List (Attribute msg) -> Html msg
searchDollarGlyph =
    glyph "fas fa-search-dollar"


chartLineGlyph : List (Attribute msg) -> Html msg
chartLineGlyph =
    glyph "fas fa-chart-bar"


exclamationCircleGlyph : List (Attribute msg) -> Html msg
exclamationCircleGlyph =
    glyph "fas fa-exclamation-circle"


angleDownGlyph : List (Attribute msg) -> Html msg
angleDownGlyph =
    glyph "fas fa-angle-down"


angleUpGlyph : List (Attribute msg) -> Html msg
angleUpGlyph =
    glyph "fas fa-angle-up"


timesGlyph : List (Attribute msg) -> Html msg
timesGlyph =
    glyph "fas fa-times"


plusCircleGlyph : List (Attribute msg) -> Html msg
plusCircleGlyph =
    glyph "fa fa-plus-circle"


redoGlyph : List (Attribute msg) -> Html msg
redoGlyph =
    glyph "fas fa-redo"
