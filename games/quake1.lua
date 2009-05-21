----------------------------------------------------------------
-- GAME DEF : Quake I
----------------------------------------------------------------
--
--  Oblige Level Maker (C) 2006-2009 Andrew Apted
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

QUAKE1_THINGS =
{
  -- players
  player1 = { id="info_player_start", kind="other", r=16,h=56 },
  player2 = { id="info_player_coop",  kind="other", r=16,h=56 },
  player3 = { id="info_player_coop",  kind="other", r=16,h=56 },
  player4 = { id="info_player_coop",  kind="other", r=16,h=56 },

  dm_player = { id="info_player_deathmatch", kind="other", r=16,h=56 },

  -- enemies
  dog      = { id="monster_dog",      kind="monster", r=32, h=80, },
  grunt    = { id="monster_army",     kind="monster", r=32, h=80, },
  enforcer = { id="monster_enforcer", kind="monster", r=32, h=80, },
  fiend    = { id="monster_demon1",   kind="monster", r=32, h=80, },

  knight   = { id="monster_knight",   kind="monster", r=32, h=80, },
  hell_knt = { id="monster_hell_knight", kind="monster", r=32, h=80, },
  ogre     = { id="monster_ogre",     kind="monster", r=32, h=80, },
  fish     = { id="monster_fish",     kind="monster", r=32, h=80, },
  scrag    = { id="monster_wizard",   kind="monster", r=32, h=80, },

  shambler = { id="monster_shambler", kind="monster", r=32, h=80, },
  spawn    = { id="monster_tarbaby",  kind="monster", r=32, h=80, },
  vore     = { id="monster_shalrath", kind="monster", r=32, h=80, },
  zombie   = { id="monster_zombie",   kind="monster", r=32, h=80, },

  -- bosses
  Chthon   = { id="monster_boss",   kind="monster", r=32, h=80, },
  Shub     = { id="monster_oldone", kind="monster", r=32, h=80, },

  -- pickups
  k_silver = { id="item_key1", kind="pickup", r=30, h=30, pass=true },
  k_gold   = { id="item_key2", kind="pickup", r=30, h=30, pass=true },

  ssg      = { id="weapon_supershotgun",    kind="pickup", r=30, h=30, pass=true },
  grenade  = { id="weapon_grenadelauncher", kind="pickup", r=30, h=30, pass=true },
  rocket   = { id="weapon_rocketlauncher",  kind="pickup", r=30, h=30, pass=true },
  nailgun  = { id="weapon_nailgun",         kind="pickup", r=30, h=30, pass=true },
  nailgun2 = { id="weapon_supernailgun",    kind="pickup", r=30, h=30, pass=true },
  zapper   = { id="weapon_lightning",       kind="pickup", r=30, h=30, pass=true },

  heal_25 = { id="item_health", spawnflags=0, kind="pickup", r=30, h=30, pass=true },
  heal_10 = { id="item_health", spawnflags=1, kind="pickup", r=30, h=30, pass=true },
  mega    = { id="item_health", spawnflags=2, kind="pickup", r=30, h=30, pass=true },

  green_armor  = { id="item_armor1",   kind="pickup", r=30, h=30, pass=true },
  yellow_armor = { id="item_armor2",   kind="pickup", r=30, h=30, pass=true },
  red_armor    = { id="item_armorInv", kind="pickup", r=30, h=30, pass=true },

  shell_20  = { id="item_shells",  spawnflags=0, kind="pickup", r=30, h=30, pass=true },
  shell_40  = { id="item_shells",  spawnflags=1, kind="pickup", r=30, h=30, pass=true },
  nail_25   = { id="item_spikes",  spawnflags=0, kind="pickup", r=30, h=30, pass=true },
  nail_50   = { id="item_spikes",  spawnflags=1, kind="pickup", r=30, h=30, pass=true },
  rocket_5  = { id="item_rockets", spawnflags=0, kind="pickup", r=30, h=30, pass=true },
  rocket_10 = { id="item_rockets", spawnflags=1, kind="pickup", r=30, h=30, pass=true },
  cell_6    = { id="item_cells",   spawnflags=0, kind="pickup", r=30, h=30, pass=true },
  cell_12   = { id="item_cells",   spawnflags=1, kind="pickup", r=30, h=30, pass=true },

  suit   = { id="item_artifact_envirosuit",      kind="pickup", r=30, h=30, pass=true },
  invis  = { id="item_artifact_invisibility",    kind="pickup", r=30, h=30, pass=true },
  invuln = { id="item_artifact_invulnerability", kind="pickup", r=30, h=30, pass=true },
  quad   = { id="item_artifact_super_damage",    kind="pickup", r=30, h=30, pass=true },

  -- scenery
  explode_sm = { id="misc_explobox2", kind="scenery", r=30, h=80, },
  explode_bg = { id="misc_explobox2", kind="scenery", r=30, h=40, },

  crucified  = { id="monster_zombie", spawnflags=1, kind="scenery", r=32, h=64, },
  torch      = { id="light_torch_small_walltorch",  kind="scenery", r=30, h=60, pass=true },

  -- ambient sounds
  snd_computer = { id="ambient_comp_hum",  kind="scenery", r=30, h=30, pass=true },
  snd_drip     = { id="ambient_drip",      kind="scenery", r=30, h=30, pass=true },
  snd_drone    = { id="ambient_drone",     kind="scenery", r=30, h=30, pass=true },
  snd_wind     = { id="ambient_suck_wind", kind="scenery", r=30, h=30, pass=true },
  snd_swamp1   = { id="ambient_swamp1",    kind="scenery", r=30, h=30, pass=true },
  snd_swamp2   = { id="ambient_swamp2",    kind="scenery", r=30, h=30, pass=true },

  -- special

}


----------------------------------------------------------------

