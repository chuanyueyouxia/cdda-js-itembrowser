json = require "json"

lang_file = "../lang/mo/ja/LC_MESSAGES/cataclysm-dda.mo"

local gettext = require("gettext")

types = {}

recipe_type = "recipe"
flag_type = "json_flag"
item_action_type = "item_action"
ITEM_CATEGORY_type = "ITEM_CATEGORY"
item_group_type = "item_group"
material_type = "material"
technique_type = "technique"
tool_quality_type = "tool_quality"
requirement_type = "requirement"

item_types = {
  "AMMO",
  "GENERIC",
  "GUN",
  "ARMOR",
  "BIONIC_ITEM",
  "COMESTIBLE",
  "CONTAINER",
  "TOOL",
  "MIGRATION",
  "GUNMOD",
  "TOOLMOD",
  "TOOL_ARMOR",
  "BOOK",
  "MAGAZINE",
  "ENGINE",
  "WHEEL"
}

function is_new_type(t)
  for key, val in ipairs(types) do
    if val == t then
      return false
    end
  end
  table.insert(types, t)
  return true
end

function is_item_type(t)
  for _, val in ipairs(item_types) do
    if val == t then
      return true
    end
  end
  return false
end

function is_recipe_type(t)
  if t == recipe_type then
    return true
  end
  return false
end

function is_requirement_type(t)
  if t == requirement_type then
    return true
  end
  return false
end

function is_material_type(t)
  if t == material_type then
    return true
  end
  return false
end

function is_flag_type(t)
  if t == flag_type then
    return true
  end
  return false
end

function translate_table(lang_data, t)
  local translate_members = {
    "name",
    "description",
    "info"
  }
  for key, val in pairs(t) do
    for mkey, mval in pairs(translate_members) do
      if key == mval then
        if lang_data[val] then
          t[key] = lang_data[val]
          break
        end
      end
    end
  end
  return t
end

local fd, err = io.open(lang_file, "rb")
if not fd then
  print("Error: Language file is not found.")
  return nil, err
end
local raw_lang_data = fd:read("*all")
fd:close()
local lang_data = assert(gettext.parseData(raw_lang_data))

local items = {}
local mod_items = {}
local recipes = {}
local mod_recipes = {}
local requirements = {}
local mod_requirements = {}
local materials = {}
local mod_materials = {}
local flags = {}
local mod_flags = {}

local list = io.open("rsc/list.txt")
local filepath = list:read()

while filepath do
  local jsonfile = io.open(filepath)
  if jsonfile then
    print("Processing : " .. filepath)
    local data = json.decode(jsonfile:read("*a"))
    for key, val in pairs(data) do
      if type(val) == "table" then
        local type_val = val["type"]
        local new_val
        if is_item_type(type_val) then
          -- langage update
          new_val = translate_table(lang_data, val)
          table.insert(items, new_val)
        elseif is_recipe_type(type_val) then
          new_val = translate_table(lang_data, val)
          table.insert(recipes, new_val)
        elseif is_requirement_type(type_val) then
          new_val = translate_table(lang_data, val)
          table.insert(requirements, new_val)
        elseif is_material_type(type_val) then
          new_val = translate_table(lang_data, val)
          table.insert(materials, new_val)
        elseif is_flag_type(type_val) then
          new_val = translate_table(lang_data, val)
          table.insert(flags, new_val)
        end
      end
    end
  end
  io.close(jsonfile)
  filepath = list:read()
end
io.close(list)

local valid_mod = nil
local modlist = io.open("modlist.json")
if modlist then
  valid_mod = json.decode(modlist:read("*a"))
end
io.close(modlist)
local mod_path = {}

list = io.open("rsc/list_mod.txt")
filepath = list:read()

while filepath do
  if string.match(filepath, "[\\/]modinfo.json$") then
    local jsonfile = io.open(filepath)
    if jsonfile then
      local data = json.decode(jsonfile:read("*a"))
      for _, val in pairs(data) do
        if type(val) == "table" then
          if val["type"] == "MOD_INFO" then
            mod_path[val["ident"]] = string.match(filepath, "(.+)[\\/]+modinfo.json$")
          end
        end
      end
    end
    io.close(jsonfile)
  end
  filepath = list:read()
