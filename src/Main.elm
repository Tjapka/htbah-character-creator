module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Input.Number as Number
import Input.Text as Text
import List.Extra exposing (..)


main =
    Html.program { init = init, view = view, update = update, subscriptions = always Sub.none }



-- MODEL


type alias Model =
    { character : Character
    , page : Page
    , inputNewActsItem : String
    , inputNewActsItemError : String
    , inputNewKnowledgeItem : String
    , inputNewKnowledgeItemError : String
    , inputNewInteractItem : String
    , inputNewInteractItemError : String
    }


type Page
    = PageBaseProperties
    | PageAdditionalProperties
    | PageSkillpoints
    | PageCharacterSheet


type StepMark
    = Checkmark
    | Final
    | Blank


type StepColors
    = Active
    | Completed
    | None


type ListItemType
    = Acts
    | Knowledge
    | Interact


type alias ListItem =
    { name : String
    , value : Int
    , itemType : ListItemType
    }


type alias Character =
    { name : String
    , firstName : String
    , stature : String
    , primaryLanguage : String
    , religion : String
    , sex : String
    , age : String
    , job : String
    , familyStatus : String
    , lifePoints : String
    , skillList : List ListItem
    , knowledge : Int
    , interact : Int
    , acts : Int
    , assignedSkillpoints : Int
    , spendableSkillpoints : Int
    , picture : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        (Character ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            "100"
            []
            0
            0
            0
            0
            500
            "img/character.jpg"
        )
        PageBaseProperties
        ""
        ""
        ""
        ""
        ""
        ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = ChangeName String
    | ChangeFirstname String
    | ChangeStature String
    | ChangePrimaryLanguage String
    | ChangeReligion String
    | ChangeSex String
    | ChangeAge String
    | ChangeJob String
    | ChangeFamilystatus String
    | ChangePage Page
    | ChangeSkillList String (Maybe Int)
    | ChangeSkillListRemoveItem String
    | InputNewItemActs String
    | ChangeActsAddNewItem String ListItemType
    | InputNewItemKnowledge String
    | ChangeKnowledgeAddNewItem String ListItemType
    | InputNewItemInteract String
    | ChangeInteractAddNewItem String ListItemType
    | NoOp String


update msg model =
    case msg of
        ChangeName name ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | name = name } }, Cmd.none )

        ChangeFirstname firstName ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | firstName = firstName } }, Cmd.none )

        ChangeStature stature ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | stature = stature } }, Cmd.none )

        ChangePrimaryLanguage primaryLanguage ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | primaryLanguage = primaryLanguage } }, Cmd.none )

        ChangeReligion religion ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | religion = religion } }, Cmd.none )

        ChangeSex sex ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | sex = sex } }, Cmd.none )

        ChangeAge age ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | age = age } }, Cmd.none )

        ChangeJob job ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | job = job } }, Cmd.none )

        ChangeFamilystatus familyStatus ->
            let
                character =
                    model.character
            in
                ( { model | character = { character | familyStatus = familyStatus } }, Cmd.none )

        ChangeSkillList name value ->
            let
                character =
                    model.character

                {--Total --}
                summedValues =
                    character.skillList
                        |> List.filter (\value -> value.name /= name)
                        |> List.map .value
                        |> List.sum

                sumAndCurrentValue =
                    summedValues + convertMaybeIntToInt value

                {--Acts --}
                actsTotal =
                    calculateTotal character Acts

                {--Knowledge --}
                knowledgeTotal =
                    calculateTotal character Knowledge

                {--Interact --}
                interactTotal =
                    calculateTotal character Interact

                skillListNew =
                    if sumAndCurrentValue <= 500 then
                        List.Extra.updateIf (\value -> value.name == name) (\input -> { input | value = convertMaybeIntToInt value }) model.character.skillList
                    else
                        model.character.skillList
            in
                ( { model | character = { character | skillList = skillListNew, assignedSkillpoints = sumAndCurrentValue, acts = actsTotal, knowledge = knowledgeTotal, interact = interactTotal } }, Cmd.none )

        ChangeSkillListRemoveItem name ->
            let
                character =
                    model.character

                skillListNew =
                    List.filter (\value -> value.name /= name) model.character.skillList
            in
                ( { model | character = { character | skillList = skillListNew } }, Cmd.none )

        ChangeActsAddNewItem newValue itemType ->
            let
                character =
                    model.character

                newList =
                    if checkIfValidNewItem newValue model.character.skillList then
                        List.append model.character.skillList [ (ListItem newValue 0 itemType) ]
                    else
                        model.character.skillList

                newInputItem =
                    if checkIfValidNewItem newValue model.character.skillList then
                        ""
                    else
                        newValue

                newInputItemError =
                    checkInputForErrorAndGenerateString newValue model.character.skillList
            in
                ( { model | character = { character | skillList = newList }, inputNewActsItem = newInputItem, inputNewActsItemError = newInputItemError }, Cmd.none )

        InputNewItemActs value ->
            ( { model | inputNewActsItem = value }, Cmd.none )

        ChangeKnowledgeAddNewItem newValue itemType ->
            let
                character =
                    model.character

                newList =
                    if checkIfValidNewItem newValue model.character.skillList then
                        List.append model.character.skillList [ (ListItem newValue 0 itemType) ]
                    else
                        model.character.skillList

                newInputItem =
                    if checkIfValidNewItem newValue model.character.skillList then
                        ""
                    else
                        newValue

                newInputItemError =
                    checkInputForErrorAndGenerateString newValue model.character.skillList
            in
                ( { model | character = { character | skillList = newList }, inputNewKnowledgeItem = newInputItem, inputNewKnowledgeItemError = newInputItemError }, Cmd.none )

        InputNewItemKnowledge value ->
            ( { model | inputNewKnowledgeItem = value }, Cmd.none )

        ChangeInteractAddNewItem newValue itemType ->
            let
                character =
                    model.character

                newList =
                    if checkIfValidNewItem newValue model.character.skillList then
                        List.append model.character.skillList [ (ListItem newValue 0 itemType) ]
                    else
                        model.character.skillList

                newInputItem =
                    if checkIfValidNewItem newValue model.character.skillList then
                        ""
                    else
                        newValue

                newInputItemError =
                    checkInputForErrorAndGenerateString newValue model.character.skillList
            in
                ( { model | character = { character | skillList = newList }, inputNewInteractItem = newInputItem, inputNewInteractItemError = newInputItemError }, Cmd.none )

        InputNewItemInteract value ->
            ( { model | inputNewInteractItem = value }, Cmd.none )

        ChangePage newPage ->
            ( { model | page = newPage }, Cmd.none )

        NoOp _ ->
            ( model, Cmd.none )


