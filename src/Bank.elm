module Bank exposing (stringToLogo)

import Asset
import Html exposing (Html, img, span)
import Html.Attributes exposing (class)


stringToLogo : String -> Html msg
stringToLogo bank =
    case bank of
        "chase" ->
            img
                [ Asset.src Asset.chaseBankLogo, class "header-info-bank-logo" ]
                []

        "avanti" ->
            img
                [ Asset.src Asset.chaseBankLogo, class "header-info-bank-logo" ]
                []

        "adirondack trust company" ->
            img
                [ Asset.src Asset.adirondackTrustCompanyLogo, class "header-info-bank-logo" ]
                []

        "citizens banks" ->
            img
                [ Asset.src Asset.citizensBankLogo, class "header-info-bank-logo" ]
                []

        _ ->
            span
                []
                []
