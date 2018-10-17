tigris = {}

function tigris.include(p)
    dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. p)
end

function tigris.include_dir(d)
    local mp = minetest.get_modpath(minetest.get_current_modname()) .. "/" .. d
    for _,entry in ipairs(minetest.get_dir_list(mp, false)) do
        tigris.include(d .. "/" .. entry)
    end
end

-- Danger level increases by 1 every <x> distance from 0,0,0.
local start = minetest.string_to_pos(minetest.settings:get("tigris.world_center")) or vector.new(0, 0, 0)
local scale = tonumber(minetest.settings:get("tigris.level_scale")) or 250
-- Scale y in distance by this much. So, going straight down, danger level increases faster.
local y_scale = tonumber(minetest.settings:get("tigris.y_scale")) or 3

function tigris.danger_level(pos)
    pos = table.copy(pos)
    local add = 1
    -- Going up does not add danger.
    pos.y = math.min(0, pos.y * y_scale)
    return math.floor(vector.distance(pos, start) / scale) + add
end

-- Should be overridden by faction mods.
function tigris.player_faction(name)
    return "player:" .. name
end

-- Can be overridden. Return old value ORed by new value.
function tigris.check_pos_safe(pos)
    return false
end

tigris.world_limits = {
    max = vector.new(31000, 31000, 31000),
    min = vector.new(-31000, -31000, -31000),
}

tigris.include("hud.lua")
tigris.include("damage.lua")
tigris.include("projectiles.lua")
