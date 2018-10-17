function tigris.smartfs_sfinv(form, fname, title)
    if not minetest.get_modpath("sfinv") then
        return
    end
    local function make_state_location(player)
        return {
            type = "inventory",
            player = player,
            _show_ = function(state)
                sfinv.set_page(state.location.player, fname)
            end,
        }
    end
    sfinv.register_page(fname, {
        title = title,
        get = function(self, player, context)
            local name = player:get_player_name()
            local sloc = make_state_location(player)
            local state = smartfs._makeState_(form, nil, sloc, name)
            local fs = ""
            if form.form_setup_callback(state) ~= "false" then
                smartfs.inv[name] = state
                fs = state:_buildFormspec_(false)
            end
            return sfinv.make_formspec(player, context, fs, true)
        end
    })
end