end
io.close(list)

for _, mod_ident in pairs(valid_mod) do
  list = io.open("rsc/list_mod.txt")
  filepath = list:read()
  while filepath do
    if mod_path[mod_ident] == string.sub(filepath, 1, string.len(mod_path[mod_ident])) then
      local jsonfile = io.open(filepath)
      if jsonfile then
        print("Processing : " .. filepath)
        local data = json.decode(jsonfile:read("*a"))
        for key, val in pairs(data) do
          if type(val) == "table" then
            local type_val = val["type"]
            local new_val
            if is_item_type(type_val) then
              -- langage update
              new_val = translate_table(lang_data, val)
              table.insert(mod_items, new_val)
            elseif is_recipe_type(type_val) then
              new_val = translate_table(lang_data, val)
              table.insert(mod_recipes, new_val)
            elseif is_requirement_type(type_val) then
              new_val = translate_table(lang_data, val)
              table.insert(mod_requirements, new_val)
            elseif is_material_type(type_val) then
              new_val = translate_table(lang_data, val)
              table.insert(mod_materials, new_val)
            elseif is_flag_type(type_val) then
              new_val = translate_table(lang_data, val)
              table.insert(mod_flags, new_val)
            end
          end
        end
      end
      io.close(jsonfile)
    end
    filepath = list:read()
  end
  io.close(list)
end

io.output("rsc/data.js")

io.write("var items = ")
io.write(json.encode(items))
io.write(";\n")

io.write("var mod_items = ")
io.write(json.encode(mod_items))
io.write(";\n")

io.write("var recipes = ")
io.write(json.encode(recipes))
io.write(";\n")

io.write("var mod_recipes = ")
io.write(json.encode(mod_recipes))
io.write(";\n")

io.write("var requirements = ")
io.write(json.encode(requirements))
io.write(";\n")

io.write("var mod_requirements = ")
io.write(json.encode(mod_requirements))
io.write(";\n")

io.write("var materials = ")
io.write(json.encode(materials))
io.write(";\n")

io.write("var mod_materials = ")
io.write(json.encode(mod_materials))
io.write(";\n")

io.write("var flags = ")
io.write(json.encode(flags))
io.write(";\n")

io.write("var mod_flags = ")
io.write(json.encode(mod_flags))
io.write(";\n")

--[[
  anatomy
  bionic
  body_part
  construction
  MONSTER_BLACKLIST
  speech
  dream
  effect_type
  emit
  fault
  json_flag
  furniture
  EXTERNAL_OPTION
  gate
  harvest
  snippet
  nil
  item_action
  ITEM_CATEGORY
  item_group
  nil
  martial_art
  material
  monstergroup
  MONSTER
  monster_attack
  MONSTER_FACTION
  morale_type
  overmap_terrain
  city_building
  mutation
  mutation_category
  overlay_order
  overmap_location
  overmap_connection
  overmap_special
  activity_type
  profession_item_substitutions
  profession
  region_settings
  vehicle_placement
  vehicle_spawn
  rotatable_symbol
  skill
  SPECIES
  start_location
  technique
  terrain
  tool_quality
  trap
  tutorial_messages
  vehicle_group
  vehicle_part
  vitamin
  AMMO
  ammunition_type
  GENERIC
  GUN
  ARMOR
  BIONIC_ITEM
  COMESTIBLE
  CONTAINER
  TOOL
  MIGRATION
  GUNMOD
  TOOLMOD
  TOOL_ARMOR
  BOOK
  MAGAZINE
  ENGINE
  WHEEL
  mapgen
  palette
  npc_class
  epilogue
  faction
  mission_definition
  npc
  talk_topic
  recipe_category
  recipe
  uncraft
  requirement
  scenario
  vehicle
]]