QUAKE1_PALETTE =
{
    0,  0,  0,  15, 15, 15,  31, 31, 31,  47, 47, 47,  63, 63, 63,
   75, 75, 75,  91, 91, 91, 107,107,107, 123,123,123, 139,139,139,
  155,155,155, 171,171,171, 187,187,187, 203,203,203, 219,219,219,
  235,235,235,  15, 11,  7,  23, 15, 11,  31, 23, 11,  39, 27, 15,
   47, 35, 19,  55, 43, 23,  63, 47, 23,  75, 55, 27,  83, 59, 27,
   91, 67, 31,  99, 75, 31, 107, 83, 31, 115, 87, 31, 123, 95, 35,
  131,103, 35, 143,111, 35,  11, 11, 15,  19, 19, 27,  27, 27, 39,
   39, 39, 51,  47, 47, 63,  55, 55, 75,  63, 63, 87,  71, 71,103,
   79, 79,115,  91, 91,127,  99, 99,139, 107,107,151, 115,115,163,
  123,123,175, 131,131,187, 139,139,203,   0,  0,  0,   7,  7,  0,
   11, 11,  0,  19, 19,  0,  27, 27,  0,  35, 35,  0,  43, 43,  7,
   47, 47,  7,  55, 55,  7,  63, 63,  7,  71, 71,  7,  75, 75, 11,
   83, 83, 11,  91, 91, 11,  99, 99, 11, 107,107, 15,   7,  0,  0,
   15,  0,  0,  23,  0,  0,  31,  0,  0,  39,  0,  0,  47,  0,  0,
   55,  0,  0,  63,  0,  0,  71,  0,  0,  79,  0,  0,  87,  0,  0,
   95,  0,  0, 103,  0,  0, 111,  0,  0, 119,  0,  0, 127,  0,  0,
   19, 19,  0,  27, 27,  0,  35, 35,  0,  47, 43,  0,  55, 47,  0,
   67, 55,  0,  75, 59,  7,  87, 67,  7,  95, 71,  7, 107, 75, 11,
  119, 83, 15, 131, 87, 19, 139, 91, 19, 151, 95, 27, 163, 99, 31,
  175,103, 35,  35, 19,  7,  47, 23, 11,  59, 31, 15,  75, 35, 19,
   87, 43, 23,  99, 47, 31, 115, 55, 35, 127, 59, 43, 143, 67, 51,
  159, 79, 51, 175, 99, 47, 191,119, 47, 207,143, 43, 223,171, 39,
  239,203, 31, 255,243, 27,  11,  7,  0,  27, 19,  0,  43, 35, 15,
   55, 43, 19,  71, 51, 27,  83, 55, 35,  99, 63, 43, 111, 71, 51,
  127, 83, 63, 139, 95, 71, 155,107, 83, 167,123, 95, 183,135,107,
  195,147,123, 211,163,139, 227,179,151, 171,139,163, 159,127,151,
  147,115,135, 139,103,123, 127, 91,111, 119, 83, 99, 107, 75, 87,
   95, 63, 75,  87, 55, 67,  75, 47, 55,  67, 39, 47,  55, 31, 35,
   43, 23, 27,  35, 19, 19,  23, 11, 11,  15,  7,  7, 187,115,159,
  175,107,143, 163, 95,131, 151, 87,119, 139, 79,107, 127, 75, 95,
  115, 67, 83, 107, 59, 75,  95, 51, 63,  83, 43, 55,  71, 35, 43,
   59, 31, 35,  47, 23, 27,  35, 19, 19,  23, 11, 11,  15,  7,  7,
  219,195,187, 203,179,167, 191,163,155, 175,151,139, 163,135,123,
  151,123,111, 135,111, 95, 123, 99, 83, 107, 87, 71,  95, 75, 59,
   83, 63, 51,  67, 51, 39,  55, 43, 31,  39, 31, 23,  27, 19, 15,
   15, 11,  7, 111,131,123, 103,123,111,  95,115,103,  87,107, 95,
   79, 99, 87,  71, 91, 79,  63, 83, 71,  55, 75, 63,  47, 67, 55,
   43, 59, 47,  35, 51, 39,  31, 43, 31,  23, 35, 23,  15, 27, 19,
   11, 19, 11,   7, 11,  7, 255,243, 27, 239,223, 23, 219,203, 19,
  203,183, 15, 187,167, 15, 171,151, 11, 155,131,  7, 139,115,  7,
  123, 99,  7, 107, 83,  0,  91, 71,  0,  75, 55,  0,  59, 43,  0,
   43, 31,  0,  27, 15,  0,  11,  7,  0,   0,  0,255,  11, 11,239,
   19, 19,223,  27, 27,207,  35, 35,191,  43, 43,175,  47, 47,159,
   47, 47,143,  47, 47,127,  47, 47,111,  47, 47, 95,  43, 43, 79,
   35, 35, 63,  27, 27, 47,  19, 19, 31,  11, 11, 15,  43,  0,  0,
   59,  0,  0,  75,  7,  0,  95,  7,  0, 111, 15,  0, 127, 23,  7,
  147, 31,  7, 163, 39, 11, 183, 51, 15, 195, 75, 27, 207, 99, 43,
  219,127, 59, 227,151, 79, 231,171, 95, 239,191,119, 247,211,139,
  167,123, 59, 183,155, 55, 199,195, 55, 231,227, 87, 127,191,255,
  171,231,255, 215,255,255, 103,  0,  0, 139,  0,  0, 179,  0,  0,
  215,  0,  0, 255,  0,  0, 255,243,147, 255,247,199, 255,255,255,
  159, 91, 83
}


----------------------------------------------------------------

