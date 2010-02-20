----------------------------------------------------------------
--  OBLIGE  :  INTERFACE WITH GUI CODE
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2009 Andrew Apted
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

require 'defs'
require 'util'

require 'levels'


function ob_traceback(msg)

  -- guard against very early errors
  if not gui or not gui.printf then
    return msg
  end

  gui.printf("\n\n****** ERROR OCCURRED ******\n\n");
  gui.printf("Stack Trace:\n")

  local stack_limit = 40

  local function format_source(info)
    if not info.short_src or info.currentline <= 0 then
      return ""
    end

    local base_fn = string.match(info.short_src, "[^/]*$")
 
    return string.format("@ %s:%d", base_fn, info.currentline)
  end

  for i = 1,stack_limit do
    local info = debug.getinfo(i+1)
    if not info then break end

    if i == stack_limit then
      gui.printf("(remaining stack trace omitted)\n")
      break;
    end

    if info.what == "Lua" then

      local func_name = "???"

      if info.namewhat and info.namewhat ~= "" then
        func_name = info.name or "???"
      else
        -- perform our own search of the global namespace,
        -- since the standard LUA code (5.1.2) will not check it
        -- for the topmost function (the one called by C code)
        for k,v in pairs(_G) do
          if v == info.func then
            func_name = k
            break;
          end
        end
      end

      gui.printf("  %d: %s() %s\n", i, func_name, format_source(info))

    elseif info.what == "main" then

      gui.printf("  %d: main body %s\n", i, format_source(info))

    elseif info.what == "tail" then

      gui.printf("  %d: tail call\n", i)

    elseif info.what == "C" then

      if info.namewhat and info.namewhat ~= "" then
        gui.printf("  %d: c-function %s()\n", i, info.name or "???")
      end
    end
  end

  return msg
end


function ob_match_conf(T)

  assert(OB_CONFIG.game)
  assert(OB_CONFIG.mode)
  assert(OB_CONFIG.engine)

  if T.for_games and not T.for_games[OB_CONFIG.game] then
    return false
  end

  if T.for_modes and not T.for_modes[OB_CONFIG.mode] then
    return false
  end

  if T.for_engines and not T.for_engines[OB_CONFIG.engine] then
    return false
  end

  if T.for_modules then
    for name,_ in pairs(T.for_modules) do
        local def = OB_MODULES[name]
        if not (def and def.shown and def.enabled) then
          return false
        end
    end -- for name
  end

  return true --OK--
end


function ob_update_engines()
  local need_new = false

  for name,def in pairs(OB_ENGINES) do
    local shown = ob_match_conf(def)

    if not shown and (OB_CONFIG.engine == name) then
      need_new = true
    end

    gui.show_button("engine", name, shown)
  end

  if need_new then
    OB_CONFIG.engine = "nolimit"
    gui.change_button("engine", OB_CONFIG.engine)
  end
end


function ob_update_themes()
  local new_label

  for name,def in pairs(OB_THEMES) do
    local shown = ob_match_conf(def)

    if not shown and (OB_CONFIG.theme == name) then
      new_label = def.label
    end

    def.shown = shown
    gui.show_button("theme", name, def.shown)
  end

  -- try to keep the same GUI label
  if new_label then
    for name,def in pairs(OB_THEMES) do
      local shown = ob_match_conf(def)

      if shown and def.label == new_label then
        OB_CONFIG.theme = name
        gui.change_button("theme", OB_CONFIG.theme)
        return
      end
    end

    -- otherwise revert to Mix It Up
    OB_CONFIG.theme = "mixed"
    gui.change_button("theme", OB_CONFIG.theme)
  end
end


function ob_update_modules()
  -- modules may depend on other modules, hence we may need
  -- to repeat this multiple times until all the dependencies
  -- have flowed through.
  
  for loop = 1,100 do
    local changed = false

    for name,def in pairs(OB_MODULES) do
      local shown = ob_match_conf(def)

      if shown ~= def.shown then
        changed = true
      end

      def.shown = shown
      gui.show_button("module", name, def.shown)
    end

    if not changed then break; end
  end
end


function ob_update_all()
  ob_update_engines()
  ob_update_modules()
  ob_update_themes()
end


