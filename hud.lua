local m = {}
tigris.hud = m

-- Registered elements.
m.registered = {}

-- Per-player elements.
m.values = {}

-- Y offset for basic text.
m.yoff = -16
m.byoff = -16

local hudbar_mod = ""
if minetest.get_modpath("hudbars") then
    hudbar_mod = "hudbars"
end

-- Register a HUD element.
function m.register(name, def)
    def.name = name

    if def.type == "text" then
        def.yoff = m.yoff
        m.yoff = m.yoff - 16
    elseif def.type == "bar" then
        if hudbar_mod == "hudbars" then
            hb.register_hudbar(name, 0xFFFFFF, def.description, {
                bar = def.texture .. "_bg.png", icon = def.texture .. "_icon.png", bgicon = def.texture .. "_bgicon.png"
            }, 0, 0, false, "%s: %d/%d")
        else
            def.byoff = m.byoff
            m.byoff = m.byoff - 16
        end
    end

    m.registered[name] = def
end

-- Update element for player.
function m.update(player, name, x)
    local r = m.registered[name]
    local hud = m.values[name .. ":" .. player:get_player_name()]

    if r.type == "text" then
        player:hud_change(hud, "text", x)
    elseif r.type == "bar" then
        if hudbar_mod == "hudbars" then
            hb.change_hudbar(player, name, x.current, x.max)
        else
            player:hud_change(hud, "number", x.current * (20 / x.max))
        end
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
                scale = {x = 100, y = 100},
                alignment = {x = 1, y = -1},
                offset = {x = 8, y = v.yoff},
                text = "",
                number = 0xFFFFFF,
            })
        elseif v.type == "bar" then
            if hudbar_mod == "hudbars" then
                hb.init_hudbar(player, k, 0, 0)
            else
                m.values[k .. ":" .. player:get_player_name()] = player:hud_add({
                    name = v.name,
                    hud_elem_type = "statbar",
                    position = {x = 0.5, y = 1},
                    size = {x = 24, y = 24},
                    text = v.texture .. "_icon.png",
                    alignment = {x = -1, y = -1},
                    offset = {x = -266, y = -132 - v.byoff},
                    number = 0,
                    max = 20,
                })
            end
        end
    end
end)

-- Destroy elements for player.
minetest.register_on_leaveplayer(function(player)
    for k,v in pairs(m.registered) do
        m.values[k .. ":" .. player:get_player_name()] = nil
    end
end)
