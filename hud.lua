local m = {}
tigris.hud = m

-- Registered elements.
m.registered = {}

-- Per-player elements.
m.values = {}

-- Y offset for basic text.
m.yoff = -16

-- Register a HUD element.
function m.register(name, def)
    def.name = name
    def.yoff = m.yoff
    m.yoff = m.yoff - 16

    m.registered[name] = def
end

-- Update element for player.
function m.update(name, player, value, max_value)
    local r = m.registered[name]
    if type(value) == "number" then
        value = max(0, max_value and min(value, max_value) or value)
    end
    if r.type == "text" then
        local hud = m.values[name .. ":" .. player:get_player_name()]
        player:hud_change(hud, "text", value)
    end
end

-- Create elements for player.
minetest.register_on_joinplayer(function(player)
    for k,v in pairs(m.registered) do
        if v.type == "text" then
            m.values[k .. ":" .. player:get_player_name()] = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0, y = 1},
                name = v.name,
                number = 0xFFFFFF,
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = -1},
                offset = {x = 8, y = v.yoff},
                text = "",
            })
        end
    end
end)

-- Destroy elements for player.
minetest.register_on_leaveplayer(function(player)
    for k,v in pairs(m.registered) do
        m.values[k .. ":" .. player:get_player_name()] = nil
    end
end)