function ob_defs_conflict(def1, def2)
  if not def1.conflicts then return false end
  if not def2.conflicts then return false end

  for K,_ in pairs(def1.conflicts) do
    if def2.conflicts[K] then
      return true
    end
  end

  return false
end


function ob_set_mod_option(name, option, value)
  local mod = OB_MODULES[name]
  if not mod then
    gui.printf("Ignoring unknown module: %s\n", name)
    return
  end
    
  if option == "self" then
    -- convert 'value' from string to a boolean
    value = not (value == "false" or value == "0")

    if mod.enabled == value then
      return -- no change
    end

    mod.enabled = value

    -- handle conflicting modules (like Radio buttons)
    if value then
      for other,odef in pairs(OB_MODULES) do
        if odef ~= mod and ob_defs_conflict(mod, odef) then
          odef.enabled = false
          gui.change_button("module", other, odef.enabled)
        end
      end
    end

    -- this is required for parsing the CONFIG.CFG file
    -- [but redundant when the user merely changed the widget]
    gui.change_button("module", name, mod.enabled)

    ob_update_all()
    return
  end


  local def = mod.options and mod.options[option]
  if not def then
    gui.printf("Ignoring unknown option: %s.%s\n", name, option)
    return
  end

  -- this can only happen while parsing the CONFIG.CFG file
  -- (containing some old no-longer-used value).
  if not def.avail_choices[value] then
    gui.printf("WARNING: invalid choice: %s (for option %s.%s)\n",
               value, name, option)
    return
  end

  def.value = value

  -- no need to call ob_update_all
  -- (nothing ever depends on custom options)
end


function ob_set_config(name, value)
  -- See the document 'doc/Config_Flow.txt' for a good
  -- description of the flow of configuration values
  -- between the C++ GUI and the Lua scripts.

  assert(name and value and type(value) == "string")

  if name == "seed" then
    OB_CONFIG[name] = tonumber(value) or 0
    return
  end


  if OB_CONFIG[name] and OB_CONFIG[name] == value then
    return -- no change
  end


  -- validate some important variables
  if name == "game" then
    assert(OB_CONFIG.game)
    if not OB_GAMES[value] then
      gui.printf("Ignoring unknown game: %s\n", value)
      return
    end
  elseif name == "engine" then
    assert(OB_CONFIG.engine)
    if not OB_ENGINES[value] then
      gui.printf("Ignoring unknown engine: %s\n", value)
      return
    end
  elseif name == "theme" then
    assert(OB_CONFIG.theme)
    if not OB_THEMES[value] then
      gui.printf("Ignoring unknown theme: %s\n", value)
      return
    end
  end

  OB_CONFIG[name] = value

  if (name == "game") or (name == "mode") or (name == "engine") then
    ob_update_all()
  end

  -- this is required for parsing the CONFIG.CFG file
  -- [but redundant when the user merely changed the widget]
  if (name == "game") or (name == "engine") or (name == "theme") then
    gui.change_button(name, OB_CONFIG[name])
  end
end


function ob_read_all_config(all_opts)

  local function do_line(fmt, ...)
    gui.config_line(string.format(fmt, ...))
  end

  local unknown = "XXX"

  do_line("-- Game Settings --");

  do_line("seed = %d",   OB_CONFIG.seed or 0)
  do_line("game = %s",   OB_CONFIG.game or unknown)
  do_line("mode = %s",   OB_CONFIG.mode or unknown)
  do_line("engine = %s", OB_CONFIG.engine or unknown)
  do_line("length = %s", OB_CONFIG.length or unknown)
  do_line("")

  do_line("-- Level Architecture --");
  do_line("theme = %s",   OB_CONFIG.theme or unknown)
  do_line("size = %s",    OB_CONFIG.size or unknown)
  do_line("outdoors = %s",OB_CONFIG.outdoors or unknown)
  do_line("secrets = %s",  OB_CONFIG.secrets or unknown)
  do_line("traps = %s",   OB_CONFIG.traps or unknown)
  do_line("")

  do_line("-- Playing Style --");
  do_line("mons = %s",    OB_CONFIG.mons or unknown)
  do_line("strength = %s",OB_CONFIG.strength or unknown)
  do_line("powers = %s",  OB_CONFIG.powers or unknown)
  do_line("health = %s",  OB_CONFIG.health or unknown)
  do_line("ammo = %s",    OB_CONFIG.ammo or unknown)
  do_line("")

  do_line("-- Custom Modules --");

  for name,def in pairs(OB_MODULES) do
    do_line("%s.self = %s", name, sel(def.enabled, "true", "false"))

    -- module options
    if def.options and (all_opts or def.enabled) then
      for o_name,opt in pairs(def.options) do
        do_line("%s.%s = %s", name, o_name, opt.value or unknown)
      end
    end
  end

  do_line("")
