local m = {}
tigris.damage = m

-- Callback functions for damage types.
m.handlers = {}

-- Sorted list.
m.list = {}

function m.player_damage_callback(player, damage, blame)
    -- Override elsewhere.
end

minetest.register_on_punchplayer(function(player, hitter, time, tool, dir, damage)
    m.player_damage_callback(player, {total = damage, groups = {fleshy = damage}}, hitter)
end)

minetest.register_on_player_hpchange(function(player, delta, reason)
    if delta < 0 then
        if ({
            fall = true,
            node_damage = true,
            drown = true,
        })[reason.type] then
            m.player_damage_callback(player, {total = -delta, groups = {fleshy = -delta}})
        end
    end
end)

-- Damage player by table of damage types.
function m.apply(obj, damage, blame)
    local lent = obj.get_luaentity and obj:get_luaentity()

    -- Check invulnerable group.
    if (obj:get_armor_groups().invulnerable or 0) > 0 then
        return
    end

    -- Sum basic damage from handlers.
    local total = 0
    for k,v in pairs(damage) do
        assert(m.handlers[k])
        total = total + m.handlers[k](obj, v)
    end

    if obj:is_player() then
        -- Apply basic damage.
        m.player_damage_callback(obj, {total = total, groups = damage}, blame)
        obj:set_hp(obj:get_hp() - total)
    else
        if lent and lent.tigris_mob then
            obj:set_hp(obj:get_hp() - total)
            lent:on_punch(blame)
        else
            -- Pass damage directly as fleshy (universal type).
            obj:punch(blame, 1, {full_punch_interval = 1, damage_groups = {fleshy = total}})
        end
    end
end

function m.friendly(a, b)
    local fa
    local fb
    if a:is_player() then
        fa = tigris.player_faction(a:get_player_name())
    elseif a:get_luaentity() and a:get_luaentity().tigris_mob then
        fa = a:get_luaentity().faction
    else
        return true
    end

    if b:is_player() then
        fb = tigris.player_faction(b:get_player_name())
    elseif b:get_luaentity() and b:get_luaentity().tigris_mob then
        fb = b:get_luaentity().faction
    else
        return true
    end

    return fa and fb and fa == fb
end

function m.register(n, f)
    m.handlers[n] = f
    table.insert(m.list, n)
    table.sort(m.list)

    if minetest.get_modpath("armor_monoid") and n ~= "fleshy" then
        armor_monoid.register_armor_group(n, 100)
    end
end

tigris.damage.register("fleshy", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.fleshy or 100) / 100)
end)

tigris.damage.register("cold", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.cold or 100) / 100)
end)

tigris.damage.register("heat", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.heat or 100) / 100)
end)

tigris.damage.register("sun", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.sun or 100) / 100)
end)
