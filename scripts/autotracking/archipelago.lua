ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CURRENT_INDEX = -1

function onClear(slotData)
    CURRENT_INDEX = -1

    -- Reset Locations
    for _, layoutLocationPath in pairs(LOCATION_MAPPING) do
        if layoutLocationPath[1] then
            local layoutLocationObject = Tracker:FindObjectForCode(layoutLocationPath[1])

            if layoutLocationObject then
                if layoutLocationPath[1]:sub(1, 1) == "@" then
                    layoutLocationObject.AvailableChestCount = layoutLocationObject.ChestCount
                else
                    layoutLocationObject.Active = false
                end
            end
        end
    end

    -- Reset Items
    for _, item in ipairs(ITEM_MAPPING) do
        for _, layoutItemData in pairs(item) do
            if layoutItemData[1] and layoutItemData[2] then
                local layoutItemObject = Tracker:FindObjectForCode(layoutItemData[1])

                if layoutItemObject then
                    if layoutItemData[2] == "toggle" then
                        layoutItemObject.Active = false
                    elseif layoutItemData[2] == "progressive" then
                        layoutItemObject.CurrentStage = 0
                        layoutItemObject.Active = false
                    elseif layoutItemData[2] == "consumable" then
                        layoutItemObject.AcquiredCount = 0
                    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print(string.format("onClear: Unknown item type %s for code %s", layoutItemData[2], layoutItemData[1]))
                    end
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: Could not find object for code %s", layoutItemData[1]))
                end
            end
        end
    end

    -- Reset Logic
    Tracker:FindObjectForCode("lives_3_4").AcquiredCount = slotData['number_life_mid']
    Tracker:FindObjectForCode("bombs_3_4").AcquiredCount = slotData['number_bomb_mid']
    Tracker:FindObjectForCode("lower_difficulty_3_4").CurrentStage = slotData['difficulty_mid']
    Tracker:FindObjectForCode("lives_5_6").AcquiredCount = slotData['number_life_end']
    Tracker:FindObjectForCode("bombs_5_6").AcquiredCount = slotData['number_bomb_end']
    Tracker:FindObjectForCode("lower_difficulty_5_6").CurrentStage = slotData['difficulty_end']
    Tracker:FindObjectForCode("lives_extra").AcquiredCount = slotData['number_life_extra']
    Tracker:FindObjectForCode("bombs_extra").AcquiredCount = slotData['number_bomb_extra']
    Tracker:FindObjectForCode("extra_stage_included").CurrentStage = slotData['extra_stage']
    Tracker:FindObjectForCode("lives_phantasm").AcquiredCount = slotData['number_life_phantasm']
    Tracker:FindObjectForCode("bombs_phantasm").AcquiredCount = slotData['number_bomb_phantasm']
    Tracker:FindObjectForCode("phantasm_stage_included").CurrentStage = slotData['phantasm_stage']
    Tracker:FindObjectForCode("shot_type_check").Active = slotData['shot_type']
    Tracker:FindObjectForCode("difficulty_check").Active = slotData['difficulty_check']
    Tracker:FindObjectForCode("include_lunatic").Active = (slotData['exclude_lunatic'] == 0)

    if not Tracker:FindObjectForCode("include_lunatic").Active then
        Tracker:FindObjectForCode("lower_difficulty").CurrentStage = 1
    end

    local cherry_border = 0
    if slotData['cherry_border'] == 0 then
        cherry_border = 1
    end

    Tracker:FindObjectForCode("cherry_border").AcquiredCount = cherry_border
end

