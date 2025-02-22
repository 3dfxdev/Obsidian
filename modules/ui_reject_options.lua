------------------------------------------------------------------------
--  PANEL: REJECT Builder Options
------------------------------------------------------------------------
--
--  Copyright (C) 2021 Dashodanger
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2,
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
------------------------------------------------------------------------

UI_REJECT_OPTIONS = { }

function UI_REJECT_OPTIONS.setup(self)
  -- these parameters have to be instantiated in this hook
  -- because begin_level happens *after* level size decisions
  for name,opt in pairs(self.options) do
    if opt.valuator then
      if opt.valuator == "button" then
        PARAM[opt.name] = gui.get_module_button_value(self.name, opt.name)
      elseif opt.valuator == "slider" then
        PARAM[opt.name] = gui.get_module_slider_value(self.name, opt.name)
      end
    else
      PARAM[opt.name] = self.options[name].value
    end
  end
end

OB_MODULES["ui_reject_options"] =
{

  name = "ui_reject_options",

  label = _("Map Build Options"),
  
  engine = "!advanced",

  side = "left",
  priority = 105,

  hooks = 
  {
    pre_setup = UI_REJECT_OPTIONS.setup,
  },

  options =
  {
    {
      name = "bool_build_reject",
      label = _("Build REJECT"),
      valuator = "button",
      default = 0,
      tooltip = "Choose to build a proper REJECT lump.",
      longtip = "If this option is not selected, a blank REJECT lump with the proper size will be inserted into the map instead." ..
      "\n\nThis is to prevent errors with some engines that are expecting a \"full\" REJECT lump to be present."
    }
  }
}

UI_UDMF_MAP_OPTIONS = { }

function UI_UDMF_MAP_OPTIONS.setup(self)
  -- these parameters have to be instantiated in this hook
  -- because begin_level happens *after* level size decisions
  for name,opt in pairs(self.options) do
    if opt.valuator then
      if opt.valuator == "button" then
        PARAM[opt.name] = gui.get_module_button_value(self.name, opt.name)
      elseif opt.valuator == "slider" then
        PARAM[opt.name] = gui.get_module_slider_value(self.name, opt.name)
      end
    else
      PARAM[opt.name] = self.options[name].value
    end
  end
end

UI_UDMF_MAP_OPTIONS.MAP_FORMAT_CHOICES = 
{
  "binary",  _("Binary"),
  "udmf", _("UDMF"),
}

OB_MODULES["ui_udmf_map_options"] =
{

  name = "ui_udmf_map_options",

  label = _("Map Build Options"),
  
  engine = "advanced",

  side = "left",
  priority = 105,

  hooks = 
  {
    pre_setup = UI_UDMF_MAP_OPTIONS.setup,
  },

  options =
  {
    {
      name = "bool_build_reject_udmf",
      label = _("Build REJECT"),
      valuator = "button",
      default = 0,
      tooltip = "Choose to build a proper REJECT lump (Binary map format only). WARNING: This can be very time consuming!",
	  longtip = "Maps with regular nodes will build the REJECT lump quickly, but maps with GL nodes use the Quake 'vis' method to calculate" ..
	    " the REJECT table. This method scales horribly with map size, and with larger maps it will take much longer to build the REJECT lump than" ..
	    " the map itself." ..
	    "\n\nEDGE and ZDoom Family will use the vis method if this option is selected, so be forewarned." ..
	    "\n\nEternity Engine will ignore this option and an empty REJECT lump will be inserted instead."
    },
    {
      name = "bool_build_nodes_udmf",
      label = _("Build Nodes"),
      valuator = "button",
      default = 0,
      tooltip = "Choose to either build nodes or allow the engine itself to do so " ..
      "upon loading the map.",
      longtip = "Some of the advanced engines supported by Obsidian are capable of building their own nodes when none are detected.\n\n" ..
        "If EDGE is selected, nodes will will only be skipped if Binary map format is selected.\n\n" ..
        "ZDoom is capable of building its own nodes in either Binary or UDMF.\n\n" ..
        "If Eternity is selected, nodes will always be built."
    },
    {
      name = "map_format",
      label = _("Map Format"),
      choices = UI_UDMF_MAP_OPTIONS.MAP_FORMAT_CHOICES,
      default = "udmf",
      tooltip = "Choose between UDMF and binary map format.",
    }
  }
}
