-- Variables
local STARTING_ID = 70000
local SHOT_TYPE_LIST = {"Reimu A", "Reimu B", "Marisa A", "Marisa B", "Sakuya A", "Sakuya B"}
local ALL_CHARACTERS_LIST = {"Reimu", "Marisa", "Sakuya", "Reimu A", "Reimu B", "Marisa A", "Marisa B", "Sakuya A", "Sakuya B"}
local STAGES_LIST = {
	{"Cirno Defeated", "Letty Defeated"},
	{"Chen - MidBoss 1", "Chen Defeated"},
	{"Alice - Midboss 1", "Alice - Midboss 2", "Alice Defeated"},
	{"Lily White - MidBoss", "Prismriver Defeated"},
	{"Youmu - MidBoss 1", "Youmu Defeated"},
	{"Youmu - MidBoss 2", "Yuyuko Defeated"},
	{"Chen - MidBoss 2",	"Ran Defeated"},
	{"Ran - MidBoss",	"Yukari Defeated"}
}
local DIFFICULTY_LIST = {"Easy", "Normal", "Hard", "Lunatic"}

local locations_data = {}
local location_id_offset = 0

LOCATION_MAPPING = {}

for _, character in ipairs(ALL_CHARACTERS_LIST) do
	local level = 0
	for _, stage in ipairs(STAGES_LIST) do
		level = level + 1
		local stage_name = tostring(level)
		local is_extra = (level == 7)
		local is_phantasm = (level == 8)

		if is_extra then
			stage_name = "Extra"
		end

		if is_phantasm then
			stage_name = "Phantasm"
		end

		for _, check in ipairs(stage) do
			local id = STARTING_ID + location_id_offset

			locations_data[id] = {
				character = character,
				stage = stage_name,
				check = check,
				has_difficulty = false,
				is_stage_clear = false,
				is_extra = is_extra,
				is_phantasm = is_phantasm
			}

			location_id_offset = location_id_offset + 1
		end

		-- Stage clear entry
		local id = STARTING_ID + location_id_offset
		locations_data[id] = {
			character = character,
			stage = stage_name,
			check = "Stage " .. stage_name .. " Clear",
			has_difficulty = false,
			is_stage_clear = true,
			is_extra = is_extra,
			is_phantasm = is_phantasm
		}

		location_id_offset = location_id_offset + 1
	end
end

-- Generate locations with difficulty
for _, difficulty in ipairs(DIFFICULTY_LIST) do
	for _, character in ipairs(ALL_CHARACTERS_LIST) do
		local level = 0
		for _, stage in ipairs(STAGES_LIST) do
			level = level + 1
			-- Skip conditions
			if not (level > 6 or (level > 5 and difficulty == "Easy")) then
				for _, check in ipairs(stage) do
					local id = STARTING_ID + location_id_offset

					locations_data[id] = {
						character = character,
						stage = level,
						check = check,
						has_difficulty = true,
						difficulty = difficulty,
						is_stage_clear = false,
						is_extra = (level == 7),
						is_phantasm = (level == 8)
					}

					location_id_offset = location_id_offset + 1
				end
			end
		end
	end
end

for id, data in pairs(locations_data) do
	local has_shot = false
	local character = data.character
	local has_difficulty = data.has_difficulty
	local is_stage_clear = data.is_stage_clear
	local is_extra = data.is_extra
	local is_phantasm = data.is_phantasm

	-- Check if the character is in SHOT_TYPE_LIST
	for _, shot_type in ipairs(SHOT_TYPE_LIST) do
		if character == shot_type then
			has_shot = true
			break
		end
	end

	-- Determine prefixes based on has_shot
	local prefix_no_difficulty
	local prefix_has_difficulty

	if has_shot then
		prefix_no_difficulty = "@hasShotNoDifficulty"
		prefix_has_difficulty = "@hasShotHasDifficulty"
	else
		prefix_no_difficulty = "@noShotNoDifficulty"
		prefix_has_difficulty = "@noShotHasDifficulty"
	end

	-- Generate the path string
	local pathStr
	if has_difficulty then
		pathStr = string.format("/[%s] Stage %s/[%s][%s] %s",
			character, data.stage,
			data.difficulty, character, data.check)

		-- Add to the LOCATION_MAPPING table
		LOCATION_MAPPING[id] = {prefix_has_difficulty .. pathStr}
	else
		pathStr = string.format("/[%s] Stage %s/[%s] %s",
			character, data.stage, character, data.check)

		-- For Stage Clear locations, Extra Stage or Phantasm Stage locations, include both difficulty and non-difficulty prefixes
		if is_stage_clear or is_extra or is_phantasm then
			LOCATION_MAPPING[id] = {
				prefix_no_difficulty .. pathStr,
				prefix_has_difficulty .. pathStr
			}
		else
			-- Normal locations without difficulty
			LOCATION_MAPPING[id] = {prefix_no_difficulty .. pathStr}
		end
	end
end