function sign(x)
  return (x<0 and 0) or 1
end

local module_stats = {
	["effectivity-module"] = { eff = 1, },
	["effectivity-module-2"] = { eff = 2, },
	["effectivity-module-3"] = { eff = 5, spd =-2, pol =-1, },
	["speed-module"] = { eff =-2, spd = 3, },
	["speed-module-2"] = { eff =-3, spd = 5, },
	["speed-module-3"] = { eff =-6, spd =11, prd =-1, pol = 1, },
	["productivity-module"] = { eff =-2, spd =-1, prd = 5, pol = 1, },
	["productivity-module-2"] = { eff =-3, spd =-1, prd = 8, pol = 2, },
	["productivity-module-3"] = { eff =-4, spd =-3, prd = 14, pol = 4, },
}
script.on_init(function() if not global.beacons then global.beacons = {} end end)
script.on_nth_tick(300, function()
	for _, v in pairs(global.beacons) do
		local output = v[2].get_module_inventory()
		output.clear()
		local eff = 0 local spd = 0 local prd = 0 local pol = 0
		for item, stack in pairs(v[1].get_module_inventory().get_contents()) do
			local x = module_stats[item]
			eff = eff + (x.eff or 0) * stack
			spd = spd + (x.spd or 0) * stack
			prd = prd + (x.prd or 0) * stack
			pol = pol + (x.pol or 0) * stack
		end
		local p = 56
		if spd - eff ~= 0 then output.insert{name=tostring(spd-eff+p+sign(spd-eff))} end
		if spd ~= 0 then output.insert{name=tostring(spd+p*3+sign(spd))} end
		if prd ~= 0 then output.insert{name=tostring(prd+p*5+sign(prd))} end
		if pol ~= 0 then output.insert{name=tostring(-pol+p*7+sign(-pol))} end
	end
end)
function new_crafter(event)
	local entity = event.created_entity
	local inv = entity.get_module_inventory()
	if inv and #inv > 0 then
		local pos = entity.position
		global.beacons[entity.unit_number] = { entity, entity.surface.create_entity{ name = "beacon", position = pos, force = entity.force } }
	end
end
function dead_crafter(event)
	local entity = event.entity.unit_number
	if global.beacons[entity] then
		if global.beacons[entity][2].destroy() then
			global.beacons[entity] = nil
		else 
			game.print("rebalance mod error: failed to destroy beacon")
		end
	end
end
local filter = {{ filter = "crafting-machine" }, { filter = "type", type = "lab" }}
script.on_event(defines.events.on_built_entity, new_crafter, filter)
script.on_event(defines.events.on_robot_built_entity, new_crafter, filter)
script.on_event(defines.events.on_entity_died, dead_crafter, filter)
script.on_event(defines.events.on_player_mined_entity, dead_crafter, filter)
script.on_event(defines.events.on_robot_mined_entity, dead_crafter, filter)
