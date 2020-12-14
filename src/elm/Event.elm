module Event exposing (..)

import Html
import Html.Events
import Json.Decode as Decode
import Main.Schema exposing (Msg)

onClickPreventDefault : Msg -> Html.Attribute Msg
onClickPreventDefault msg =
    Html.Events.custom "click" (Decode.succeed {message = msg, stopPropagation = True, preventDefault = True})