calculateTotal : Character -> ListItemType -> Int
calculateTotal character listItemType =
    (calculateSkillDivided character listItemType) + (calculateSkillOutstanding character listItemType)


calculateSkillDivided : Character -> ListItemType -> Int
calculateSkillDivided character listItemType =
    (character.skillList
        |> List.filter (\value -> value.itemType == listItemType)
        |> List.map .value
        |> List.sum
    )
        // 10


calculateSkillOutstanding : Character -> ListItemType -> Int
calculateSkillOutstanding character listItemType =
    (character.skillList
        |> List.filter (\value -> value.itemType == listItemType && value.value >= 80)
        |> List.length
    )
        * 10


checkForDuplicate list name =
    list
        |> List.map .name
        |> List.member name


checkIfValidNewItem : String -> List ListItem -> Bool
checkIfValidNewItem value list =
    String.trim value /= "" && not (checkForDuplicate list value)


checkInputForErrorAndGenerateString value list =
    if String.trim value == "" then
        "Bitte geb einen Namen für die Begabung ein."
    else if (checkForDuplicate list value) then
        "Begabung mit dem Namen bereits vorhanden."
    else
        ""



-- VIEW


view : Model -> Html Msg
view model =
    case model.page of
        PageBaseProperties ->
            renderHeaderAndFooter pageBaseProperties model

        PageAdditionalProperties ->
            renderHeaderAndFooter pageAdditionalProperties model

        PageSkillpoints ->
            renderHeaderAndFooter pageSkillpoints model

        PageCharacterSheet ->
            renderHeaderAndFooter pageCharacterSheet model


pageBaseProperties : Model -> Html Msg
pageBaseProperties model =
    div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ addInput "Vorname" "Der Vorname deines Characters." ChangeFirstname model.character.firstName False
                , addInput "Name" "Der Nachname deines Characters." ChangeName model.character.name False
                , addInput "Alter" "Bist du schon ein Greiß oder eher ein junger Hüpfer?" ChangeAge model.character.age False
                , addInput "Geschlecht" "Welchem Geschlecht gehört dein Charakter an?" ChangeSex model.character.sex False
                ]
            ]
        , (renderNextAndPreviousButtons model Nothing (Just PageAdditionalProperties))
        ]