QUAKE1_MATERIALS =
{
  ADOOR01_2  = { t="adoor01_2" },
  ADOOR02_2  = { t="adoor02_2" },
  ADOOR03_2  = { t="adoor03_2" },
  ADOOR03_3  = { t="adoor03_3" },
  ADOOR03_4  = { t="adoor03_4" },
  ADOOR03_5  = { t="adoor03_5" },
  ADOOR03_6  = { t="adoor03_6" },
  ADOOR09_1  = { t="adoor09_1" },
  ADOOR09_2  = { t="adoor09_2" },
  AFLOOR1_3  = { t="afloor1_3" },
  AFLOOR1_4  = { t="afloor1_4" },
  AFLOOR1_8  = { t="afloor1_8" },
  AFLOOR3_1  = { t="afloor3_1" },
  ALTAR1_1   = { t="altar1_1" },
  ALTAR1_3   = { t="altar1_3" },
  ALTAR1_4   = { t="altar1_4" },
  ALTAR1_6   = { t="altar1_6" },
  ALTAR1_7   = { t="altar1_7" },
  ALTAR1_8   = { t="altar1_8" },
  ALTARB_1   = { t="altarb_1" },
  ALTARB_2   = { t="altarb_2" },
  ALTARC_1   = { t="altarc_1" },
  ARCH7      = { t="arch7" },
  ARROW_M    = { t="arrow_m" },
  AZ1_6      = { t="az1_6" },
  AZFLOOR1_1 = { t="azfloor1_1" },
  AZSWITCH3  = { t="azswitch3" },
  AZWALL1_5  = { t="azwall1_5" },
  AZWALL3_1  = { t="azwall3_1" },
  AZWALL3_2  = { t="azwall3_2" },
  BASEBUTN3  = { t="basebutn3" },
  BLACK      = { t="black" },
  BODIESA2_1 = { t="bodiesa2_1" },
  BODIESA2_4 = { t="bodiesa2_4" },
  BODIESA3_1 = { t="bodiesa3_1" },
  BODIESA3_2 = { t="bodiesa3_2" },
  BODIESA3_3 = { t="bodiesa3_3" },
  BRICKA2_1  = { t="bricka2_1" },
  BRICKA2_2  = { t="bricka2_2" },
  BRICKA2_4  = { t="bricka2_4" },
  BRICKA2_6  = { t="bricka2_6" },
  CARCH02    = { t="carch02" },
  CARCH03    = { t="carch03" },
  CARCH04_1  = { t="carch04_1" },
  CARCH04_2  = { t="carch04_2" },
  CEIL1_1    = { t="ceil1_1" },
  CEILING1_3 = { t="ceiling1_3" },
  CEILING4   = { t="ceiling4" },
  CEILING5   = { t="ceiling5" },
  CHURCH1_2  = { t="church1_2" },
  CHURCH7    = { t="church7" },

  CITY1_4    = { t="city1_4" },
  CITY1_7    = { t="city1_7" },
  CITY2_1    = { t="city2_1" },
  CITY2_2    = { t="city2_2" },
  CITY2_3    = { t="city2_3" },
  CITY2_5    = { t="city2_5" },
  CITY2_6    = { t="city2_6" },
  CITY2_7    = { t="city2_7" },
  CITY2_8    = { t="city2_8" },
  CITY3_2    = { t="city3_2" },
  CITY3_4    = { t="city3_4" },
  CITY4_1    = { t="city4_1" },
  CITY4_2    = { t="city4_2" },
  CITY4_5    = { t="city4_5" },
  CITY4_6    = { t="city4_6" },
  CITY4_7    = { t="city4_7" },
  CITY4_8    = { t="city4_8" },
  CITY5_1    = { t="city5_1" },
  CITY5_2    = { t="city5_2" },
  CITY5_3    = { t="city5_3" },
  CITY5_4    = { t="city5_4" },
  CITY5_6    = { t="city5_6" },
  CITY5_7    = { t="city5_7" },
  CITY5_8    = { t="city5_8" },
  CITY6_3    = { t="city6_3" },
  CITY6_4    = { t="city6_4" },
  CITY6_7    = { t="city6_7" },
  CITY6_8    = { t="city6_8" },
  CITY8_2    = { t="city8_2" },
  CITYA1_1   = { t="citya1_1" },
  CLIP       = { t="clip" },
  COLUMN01_3 = { t="column01_3" },
  COLUMN01_4 = { t="column01_4" },
  COLUMN1_2  = { t="column1_2" },
  COLUMN1_4  = { t="column1_4" },
  COLUMN1_5  = { t="column1_5" },
  COMP1_1    = { t="comp1_1" },
  COMP1_2    = { t="comp1_2" },
  COMP1_3    = { t="comp1_3" },
  COMP1_4    = { t="comp1_4" },
  COMP1_5    = { t="comp1_5" },
  COMP1_6    = { t="comp1_6" },
  COMP1_7    = { t="comp1_7" },
  COMP1_8    = { t="comp1_8" },
  COP1_1     = { t="cop1_1" },
  COP1_2     = { t="cop1_2" },
  COP1_3     = { t="cop1_3" },
  COP1_4     = { t="cop1_4" },
  COP1_5     = { t="cop1_5" },
  COP1_6     = { t="cop1_6" },
  COP1_7     = { t="cop1_7" },
  COP1_8     = { t="cop1_8" },
  COP2_1     = { t="cop2_1" },
  COP2_2     = { t="cop2_2" },
  COP2_3     = { t="cop2_3" },
  COP2_4     = { t="cop2_4" },
  COP2_5     = { t="cop2_5" },
  COP2_6     = { t="cop2_6" },
  COP3_1     = { t="cop3_1" },
  COP3_2     = { t="cop3_2" },
  COP3_4     = { t="cop3_4" },
  COP4_3     = { t="cop4_3" },
  COP4_5     = { t="cop4_5" },

  CRATE0_SIDE = { t="crate0_side" },
  CRATE0_TOP  = { t="crate0_top" },
  CRATE1_SIDE = { t="crate1_side" },
  CRATE1_TOP  = { t="crate1_top" },

  DEM4_1     = { t="dem4_1" },
  DEM4_4     = { t="dem4_4" },
  DEM5_3     = { t="dem5_3" },
  DEMC4_4    = { t="demc4_4" },
  DOOR01_2   = { t="door01_2" },
  DOOR02_1   = { t="door02_1" },
  DOOR02_2   = { t="door02_2" },
  DOOR02_3   = { t="door02_3" },
  DOOR02_7   = { t="door02_7" },
  DOOR03_2   = { t="door03_2" },
  DOOR03_3   = { t="door03_3" },
  DOOR03_4   = { t="door03_4" },
  DOOR03_5   = { t="door03_5" },
  DOOR04_1   = { t="door04_1" },
  DOOR04_2   = { t="door04_2" },
  DOOR05_2   = { t="door05_2" },
  DOOR05_3   = { t="door05_3" },
  DOPEBACK   = { t="dopeback" },
  DOPEFISH   = { t="dopefish" },
  DR01_1     = { t="dr01_1" },
  DR01_2     = { t="dr01_2" },
  DR02_1     = { t="dr02_1" },
  DR02_2     = { t="dr02_2" },
  DR03_1     = { t="dr03_1" },
  DR05_2     = { t="dr05_2" },
  DR07_1     = { t="dr07_1" },
  DUNG01_1   = { t="dung01_1" },
  DUNG01_2   = { t="dung01_2" },
  DUNG01_3   = { t="dung01_3" },
  DUNG01_4   = { t="dung01_4" },
  DUNG01_5   = { t="dung01_5" },
  DUNG02_1   = { t="dung02_1" },
  DUNG02_5   = { t="dung02_5" },
  ECOP1_1    = { t="ecop1_1" },
  ECOP1_4    = { t="ecop1_4" },
  ECOP1_6    = { t="ecop1_6" },
  ECOP1_7    = { t="ecop1_7" },
  ECOP1_8    = { t="ecop1_8" },
  EDOOR01_1  = { t="edoor01_1" },
  ELWALL1_1  = { t="elwall1_1" },
  ELWALL2_4  = { t="elwall2_4" },
  EMETAL1_3  = { t="emetal1_3" },
  ENTER01    = { t="enter01" },
  EXIT01     = { t="exit01" },
  EXIT02_2   = { t="exit02_2" },
  EXIT02_3   = { t="exit02_3" },
  FLOOR01_5  = { t="floor01_5" },

  GRAVE01_1  = { t="grave01_1" },
  GRAVE01_3  = { t="grave01_3" },
  GRAVE02_1  = { t="grave02_1" },
  GRAVE02_2  = { t="grave02_2" },
  GRAVE02_3  = { t="grave02_3" },
  GRAVE02_4  = { t="grave02_4" },
  GRAVE02_5  = { t="grave02_5" },
  GRAVE02_6  = { t="grave02_6" },
  GRAVE02_7  = { t="grave02_7" },
  GRAVE03_1  = { t="grave03_1" },
  GRAVE03_2  = { t="grave03_2" },
  GRAVE03_3  = { t="grave03_3" },
  GRAVE03_4  = { t="grave03_4" },
  GRAVE03_5  = { t="grave03_5" },
  GRAVE03_6  = { t="grave03_6" },
  GRAVE03_7  = { t="grave03_7" },
  GROUND1_1  = { t="ground1_1" },
  GROUND1_2  = { t="ground1_2" },
  GROUND1_5  = { t="ground1_5" },
  GROUND1_6  = { t="ground1_6" },
  GROUND1_7  = { t="ground1_7" },
  GROUND1_8  = { t="ground1_8" },
  KEY01_1    = { t="key01_1" },
  KEY01_2    = { t="key01_2" },
  KEY01_3    = { t="key01_3" },
  KEY02_1    = { t="key02_1" },
  KEY02_2    = { t="key02_2" },
  KEY03_1    = { t="key03_1" },
  KEY03_2    = { t="key03_2" },
  KEY03_3    = { t="key03_3" },
  LGMETAL    = { t="lgmetal" },
  LGMETAL2   = { t="lgmetal2" },
  LGMETAL3   = { t="lgmetal3" },
  LGMETAL4   = { t="lgmetal4" },
  LIGHT1_1   = { t="light1_1" },
  LIGHT1_2   = { t="light1_2" },
  LIGHT1_3   = { t="light1_3" },
  LIGHT1_4   = { t="light1_4" },
  LIGHT1_5   = { t="light1_5" },
  LIGHT1_7   = { t="light1_7" },
  LIGHT1_8   = { t="light1_8" },
  LIGHT3_3   = { t="light3_3" },
  LIGHT3_5   = { t="light3_5" },
  LIGHT3_6   = { t="light3_6" },
  LIGHT3_7   = { t="light3_7" },
  LIGHT3_8   = { t="light3_8" },

  M5_3       = { t="m5_3" },
  M5_5       = { t="m5_5" },
  M5_8       = { t="m5_8" },
  MET5_1     = { t="met5_1" },
  MET5_2     = { t="met5_2" },
  MET5_3     = { t="met5_3" },
  METAL1_1   = { t="metal1_1" },
  METAL1_2   = { t="metal1_2" },
  METAL1_3   = { t="metal1_3" },
  METAL1_4   = { t="metal1_4" },
  METAL1_5   = { t="metal1_5" },
  METAL1_6   = { t="metal1_6" },
  METAL1_7   = { t="metal1_7" },
  METAL2_1   = { t="metal2_1" },
  METAL2_2   = { t="metal2_2" },
  METAL2_3   = { t="metal2_3" },
  METAL2_4   = { t="metal2_4" },
  METAL2_5   = { t="metal2_5" },
  METAL2_6   = { t="metal2_6" },
  METAL2_7   = { t="metal2_7" },
  METAL2_8   = { t="metal2_8" },
  METAL3_2   = { t="metal3_2" },
  METAL4_2   = { t="metal4_2" },
  METAL4_3   = { t="metal4_3" },
  METAL4_4   = { t="metal4_4" },
  METAL4_5   = { t="metal4_5" },
  METAL4_6   = { t="metal4_6" },
  METAL4_7   = { t="metal4_7" },
  METAL4_8   = { t="metal4_8" },
  METAL5_1   = { t="metal5_1" },
  METAL5_2   = { t="metal5_2" },
  METAL5_3   = { t="metal5_3" },
  METAL5_4   = { t="metal5_4" },
  METAL5_5   = { t="metal5_5" },
  METAL5_6   = { t="metal5_6" },
  METAL5_8   = { t="metal5_8" },
  METAL6_1   = { t="metal6_1" },
  METAL6_2   = { t="metal6_2" },
  METAL6_3   = { t="metal6_3" },
  METAL6_4   = { t="metal6_4" },
  METALT1_1  = { t="metalt1_1" },
  METALT1_2  = { t="metalt1_2" },
  METALT1_7  = { t="metalt1_7" },
  METALT2_1  = { t="metalt2_1" },
  METALT2_2  = { t="metalt2_2" },
  METALT2_3  = { t="metalt2_3" },
  METALT2_4  = { t="metalt2_4" },
  METALT2_5  = { t="metalt2_5" },
  METALT2_6  = { t="metalt2_6" },
  METALT2_7  = { t="metalt2_7" },
  METALT2_8  = { t="metalt2_8" },
  METFLOR2_1 = { t="metflor2_1" },
  MMETAL1_1  = { t="mmetal1_1" },
  MMETAL1_2  = { t="mmetal1_2" },
  MMETAL1_3  = { t="mmetal1_3" },
  MMETAL1_5  = { t="mmetal1_5" },
  MMETAL1_6  = { t="mmetal1_6" },
  MMETAL1_7  = { t="mmetal1_7" },
  MMETAL1_8  = { t="mmetal1_8" },
  MSWTCH_2   = { t="mswtch_2" },
  MSWTCH_3   = { t="mswtch_3" },
  MSWTCH_4   = { t="mswtch_4" },
  MUH_BAD    = { t="muh_bad" },
  NMETAL2_1  = { t="nmetal2_1" },
  NMETAL2_6  = { t="nmetal2_6" },
  PLAT_SIDE1 = { t="plat_side1" },
  PLAT_STEM  = { t="plat_stem" },
  PLAT_TOP1  = { t="plat_top1" },
  PLAT_TOP2  = { t="plat_top2" },

  QUAKE      = { t="quake" },
  RAVEN      = { t="raven" },
  ROCK1_2    = { t="rock1_2" },
  ROCK3_2    = { t="rock3_2" },
  ROCK3_7    = { t="rock3_7" },
  ROCK3_8    = { t="rock3_8" },
  ROCK4_1    = { t="rock4_1" },
  ROCK4_2    = { t="rock4_2" },
  ROCK5_2    = { t="rock5_2" },
  RUNE1_1    = { t="rune1_1" },
  RUNE1_4    = { t="rune1_4" },
  RUNE1_5    = { t="rune1_5" },
  RUNE1_6    = { t="rune1_6" },
  RUNE1_7    = { t="rune1_7" },
  RUNE2_1    = { t="rune2_1" },
  RUNE2_2    = { t="rune2_2" },
  RUNE2_3    = { t="rune2_3" },
  RUNE2_4    = { t="rune2_4" },
  RUNE2_5    = { t="rune2_5" },
  RUNE_A     = { t="rune_a" },
  SFLOOR1_2  = { t="sfloor1_2" },
  SFLOOR3_2  = { t="sfloor3_2" },
  SFLOOR4_1  = { t="sfloor4_1" },
  SFLOOR4_2  = { t="sfloor4_2" },
  SFLOOR4_4  = { t="sfloor4_4" },
  SFLOOR4_5  = { t="sfloor4_5" },
  SFLOOR4_6  = { t="sfloor4_6" },
  SFLOOR4_7  = { t="sfloor4_7" },
  SFLOOR4_8  = { t="sfloor4_8" },
  SKILL0     = { t="skill0" },
  SKILL1     = { t="skill1" },
  SKILL2     = { t="skill2" },
  SKILL3     = { t="skill3" },
  SLIP1      = { t="slip1" },
  SLIP2      = { t="slip2" },
  SLIPBOTSD  = { t="slipbotsd" },
  SLIPLITE   = { t="sliplite" },
  SLIPSIDE   = { t="slipside" },
  SLIPTOPSD  = { t="sliptopsd" },
  STONE1_3   = { t="stone1_3" },
  STONE1_5   = { t="stone1_5" },
  STONE1_7   = { t="stone1_7" },
  SWITCH_1   = { t="switch_1" },
  SWTCH1_1   = { t="swtch1_1" },

  TECH01_1   = { t="tech01_1" },
  TECH01_2   = { t="tech01_2" },
  TECH01_3   = { t="tech01_3" },
  TECH01_5   = { t="tech01_5" },
  TECH01_6   = { t="tech01_6" },
  TECH01_7   = { t="tech01_7" },
  TECH01_9   = { t="tech01_9" },
  TECH02_1   = { t="tech02_1" },
  TECH02_2   = { t="tech02_2" },
  TECH02_3   = { t="tech02_3" },
  TECH02_5   = { t="tech02_5" },
  TECH02_6   = { t="tech02_6" },
  TECH02_7   = { t="tech02_7" },
  TECH03_1   = { t="tech03_1" },
  TECH03_2   = { t="tech03_2" },
  TECH04_1   = { t="tech04_1" },
  TECH04_2   = { t="tech04_2" },
  TECH04_3   = { t="tech04_3" },
  TECH04_4   = { t="tech04_4" },
  TECH04_5   = { t="tech04_5" },
  TECH04_6   = { t="tech04_6" },
  TECH04_7   = { t="tech04_7" },
  TECH04_8   = { t="tech04_8" },
  TECH05_1   = { t="tech05_1" },
  TECH05_2   = { t="tech05_2" },
  TECH06_1   = { t="tech06_1" },
  TECH06_2   = { t="tech06_2" },
  TECH07_1   = { t="tech07_1" },
  TECH07_2   = { t="tech07_2" },
  TECH08_1   = { t="tech08_1" },
  TECH08_2   = { t="tech08_2" },
  TECH09_3   = { t="tech09_3" },
  TECH09_4   = { t="tech09_4" },
  TECH10_1   = { t="tech10_1" },
  TECH10_3   = { t="tech10_3" },
  TECH11_1   = { t="tech11_1" },
  TECH11_2   = { t="tech11_2" },
  TECH12_1   = { t="tech12_1" },
  TECH13_2   = { t="tech13_2" },
  TECH14_1   = { t="tech14_1" },
  TECH14_2   = { t="tech14_2" },
  TELE_TOP   = { t="tele_top" },
  TLIGHT01   = { t="tlight01" },
  TLIGHT01_2 = { t="tlight01_2" },
  TLIGHT02   = { t="tlight02" },
  TLIGHT03   = { t="tlight03" },
  TLIGHT05   = { t="tlight05" },
  TLIGHT07   = { t="tlight07" },
  TLIGHT08   = { t="tlight08" },
  TLIGHT09   = { t="tlight09" },
  TLIGHT10   = { t="tlight10" },
  TLIGHT11   = { t="tlight11" },
  TRIGGER    = { t="trigger" },
  TWALL1_1   = { t="twall1_1" },
  TWALL1_2   = { t="twall1_2" },
  TWALL1_4   = { t="twall1_4" },
  TWALL2_1   = { t="twall2_1" },
  TWALL2_2   = { t="twall2_2" },
  TWALL2_3   = { t="twall2_3" },
  TWALL2_5   = { t="twall2_5" },
  TWALL2_6   = { t="twall2_6" },
  TWALL3_1   = { t="twall3_1" },
  TWALL5_1   = { t="twall5_1" },
  TWALL5_2   = { t="twall5_2" },
  TWALL5_3   = { t="twall5_3" },

  UNWALL1_8  = { t="unwall1_8" },
  UWALL1_2   = { t="uwall1_2" },
  UWALL1_3   = { t="uwall1_3" },
  UWALL1_4   = { t="uwall1_4" },
  VINE1_2    = { t="vine1_2" },
  WALL11_2   = { t="wall11_2" },
  WALL11_6   = { t="wall11_6" },
  WALL14_5   = { t="wall14_5" },
  WALL14_6   = { t="wall14_6" },
  WALL16_7   = { t="wall16_7" },
  WALL3_4    = { t="wall3_4" },
  WALL5_4    = { t="wall5_4" },
  WALL9_3    = { t="wall9_3" },
  WALL9_8    = { t="wall9_8" },
  WARCH05    = { t="warch05" },
  WBRICK1_4  = { t="wbrick1_4" },
  WBRICK1_5  = { t="wbrick1_5" },
  WCEILING4  = { t="wceiling4" },
  WCEILING5  = { t="wceiling5" },
  WENTER01   = { t="wenter01" },
  WEXIT01    = { t="wexit01" },
  WGRASS1_1  = { t="wgrass1_1" },
  WGRND1_5   = { t="wgrnd1_5" },
  WGRND1_6   = { t="wgrnd1_6" },
  WGRND1_8   = { t="wgrnd1_8" },
  WINDOW01_1 = { t="window01_1" },
  WINDOW01_2 = { t="window01_2" },
  WINDOW01_3 = { t="window01_3" },
  WINDOW01_4 = { t="window01_4" },
  WINDOW02_1 = { t="window02_1" },
  WINDOW03   = { t="window03" },
  WINDOW1_2  = { t="window1_2" },
  WINDOW1_3  = { t="window1_3" },
  WINDOW1_4  = { t="window1_4" },
  WIZ1_1     = { t="wiz1_1" },
  WIZ1_4     = { t="wiz1_4" },
  WIZMET1_1  = { t="wizmet1_1" },
  WIZMET1_2  = { t="wizmet1_2" },
  WIZMET1_3  = { t="wizmet1_3" },
  WIZMET1_4  = { t="wizmet1_4" },
  WIZMET1_5  = { t="wizmet1_5" },
  WIZMET1_6  = { t="wizmet1_6" },
  WIZMET1_7  = { t="wizmet1_7" },
  WIZMET1_8  = { t="wizmet1_8" },
  WIZWIN1_2  = { t="wizwin1_2" },
  WIZWIN1_8  = { t="wizwin1_8" },
  WIZWOOD1_2 = { t="wizwood1_2" },
  WIZWOOD1_3 = { t="wizwood1_3" },
  WIZWOOD1_4 = { t="wizwood1_4" },
  WIZWOOD1_5 = { t="wizwood1_5" },
  WIZWOOD1_6 = { t="wizwood1_6" },
  WIZWOOD1_7 = { t="wizwood1_7" },
  WIZWOOD1_8 = { t="wizwood1_8" },
  WKEY02_1   = { t="wkey02_1" },
  WKEY02_2   = { t="wkey02_2" },
  WKEY02_3   = { t="wkey02_3" },
  WMET1_1    = { t="wmet1_1" },
  WMET2_1    = { t="wmet2_1" },
  WMET2_2    = { t="wmet2_2" },
  WMET2_3    = { t="wmet2_3" },
  WMET2_4    = { t="wmet2_4" },
  WMET2_6    = { t="wmet2_6" },
  WMET3_1    = { t="wmet3_1" },
  WMET3_3    = { t="wmet3_3" },
  WMET3_4    = { t="wmet3_4" },
  WMET4_2    = { t="wmet4_2" },
  WMET4_3    = { t="wmet4_3" },
  WMET4_4    = { t="wmet4_4" },
  WMET4_5    = { t="wmet4_5" },
  WMET4_6    = { t="wmet4_6" },
  WMET4_7    = { t="wmet4_7" },
  WMET4_8    = { t="wmet4_8" },
  WOOD1_1    = { t="wood1_1" },
  WOOD1_5    = { t="wood1_5" },
  WOOD1_7    = { t="wood1_7" },
  WOOD1_8    = { t="wood1_8" },
  WOODFLR1_2 = { t="woodflr1_2" },
  WOODFLR1_4 = { t="woodflr1_4" },
  WOODFLR1_5 = { t="woodflr1_5" },
  WSWAMP1_2  = { t="wswamp1_2" },
  WSWAMP1_4  = { t="wswamp1_4" },
  WSWAMP2_1  = { t="wswamp2_1" },
  WSWAMP2_2  = { t="wswamp2_2" },
  WSWITCH1   = { t="wswitch1" },
  WWALL1_1   = { t="wwall1_1" },
  WWOOD1_5   = { t="wwood1_5" },
  WWOOD1_7   = { t="wwood1_7" },
  Z_EXIT     = { t="z_exit" },

---  +0basebtn
---  +0butn
---  +0butnn
---  +0button
---  +0floorsw
---  +0light01
---  +0mtlsw
---  +0planet
---  +0shoot
---  +0slip
---  +0slipbot
---  +0sliptop
---  +1basebtn
---  +1butn
---  +1butnn
---  +1button
---  +1floorsw
---  +1light01
---  +1mtlsw
---  +1planet
---  +1shoot
---  +1slip
---  +2butn
---  +2butnn
---  +2button
---  +2floorsw
---  +2light01
---  +2mtlsw
---  +2planet
---  +2shoot
---  +2slip
---  +3butn
---  +3butnn
---  +3button
---  +3floorsw
---  +3mtlsw
---  +3planet
---  +3shoot
---  +3slip
---  +4slip
---  +5slip
---  +6slip
---  +abasebtn
---  +abutn
---  +abutnn
---  +abutton
---  +afloorsw
---  +amtlsw
---  +ashoot

---  *lava1
---  *slime
---  *slime0
---  *slime1
---  *teleport
---  *water0
---  *water1
---  *water2
---  *04awater1
---  *04mwat1
---  *04mwat2
---  *04water1
---  *04water2
}


