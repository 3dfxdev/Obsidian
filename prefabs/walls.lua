----------------------------------------------------------------
--  WALL PREFABS
----------------------------------------------------------------
--
--  Oblige Level Maker
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

PREFAB.WALL =
{
  placement = "fitted",

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?wall" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y = 16, mat = "?wall" },
      { x =   0, y = 16, mat = "?wall" },
    },
  },
}


PREFAB.PICTURE =
{
  placement = "fitted",

  x_sizes = { {64,1}, {64,"?width"}, {64,1} },
  y_sizes = { {8,1}, {8,0} },
  z_sizes = { {64,"?height"} },

  defaults =
  {
    width  = 64,
    height = 64,
  },

  brushes =
  {
    -- wall behind picture
    {
      { x =   0, y =  0, mat = "?wall" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y =  4, mat = "?wall" },
      { x =   0, y =  4, mat = "?wall" },
    },

    -- space in front of it
    {
      { m = "air" },
      { x =   0, y =  16 },
      { x = 192, y =  16 },
      { x = 192, y =  80 },
      { x =   0, y =  80 },
    },

    -- picture itself
    {
      { x =  64, y =  4 },
      { x = 128, y =  4 },
      { x = 128, y =  8, mat = "?pic", peg="?peg", x_offset="?x_offset", y_offset="?y_offset", special="?line_kind" },
      { x =  64, y =  8 },
    },

    -- right side wall
    {
      { x = 0, y =  4, mat = "?wall" },
      { x = 8, y =  4, mat = "?wall" },
      { x = 8, y = 16, mat = "?wall" },
      { x = 0, y = 16, mat = "?wall" },
    },

    {
      { x =  8, y =  4, mat = "?wall" },
      { x = 64, y =  4, mat = "?side" },
      { x = 64, y = 16, mat = "?wall" },
      { x =  8, y = 16, mat = "?side" },
    },

    -- left side wall
    {
      { x = 184, y =  4, mat = "?wall" },
      { x = 192, y =  4, mat = "?wall" },
      { x = 192, y = 16, mat = "?wall" },
      { x = 184, y = 16, mat = "?wall" },
    },

    {
      { x = 128, y =  4, mat = "?wall" },
      { x = 184, y =  4, mat = "?side" },
      { x = 184, y = 16, mat = "?wall" },
      { x = 128, y = 16, mat = "?side" },
    },

    -- frame bottom
    {
      { x =  64, y =  4, mat = "?wall" },
      { x = 128, y =  4, mat = "?wall" },
      { x = 128, y = 16, mat = "?wall", blocked=1 },
      { x =  64, y = 16, mat = "?wall" },
      { t = 0, mat = "?floor" },
    },

    -- frame top
    {
      { x =  64, y =  4, mat = "?wall" },
      { x = 128, y =  4, mat = "?wall" },
      { x = 128, y = 16, mat = "?wall", blocked=1 },
      { x =  64, y = 16, mat = "?wall" },
      { b = 64, mat = "?floor", light = "?light"  },
    },
  },
}


PREFAB.ITEM_NICHE =
{
  placement = "fitted",

  defaults =
  {
    key = "?wall",
  },

  brushes =
  {
    -- wall behind it
    {
      { x =   0, y =  0, mat = "?wall" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y =  4, mat = "?wall" },
      { x =   0, y =  4, mat = "?wall" },
    },

    -- space in front of it
    {
      { m = "walk" },
      { x =   0, y =  64 },
      { x = 192, y =  64 },
      { x = 192, y = 128 },
      { x =   0, y = 128 },
    },

    -- right side

    {
      { x =  0, y =  4, mat = "?wall" },
      { x = 64, y =  4, mat = "?key" },
      { x = 32, y = 64, mat = "?wall" },
      { x =  0, y = 64, mat = "?wall" },
    },

    -- left side
    {
      { x = 128, y =  4, mat = "?wall" },
      { x = 192, y =  4, mat = "?wall" },
      { x = 192, y = 64, mat = "?wall" },
      { x = 160, y = 64, mat = "?key" },
    },

    -- frame bottom
    {
      { x =  64, y =  4, mat = "?wall" },
      { x = 128, y =  4, mat = "?wall" },
      { x = 160, y = 64, mat = "?wall", blocked=1 },
      { x =  32, y = 64, mat = "?wall" },
      { t = 32, mat = "?floor" },
    },

    -- frame top
    {
      { x =  64, y =  4, mat = "?wall" },
      { x = 128, y =  4, mat = "?wall" },
      { x = 160, y = 64, mat = "?wall", blocked=1 },
      { x =  32, y = 64, mat = "?wall" },
      { b = 128, mat = "?wall", light = "?light", special = "?special"  },
    },

    -- FIXME: walk space
  },

  entities =
  {
    { x = 96, y = 48, z = 32, ent = "?item", angle = 90 },
  },
}



PREFAB.WALL_SPIKE_SHOOTER =
{
  placement = "fitted",

  x_sizes = { {16,1}, {96,0}, {16,1} },
  y_sizes = { {16,1}, {24,0} },

  repeat_width = 128,

  defaults =
  {
    targetname = "spikey",
  },

  brushes =
  {
    -- wall behind it
    {
      { x =   0, y =  0, mat = "?wall" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 16, mat = "?wall" },
      { x =   0, y = 16, mat = "?wall" },
    },

    -- space in front of it
    {
      { m = "walk" },
      { x =   0, y =  16 },
      { x = 128, y =  16 },
      { x = 128, y = 112 },
      { x =   0, y = 112 },
    },

    -- the shooter
    {
      { x =  40, y = 16, mat = "?metal" },
      { x =  60, y = 16, mat = "?metal" },
      { x =  60, y = 40, mat = "?metal" },
      { b = 32, mat = "?metal" },
      { t = 56, mat = "?metal" },
    },

    {
      { x =  68, y = 16, mat = "?metal" },
      { x =  88, y = 16, mat = "?metal" },
      { x =  68, y = 40, mat = "?metal" },
      { b = 32, mat = "?metal" },
      { t = 56, mat = "?metal" },
    },

    {
      { x =  60, y = 16, mat = "?metal" },
      { x =  68, y = 16, mat = "?metal" },
      { x =  68, y = 40, mat = "?metal" },
      { x =  60, y = 40, mat = "?metal" },
      { b = 32, mat = "?metal" },
      { t = 36, mat = "?metal" },
    },

    {
      { x =  60, y = 16, mat = "?metal" },
      { x =  68, y = 16, mat = "?metal" },
      { x =  68, y = 40, mat = "?metal" },
      { x =  60, y = 40, mat = "?metal" },
      { b = 52, mat = "?metal" },
      { t = 56, mat = "?metal" },
    },
  },

  models =
  {
    -- the trigger
    {
      x1 =  16, x2 = 112, x_face = { mat="TRIGGER" },
      y1 =  16, y2 = 480, y_face = { mat="TRIGGER" },
      z1 =   0, z2 =  80, z_face = { mat="TRIGGER" },

      entity =
      {
        ent = "trigger_multiple", target = "?targetname",
      },
    },
  },

  entities =
  {
    { x = 64, y = 20, z = 20, ent = "spiker", angle = 90, targetname="?targetname" },
  },
}