pageAdditionalProperties : Model -> Html Msg
pageAdditionalProperties model =
    div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ addInput "Beruf" "Dein Beruf, z.B. Busfahrer oder Drachenjäger." ChangeJob model.character.job False
                , addInput "Statur" "Die Statur deines Characters, sollte zum Beruf passen." ChangeStature model.character.stature False
                , addInput "Muttersprache" "Die Muttersprache deines Characters." ChangePrimaryLanguage model.character.primaryLanguage False
                , addInput "Religion" "Deine Religion." ChangeReligion model.character.religion False
                , addInput "Familienstand" "Wie ist dein Familienstand?" ChangeFamilystatus model.character.familyStatus False
                ]
            ]
        , (renderNextAndPreviousButtons model (Just PageBaseProperties) (Just PageSkillpoints))
        ]


remainingSkillpoints : Model -> String
remainingSkillpoints model =
    toString (model.character.spendableSkillpoints - model.character.assignedSkillpoints)


pageSkillpoints : Model -> Html Msg
pageSkillpoints model =
    div [ class "container" ]
        [ div [ class "field" ]
            [ label [ class "label has-text-centered" ]
                [ text "Verbleibende Skillpunkte" ]
            , div [ class "control" ]
                [ input [ class "input is-large has-text-centered", type_ "text", value (remainingSkillpoints model), readonly True, disabled True ]
                    []
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column" ]
                [ div [ class "card" ]
                    [ header [ class "card-header" ]
                        [ p [ class "card-header-title is-centered" ]
                            [ renderHeaderAndPoints model.character.acts "Handeln"
                            ]
                        ]
                    , div [ class "card-content" ]
                        [ renderList Acts model.character.skillList
                        , renderInputWithPlusButton model.inputNewActsItem model.inputNewActsItemError InputNewItemActs (ChangeActsAddNewItem model.inputNewActsItem Acts) "Neue Handeln Begabung"
                        ]
                    ]
                ]
            , div [ class "column" ]
                [ div [ class "card" ]
                    [ header [ class "card-header" ]
                        [ p [ class "card-header-title is-centered" ]
                            [ renderHeaderAndPoints model.character.knowledge "Wissen" ]
                        ]
                    , div [ class "card-content" ]
                        [ renderList Knowledge model.character.skillList
                        , renderInputWithPlusButton model.inputNewKnowledgeItem model.inputNewKnowledgeItemError InputNewItemKnowledge (ChangeKnowledgeAddNewItem model.inputNewKnowledgeItem Knowledge) "Neue Wissens Begabung"
                        ]
                    ]
                ]
            , div [ class "column" ]
                [ div [ class "card" ]
                    [ header [ class "card-header" ]
                        [ p [ class "card-header-title is-centered" ]
                            [ renderHeaderAndPoints model.character.interact "Interagieren" ]
                        ]
                    , div [ class "card-content" ]
                        [ renderList Interact model.character.skillList
                        , renderInputWithPlusButton model.inputNewInteractItem model.inputNewInteractItemError InputNewItemInteract (ChangeInteractAddNewItem model.inputNewInteractItem Interact) "Neue Interaktions Begabung"
                        ]
                    ]
                ]
            ]
        , (renderNextAndPreviousButtons model (Just PageAdditionalProperties) (Just PageCharacterSheet))
        ]


pageCharacterSheet : Model -> Html Msg
pageCharacterSheet model =
    div [ class "container" ]
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ addInput "Vorname" "" ChangeFirstname model.character.firstName True
                , addInput "Geschlecht" "" ChangeSex model.character.sex True
                , addInput "Alter" "" ChangeAge model.character.age True
                , addInput "Statur" "" ChangeStature model.character.stature True
                , addInput "Muttersprache" "" ChangePrimaryLanguage model.character.primaryLanguage True
                ]
            , div [ class "column" ]
                [ figure [ class "image is-square" ]
                    [ img [ src model.character.picture ] []
                    ]
                    , addInput "Lebenspunkte" "" NoOp model.character.lifePoints True
                ]
            , div [ class "column" ]
                [ addInput "Name" "" ChangeName model.character.name True
                , addInput "Beruf" "" ChangeJob model.character.job True
                , addInput "Religion" "" ChangeReligion model.character.religion True
                , addInput "Familienstand" "" ChangeFamilystatus model.character.familyStatus True
                ]
            ]
        , div [ class "columns" ]
            [ div [ class "column" ]
                [ div [ class "box" ]
                    [ renderHeaderAndPoints model.character.acts "Handeln"
                    , renderOrderedStaticList Acts model.character.skillList
                    ]
                ]
            , div [ class "column" ]
                [ div [ class "box" ]
                    [ renderHeaderAndPoints model.character.knowledge "Wissen"
                    , renderOrderedStaticList Knowledge model.character.skillList
                    ]
                ]
            , div [ class "column" ]
                [ div [ class "box" ]
                    [ renderHeaderAndPoints model.character.interact "Interagieren"
                    , renderOrderedStaticList Interact model.character.skillList
                    ]
                ]
            ]
        , (renderNextAndPreviousButtons model (Just PageSkillpoints) Nothing)
        ]