----------------------------------------------------------------

QUAKE1_COMBOS =
{
  TECH_BASE1 = { wall = "TECH06_1" },
  TECH_BASE2 = { wall = "TECH08_2" },
  TECH_BASE3 = { wall = "TECH09_3" },
  TECH_BASE4 = { wall = "TECH13_2" },
  TECH_BASE5 = { wall = "TECH14_1" },
  TECH_BASE6 = { wall = "TWALL1_4" },
  TECH_BASE7 = { wall = "TWALL2_3" },

  TECH_GROUND =
  {
    outdoor = true,

    wall  = "GROUND1_6",
    floor = "GROUND1_6",
    ceil  = "GROUND1_6",
  }
}

QUAKE1_EXITS =
{
  ELEVATOR =  -- FIXME: not needed, remove
  {
    mat_pri = 0,
    wall = 21, void = 21, floor=0, ceil=0,
  },
}


QUAKE1_KEY_DOORS =
{
  k_silver = { door_kind="door_silver", door_side=14 },
  k_gold   = { door_kind="door_gold",   door_side=14 },
}

QUAKE1_MISC_PREFABS =
{
  elevator =
  {
    prefab = "WOLF_ELEVATOR",
    add_mode = "extend",

    skin = { elevator=21, front=14, }
  },
}



