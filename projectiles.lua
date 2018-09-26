local function passable(name)
    local def = minetest.registered_nodes[name]
    return (not def.walkable) and (def.buildable_to)
end

function tigris.register_projectile(name, def)
    local timeout = def.timeout or 30
    minetest.register_entity(name, {
        physical = false,
        hp_max = 1,
        visual = "sprite",
        visual_size = {x = 0.4 * (def.size or 1), y = 0.4 * (def.size or 1)},
        textures = {def.texture},
        collisionbox = {0,0,0,0,0,0},
        static_save = false,

        _created = 0,

        on_activate = function(self, static_data)
            if static_data and static_data ~= "" then
                for k,v in pairs(minetest.deserialize(static_data)) do
                    self[k] = v
                end
                if self._forceload then
                    minetest.forceload_free_block(self._forceload)
                    self._forceload = nil
                end
            end
        end,

        get_staticdata = function(self)
            local t = {}
            for k,v in pairs(self) do
                -- Only save custom properties.
                if k:sub(1,1) == "_" then
                    t[k] = v
                end
            end
            return minetest.serialize(t)
        end,

        on_step = function(self, dtime)
            local alive = os.time() - self._created
            if alive > (self.timeout_override or timeout) then
                if def.on_timeout then
                    def.on_timeout(self)
                end
                self.object:remove()
                return
            end

            print(alive, minetest.pos_to_string(self.object:getvelocity()), minetest.pos_to_string(self.object:getpos()))

            local pos = self.object:getpos()
            local diff = vector.new(pos.x - self._last_pos.x, pos.y - self._last_pos.y, pos.z - self._last_pos.z)
            local dir = vector.apply(diff, function(a) return (a / math.abs(a)) * 0.25 end)

            for x=self._last_pos.x,pos.x,dir.x do
            for y=self._last_pos.y,pos.y,dir.y do
            for z=self._last_pos.z,pos.z,dir.z do
                local point = vector.new(x, y, z)
                local node = minetest.get_node(point)

                if node.name == "ignore" then
                    if def.load_map then
                        VoxelManip():read_from_map(point, point)
                        node = minetest.get_node(point)
                        -- Still not available. Try emerging if within limits.
                        if node.name == "ignore" then
                            local ok = true
                            for _,c in ipairs{"x", "y", "z"} do
                                if point[c] < tigris.world_limits.min[c] or point[c] > tigris.world_limits.max[c] then
                                    ok = false
                                end
                            end
                            if ok then
                                minetest.emerge_area(point, point, function()
                                    self._forceload = point
                                    minetest.forceload_block(self._forceload)
                                end)
                            else
                                self.object:remove()
                            end
                            return
                        end
                    else
                        self.object:remove()
                        return
                    end
                end

                if node.name == "air" then
                    self._last_air = vector.round(point)
                else
                    if def.on_any_hit and def.on_any_hit(self, point) then
                        self.object:remove()
                        return
                    end
                end

                if not passable(node.name) then
                    if def.on_node_hit and def.on_node_hit(self, point) then
                        self.object:remove()
                        return
                    end
                end

                if minetest.get_item_group(node.name, "liquid") > 0 then
                    if def.on_liquid_hit and def.on_liquid_hit(self, point) then
                        self.object:remove()
                        return
                    end
                end

                local objs = minetest.get_objects_inside_radius(point, 6)
                for _, obj in pairs(objs) do
                    local bb = obj:get_properties().collisionbox
                    local pp = obj:getpos()
                    local b1 = vector.add(pp, vector.multiply({x=bb[1], y=bb[2], z=bb[3]}, 1.5))
                    local b2 = vector.add(pp, vector.multiply({x=bb[4], y=bb[5], z=bb[6]}, 1.5))

                    local collide = true
                    for _,c in ipairs({"x" ,"y", "z"}) do
                        if point[c] < b1[c] or point[c] > b2[c] then
                            collide = false
                            break
                        end
                    end
                    local self_player = obj:is_player() and obj:get_player_name() == self._owner
                    local self_mob = not obj:is_player() and obj:get_luaentity().tigris_mob and obj:get_luaentity().uid == self._owner
                    local owner_ok = ((not self_player) and (not self_mob)) or alive > 1
                    if collide and owner_ok then
                        if def.on_entity_hit and def.on_entity_hit(self, obj) then
                            self.object:remove()
                            return
                        end
                    end
                end
            end
            end
            end

            self._last_pos = pos
        end,
    })
end

function tigris.create_projectile(name, def)
    local obj = minetest.add_entity(vector.add(def.pos, vector.multiply(def.velocity, 0.1)), name)
    obj:setvelocity(def.velocity)
    obj:setacceleration(vector.new(0, -8.5 * (def.gravity or 0), 0))
    local ent = obj:get_luaentity()
    ent._last_pos = obj:getpos()
    ent._owner = def.owner
    ent._owner_object = def.owner_object
    ent._created = os.time()
    return obj
end
