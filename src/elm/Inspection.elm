module Inspection exposing (inspectionDecoder, Inspection, Group, Card)

import Array exposing (Array)
import Json.Decode as Decode exposing (Decoder, array, bool, int, string)
import Json.Decode.Pipeline exposing (optional, required)

type alias Inspection = {
        status : String
        , groups : Array Group
    }

type alias Group = {
        -- Invariable, required
        title : String
        , description : Array String
        , cards : Array Card
        -- Variable between group types
        , thirdPartyTrackersFound : Bool
    }

type alias Card = {
        -- Invariable, required
        title : String
        , cardType : String
        , body : Array String
        -- Variable between card types
        , caveat : String
        , surveyLink : String
        , methodology : String
        , bl_data_type : String
        , last_updated : String
        , onAvgStatement : String
        , privacy_policy : String
        , ddg_company_lookup : String
        , domains_found : Array String
        , dataUrlForImage : Array String
        , expandableList : Array (Array String)
        , bigNumber : Int
        , testEventsFound : Bool
    }

inspectionDecoder : Decoder Inspection
inspectionDecoder =
    Decode.succeed Inspection
        |> required "status" string
        |> optional "groups" (array groupDecoder) Array.empty

groupDecoder : Decoder Group
groupDecoder =
    Decode.succeed Group
        |> required "title" string
        |> required "description" (array string)
        |> required "cards" (array cardDecoder)
        |> optional "thirdPartyTrackersFound" bool False

cardDecoder : Decoder Card
cardDecoder =
    Decode.succeed Card
        |> required "title" string
        |> required "cardType" string
        |> required "body" (array string)
        |> optional "caveat" string ""
        |> optional "surveyLink" string ""
        |> optional "methodology" string ""
        |> optional "bl_data_type" string ""
        |> optional "last_updated" string ""
        |> optional "onAvgStatement" string ""
        |> optional "privacy_policy" string ""
        |> optional "ddg_company_lookup" string ""
        |> optional "domains_found" (array string) Array.empty
        |> optional "dataUrlForImage" (array string) Array.empty
        |> optional "expandableList" (array (array string)) Array.empty
        |> optional "bigNumber" int -1
        |> optional "testEventsFound" bool False