QUAKE1_ROOMS =
{
  PLAIN =
  {
  },

  HALLWAY =
  {
    scenery = { ceil_light=90 },

    space_range = { 10, 50 },
  },

  STORAGE =
  {
    scenery = { barrel=50, green_barrel=80, }
  },

  TREASURE =
  {
    pickups = { cross=90, chalice=90, chest=20, crown=5 },
    pickup_rate = 90,
  },

  SUPPLIES =
  {
    scenery = { barrel=70, bed=40, },

    pickups = { first_aid=50, good_food=90, clip_8=70 },
    pickup_rate = 66,
  },

  QUARTERS =
  {
    scenery = { table_chairs=70, bed=70, chandelier=70,
                bare_table=20, puddle=20,
                floor_lamp=10, urn=10, plant=10
              },
  },

  BATHROOM =
  {
    scenery = { sink=50, puddle=90, water_well=30, empty_well=30 },
  },

  KITCHEN =
  {
    scenery = { kitchen_stuff=50, stove=50, pots=50,
                puddle=20, bare_table=20, table_chairs=5,
                sink=10, barrel=10, green_barrel=5, plant=2
              },

    pickups = { good_food=15, dog_food=5 },
    pickup_rate = 20,
  },

  TORTURE =
  {
    scenery = { hanging_cage=80, skeleton_in_cage=80,
                skeleton_relax=30, skeleton_flat=40,
                hanged_man=60, spears=10, bare_table=10,
                gibs_1=10, gibs_2=10,
                junk_1=10, junk_2=10,junk_3=10
              },
  },
}

