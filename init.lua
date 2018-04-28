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
local scale = tonumber(minetest.settings:get("tigris.level_scale")) or 500
local udl = tonumber(minetest.settings:get("tigris.underground_danger_limit")) or -100

function tigris.danger_level(pos)
    local add = 1
    -- Being underground past the UDL adds 10 to the danger level.
    if pos.y < udl then
        add = add + 10
    end
    return math.floor(vector.distance(pos, start) / scale) + add
end

tigris.world_limits = {
    max = vector.new(31000, 31000, 31000),
    min = vector.new(-31000, -31000, -31000),
}

tigris.include("hud.lua")
tigris.include("damage.lua")
tigris.include("projectiles.lua")
