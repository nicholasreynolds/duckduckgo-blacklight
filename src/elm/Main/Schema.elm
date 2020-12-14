module Main.Schema exposing (..)

import Html exposing (Html)
import Http
import Inspection exposing (Inspection)

type alias Model = {
        url : Url
        , status : Status
        , retry : Bool
        , error : String
        , cache : Maybe (Html Msg)
    }

type alias Url = String

type Status = Waiting
         | Loading
         | Failure
         | Success

type Msg = Opened
         | Closed
         | GotJson String