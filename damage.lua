local m = {}
tigris.damage = m

-- Callback functions for damage types.
m.handlers = {}

-- Sorted list.
m.list = {}

-- Damage player by table of damage types.
function m.apply(obj, damage, blame)
    -- Don't damage immortal objects.
    if (obj:get_armor_groups().immortal or 0) > 0 then
        return
    end

    -- Sum basic damage from handlers.
    local total = 0
    for k,v in pairs(damage) do
        assert(m.handlers[k])
        total = total + m.handlers[k](obj, v)
    end

    -- Apply basic damage.
    obj:set_hp(obj:get_hp() - total)

    if not obj:is_player() and obj:get_luaentity().tigris_mob then
        obj:get_luaentity():on_punch(blame)
    end
end

function m.friendly(a, b)
    local fa
    local fb
    if a:is_player() then
        fa = tigris.player and tigris.player.faction(a:get_player_name()) or a:get_player_name()
    elseif a:get_luaentity() and a:get_luaentity().tigris_mob then
        fa = a:get_luaentity().faction
    else
        return true
    end

    if b:is_player() then
        fb = tigris.player and tigris.player.faction(b:get_player_name()) or b:get_player_name()
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
