module Inspection.Render exposing (..)

import Event exposing (onClickPreventDefault)
import Html.Parser exposing (run)
import Html.Parser.Util
import Inspection exposing (Inspection, Group, Card)
import Array exposing (Array)
import Html exposing (Html, button, div, h3, h4, p, strong, text)
import Html.Attributes exposing (class)
import Main.Schema exposing (Msg)

viewInspection : Inspection -> Msg -> Html Msg
viewInspection insp closeMsg =
        div [class "inspection"] <|
            [
                button [class "close", onClickPreventDefault closeMsg] [text "Close"]
            ]
            ++ viewErrorStatus insp

viewErrorStatus : Inspection -> List (Html msg)
viewErrorStatus insp =
    if not (insp.status == "success") then
        [viewError insp.status]
    else
        [viewGroup0 (Array.get 0 insp.groups)
        , viewGroup1 (Array.get 1 insp.groups)]

viewError : String -> Html msg
viewError str =
    div [class "error"] [ strong [] [ text str ] ]

viewGroup0 : Maybe Group -> Html msg
viewGroup0 maybe =
    case maybe of
        Nothing -> viewError "Error rendering group 0"
        Just g0 -> div [class "group0"] <|
            [
                h3 [] [text g0.title]
            ]
            ++ viewStringArray g0.description
            ++ viewCards g0.cards

viewGroup1 : Maybe Group -> Html msg
viewGroup1 maybe =
    case maybe of
        Nothing -> viewError "Error rendering group 1"
        Just g1 -> div [class "group1"] <|
            [
                h3 [] [text g1.title]
            ]
            ++ viewCards g1.cards

viewCards : Array Card -> List (Html msg)
viewCards cards =
    Array.toList cards
    |> List.map (\card ->
            viewCard card
        )

viewCard : Card -> Html msg
viewCard card =
    div [class "card"] (
        [
            viewCardTitle card
        ]
        ++ viewStringArray card.body
        ++ [
            viewCardAdditional card
        ]
    )

viewCardTitle : Card -> Html msg
viewCardTitle card =
    h4 []
    [
        text
        (
            (
                if (card.bigNumber >= 0) then
                    String.fromInt card.bigNumber ++ " "
                else
                    ""
            )
            ++ card.title
        )
    ]

viewCardAdditional : Card -> Html msg
viewCardAdditional card =
    if not (String.isEmpty card.onAvgStatement) then
        viewAsVirtualDom card.onAvgStatement
    else if not (String.isEmpty card.caveat) then
        viewAsVirtualDom card.caveat
    else
        text ""

viewStringArray : Array String -> List (Html msg)
viewStringArray body =
    Array.toList body
    |> List.map (\par -> viewAsVirtualDom par)

viewAsVirtualDom : String -> Html msg
viewAsVirtualDom html =
    case (run html) of
         Ok nodes -> p [] (Html.Parser.Util.toVirtualDom nodes)
         Err _ -> text ""