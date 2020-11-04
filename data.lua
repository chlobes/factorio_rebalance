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

function mul_recipe(name, m)
	local r = data.raw["recipe"][name]
	if r.ingredients then
		mul_recipe_int(r, m)
	else
		mul_recipe_int(r.normal, m)
		mul_recipe_int(r.expensive, m)
	end
end
function mul_recipe_int(r, m)
	r.energy_required = (r.energy_required or 0.5) * m
	for _, v in pairs(r.ingredients) do
		v[2] = math.floor(v[2] * m + 0.5)
	end
end

function blank_module(name)
	data.raw["module"][name] = {
		type = "module",
		effect = {},
		stack_size = 1,
		icon = "__base__/graphics/icons/effectivity-module.png",
		icon_size = 64,
		category = "effectivity",
		tier = 1,
		name = name,
		flags = { "hidden" },
	}
end

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

mul_recipe("solar-panel", setting("solar panel cost multiplier"))
mul_recipe("accumulator", setting("accumulator cost multiplier"))
mul_recipe("boiler", setting("boiler cost multiplier"))
mul_recipe("fast-inserter", setting("fast inserter cost multiplier"))
mul_recipe("steam-engine", setting("steam engine cost multiplier"))

data.raw["solar-panel"]["solar-panel"].production = setting("solar panel power output (kW)") .. "kW"
data.raw["accumulator"]["accumulator"].energy_source.buffer_capacity = setting("accumulator max energy (MJ)") .. "MJ"
if setting("rebalance furnaces") then
	data.raw["furnace"]["steel-furnace"].energy_usage = "135kW"
	data.raw["furnace"]["steel-furnace"].energy_source.emissions_per_minute = 3
	data.raw["furnace"]["steel-furnace"].module_specification = { module_slots = 1 }
	data.raw["furnace"]["steel-furnace"].allowed_effects = { "consumption", "speed", "productivity", "pollution", }
	data.raw["furnace"]["electric-furnace"].energy_usage = "350kW"
	data.raw["furnace"]["electric-furnace"].crafting_speed = 4
	data.raw["furnace"]["electric-furnace"].energy_source.emissions_per_minute = 2.5
	data.raw["furnace"]["electric-furnace"].module_specification.module_slots = 3
	mul_recipe("electric-furnace", 2)
end
if setting("rebalance assemblers") then
	mul_recipe("assembling-machine-2", 2)
	mul_recipe("assembling-machine-3", 2)
	data.raw["assembling-machine"]["assembling-machine-2"].crafting_speed = 1
	data.raw["assembling-machine"]["assembling-machine-2"].energy_usage = "200kW"
	data.raw["assembling-machine"]["assembling-machine-2"].energy_source.emissions_per_minute = 6
	data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = 4
	data.raw["assembling-machine"]["assembling-machine-3"].energy_usage = "1600kW"
	data.raw["assembling-machine"]["assembling-machine-3"].energy_source.emissions_per_minute = 18
end
data.raw["lab"]["lab"].energy_usage = setting("lab power use (kW)") .. "kW"
data.raw["inserter"]["fast-inserter"].energy_per_movement = setting("fast inserter power cost (KJ)") .. "KJ"
data.raw["inserter"]["fast-inserter"].energy_per_rotation = setting("fast inserter power cost (KJ)") .. "KJ"
data.raw["inserter"]["fast-inserter"].energy_source.drain = setting("fast inserter idle power (kW)") .. "kW"
data.raw["item"]["solid-fuel"].fuel_value = setting("solid fuel energy (MJ)") .. "MJ"
data.raw["item"]["rocket-fuel"].fuel_value = setting("rocket fuel energy (MJ)") .. "MJ"
data.raw["recipe"]["rocket-fuel"].energy_required = setting("rocket fuel crafting time")
local s = data.raw["energy-shield-equipment"]["energy-shield-mk2-equipment"].energy_source
s.input_flow_limit = (30 * setting("energy shield mk2 recharge rate")) .. "kW"
s.buffer_capacity = (15 * setting("energy shield mk2 recharge rate")) .. "kJ"
local s = data.raw["active-defense-equipment"]["personal-laser-defense-equipment"]
local p = setting("personal laser defense power use (KJ)")
s.attack_parameters.ammo_type.energy_consumption = p .. "kJ"
s.energy_source.buffer_capacity = (220 * p / 50) .. "kJ"
s.attack_parameters.damage_modifier = setting("personal laser defense damage multiplier (base game is 3)")

data.raw["capsule"]["raw-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount = - setting("fish healing")

for _, m in pairs(data.raw.module) do m.effect = {} end
local p = 112

for i=1,p*8,1 do
	blank_module(i)
end
for i=1,p*2,1 do
	local v = i - p
	v = v + sign(v)
	data.raw["module"][i].effect.consumption = { bonus = 1.1046^v - 1 }
	data.raw["module"][i+p*2].effect.speed = { bonus = 1.1046^v - 1 }
	data.raw["module"][i+p*4].effect.productivity = { bonus = 1.01^v - 1 }
	data.raw["module"][i+p*6].effect.pollution = { bonus = 1.2202^v - 1 }
end
local v = 20.48
local n = 12
for i=1,n,1 do --extra productivity modules for miners
	blank_module("mining-prd-"..i)
	data.raw["module"]["mining-prd-"..i].effect.productivity = { bonus = v }
	v = v / 2
end
for i=1,6,1 do
	data.raw.technology["research-speed-"..i].effects = nil
end
local beacon = data.raw["beacon"].beacon
local delete = { "close_sound", "collision_box", "corpse", "damage_trigger_effect", "drawing_box", "dying_explosion","graphics_set","flags","icon","icon_mipmaps","icon_size","max_health","minable","open_sound","radius_visualisation_picture","selection_box","vehicle_impact_sound","water_reflection","working_sound" }
for _, name in ipairs(delete) do
	beacon[name] = nil
end

beacon.allowed_effects = { "consumption", "speed", "productivity", "pollution" }
beacon.distribution_effectivity = 1
beacon.energy_source = { type = "void" }
beacon.module_specification.module_slots = 4+n
beacon.supply_area_distance = 0
beacon.flags = { "placeable-off-grid","not-blueprintable","not-deconstructable","not-on-map","hidden","hide-alt-info","not-flammable","no-copy-paste","not-selectable-in-game","not-upgradable","no-automated-item-insertion","no-automated-item-removal"}
