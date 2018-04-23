local m = {}
tigris.damage = m

-- Callback functions for damage types.
m.handlers = {}

-- Damage player by table of damage types.
function m.apply(obj, damage)
    -- Sum basic damage from handlers.
    local total = 0
    for k,v in pairs(damage) do
        assert(m.damage_handlers[k])
        total = total + m.damage_handlers[k](obj, v)
    end

    -- Apply basic damage.
    obj:set_hp(obj:get_hp() - total)
end

function m.register(n, f)
    m.handlers[n] = f
end

tigris.damage.register("fleshy", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.fleshy or 100) / 100)
end)
