tigris = {}

function tigris.include(p)
    dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/" .. p)
end

tigris.include("hud.lua")