end


function ob_init()

  -- the missing console functions
  gui.printf = function (fmt, ...)
    if fmt then gui.raw_log_print(string.format(fmt, ...)) end
  end

  gui.debugf = function (fmt, ...)
    if fmt then gui.raw_debug_print(string.format(fmt, ...)) end
  end

  name_it_up(OB_GAMES)
  name_it_up(OB_THEMES)
  name_it_up(OB_ENGINES)
  name_it_up(OB_MODULES)


  local function button_sorter(A, B)
    if A.priority or B.priority then
      return (A.priority or 50) > (B.priority or 50)
    end

    return A.label < B.label
  end

  local function create_buttons(what, DEFS)
    assert(DEFS)
  
    local list = {}

    for name,def in pairs(DEFS) do
      assert(def.name and def.label)
      table.insert(list, def)
    end

    table.sort(list, button_sorter)

    for _,def in ipairs(list) do
      gui.add_button(what, def.name, def.label)

      if what == "game" then
        gui.show_button(what, def.name, true)
      end
    end

    return list[1] and list[1].name
  end

  local function create_mod_options()
    for _,mod in pairs(OB_MODULES) do
      if not mod.options then
        mod.options = {}
      else
        local list = {}

        for name,opt in pairs(mod.options) do
          opt.name = name
          table.insert(list, opt)
        end

        table.sort(list, button_sorter)

        for _,opt in ipairs(list) do
          assert(opt.label)
          assert(opt.choices)

          gui.add_mod_option(mod.name, opt.name, opt.label)

          opt.value = opt.default or opt.choices[1]

          opt.avail_choices = {}

          for i = 1,#opt.choices,2 do
            local id    = opt.choices[i]
            local label = opt.choices[i+1]

            gui.add_mod_option(mod.name, opt.name, id, label)
            opt.avail_choices[id] = 1
          end

          -- FIXME FIXME REMOVE THIS TEST FOR RELEASE !!!!!!! 
          if gui.change_mod_option then
             gui.change_mod_option(mod.name, opt.name, opt.value)
          else
            opt.value = opt.choices[1]
          end
        end -- for opt
      end
    end -- for mod
  end

  OB_CONFIG.seed = 0
  OB_CONFIG.mode = "sp" -- GUI code sets the real default

  OB_CONFIG.game   = create_buttons("game",   OB_GAMES)
  OB_CONFIG.engine = create_buttons("engine", OB_ENGINES)
  OB_CONFIG.theme  = create_buttons("theme",  OB_THEMES)

  create_buttons("module", OB_MODULES)
  create_mod_options()

  ob_update_all()

  gui.change_button("game",   OB_CONFIG.game)
  gui.change_button("engine", OB_CONFIG.engine)
end


function ob_game_format()
  assert(OB_CONFIG)
  assert(OB_CONFIG.game)

  local game = OB_GAMES[OB_CONFIG.game]

  assert(game)
  assert(game.param)

  return assert(game.param.format)
end


function ob_build_cool_shit()
  assert(OB_CONFIG)
  assert(OB_CONFIG.game)

  gui.printf("\n\n~~~~~~~ Making Levels ~~~~~~~\n\n")

  gui.printf("Settings =\n%s\n", table_to_str(OB_CONFIG))

  gui.ticker()

  Game_setup()

  local status = Game_make_all()

  Game_clean_up()

  if status == "abort" then
    gui.printf("\n~~~~~~~ Build Aborted! ~~~~~~~\n\n")
    return "abort"
  end

  gui.printf("\n~~~~~~ Finished Making Levels ~~~~~~\n\n")

  return "ok"
end

