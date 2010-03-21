----------------------------------------------------------------
--  MODULE: Lighting Control
----------------------------------------------------------------
--
--  Copyright (C) 2010 Andrew Apted
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

-- NOTE: this might be better done as an Option in the GUI


function LightControl_setup(self)
  GAME.lighting_precision = self.options.precision.value
end


OB_MODULES["lighting_control"] =
{
  label = "Lighting Control",

  setup_func = LightControl_setup,

  options =
  {
    precision =
    {
      label="Precision",
      choices=
      {
        "low",  "Fastest",
        "medium", "Medium",
        "high", "High \\/ Slow",
      },
    },
  }
}