leadsUpToCurrentPage : Page -> Page -> StepMark
leadsUpToCurrentPage page currentPage =
    case currentPage of
        PageAdditionalProperties ->
            if (page == PageBaseProperties) then
                Checkmark
            else if page == PageCharacterSheet then
                Final
            else
                Blank

        PageSkillpoints ->
            if (page == PageBaseProperties || page == PageAdditionalProperties) then
                Checkmark
            else if page == PageCharacterSheet then
                Final
            else
                Blank

        PageCharacterSheet ->
            if (page == PageBaseProperties || page == PageAdditionalProperties || page == PageSkillpoints) then
                Checkmark
            else if page == PageCharacterSheet then
                Final
            else
                Blank

        _ ->
            Blank


getStepMarkHtml : StepMark -> Html msg
getStepMarkHtml stepmark =
    case stepmark of
        Checkmark ->
            Html.span [ class "icon" ]
                [ i [ class "fa fa-check" ]
                    []
                ]

        Final ->
            Html.span [ class "icon" ]
                [ i [ class "fa fa-flag" ]
                    []
                ]

        Blank ->
            text ""


leadUpToCurrentPageColors : Page -> Page -> StepColors
leadUpToCurrentPageColors page currentPage =
    case currentPage of
        PageBaseProperties ->
            if (page == PageBaseProperties) then
                Active
            else
                None

        PageAdditionalProperties ->
            if (page == PageAdditionalProperties) then
                Active
            else if page == PageBaseProperties then
                Completed
            else
                None

        PageSkillpoints ->
            if (page == PageSkillpoints) then
                Active
            else if (page == PageBaseProperties || page == PageAdditionalProperties) then
                Completed
            else
                None

        PageCharacterSheet ->
            if (page == PageCharacterSheet) then
                Active
            else if (page == PageBaseProperties || page == PageAdditionalProperties || page == PageSkillpoints) then
                Completed
            else
                None


colorSteps : StepColors -> String
colorSteps stepcolor =
    if stepcolor == Completed then
        "step-item is-completed is-primary"
    else if stepcolor == Active then
        "step-item is-active"
    else
        "step-item"


renderStepsOverview : Model -> Html Msg
renderStepsOverview model =
    div [ class "steps  no-print hide-mobile" ]
        [ div [ class (leadUpToCurrentPageColors PageBaseProperties model.page |> colorSteps) ]
            [ div [ class "step-marker" ]
                [ leadsUpToCurrentPage PageBaseProperties model.page |> getStepMarkHtml ]
            , div [ class "step-details" ]
                [ p [ class "step-title" ]
                    [ text "Wer bist du?" ]
                , p []
                    [ text "Ein paar grundlegende Infos über deinen Charakter." ]
                ]
            ]
        , div [ class (leadUpToCurrentPageColors PageAdditionalProperties model.page |> colorSteps) ]
            [ div [ class "step-marker" ]
                [ leadsUpToCurrentPage PageAdditionalProperties model.page |> getStepMarkHtml ]
            , div [ class "step-details" ]
                [ p [ class "step-title" ]
                    [ text "Was machst du?" ]
                , p []
                    [ text "Was ist dein Beruf, wie ist deine Religion? Erstelle deine Hintergrundgeschichte." ]
                ]
            ]
        , div [ class (leadUpToCurrentPageColors PageSkillpoints model.page |> colorSteps) ]
            [ div [ class "step-marker" ]
                [ leadsUpToCurrentPage PageSkillpoints model.page |> getStepMarkHtml ]
            , div [ class "step-details" ]
                [ p [ class "step-title" ]
                    [ text "Begabungspunkte" ]
                , p []
                    [ text "Es ist soweit, hier kannst du deine Begabungspunkte verteilen!" ]
                ]
            ]
        , div [ class (leadUpToCurrentPageColors PageCharacterSheet model.page |> colorSteps) ]
            [ div [ class "step-marker" ]
                [ leadsUpToCurrentPage PageCharacterSheet model.page |> getStepMarkHtml ]
            , div [ class "step-details" ]
                [ p [ class "step-title" ]
                    [ text "Charakterbogen" ]
                , p []
                    [ text "Dein fertiger Charakterbogen, zum drucken." ]
                ]
            ]
        ]


