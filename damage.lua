local m = {}
tigris.damage = m

-- Callback functions for damage types.
m.handlers = {}

-- Damage player by table of damage types.
function m.apply(obj, damage)
    -- Process damage and convert to fleshy.
    local armor = obj:get_armor_groups()
    local total_fleshy = 0
    for k,v in pairs(damage) do
        assert(m.damage_handlers[k])
        v = m.damage_handlers[k](obj, v)

        -- Ignore armor (fleshy handler will handle actual fleshy damage).
        local factor = (armor.fleshy or 100) / 100
        if factor > 0 then
            total_fleshy = total_fleshy + v / factor
        end
    end

    obj:punch(obj, 1.0, {full_punch_interval=1.0, damage_groups={fleshy=total_fleshy}, nil})
end

tigris.damage.register("fleshy", function(obj, value)
    local armor = obj:get_armor_groups()
    return value * ((armor.fleshy or 100) / 100)
end)
