port module Main exposing (main)

import Event exposing (onClickPreventDefault)
import Json.Decode
import Main.Schema exposing (..)
import Browser
import Html exposing (Html, button)
import Inspection.Render exposing (viewInspection)
import Json.Encode as Encode exposing (Value)
import Inspection exposing (..)

port requestInspection : String -> Cmd msg
port receiveInspection : (String -> msg) -> Sub msg

main : Program Url Model Msg
main =
    Browser.element {
        init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
    }

init : Url -> (Model, Cmd Msg)
init url =
    ({
        url = url
        , status = Waiting
        , retry = False
        , error = ""
        , cache = Nothing
     }, Cmd.none)

view : Model -> Html Msg
view model =
    case model.status of
        Success ->
            case model.cache of
                Just cache -> cache
                Nothing -> viewButton model
        _ -> viewButton model

viewButton : Model -> Html Msg
viewButton model =
    button [onClickPreventDefault Opened] [Html.text <| getStatus <| model]


getStatus : Model -> String
getStatus model =
    case model.status of
        Waiting -> "Inspect"
        Loading -> "Inspecting"
        Failure -> model.error
        Success -> "Inspection complete"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Opened ->
            let
                requestCommand = requestInspection model.url
            in
            case model.cache of
                Nothing -> ({model | status = Loading}, requestCommand)
                Just _ -> (
                    {model | status = Success}
                    ,
                        if model.retry then
                            requestCommand
                        else
                            Cmd.none
                    )
        Closed -> ({model | status = Waiting}, Cmd.none)
        GotJson result ->
            let
                decoded = Json.Decode.decodeString inspectionDecoder result
            in
            case decoded of
                Ok value -> (
                    {model | status = Success, cache = Just (viewInspection value Closed), retry = not (value.status == "success")}
                    , Cmd.none
                    )
                Err _ -> ({model | status = Failure, error = "Couldn't parse response"}, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveInspection GotJson