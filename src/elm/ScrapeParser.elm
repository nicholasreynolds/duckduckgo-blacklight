module ScrapeParser exposing (parse)

import Html exposing (Html)
import Html.Parser exposing (Document, Node(..), runDocument, Attribute)
import Html.Attributes exposing (attribute)

parse : String -> Html msg
parse str =
    let
        res = runDocument str
    in
    case res of
        Ok doc ->
            Tuple.second doc.document
            |> strip
            |> \maybe ->
                case maybe of
                    Just nodes -> build nodes
                    Nothing -> emptyNode
        Err _ -> emptyNode

emptyNode : Html msg
emptyNode = Html.div [] []

build : List Node -> Html msg
build nodes =
    Html.div [] (mapNodes nodes)

mapNodes : List Node -> List (Html msg)
mapNodes nodes =
    nodes
    |> List.map (\node ->
        case node of
            Element tag attr kids -> Html.node tag (mapAttr attr) (mapNodes kids)
            Comment _ -> emptyNode
            Text str -> Html.text str
        )

mapAttr : List Attribute -> List (Html.Attribute msg)
mapAttr butes =
    butes
    |> List.map (\(name,val) -> (attribute name val))

strip : List Node -> Maybe (List Node)
strip nodes =
    get (is "body") nodes
    |> getMaybe (get (is "div"))
    |> getMaybe (get (is "article"))
    |> getMaybe (getFirst 3)
    |> getMaybe (get (isClass "blacklight-client__results-wrapper"))
    |> getMaybe (getFirst 2)
    |> getMaybe (get (isClass "blacklight-client__groups"))

type alias Getter = (List Node -> Maybe (List Node))

getMaybe : Getter -> Maybe (List Node) -> Maybe (List Node)
getMaybe getter maybe =
    case maybe of
        Just nodes -> getter nodes
        Nothing -> Nothing

get : (Node -> Bool) -> Getter
get comp nodes =
    List.filter comp nodes
    |> List.head
    |> \maybe ->
        case maybe of
            Nothing -> Nothing
            Just node ->
                case node of
                    Element _ _ kids -> Just kids
                    _ -> Nothing

getFirst : Int -> Getter
getFirst depth nodes =
    case depth of
        0 -> Nothing
        _ ->
            let
                maybe : Maybe (List Node)
                maybe = case (List.head nodes) of
                            Nothing -> Nothing
                            Just node ->
                                case node of
                                    Element _ _ kids -> Just kids
                                    _ -> Nothing
            in
            case depth of
                1 -> maybe
                _ -> getMaybe (getFirst (depth - 1)) maybe

isClass : String -> Node -> Bool
isClass class node =
    case node of
        Element _ attr _ -> List.any (\(key,val) -> key == "class" && val == class) attr
        _ -> False

is : String -> Node -> Bool
is tag node =
    case node of
        Element str _ _ -> str == tag
        _ -> False