renderNextAndPreviousButtons : Model -> Maybe Page -> Maybe Page -> Html Msg
renderNextAndPreviousButtons model previousPage nextPage =
    div [ class "field  is-grouped is-grouped-centered no-print" ]
        [ div [ class "control" ]
            [ case previousPage of
                Nothing ->
                    (div [] [])

                Just value ->
                    (button [ class "button is-link", onClick (ChangePage value) ]
                        [ text "Zurück" ]
                    )
            ]
        , div [ class "control" ]
            [ case nextPage of
                Nothing ->
                    (div [] [])

                Just value ->
                    (button [ class "button is-link", onClick (ChangePage value) ]
                        [ text "Weiter" ]
                    )
            ]
        ]


addInput title placeholderText inputMessage value readonlyInput =
    div [ class "field" ]
        [ label [ class "label" ]
            [ text title ]
        , div [ class "control" ]
            [ (Text.input
                (Text.defaultOptions inputMessage)
                [ class "input"
                , type_ "text"
                , placeholder placeholderText
                , readonly readonlyInput
                , disabled readonlyInput
                ]
                value
              )
            ]
        ]


renderOrderedStaticList : ListItemType -> List ListItem -> Html Msg
renderOrderedStaticList itemType list =
    div []
        (list
            |> List.filter (\item -> item.itemType == itemType)
            |> List.sortBy .value
            |> List.reverse
            |> (List.map (\input -> addInput input.name "" NoOp (toString input.value) True))
        )


renderList : ListItemType -> List ListItem -> Html Msg
renderList itemType list =
    div []
        (list
            |> List.filter (\item -> item.itemType == itemType)
            |> (List.map createListNumbers)
        )


createListNumbers listItem =
    div []
        [ label [ class "label" ]
            [ text listItem.name ]
        , div [ class "field has-addons" ]
            [ div [ class "control is-expanded" ]
                [ Number.input
                    { onInput = ChangeSkillList listItem.name
                    , maxLength = Nothing
                    , maxValue = Just 100
                    , minValue = Just 0
                    , hasFocus = Nothing
                    }
                    [ class "input"
                    ]
                    (Just listItem.value)
                ]
            , div [ class "control" ] [ button [ class "button is-danger", onClick (ChangeSkillListRemoveItem listItem.name) ] [ i [ class "fa fa-trash" ] [] ] ]
            ]
        ]


renderHeaderAndFooter : (Model -> Html Msg) -> Model -> Html Msg
renderHeaderAndFooter page model =
    div []
        [ section [ class "hero is-primary no-print" ]
            [ div [ class "hero-body" ]
                [ div [ class "container" ]
                    [ h1 [ class "title" ]
                        [ text "How to be a hero" ]
                    , h2 [ class "subtitle" ]
                        [ text "Characterblatt-Ersteller" ]
                    ]
                ]
            ]
        , section [ class "section" ] [ renderStepsOverview model, page model ]
        , footer [ class "footer no-print" ]
            [ div [ class "container" ]
                [ div [ class "content has-text-centered" ]
                    [ p []
                        [ text "How to be a hero character sheet creator done with "
                        , i [ class "fa fa-heart" ] []
                        , text " by Kolja Lampe. The source code is licensed MIT."
                        ]
                    , p []
                        [ text "You can find it on "
                        , a [ href "https://github.com/Razzeee/htbah-character-creator/" ] [ text "github" ]
                        ]
                    ]
                ]
            ]
        ]


renderHeaderAndPoints : Int -> String -> Html Msg
renderHeaderAndPoints value title =
    div [ class "control" ]
        [ div [ class "tags has-addons" ]
            [ Html.span [ class "tag is-large" ]
                [ text title ]
            , Html.span [ class "tag is-primary is-large" ]
                [ text (toString value)
                ]
            ]
        ]


convertMaybeIntToInt : Maybe number -> number
convertMaybeIntToInt input =
    case input of
        Nothing ->
            0

        Just value ->
            value


renderInputWithPlusButton : String -> String -> (String -> msg) -> msg -> String -> Html msg
renderInputWithPlusButton value error inputEvent onClickEvent placeholderString =
    div []
        [ label [ class "label" ]
            []
        , div [ class "field has-addons" ]
            [ div [ class "control is-expanded" ]
                [ Text.input
                    (Text.defaultOptions inputEvent)
                    [ class "input", type_ "text", placeholder placeholderString ]
                    value
                ]
            , div [ class "control" ]
                [ button [ class "button is-info", onClick onClickEvent ]
                    [ i [ class "fa fa-plus" ] [] ]
                ]
            ]
        , if error /= "" then
            div [ class "notification is-danger" ]
                [ text error
                ]
          else
            div [] []
        ]