QUAKE1_THEMES =
{
  TECH =
  {
    building =
    {
      TECH_BASE1=50,
      TECH_BASE2=50,
      TECH_BASE3=50,
      TECH_BASE4=50,
      TECH_BASE5=50,
      TECH_BASE6=50,
      TECH_BASE7=50,
    },

    ground =
    {
      TECH_GROUND=50,
    },

    floors =
    {
      FLOOR01_5=50,
      METAL2_4=50,
      METFLOR2_1=50,
      MMETAL1_1=50,

      SFLOOR4_1=50,
      SFLOOR4_5=50,
      SFLOOR4_6=50,
      SFLOOR4_7=50,
    },

    ceilings =
    {
      FLOOR01_5=50,
      METAL2_4=50,
      METFLOR2_1=50,
      MMETAL1_1=50,

      SFLOOR4_1=50,
      SFLOOR4_5=50,
      SFLOOR4_6=50,
      SFLOOR4_7=50,
    },

    hallway =
    {
      -- FIXME
    },

    exit =
    {
      -- FIXME
    },

    scenery =
    {
      -- FIXME
    },
  }, -- TECH
}


----------------------------------------------------------------

QUAKE1_MONSTERS =
{
  dog =
  {
    prob=10, guard_prob=1, trap_prob=1,
    health=25, damage=5, attack="melee",
  },

  fish =
  {
    health=25, damage=3, attack="melee",
  },

  grunt =
  {
    prob=80, guard_prob=11, trap_prob=11, cage_prob=11,
    health=30, damage=14, attack="hitscan",
    give={ {ammo="shell",count=5} },
  },

  enforcer =
  {
    prob=40, guard_prob=11, trap_prob=11, cage_prob=11,
    health=80, damage=18, attack="missile",
    give={ {ammo="cell",count=5} },
  },

  zombie =
  {
    prob=10, guard_prob=1, cage_prob=11,
    health=60, damage=8,  attack="melee",
  },

  scrag =
  {
    prob=60, guard_prob=11, trap_prob=11, cage_prob=11,
    health=80, damage=18, attack="missile",
  },

  spawn =
  {
    prob=10, trap_prob=11,
    health=80, damage=10, attack="melee",
  },

  knight =
  {
    prob=60, guard_prob=1, trap_prob=11, cage_prob=11,
    health=75, damage=9,  attack="melee",
  },

  hell_knt =
  {
    prob=30, guard_prob=31, trap_prob=21, cage_prob=11,
    health=250, damage=30, attack="missile",
  },

  ogre =
  {
    prob=40, guard_prob=21, trap_prob=31, cage_prob=11,
    health=200, damage=15, attack="missile",
    give={ {ammo="rocket",count=2} },
  },

  fiend =
  {
    prob=10, guard_prob=51, trap_prob=31,
    health=300, damage=20, attack="melee",
  },

  vore =
  {
    prob=10, guard_prob=31, trap_prob=31, cage_prob=11,
    health=400, damage=25, attack="missile",
  },

  shambler =
  {
    prob=10, guard_prob=31, trap_prob=21, cage_prob=11,
    health=600, damage=30, attack="hitscan",
    immunity={ rocket=0.5, grenade=0.5 },
  },
}


