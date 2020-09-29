function sign(x)
  return (x<0 and 0) or 1
end

function disable_recipe(name)
	data.raw["recipe"][name] = nil
	for k, v in pairs(data.raw.module) do
		if v.name:find("productivity%-module") and v.limitation then
			for i, recipe in ipairs(v.limitation) do
				if recipe == name then
					table.remove(v.limitation, i)
					break
				end
			end
		end
	end
end

function setting(name) log("setting: " .. name) return settings.startup[name].value end

if setting("disable burner inserters") then disable_recipe("burner-inserter") end
if setting("disable solid fuel from heavy oil") then
	disable_recipe("solid-fuel-from-heavy-oil")
	effects = data.raw.technology["advanced-oil-processing"].effects
	for i, v in ipairs(effects) do
		if v.recipe == "solid-fuel-from-heavy-oil" then
			table.remove(effects, i)
		end
	end
end
data.raw.technology["effect-transmission"] = nil

local x = setting("solar panel cost multiplier")
data.raw["recipe"]["solar-panel"].energy_required = data.raw["recipe"]["solar-panel"].energy_required * x
for _, v in pairs(data.raw["recipe"]["solar-panel"].ingredients) do
	v[2] = math.floor(v[2] * x + 0.5)
end
x = setting("accumulator cost multiplier")
data.raw["recipe"]["accumulator"].energy_required = data.raw["recipe"]["accumulator"].energy_required * x
for _, v in pairs(data.raw["recipe"]["accumulator"].ingredients) do
	v[2] = math.floor(v[2] * x + 0.5)
end
x = setting("boiler cost multiplier")
data.raw["recipe"]["boiler"].energy_required = 10
for _, v in pairs(data.raw["recipe"]["boiler"].ingredients) do
	v[2] = math.floor(v[2] * x + 0.5)
end
if setting("cheaper steam engines") then
	data.raw["recipe"]["steam-engine"].normal.ingredients[1][2] = 4
	data.raw["recipe"]["steam-engine"].normal.ingredients[3][2] = 5
end

data.raw["solar-panel"]["solar-panel"].production = setting("solar panel power output (kW)") .. "kW"
data.raw["accumulator"]["accumulator"].energy_source.buffer_capacity = setting("accumulator max energy (MJ)") .. "MJ"
if setting("rebalance furnace power and emissions") then
	data.raw["furnace"]["steel-furnace"].energy_usage = "135kW"
	data.raw["furnace"]["steel-furnace"].energy_source.emissions_per_minute = 3
	data.raw["furnace"]["electric-furnace"].energy_usage = "225kW"
	data.raw["furnace"]["electric-furnace"].module_specification.module_slots = 4
	data.raw["furnace"]["electric-furnace"].energy_source.emissions_per_minute = 1.25
end
if setting("rebalance fast inserters") then
	for _, v in pairs(data.raw["recipe"]["fast-inserter"].ingredients) do
		v[2] = v[2] + 1
	end
	data.raw["inserter"]["fast-inserter"].energy_per_movement = "4.5KJ"
	data.raw["inserter"]["fast-inserter"].energy_per_rotation = "4.5KJ"
	data.raw["inserter"]["fast-inserter"].energy_source.drain = "0.8kW"
end
data.raw["item"]["solid-fuel"].fuel_value = setting("solid fuel energy (MJ)") .. "MJ"
data.raw["item"]["rocket-fuel"].fuel_value = setting("rocket fuel energy (MJ)") .. "MJ"
data.raw["recipe"]["rocket-fuel"].energy_required = setting("rocket fuel crafting time")

for _, m in pairs(data.raw.module) do m.effect = {} end
local p = 56
for i=1,p*8,1 do
	data.raw["module"][i] = {
		type = "module",
		effect = {},
		stack_size = 1,
		icon = "__base__/graphics/icons/effectivity-module.png",
		icon_size = 64,
		category = "effectivity",
		tier = 1,
		name = i
	}
end
for i=1,p*2,1 do
	local v = i - p
	v = v + sign(v)
	data.raw["module"][i].effect.consumption = { bonus = 1.1^v - 1 }
	data.raw["module"][i+p*2].effect.speed = { bonus = 1.1^v - 1 }
	data.raw["module"][i+p*4].effect.productivity = { bonus = 1.01^v - 1 }
	data.raw["module"][i+p*6].effect.pollution = { bonus = 1.2^v - 1 }
end
local beacon = data.raw["beacon"].beacon
local delete = { "close_sound", "collision_box", "corpse", "damage_trigger_effect", "drawing_box", "dying_explosion", "flags","graphics_set","icon","icon_mipmaps","icon_size","max_health","minable","open_sound","radius_visualisation_picture","selection_box","vehicle_impact_sound","water_reflection","working_sound" }
for _, name in ipairs(delete) do
	beacon[name] = nil
end

beacon.allowed_effects = { "consumption", "speed", "productivity", "pollution" }
beacon.distribution_effectivity = 1
beacon.energy_source = { type = "void" }
beacon.module_specification.module_slots = 4
beacon.supply_area_distance = 0
beacon.hide_alt_info = true
