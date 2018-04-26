tigris = {}

function tigris.include(p)
    dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. p)
end

-- Danger level increases by 1 every <x> distance from 0,0,0.
local start = minetest.string_to_pos(minetest.settings:get("tigris.world_center")) or vector.new(0, 0, 0)
local scale = tonumber(minetest.settings:get("tigris.level_scale")) or 200

function tigris.danger_level(pos)
    return math.floor(vector.distance(pos, start) / scale) + 1
end

tigris.world_limits = {
    max = vector.new(31000, 31000, 31000),
    min = vector.new(-31000, -31000, -31000),
}

tigris.include("hud.lua")
tigris.include("damage.lua")
tigris.include("projectiles.lua")
