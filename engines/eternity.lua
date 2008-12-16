----------------------------------------------------------------
--  Engine: Eternity (DOOM)
----------------------------------------------------------------
--
--  Oblige Level Maker (C) 2008 Andrew Apted
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

OB_ENGINES["eternity"] =
{
  label = "Eternity 3.33",

  for_games = { doom1=1, doom2=1, heretic=1, hexen=1 },

  caps =
  {
    -- TODO
  },

  hooks =
  {
    set_level_desc = Boom_set_level_desc,
  },
}