QUAKE1_WEAPONS =
{
  axe =
  {
    rate=2.0, damage=20, attack="melee",
  },

  pistol =
  {
    pref=10,
    rate=2.0, damage=20, attack="hitscan",
    ammo="shell", per=1,
  },

  ssg =
  {
    pref=50, add_prob=40,
    rate=1.4, damage=45, attack="hitscan", splash={0,3},
    ammo="shell", per=2,
    give={ {ammo="shell",count=5} },
  },

  grenade =
  {
    pref=10, add_prob=15,
    rate=1.5, damage= 5, attack="missile", splash={60,15,3},
    ammo="rocket", per=1,
    give={ {ammo="rocket",count=5} },
  },

  rocket =
  {
    pref=30, add_prob=10,
    rate=1.2, damage=80, attack="missile", splash={0,20,6,2},
    ammo="rocket", per=1,
    give={ {ammo="rocket",count=5} },
  },

  nailgun =
  {
    pref=50, add_prob=30,
    rate=5.0, damage=8, attack="missile",
    ammo="nail", per=1,
    give={ {ammo="nail",count=30} },
  },

  nailgun2 =
  {
    pref=80, add_prob=10,
    rate=5.0, damage=18, attack="missile",
    ammo="nail", per=2,
    give={ {ammo="nail",count=30} },
  },

  zapper =
  {
    pref=30, add_prob=2,
    rate=10, damage=30, attack="hitscan", splash={0,4},
    ammo="cell", per=1,
    give={ {ammo="cell",count=15} },
  },


  -- Notes:
  --
  -- Grenade damage (for a direct hit) is really zero, all of
  -- the actual damage comes from splash.
  --
  -- Rocket splash damage does not hurt the monster that was
  -- directly hit by the rocket.
  --
  -- Lightning bolt damage is done by three hitscan attacks
  -- over the same range (16 units apart).  As I read it, you
  -- can only hit two monsters if (a) the hitscan passes by
  -- the first one, or (b) the first one is killed.
}


