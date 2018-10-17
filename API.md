# General Utility
* `tigris.world_limits`: Table in format `{max = <vector>, min = <vector>}` where max and min are the boundaries of the world.
* `tigris.include(path)`: Include file `<path>` from the current modpath.
* `tigris.include_dir(path)`: Include all files in directory `<path>` from the current modpath.
* `tigris.player_faction(name)`: Return a "faction string" for a player name. Faction mods may override this. Default response is "player:`<name>`".

# Tigris-specific
* `tigris.danger_level(pos)`: Returns the danger level at `<pos>`.

# Damage
* `tigris.damage.register(name, handler)`: Register a damage type `<name>`. `<handler>` is a function `function(obj, value)` called upon damaging `<obj>` through tigris.damage.apply(). `<handler>` should return the actual damage to be subtracted from `<obj>`'s hp by taking into account armor or other factors.
* `tigris.damage.player_damage_callback(player, damage, blame)`: May be overriden by other mods. Called upon damage from tigris.damage and the engine. `<player>` is the target of the damage. `<damage>` is a table `{raw = `<total damage>`, groups = {fleshy = <fleshy damage>, ...}}`. `<blame>`, which may be `nil`, is the cause of the damage.
* `tigris.damage.apply(obj, damage, blame)`: Apply `<damage>` to `<obj>`, blaming `<blame>`. `<obj>` and `<blame>` are objects. `<blame>` may be `nil`. `<damage>` is in group format: `{fleshy = <fleshy damage>, ...}`.

# Projectiles
* `tigris.register_projectile(name, def)`: Register a projectile. `<def>` fields below, usable default values in brackets:
  * `texture`: The projectile's texture.
  * `size` [1]: The size multiplier for all coordinates.
  * `timeout` [30]: Time in seconds the projectile can be alive before timeout. Can be overriden after creation by setting `_timeout_override` in the lua entity.
  * `load_map` [false]: If true, will load and generate the map along the projectile's path so it can continue without being destroyed in unloaded blocks.
  * `on_timeout(self)` [nil]: Called upon timeout.
  * `on_any_hit(self, pos)` [nil]: Called when any node except air is entered. Return true to kill the projectile.
  * `on_node_hit(self, pos)` [nil]: Called when any non-passable node is entered. Return true to kill the projectile.
  * `on_liquid_hit(self, pos)` [nil]: Called when any liquid node is entered. Return true to kill the projectile.
  * `on_entity_hit(self, obj)` [nil]: If this is specified, will be called when an entity is hit. Return true to kill the projectile.
  * `on_step(self)` [nil]: Called every step.
* `tigris.create_projectile(name, def)`: Create a new projectile. `<def>` fields below, usable default values in brackets. Returns entity created.
  * `pos`: Initial vector position of the projectile.
  * `velocity`: Initial vector velocity of the projectile.
  * `gravity` [0]: Gravity multiplier.
  * `owner` [nil]: Name of owning player.
  * `owner_object` [nil]: Owner object (player, mob, ...).
