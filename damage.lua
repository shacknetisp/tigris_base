local m = {}
tigris.damage = m

-- Callback functions for damage types.
m.handlers = {}

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

function m.register(n, f)
    m.handlers[n] = f
end

tigris.damage.register("fleshy", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.fleshy or 100) / 100)
end)

tigris.damage.register("cold", function(obj, value)
    return value
end)

tigris.damage.register("heat", function(obj, value)
    return value
end)
