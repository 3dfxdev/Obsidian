----------------------------------------------------------------
--  LEVEL MANAGEMENT
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2010 Andrew Apted
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
----------------------------------------------------------------

--[[ *** CLASS INFORMATION ***

class LEVEL
{
  name : string  -- engine name for this level, e.g. MAP01

  epi_along : float  -- how far along the episode, 0.0 -> 1.0
}


--------------------------------------------------------------]]

require 'defs'
require 'util'

require 'seeds'
require 'planner'
require 'connect'
require 'naming'
require 'quests'
require 'builder'

require 'caves'
require 'layout'
require 'rooms'
require 'fight'
require 'monsters'


STYLE_LIST =
{
  skies      = { few=20, some=60, heaps=40 },
  hallways   = { few=10, some=90, heaps=30 },
  liquids    = { few=30, some=50, heaps=20 },
  scenics    = { few=30, some=50, heaps=10 },
  naturals   = { none=10, few=30, some=80, heaps=5 },
  lakes      = { few=60, heaps=10 },
  subrooms   = { none=40, some=80, heaps=5 },
  islands    = { few=60, heaps=40 },

  junk       = { few=10, some=60, heaps=20 },
  symmetry   = { few=20, some=60, heaps=20 },
  pillars    = { few=30, some=60, heaps=20 },
  beams      = { few=25, some=50, heaps=5  },
  barrels    = { few=50, some=50, heaps=10 },

  windows    = { few=20, some=50, heaps=20 },
  pictures   = { few=10, some=50, heaps=10 },
  cages      = { none=50, some=50, heaps=6 },
  fences     = { none=30, few=30, some=10 },
  crates     = { none=20, some=40, heaps=10 },
  switches   = { none=2, few=6, some=60, heaps=6 },

  lt_trim    = { none=40, some=20, heaps=10 },
  lt_spokes  = { none=90, some=20, heaps=5 },
  lt_swapped = { none=90, heaps=20 },

  favor_shape = { none=80, L=5, T=5, O=5, S=5, X=5 },
}


function Game_clean_up()
  GAME   = {}
  PARAM  = {}
  STYLE  = {}

  LEVEL  = nil
  SEEDS  = nil

  collectgarbage("collect")
end


function Game_merge_tab(name, tab)
  assert(name)

  if not tab then
    error("No such table: " .. tostring(name))
  end

  if not GAME[name] then
    GAME[name] = deep_copy(tab)
    return
  end

  if name ~= "sub_themes" then
    deepish_merge(GAME[name], tab)
    return
  end

  -- special handling for sub_themes

  for k,info in pairs(tab) do
    if tab == REMOVE_ME then
      GAME.sub_themes[k] = nil
    elseif not GAME.sub_themes[k] then
      GAME.sub_themes[k] = deep_copy(info)
    else
      deepish_merge(GAME.sub_themes[k], info)
    end
  end
end


function Game_merge_table_list(tab_list)
  for i = 1,#tab_list,2 do
    local name = tab_list[i]
    local tab  = tab_list[i+1]

    Game_merge_tab(name, tab)
  end
end


function Game_sort_modules()
  GAME.all_modules = {}

  local game = OB_GAMES[OB_CONFIG.game]
  if not game then
    error("UNKNOWN GAME: " .. tostring(OB_CONFIG.game))
  end

  local engine = OB_ENGINES[OB_CONFIG.engine]
  if not engine then
    error("UNKNOWN ENGINE: " .. tostring(OB_CONFIG.engine))
  end

  -- validate reference for extended games / engines

  if game.extends then
    game.extend_other = OB_GAMES[game.extends]
    if not game.extend_other then
      error("UNKNOWN GAME TO EXTEND: " .. game.extends)
    end
  end

  if engine.extends then
    engine.extend_other = OB_GAMES[engine.extends]
    if not engine.extend_other then
      error("UNKNOWN ENGINE TO EXTEND: " .. engine.extends)
    end
  end

  -- find all the visible & enabled modules

  for _,mod in pairs(OB_MODULES) do
    if mod.enabled and mod.shown then
      table.insert(GAME.all_modules, mod)
    end
  end

  -- sort them : lowest -> highest priority, because later
  -- entries can override things done by earlier ones.

  local function module_sorter(A, B)
    if A.priority or B.priority then
      return (A.priority or 50) < (B.priority or 50)
    end

    return A.label < B.label
  end

  if #GAME.all_modules > 1 then
    table.sort(GAME.all_modules, module_sorter)
  end
 
  -- first entry must be the game def, and second entry must be
  -- the engine def.  NOTE: neither of these are real modules.

  table.insert(GAME.all_modules, 1, game)
  table.insert(GAME.all_modules, 2, engine)