function onItem(index, itemId, itemName, playerNumber)
    if index <= CURRENT_INDEX then
        return
    end

    CURRENT_INDEX = index

    --- Special case for the extra stage when it's in progressive mode
    if Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 then
        --- We only check the first one since we consider that there is only one type of stage unlock group
        if(itemId == STARTING_ITEM_ID + 200 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5) then
            itemId = STARTING_ITEM_ID + 210
        elseif(itemId == STARTING_ITEM_ID + 201 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 211
        elseif(itemId == STARTING_ITEM_ID + 202 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 212
        elseif(itemId == STARTING_ITEM_ID + 203 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 213
        elseif(itemId == STARTING_ITEM_ID + 204 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 214
        elseif(itemId == STARTING_ITEM_ID + 205 and Tracker:FindObjectForCode("reimu_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 215
        elseif(itemId == STARTING_ITEM_ID + 206 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 216
        elseif(itemId == STARTING_ITEM_ID + 207 and Tracker:FindObjectForCode("marisa_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 217
        elseif(itemId == STARTING_ITEM_ID + 208 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 218
        elseif(itemId == STARTING_ITEM_ID + 209 and Tracker:FindObjectForCode("sakuya_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 219
        end
    end

    --- Special case for the phantasm stage when it's in progressive mode
    if Tracker:FindObjectForCode("extra_stage_included").CurrentStage ~= 1 and Tracker:FindObjectForCode("phantasm_stage_included").CurrentStage == 1 then
        --- We only check the first one since we consider that there is only one type of stage unlock group
        if(itemId == STARTING_ITEM_ID + 200 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5) then
            itemId = STARTING_ITEM_ID + 220
        elseif(itemId == STARTING_ITEM_ID + 201 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 221
        elseif(itemId == STARTING_ITEM_ID + 202 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 222
        elseif(itemId == STARTING_ITEM_ID + 203 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 223
        elseif(itemId == STARTING_ITEM_ID + 204 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 224
        elseif(itemId == STARTING_ITEM_ID + 205 and Tracker:FindObjectForCode("reimu_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 225
        elseif(itemId == STARTING_ITEM_ID + 206 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 226
        elseif(itemId == STARTING_ITEM_ID + 207 and Tracker:FindObjectForCode("marisa_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 227
        elseif(itemId == STARTING_ITEM_ID + 208 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 228
        elseif(itemId == STARTING_ITEM_ID + 209 and Tracker:FindObjectForCode("sakuya_b_stage_unlocked").CurrentStage >= 5)  then
            itemId = STARTING_ITEM_ID + 229
        end
    elseif Tracker:FindObjectForCode("extra_stage_included").CurrentStage == 1 and Tracker:FindObjectForCode("phantasm_stage_included").CurrentStage == 1 then
        if(itemId == STARTING_ITEM_ID + 210 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5 and Tracker:FindObjectForCode("reimu_a_extra_stage").Active) then
            itemId = STARTING_ITEM_ID + 220
        elseif(itemId == STARTING_ITEM_ID + 211 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("reimu_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 221
        elseif(itemId == STARTING_ITEM_ID + 212 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("marisa_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 222
        elseif(itemId == STARTING_ITEM_ID + 213 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("sakuya_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 223
        elseif(itemId == STARTING_ITEM_ID + 214 and Tracker:FindObjectForCode("reimu_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("reimu_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 224
        elseif(itemId == STARTING_ITEM_ID + 215 and Tracker:FindObjectForCode("reimu_b_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("reimu_b_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 225
        elseif(itemId == STARTING_ITEM_ID + 216 and Tracker:FindObjectForCode("marisa_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("marisa_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 226
        elseif(itemId == STARTING_ITEM_ID + 217 and Tracker:FindObjectForCode("marisa_b_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("reimu_b_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 227
        elseif(itemId == STARTING_ITEM_ID + 218 and Tracker:FindObjectForCode("sakuya_a_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("sakuya_a_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 228
        elseif(itemId == STARTING_ITEM_ID + 219 and Tracker:FindObjectForCode("sakuya_b_stage_unlocked").CurrentStage >= 5) and Tracker:FindObjectForCode("sakuya_b_extra_stage").Active then
            itemId = STARTING_ITEM_ID + 229
        end
    end

    local itemObject = ITEM_MAPPING[itemId]

    if not itemObject or not itemObject[1] then
        return
    end

    for _, item in ipairs(itemObject) do
        local trackerItemObject = Tracker:FindObjectForCode(item[1])

        if trackerItemObject then
            if item[2] == "toggle" then
                trackerItemObject.Active = true
            elseif item[2] == "progressive" then
                trackerItemObject.CurrentStage = trackerItemObject.CurrentStage + 1
            elseif item[2] == "consumable" then
                trackerItemObject.AcquiredCount = trackerItemObject.AcquiredCount + item[3]
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onItem: Unknown item type %s for code %s", item[2], item[1]))
            end
        else
            print(string.format("onItem: Could not find object for code %s", item[1]))
        end
    end
end

function onLocation(locationId, locationName)
    local locationObject = LOCATION_MAPPING[locationId]

    if not locationObject or not locationObject[1] then
        return
    end

    for _, location in ipairs(locationObject) do
        local trackerLocationObject = Tracker:FindObjectForCode(location)

        if trackerLocationObject then
            if location:sub(1, 1) == "@" then
                trackerLocationObject.AvailableChestCount = trackerLocationObject.AvailableChestCount - 1
            else
                trackerLocationObject.Active = false
            end
        else
            print(string.format("onLocation: Could not find object for code %s", location))
        end
    end
end

Archipelago:AddClearHandler("Clear", onClear)
Archipelago:AddItemHandler("Item", onItem)
Archipelago:AddLocationHandler("Location", onLocation)