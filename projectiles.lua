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
        visual_size = {x = 0.4, y = 0.4},
        textures = {def.texture},
        collisionbox = {0,0,0,0,0,0},

        created = 0,

        on_step = function(self, dtime)
            local alive = os.time() - self.created
            if alive > timeout then
                self.object:remove()
                return
            end

            local pos = self.object:getpos()
            local diff = vector.new(pos.x - self.last_pos.x, pos.y - self.last_pos.y, pos.z - self.last_pos.z)
            local dir = vector.apply(diff, function(a) return (a / math.abs(a)) * 0.5 end)

            for x=self.last_pos.x,pos.x,dir.x do
            for y=self.last_pos.y,pos.y,dir.y do
            for z=self.last_pos.z,pos.z,dir.z do
                local point = vector.new(x, y, z)
                local node = minetest.get_node(point)
                if node.name == "ignore" then
                    self.object:remove()
                    return
                end

                if not passable(node.name) then
                    if def.on_node_hit and def.on_node_hit(self, point) then
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
                    if not collide then
                        break
                    end

                    local player_ok = not obj:is_player() or obj:get_player_name() ~= self.owner or alive > 1
                    local immortal = obj:get_armor_groups().immortal
                    if player_ok and ((not immortal) or immortal <= 0) then
                        if def.on_entity_hit and def.on_entity_hit(self, obj) then
                            self.object:remove()
                            return
                        end
                    end
                end
            end
            end
            end

            self.last_pos = pos
        end,
    })
end

function tigris.create_projectile(name, def)
    local obj = minetest.add_entity(vector.add(def.pos, vector.multiply(def.velocity, 0.1)), name)
    obj:setvelocity(def.velocity)
    obj:setacceleration(vector.new(0, -8.5 * (def.gravity or 0), 0))
    local ent = obj:get_luaentity()
    ent.last_pos = obj:getpos()
    ent.owner = def.owner
    ent.created = os.time()
    return obj
end