end


function Game_invoke_hook(name, rseed, ...)
  for index,mod in ipairs(GAME.all_modules) do
    local func = mod[name]
    if func then
      if rseed then gui.rand_seed(rseed) end
      func(mod, ...)
    end
  end -- for mod
end


function Game_setup()
  Game_clean_up()

  Game_sort_modules()

  -- merge parameters and tables from each module

  local function merge_stuff(mod)
    if mod.param then
      shallow_merge(PARAM, mod.param)
    end

    if mod.tables then
      Game_merge_table_list(mod.tables)
    end
  end

  for index,mod in ipairs(GAME.all_modules) do
    if mod.extend_other then
      merge_stuff(mod.extend_other)
    end

    merge_stuff(mod)
  end -- for mod


  -- allow themes to supply sub-themes (etc)

  for name,theme in pairs(OB_THEMES) do
    if theme.shown and theme.tables then
      Game_merge_table_list(theme.tables)
    end
  end


  Game_invoke_hook("setup_func",  OB_CONFIG.seed)
  Game_invoke_hook("setup2_func", OB_CONFIG.seed)


  name_it_up(ROOM_PATTERNS)
  expand_copies(ROOM_PATTERNS)
end


function Level_themes()
  gui.rand_seed(OB_CONFIG.seed * 200)

  local function set_sub_theme(L, name)
    local info = assert(OB_THEMES[name])

    L.super_theme = info

    if not L.name_theme then
      L.name_theme = info.name_theme
    end

    -- don't overwrite theme of special levels
    if L.sub_theme then return end

    local sub_tab = {}
    local sub_pattern = "^" .. name

    for which,theme in pairs(GAME.sub_themes) do
      local prob = theme.prob or 50
      if prob > 0 and string.find(which, sub_pattern) then
        sub_tab[which] = prob
      end
    end

    if table_empty(sub_tab) then
      error("No sub-themes for " .. name)
    end

    local which = rand_key_by_probs(sub_tab)
    L.sub_theme = assert(GAME.sub_themes[which])

    gui.printf("Theme for level %s = %s\n", L.name, which)
  end


  ---| Level_themes |---

  gui.printf("\n")

  -- the user can specify the main theme
  if OB_CONFIG.theme ~= "mixed" and OB_CONFIG.theme ~= "original" and
     OB_CONFIG.theme ~= "psycho"
  then
    for _,L in ipairs(GAME.all_levels) do
      set_sub_theme(L, OB_CONFIG.theme)
    end

    return;
  end

  if OB_CONFIG.theme == "psycho" then
    local prob_tab = {}
    for name,info in pairs(OB_THEMES) do
      local prob = info.psycho_prob or info.mixed_prob or 0
      if info.shown and prob then
        prob_tab[name] = prob
      end
    end

    assert(not table_empty(prob_tab))

    for idx,L in ipairs(GAME.all_levels) do
      if not L.sub_theme then
        local name = rand_key_by_probs(prob_tab)

        if not L.name_theme and ((idx % 2) == 1) then
          L.name_theme = "PSYCHO"
        end

        set_sub_theme(L, name)
      end
    end

    return;
  end

  -- Mix It Up : choose a theme for each episode
  local episode_list = {}
  local total = 0

  local prob_tab = {}
  for name,info in pairs(OB_THEMES) do
    if info.shown and info.mixed_prob then
      prob_tab[name] = info.mixed_prob
      total = total + 1
    end
  end

  assert(total > 0)

  if OB_CONFIG.theme == "original" and GAME.original_themes then
    total = math.max(total, # GAME.original_themes)
  end

  while not table_empty(prob_tab) do
    local name = rand_key_by_probs(prob_tab)
    prob_tab[name] = nil

    local info = OB_THEMES[name]
    local pos = rand_irange(1, total)

    if OB_CONFIG.theme == "original" and GAME.original_themes then
      for i,orig_theme in ipairs(GAME.original_themes) do
        if name == orig_theme and not episode_list[i] then
          -- this can leave gaps, but they are filled later
          pos = i ; break
        end
      end
    end

    if episode_list[pos] then
      pos = table_find_unused(episode_list)
    end

    episode_list[pos] = name 
  end

  gui.debugf("Initial theme list = \n%s\n", table_to_str(episode_list))

  -- fill any gaps when in "As Original" mode
  if OB_CONFIG.theme == "original" and GAME.original_themes then
    gui.debugf("original_themes =\n%s\n", table_to_str(GAME.original_themes))

    for i,orig_theme in ipairs(GAME.original_themes) do
      if not episode_list[i] then
        episode_list[i] = orig_theme
      end
    end

    assert(# episode_list == total)
  end

  gui.printf("Theme for episodes =\n%s\n", table_to_str(episode_list))

  -- flesh it out
  if total == 2 then
    local dist = rand_sel(70, 0, 1)
    table.insert(episode_list, episode_list[1 + dist])
    table.insert(episode_list, episode_list[2 - dist])
  end

  while #episode_list < 40 do
    table.insert(episode_list, episode_list[rand_irange(1, total)])
  end


  -- single episode is different: have a few small batches
  if OB_CONFIG.length == "episode" then
    local pos = 1
    local count = 0

    for _,L in ipairs(GAME.all_levels) do
      if count >= 2 and (rand_odds(50) or count >= 5) then
        pos = pos + 1
        count = 0
      end

      set_sub_theme(L, episode_list[pos])
      count = count + 1
    end

    return;
  end

  for _,L in ipairs(GAME.all_levels) do
    set_sub_theme(L, episode_list[L.episode])
  end
end


function Level_rarify(seed_idx, tab)
  gui.rand_seed(OB_CONFIG.seed * 200 + seed_idx)

  local function Rarify(name, rarity)
    for group = 1, #GAME.all_levels, rarity do
      
      -- this level in the group will allow the item, every other
      -- level will forbid it (by setting the allowance to 0).
      local which = rand_irange(0, rarity-1)

      for offset = 0, rarity-1 do
        local L = GAME.all_levels[group + offset]
        if not L then break; end

        L.allowances[name] = sel(offset == which, 1, 0)

        -- spice it up a bit more
        if rand_odds(10) then
          L.allowances[name] = 1 - L.allowances[name]
        end
      end -- for offset
    end -- for group
  end

  --| Level_rarify |--

  for _,L in ipairs(GAME.all_levels) do
    if not L.allowances then
      L.allowances = {}
    end
  end

  for name,info in pairs(tab) do
    if info.rarity and info.rarity > 1 then
      Rarify(name, int(info.rarity))
    end
  end

  for _,L in ipairs(GAME.all_levels) do
    if not table_empty(L.allowances) then
      gui.debugf("Allowances in level %s =\n", L.name)
      gui.debugf("%s\n", table_to_str(L.allowances, 1))
    end
  end
end


function Level_styles()
  gui.rand_seed(LEVEL.seed)

  local style_tab = shallow_copy(STYLE_LIST)

  -- per game, per level and per theme style_lists
  if GAME.style_list then
    shallow_merge(style_tab, GAME.style_list)
  end
  if LEVEL.style_list then
    shallow_merge(style_tab, LEVEL.style_list)
  end
  if THEME.style_list then
    shallow_merge(style_tab, THEME.style_list)
  end

  -- decide the values
  STYLE = {}

  for name,prob_tab in pairs(style_tab) do
    STYLE[name] = rand_key_by_probs(prob_tab)
  end

  -- GUI overrides...
  if OB_CONFIG.outdoors and OB_CONFIG.outdoors ~= "mixed" then
    STYLE.skies = OB_CONFIG.outdoors
  end
end


function Level_build_it()
  gui.rand_seed(LEVEL.seed)

  -- does the level have a custom build function?
  if LEVEL.build_func then
    LEVEL.build_func()
    if gui.abort() then return "abort" end

    gui.progress(90)
    return "ok"
  end

  Plan_rooms_sp()
    if gui.abort() then return "abort" end
    gui.progress(10)

  Connect_rooms()
    if gui.abort() then return "abort" end
    gui.progress(30)

  Quest_assign()
    if gui.abort() then return "abort" end
    gui.progress(50)

  Rooms_build_all()
    if gui.abort() then return "abort" end
    gui.progress(70)

  -- here is where the tiler.lua layout code used to kick in
  assert(not PARAM.tiled)

  Monsters_make_battles()
    if gui.abort() then return "abort" end
    gui.progress(90)

  return "ok"
end


function Level_handle_prebuilt()
  assert(LEVEL.prebuilt_wad)
  assert(LEVEL.prebuilt_map)

  -- FIXME: support other games (Wolf3d, Quake, etc)
  gui.wad_transfer_map(LEVEL.prebuilt_wad, LEVEL.prebuilt_map, LEVEL.name)

  return "ok"
end


function Level_make(L, index, NUM)
  LEVEL = L

  assert(LEVEL)
  assert(LEVEL.name)

  gui.at_level(LEVEL.name, index, NUM)

  gui.printf("\n\n~~~~~~| %s |~~~~~~\n", LEVEL.name)

  LEVEL.seed = OB_CONFIG.seed * 100 + index

  THEME = shallow_copy(assert(LEVEL.sub_theme))

  if GAME.sub_defaults then
    merge_missing(THEME, GAME.sub_defaults)
  end


  -- use a pre-built level ?

  if LEVEL.prebuilt then
    Game_invoke_hook("begin_level_func",  LEVEL.seed)
    Game_invoke_hook("begin_level2_func", LEVEL.seed)

    local res = Level_handle_prebuilt()
    if res == "abort" then
      return res
    end

    Game_invoke_hook("end_level_func",  LEVEL.seed)
    Game_invoke_hook("end_level2_func", LEVEL.seed)

    return "ok"
  end


  gui.begin_level()
  gui.property("level_name", LEVEL.name);

  Level_styles()

  Game_invoke_hook("begin_level_func",  LEVEL.seed)
  Game_invoke_hook("begin_level2_func", LEVEL.seed)

  gui.printf("\nStyles = \n%s\n\n", table_to_str(STYLE, 1))


  local error_mat = assert(GAME.materials["_ERROR"])

  gui.property("error_tex",  error_mat.t)
  gui.property("error_flat", error_mat.f or error_mat.t)

  if LEVEL.description then
    gui.property("description", LEVEL.description)
  end


  local res = Level_build_it()
  if res == "abort" then
    return res
  end


  Game_invoke_hook("end_level_func",  LEVEL.seed)
  Game_invoke_hook("end_level2_func", LEVEL.seed)

  gui.end_level()


  -- intra-level cleanup
  if index < NUM then
    LEVEL = nil
    SEEDS = nil

    collectgarbage("collect")
  end

  return "ok"
end


function Game_make_all()

  GAME.all_levels = {}

  Game_invoke_hook("levels_start_func",  OB_CONFIG.seed)
  Game_invoke_hook("levels_start2_func", OB_CONFIG.seed)

  if #GAME.all_levels == 0 then
    error("Level list is empty!")
  end

  Level_themes()

  Level_rarify(1, GAME.weapons)
--Level_rarify(2, GAME.monsters)
--Level_rarify(3, GAME.powerups)

  for index,L in ipairs(GAME.all_levels) do
    if Level_make(L, index, #GAME.all_levels) == "abort" then
      return "abort"
    end
  end

  Game_invoke_hook("all_done_func",  OB_CONFIG.seed)
  Game_invoke_hook("all_done2_func", OB_CONFIG.seed)

---!!!  if HOOKS.remap_music then
---!!!     HOOKS.remap_music()
---!!!  end

  return "ok"
end