QUAKE1_PICKUPS =
{
  -- HEALTH --

  heal_10 =
  {
    prob=20, cluster={ 1,2 },
    give={ {health=8} },   -- real amount is 5-10 units
  },

  heal_25 =
  {
    prob=50,
    give={ {health=25} },
  },

  mega =
  {
    prob=3, big_item=true,
    give={ {health=70} },  -- gives 100 but it rots aways
  },

  -- ARMOR --

  green_armor =
  {
    prob=9,
    give={ {health=30} },
  },

  yellow_armor =
  {
    prob=3,
    give={ {health=90} },
  },

  red_armor =
  {
    prob=1,
    give={ {health=160} },
  },

  -- AMMO --

  shell_20 =
  {
    prob=10,
    give={ {ammo="shell",count=20} },
  },

  shell_40 =
  {
    prob=20,
    give={ {ammo="shell",count=40} },
  },

  nail_25 =
  {
    prob=10,
    give={ {ammo="nail",count=25} },
  },

  nail_50 =
  {
    prob=20,
    give={ {ammo="nail",count=50} },
  },

  rocket_5 =
  {
    prob=10,
    give={ {ammo="rocket",count=5} },
  },

  rocket_10 =
  {
    prob=20,
    give={ {ammo="rocket",count=10} },
  },

  cell_6 =
  {
    prob=10,
    give={ {ammo="cell",count=6} },
  },

  cell_12 =
  {
    prob=20,
    give={ {ammo="cell",count=12} },
  },
}


QUAKE1_PLAYER_MODEL =
{
  quakeguy =
  {
    stats   = { health=0, shell=0, nail=0, rocket=0, cell=0 },
    weapons = { pistol=1, axe=1 },
  }
}


------------------------------------------------------------

QUAKE1_EPISODE_THEMES =
{
  { BASE=7, },
  { BASE=6, },
  { BASE=6, },
  { BASE=6, },
}

QUAKE1_KEY_NUM_PROBS =
{
  small   = { 90, 50, 20 },
  regular = { 40, 90, 40 },
  large   = { 20, 50, 90 },
}



----------------------------------------------------------------

function Quake1_setup()
  -- nothing to do
end

function Quake1_get_levels()
  local EP_NUM  = sel(OB_CONFIG.length == "full", 4, 1)
  local MAP_NUM = sel(OB_CONFIG.length == "single", 1, 7)

  if OB_CONFIG.length == "few" then MAP_NUM = 3 end

  for episode = 1,EP_NUM do
    for map = 1,MAP_NUM do

      local LEV =
      {
        name = string.format("e%dm%d", episode, map),

        ep_along = map / MAP_NUM,

        theme_ref = "BASE",

--        key_list = { "foo" },
  --      switch_list = { "foo" },
    --    bar_list = { "foo" },
      }

      table.insert(GAME.all_levels, LEV)
    end -- for map

  end -- for episode
end

function Quake1_begin_level()
  -- set the description here
  if not LEVEL.description and LEVEL.name_theme then
    LEVEL.description = Naming_grab_one(LEVEL.name_theme)
  end
end



OB_THEMES["q1_base"] =
{
  ref = "TECH",
  label = "Base",

  for_games = { quake1=1 },
}


OB_GAMES["quake1"] =
{
  label = "Quake 1",
  format = "quake1",

  setup_func = Quake1_setup,
  levels_start_func = Quake1_get_levels,
  begin_level_func = Quake1_begin_level,

  param =
  {
    -- TODO

    -- need to put center of map around (0,0) since the quake
    -- engine needs all coords to lie between -4000 and +4000.
    center_map = true,

    seed_size = 240,

    no_keys = true,  --!!!! FIXME

    sky_tex  = "sky4",
    sky_flat = "sky4",

    error_mat = "METAL1_1",

    entity_delta_z = 24,

    -- the name buffer in Quake can fit 39 characters, however
    -- the on-screen space for the name is much less.
    max_name_length = 20,

    skip_monsters = { 2,4 },

    mon_time_max = 12,
    mon_damage_max  = 200,
    mon_damage_high = 100,
    mon_damage_low  =   1,

    ammo_factor   = 0.8,
    health_factor = 0.7,
  },

  tables =
  {
    "things", QUAKE1_THINGS,
    "player_model", QUAKE1_PLAYER_MODEL,

    "monsters", QUAKE1_MONSTERS,
    "weapons",  QUAKE1_WEAPONS,
    "pickups",  QUAKE1_PICKUPS,

    "materials", QUAKE1_MATERIALS,
    "combos", QUAKE1_COMBOS,
    "exits",  QUAKE1_EXITS,

    "themes", QUAKE1_THEMES,
    "rooms",  QUAKE1_ROOMS,

    "key_doors", QUAKE1_KEY_DOORS,
    "misc_fabs", QUAKE1_MISC_PREFABS,
  },
}

