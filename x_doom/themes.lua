--------------------------------------------------------------------
--  DOOM THEMES
--------------------------------------------------------------------
--
--  Copyright (C) 2006-2013 Andrew Apted
--  Copyright (C)      2011 Chris Pisarczyk
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--------------------------------------------------------------------

DOOM.THEME_DEFAULTS =
{
  starts = { Start_basic = 10, Start_Closet = 70 }

  exits = { Exit_pillar = 10, Exit_Closet_tech = 70 }

  pedestals = { Pedestal_1 = 50 }

  stairs = { Stair_Up1 = 50, Stair_Down1 = 50,
             Lift_Up1 = 4, Lift_Down1 = 4 }

  keys = { kc_red=50, kc_blue=50, kc_yellow=50 }

  -- TODO: sw_wood  sw_marble
  switches = { sw_blue=50 }  --!!!! , sw_red=50, sw_pink=20, sw_vine=20 }

  switch_fabs  = { Switch_blue1=50 }
                 --!!!! Switch_red1=50, Switch_pink1=50, Switch_vine1=50 }

  locked_doors = { Locked_kc_blue = 50,   Locked_ks_blue = 50,
                   Locked_kc_red = 50,    Locked_ks_red = 50,
                   Locked_kc_yellow = 50, Locked_ks_yellow = 50,

                   Door_SW_blue = 50,
                   --!!!! Door_SW_red = 50, Door_SW_pink = 50, Door_SW_vine = 50,

--[[ !!!
                   Locked_kc_blue_NAR = 3,   Locked_ks_blue_NAR = 3,
                   Locked_kc_red_NAR = 3,    Locked_ks_red_NAR = 3,
                   Locked_kc_yellow_NAR = 3, Locked_ks_yellow_NAR = 3,
                     
                   Door_SW_blue_NAR = 3, Door_SW_red_NAR = 3,
                   Door_SW_pink_NAR = 3, Door_SW_vine_NAR = 3
--]]
                 }

  secrets = { Secret_Closet = 50 }

  arches = { Arch1 = 50 }

  doors = { Door_silver = 50 }

  teleporters = { Teleporter1 = 10, Teleporter_Closet = 80 }

  logos = { Pic_Carve=50 } --!!!! , Pic_Pill=50, Pic_Neon=20 }

  windows = { Window1 = 50 }

  fences = { Fence1 = 50 }

  hallway_groups = { hall_basic = 50 } --!!!! , hall_thin = 15 }  -- TODO: cavey

  mini_halls = { Hall_Basic_I = 50 } --!!!! , MiniHall_Door_tech = 20 }

  sky_halls = { sky_hall = 50 }

  big_junctions =
  {
--!!!     junc_ledge = 80
--!!!     junc_octo = 50
--!!!     junc_nuke_pipes = 14
--!!!  -- junc_Nuke_Islands = 70  -- size restriction means this is fairly rare
--!!!     junc_spokey = 10

    junc_circle_gothic = 40
  }

  fat_cages = { Fat_Cage1 = 50 } --- , Fat_Cage_W_Bars = 8 }

  outdoor_decor = { big_tree=50, burnt_tree=10, brown_stub=10 }

  indoor_decor = { barrel=60, burning_barrel=20,
                   dead_player=10, gibbed_player=10,
                   tech_column=10,
                   impaled_twitch=10, evil_eye=5,
                   candelabra=10, red_torch=5,
                   green_torch=5, blue_torch=5 }

  indoor_fabs = { Pillar_2=70,
                  Crate1=10, Crate2=10, 
                  CrateICK=10, CrateWOOD=10 }

  --------- OLD CRUD --------> > >

  outer_fences = { BROWN144=50, STONE2=30, BROWNHUG=10,
                   BROVINE2=10, GRAYVINE=10, ICKWALL3=2,
                   GRAY1=10, STONE=20,
                 }

  -- FIXME: should not be separated (environment = "liquid" ??)
  liquid_pics = { pois1=70, pois2=30 }

  crates = { crate1=50, crate2=50, }

  -- FIXME: should not be separated, have 'environment' fields
  out_crates = { wood=50, ick=50 }

  bars = { bar_silver=50 }

  -- MISC STUFF : these don't quite fit in yet --  (FIXME)

  periph_pillar_mat = "SUPPORT3",
  beam_mat = "METAL",
  light_trim = "METAL",
  corner_supports = { SUPPORT2=50, SUPPORT3=10 }
  ceiling_trim = "METAL",
  ceiling_spoke = "SHAWN2",
  teleporter_mat = "GATE3",
  raising_start_switch = "SW1COMP",
  pedestal_mat = "CEIL1_2",
  hall_trim1 = "GRAY7",
  hall_trim2 = "METAL",
  window_side_mat = "DOORSTOP",
  track_mat = "DOORTRAK",

  lowering_pedestal_skin =
  {
    side="WOOD3", top="CEIL1_3",
    x_offset=0, y_offset=0, peg=1,
    special=23,
  }

  lowering_pedestal_skin2 =
  {
    side="PIPEWAL1", top="CEIL1_2",
    x_offset=0, y_offset=0, peg=1,
    special=23,
  }
}


DOOM.NAME_THEMES =
{
  -- these tables provide *additional* words to those in naming.lua

  TECH =
  {
    lexicon =
    {
      a =
      {
        Deimos=30
        Phobos=30
        ["Tei Tenga"]=15
      }

      b =
      {
        UAC=30
      }

      s =
      {
        ["UAC Crisis"]=30
      }
    }
  }
}


DOOM.GROUPS =
{
  ---| HALLWAYS |---

  hall_basic =
  {
    kind = "hallway"

    parts =
    {
      Hall_Basic_I = 50
      Hall_Basic_C = 50
      Hall_Basic_T = 50
      Hall_Basic_P = 50

      Hall_Basic_I_Stair = 20
      Hall_Basic_I_Lift  = 2
    }
  }


  hall_thin =
  {
    kind = "hallway"

    narrow = 1

    parts =
    {
      Hall_Thin_I = 50
      Hall_Thin_C = 50
      Hall_Thin_T = 50

      Hall_Thin_I_Stair = 20
      Hall_Basic_I_Lift  = 2  -- TODO

      Hall_Thin_I_Bulge = 70
      Hall_Thin_I_Bend  = 20

      Hall_Thin_I_Oh = 5
      Hall_Thin_C_Oh = 5
      Hall_Thin_T_Oh = 20
      Hall_Thin_P_Oh = 50

      Hall_Basic_P = 1  -- TODO (needed since Hall_Thin_P_Oh is large)
    }
  }


  hall_cavey =
  {
    kind = "hallway"

    parts =
    {
      Hall_Cavey_I = 50
      Hall_Cavey_C = 50
      Hall_Cavey_T = 50
      Hall_Cavey_P = 50

      Hall_Cavey_I_Stair = 20
      Hall_Basic_I_Lift  = 2   -- TODO
    }
  }


  sky_hall =
  {
    kind = "skyhall"

    parts =
    {
      Sky_Hall_I = 50
      Sky_Hall_C = 50
      Sky_Hall_I_Stair = 50

      Hall_Basic_T = 50  -- use indoor versions for these
      Hall_Basic_P = 50  --

      Hall_Basic_I_Lift = 2   -- TODO: sky version
    }
  }


  ---| BIG JUNCTIONS |---

  junc_ledge =
  {
    parts =
    {
      Junc_Ledge_P = 50
      Junc_Ledge_T = 50
    }
  }

  junc_octo =
  {
    parts =
    {
      Junc_Octo_I = 50
      Junc_Octo_C = 50
      Junc_Octo_T = 50
      Junc_Octo_P = 50
    }
  }

  junc_nuke_pipes =
  {
    parts =
    {
      Junc_Nuke_Pipes_I = 50
      Junc_Nuke_Pipes_C = 50
      Junc_Nuke_Pipes_T = 50
      Junc_Nuke_Pipes_P = 50
    }
  }

  junc_nuke_islands =
  {
    parts =
    {
      Junc_Nuke_Islands_C = 50
    }
  }

  junc_spokey =
  {
    parts =
    {
      Junc_Spokey_I = 50
      Junc_Spokey_C = 50
      Junc_Spokey_T = 50
      Junc_Spokey_P = 50
    }
  }

  junc_circle_tech =
  {
    parts =
    {
      Junc_Circle_tech_I = 50
      Junc_Circle_tech_C = 50
      Junc_Circle_tech_T = 50
      Junc_Circle_tech_P = 50
    }
  }

  junc_circle_gothic =
  {
    parts =
    {
      Junc_Circle_gothic_I = 50
      Junc_Circle_gothic_C = 50
      Junc_Circle_gothic_T = 50
      Junc_Circle_gothic_P = 50
    }
  }

  junc_well =
  {
    parts =
    {
      Junc_Well_I = 50
      Junc_Well_T = 50
      Junc_Well_P = 50
    }
  }
}


DOOM.ROOM_THEMES =
{
  ----- Tech Base ---------------------------

  Tech2_startan3 =
  {
    walls =
    {
      STARTAN3=60
      STARG3=40
      STARG1=10
    }

    floors =
    {
      FLOOR4_8=50
      FLOOR5_1 = 20
      FLOOR5_3=30
      FLOOR3_3=20
      FLOOR0_1 = 20
      FLOOR0_2 = 20
      FLOOR0_3=30
      SLIME15=10
      SLIME16=10
      FLAT4 = 15
      FLOOR1_1 = 8
    }

    ceilings =
    {
      CEIL3_3 = 15
      CEIL3_5=20,
      CEIL3_1=20,
      FLAT4=20,
      CEIL4_2 = 10,
      CEIL4_3=10,
      CEIL5_1=10,
      FLAT9=15,
    }
  }

  Tech2_startan2 =
  {
    walls =
    {
      STARTAN2 = 50
      STARBR2  = 40
    }

    floors =
    {
      FLOOR4_8=50,
      FLOOR5_1 = 25,
      FLOOR5_3=30,
      FLOOR3_3=20,
      FLOOR0_1 = 20,
      FLOOR0_2 = 15,
      FLOOR0_3=30,
      SLIME15=10,
      SLIME16=10,
      FLAT4=15,
    }

    ceilings =
    {
      CEIL3_1 = 20,
      CEIL3_2 = 20,
      CEIL3_5=20,
      CEIL3_1=20,
      FLAT4=20,
      CEIL4_3=10,
      CEIL5_1 = 15,
      CEIL5_2=10,
      FLAT9=30,
      FLAT19 = 20,
    }
  }

  Tech2_stargrey =
  {
    rarity = "minor"

    walls =
    {
      STARGR2=50,
    }

    floors =
    {
      FLOOR4_8=50,
      FLOOR5_1 = 20,
      FLOOR5_3=30,
      FLOOR3_3=20,
      FLOOR0_3=30,
      FLOOR0_5 = 15,
      SLIME15=10,
      SLIME16=10,
      FLAT4=15,
    }

    ceilings =
    {
      CEIL3_5=20,
      CEIL3_1=20,
      FLAT4=20,
      CEIL4_3=10,
      CEIL5_2=10,
      FLAT9=30,
      SLIME14 = 10,
    }
  }

  Tech2_tekgren =
  {
    walls =
    {
      TEKGREN2 = 50, 
    }

    floors =
    {
      FLAT14 = 60
      FLOOR0_3 = 20
      FLOOR3_3 = 40
      FLOOR5_1 = 20
    }

    ceilings =
    {
      -- FIXME
      GRNLITE1=5  
    }
  }

  Tech2_metal2 =
  {
    walls =
    {
      METAL2 = 50, 
    }

    floors =
    {
      FLAT3 = 50,
      FLOOR0_1 = 30,
      FLOOR4_5 = 20,
      FLOOR4_6 = 20,
      FLOOR7_1 = 15,
      FLAT4 = 5
      SLIME15 = 20,
      SLIME14 = 20,
    }

    ceilings =
    {
      CEIL5_1 = 40
      CEIL5_2 = 40
      SLIME15 = 40
      CEIL4_1 = 20
      SLIME14 = 40
    }
  }

  Tech2_cave =
  {
    naturals =
    {
      SP_ROCK1=50,
      GRAYVINE=50,
      TEKWALL4=3,
      ASHWALL2 = 50
      ASHWALL4 = 50
      ASHWALL6  = 10
      TANROCK7  = 10
      ZIMMER1  = 15
      ZIMMER3  = 20
      ZIMMER7  = 15
    }
  }

  Tech2_outdoors =
  {
    floors =
    {
      BROWN1=50,
      BRICK12=20,
      SLIME14=20,
      SLIME16=20,
      STONE3=40,
      FLOOR4_8=10,
      FLOOR5_4=20,
      GRASS1=40,   -- MOVE TO naturals
      FLOOR5_4=20,
    }

    naturals =
    {
      ASHWALL2=50,
      ASHWALL4=50,
      SP_ROCK1=50,
      ASHWALL6  = 20
      TANROCK4  = 15
      ZIMMER2  = 15
      ZIMMER4  = 15
      ZIMMER8  = 5
      ROCK5  = 20
    }
  }

  Tech2_hallway =
  {
    walls =
    {
      TEKWALL6 = 50,
      TEKGREN1 = 50,
      BROWNPIP = 20,
      PIPEWAL2 = 50,
      STARGR1 = 10,
      STARBR2 = 10
      PIPE2 = 15
      PIPE4 = 15
      TEKWALL4 = 10
    }

    floors =
    {
      FLAT14 = 50,
      FLOOR4_8 = 15
      FLAT1 = 20,
      FLOOR0_2 = 20,
      FLOOR1_6 = 5,
      CEIL4_1 = 20
    }

    ceilings =
    {
      CEIL3_5=50,
      CEIL3_6=20,
      CEIL3_1=50,
      RROCK03=50,
      TLITE6_5=10
      CEIL4_2 = 20
      GRNLITE1 = 20
    }
  }


  ----- Hell / Gothic -------------------------

  Hell2_hotbrick =
  {
    walls =
    {
      SP_HOT1 = 50
    }

    floors =
    {
      FLAT5_3 = 30
      FLAT10   = 50
      FLAT1  = 20
      FLOOR7_1 = 50
      FLAT5_7 = 10
      FLAT5_8 = 10
    }

    ceilings =
    {
      FLOOR6_1 = 20
      FLOOR6_2 = 20
      FLAT10 = 15
      FLAT5_3 = 10
    }
  }

  Hell2_marble =
  {
    walls =
    {
      MARBLE1  = 20
      MARBLE2 = 50
      MARBLE3  = 50
    }

    floors =
    {
      FLAT10   = 25
      FLOOR7_1 = 30
      DEM1_5  = 50
      DEM1_6  = 30
      FLOOR7_2  = 30
    }

    ceilings =
    {
      FLOOR7_2  = 50
      DEM1_5  = 20
      FLOOR6_1 = 20
      FLOOR6_2 = 20
      MFLR8_4  = 15
    }
  }

  Hell2_hallway =
  {
    walls =
    {
      MARBGRAY = 80
      GSTVINE1 = 40
      GSTVINE2 = 40
      GSTONE1  = 20
      SKINMET1 = 10
      SKINMET2 = 10
    }

    floors =
    {
      FLAT1 = 50
      DEM1_6  = 30
      FLOOR7_1  = 20
      FLOOR7_2  = 25
      FLAT10  = 20
    }

    ceilings =
    {
      FLAT1 = 50
      SFLR6_1 = 20
      SFLR6_4 = 20
      FLAT5_2 = 10
      FLOOR7_2 = 20
    }
  }

  Hell2_cave =
  {
    naturals =
    {
      ROCKRED1 = 50
      SP_ROCK1 = 25
      GSTVINE2 = 25
      ZIMMER1  = 15
      SKIN2 = 10
      FIREBLU1 = 12
    }
  }

  Hell2_outdoors =
  {
    floors =
    {
      FLOOR6_2 = 10
      FLAT5_7 = 20
      FLAT5_8 = 10
      RROCK03 = 30  -- REMOVE
      RROCK04 = 30  -- REMOVE
      RROCK09 = 15  -- REMOVE
    }

    naturals =
    {
      ROCKRED1 = 50
      SP_ROCK1 = 30
      ASHWALL2 = 30
      ASHWALL3  = 25
      ASHWALL6  = 20
      ASHWALL7  = 15
      ASHWALL4 = 30
      SKIN2 = 10
      SKSNAKE1 = 30
      SKSNAKE2 = 30
    }
  }


  ---- Urban / City / Earth ---------------------

--PANEL7 looks silly as a facade --Chris

  Urban_panel =
  {
    facades =
    {
      BIGBRIK1 = 30
      BIGBRIK2 = 15
      BLAKWAL2 = 10
      MODWALL1 = 20
      MODWALL3 = 10
      CEMENT7 = 5
      CEMENT9 = 5
      METAL2 = 3
    }

    walls =
    {
      PANEL6 = 50
      PANEL8 = 50
      PANEL9 = 30
      PANEL7 = 20
      PANEL3 = 50
      PANEL2 = 50
      PANCASE2 = 30
    }

    floors =
    {
      FLOOR0_2 = 15
      FLOOR5_3 = 20
      FLOOR5_4 = 15
      FLAT1_1 = 50
      FLAT4 = 50
      FLAT1 = 30
      FLAT8 = 10
      FLAT5_5 = 30
      FLAT5 = 20
    }

    ceilings =
    {
      FLAT1 = 50
      CEIL1_1 = 20
      FLAT5_2 = 20
      CEIL3_3 = 10
      RROCK10 = 20
    }
  }

  Urban_bigbrik =
  {
    walls =
    {
      BIGBRIK1 = 50
      BIGBRIK2 = 50
    }

    floors =
    {
      FLOOR0_1 = 20
      FLAT1_1 = 50
      FLOOR0_3 = 20
      FLAT5_1 = 50
      FLAT5_2 = 20
      FLAT1 = 30
      FLAT5 = 15
      FLOOR5_4 = 10
    }

    ceilings =
    {
      FLAT1 = 50
      RROCK10 = 20
      RROCK14 = 20
      MFLR8_1 = 10
      CEIL1_1 = 15
      FLAT5_2 = 10
    }
  }

  Urban_brick =
  {
    walls =
    {
      BRICK1 = 10
      BRICK2  = 15
      BRICK5  = 50
      BRICK6  = 20
      BRICK7  = 30
      BRICK8  = 15
      BRICK9  = 20
      BRICK12 = 30
      BRICK11 = 3
      BRICK10  = 5
    }

    floors =
    {
      FLOOR0_1 = 20
      FLOOR0_2 = 20
      FLOOR0_3 = 20
      FLOOR4_6 = 20
      FLOOR5_3 = 25
      FLAT8 = 50
      FLAT5_1 = 50
      FLAT5_2 = 30
      FLAT5_4 = 20
      FLAT5_5 = 30
      FLAT1 = 30
    }

    ceilings =
    {
      FLAT1 = 50
      FLAT5_4 = 20
      FLAT8 = 15
      RROCK10 = 20
      RROCK14 = 20
      SLIME13 = 5
    }
  }

  Urban_stone =
  {
    walls =
    {
      STONE2 = 50
      STONE3 = 50
    }

    floors =
    {
      FLAT1_2 = 50
      FLAT5_2 = 50
      FLAT1 = 50
      FLAT8 = 20
      FLAT5_4 = 35
      FLAT5_5 = 20
      FLAT5_1 = 50
      SLIME15 = 15
    }

    ceilings =
    {
      FLAT1 = 50
      CEIL1_1 = 20
      CEIL3_5 = 25
      MFLR8_1 = 30
      FLAT5_4 = 20
    }
  }

  Urban_hallway =
  {
    walls =
    {
      BIGBRIK1 = 50
      BIGBRIK2 = 50
      BRICK10  = 50
      BRICK11  = 10
      WOOD1    = 50
      WOOD12   = 50
      WOOD9    = 50
      WOODVERT = 50
      PANEL1   = 50
      PANEL7   = 30
      STUCCO  = 30
      STUCCO1  = 30
      STUCCO3  = 30
    }

    floors =
    {
      FLAT5_1 = 50
      FLAT5_2 = 20
      FLAT8   = 50
      FLAT5_4 = 50
      MFLR8_1 = 50
      FLOOR5_3 = 20
      FLAT5 = 20
    }

    ceilings =
    {
      CEIL1_1 = 30
      FLAT5_2 = 25
      CEIL3_5 = 20
      MFLR8_1 = 50
      FLAT1   = 30
    }
  }

  Urban_cave =
  {
    naturals =
    {
      ASHWALL2 = 50
      ASHWALL4 = 50
      BSTONE1  = 15
      ZIMMER5  = 15
      ROCK3    = 70
    }
  }

  Urban_outdoors =
  {
    floors =
    {
      STONE = 50
      FLAT5_2 = 50
    }

    naturals =
    {
      ASHWALL2 = 50
      ASHWALL4 = 50
      BSTONE1  = 15
      ZIMMER5  = 15
      ROCK3    = 70
    }
  }
}


--------------------------------------------------------------------
--  DOOM II : Hell on Earth
--------------------------------------------------------------------


DOOM2.ROOM_THEMES =
{
  ---- Wolfenstein 3D -------------

  Wolf_cells =
  {
    walls =
    {
      ZZWOLF9=50
    }

    floors =
    {
      FLAT1=50
    }

    ceilings =
    {
      FLAT1=50
    }
  }

  Wolf_stein =
  {
    walls =
    {
      ZZWOLF1=50,
    }

    floors =
    {
      FLAT1=50,
      MFLR8_1=50,
    }

    ceilings =
    {
      FLAT1=50
    }
  }

  Wolf_brick =
  {
    walls =
    {
      ZZWOLF11=50,
    }

    floors =
    {
      FLAT1=50
    }

    ceilings =
    {
      FLAT5_3=30,
    }
  }

  Wolf_hall =
  {
    walls =
    {
      ZZWOLF5=50,
    }

    floors =
    {
      CEIL5_1=50,
    }

    ceilings =
    {
      CEIL1_1=50,
      FLAT5_1=50,
    }
  }

  Wolf_cave =
  {
    square_caves = true

    naturals =
    {
      ROCK4=50,
      SP_ROCK1=10
    }
  }

  Wolf_outdoors =
  {
    floors =
    {
      MFLR8_1=20,
      FLAT1_1=10,
      RROCK13=20
    }

    naturals =
    {
      ROCK4=50,
      SP_ROCK1=10
    }
  }
}


--[[  
   THEME IDEAS

   (a) nature  (outdoor, grassy/rocky/muddy, water)
   (b) urban   (outdoor, bricks/concrete,  slime)

   (c) gothic     (indoor, gstone, blood, castles) 
   (d) tech       (indoor, computers, lights, lifts) 
   (e) cave       (indoor, rocky/ashy, darkness, lava)
   (f) industrial (indoor, machines, lifts, crates, nukage)

   (h) hell    (indoor+outdoor, fire/lava, bodies, blood)
--]]



DOOM2.LEVEL_THEMES =
{
  tech1 =
  {
    prob = 60

    liquids = { nukage=90, water=15, lava=10, slime=5 }

    buildings = { Tech2_startan3=60, Tech2_startan2=40,
                  Tech2_stargrey=10,
                  Tech2_tekgren=20, Tech2_metal2=10,
                }
    hallways  = { Tech2_hallway=50 }
    caves     = { Tech2_cave=50 }
    outdoors  = { Tech2_outdoors=50 }

    OLD__doors =
    {
      silver=20, silver_fast=33, silver_once=2,
      bigdoor2=5, bigdoor2_fast=8, bigdoor2_once=5,
      bigdoor4=5, bigdoor4_fast=8, bigdoor4_once=5,
      bigdoor3=5,
    }

    ceil_lights =
    {
      TLITE6_5=50, TLITE6_6=30, TLITE6_1=30, FLOOR1_7=30,
      FLAT2=20,  CEIL3_4=10, FLAT22=10,

      GRNLITE1=10,
    }

    big_lights =
    {
      TLITE6_5=30, TLITE6_6=30, GRNLITE1=30, FLAT17=30, CEIL3_4=30,

      GRNLITE1=20
    }

    pillars =
    {
      metal1=70, tekwall4=20,
      teklite=50, silver2=10, shawn2=10, metal1=15
    }

    big_pillars = { big_red=50, big_blue=50 }

--!!!!    logos = { Pic_Carve=10, Pic_Pill=90, Pic_Neon=50 }

    pictures =
    {
      Pic_Computer = 70
--!!!      Pic_TekWall = 10
--!!!      Pic_Silver3 = 25
--!!!
--!!!      Pic_LiteGlow = 20
--!!!      Pic_LiteGlowBlue = 10
--!!!      Pic_LiteFlash = 20
    }

    crates = { crate1=50, crate2=50, comp=70, lite5=20,
      space=90, mod=15 }

    monster_prefs = { arach=2.0 }

    style_list =
    {
      naturals = { none=30, few=70, some=30, heaps=2 }
    }
  }


  hell1 =
  {
    prob = 50,

    liquids = { lava=90, blood=40, nukage=5 }

    keys = { ks_red=50, ks_blue=50, ks_yellow=50 }

    buildings = { Hell2_hotbrick=50, Hell2_marble=50 }
    hallways  = { Hell2_hallway=50 }
    outdoors  = { Hell2_outdoors=50 }
    caves     = { Hell2_cave=50 }

    __mini_halls = { MiniHall_Arch1 = 50, MiniHall_Door_hell = 20 }

    __big_junctions =
    {
      junc_octo = 50
      junc_nuke_pipes = 5
      junc_spokey = 10
      junc_circle_gothic = 40
    }

--!!    exits = { Exit_Closet_hell = 50, Exit_Pillar_gothic = 10 }

--!!!!    logos = { Pic_Carve=90, Pic_Pill=50, Pic_Neon=5 }

--[[
    pictures =
    {
      Pic_MarbFace = 40
      Pic_DemonicFace = 20
      Pic_FireWall = 30
      Pic_SkinScroll = 10
      Pic_FaceScroll = 10
    }
--]]

    big_pillars = { big_red=50, sloppy=20, sloppy2=20, }

    OLD__switches = { sw_skin=50, sw_vine=50, sw_wood=50 }

    bars = { bar_wood=50, bar_metal=50 }

    outer_fences = { ROCKRED1=25, SP_ROCK1=20, BROVINE2=10, GRAYVINE=10 }

    monster_prefs = { zombie=0.3, shooter=0.6, skull=2.0, vile=2.0 }
  }


  -- AJA: not sure whether to keep this
  Hmmm_hell2 =
  {
    prob = 25,

    liquids = { lava=40, blood=90, slime=10 }

    keys = { ks_red=50, ks_blue=50, ks_yellow=50 }

    buildings = { D2_Hot_room=50 }
    outdoors  = { D2_Hot_outdoors=50 }
    caves     = { D2_Hell_cave=50 }

    FIXME_switch_doors = { Door_pink = 50, Door_vine = 50 }

    OLD__exits = { skin_pillar=40, skull_pillar=20,
      demon_pillar2=10, demon_pillar3=10 }

    big_pillars = { big_red=50, sloppy=20, sloppy2=20, }

--!!!!    logos = { carve=90, pill=50, neon=5 }

--[[
    pictures =
    {
      marbfac2=10, marbfac3=10,
      spface1=2, firewall=20,
      spine=5,

      spdude7=7,
    }
--]]

    OLD__switches = { sw_skin=50, sw_marble=50, sw_vine=50 }

    bars = { bar_wood=50, bar_metal=50 }

    outer_fences = { ROCKRED1=25, SP_ROCK1=20, BROVINE2=10, GRAYVINE=10 }

    monster_prefs = { zombie=0.3, shooter=0.6, skull=2.0, vile=2.0 }
  }


  urban1 =
  {
    prob = 50,

    liquids = { water=90, slime=40, lava=20, blood=7, nukage=2 }

    buildings = { Urban_panel=20, Urban_brick=50, Urban_bigbrik=50,
                  Urban_stone=60 }
    hallways  = { Urban_hallway=50 }
    caves     = { Urban_cave=50 }
    outdoors  = { Urban_outdoors=50 }

--!!    exits = { Exit_Closet_urban=50, Exit_Pillar_urban=10,
--!!              Exit_Pillar_gothic=3 }

    __mini_halls = { MiniHall_Arch1 = 50 }

    __big_junctions =
    {
      junc_well = 99

      junc_octo = 50
      junc_nuke_pipes = 5
      junc_spokey = 10
      junc_circle_gothic = 40
    }

--!!!!    logos = { Pic_Carve=30, Pic_Pill=30, Pic_Neon=70 }

--[[
    pictures =
    {
      Pic_MetalFace = 50
      Pic_MetalFaceLit = 50
      Pic_MarbFace = 25

      Pic_Eagle = 20
      Pic_Wreath = 20
      Pic_Adolf = 2
    }
--]]

    lifts = { shiny=20, platform=20, rusty=50 }

    OLD__switches = { sw_wood=50, sw_blue=50, sw_hot=50 }

    bars = { bar_wood=50, bar_metal=50 }

    room_types =
    {
      -- FIXME PRISON WAREHOUSE
    }

    monster_prefs =
    {
      caco=1.3, revenant=1.2, knight=1.5, demon=1.2, gunner=1.5,
    }
  }


  -- this theme is not normally used (only for secret levels)
  wolf1 =
  {
    prob = 10,

    max_dominant_themes = 1

    buildings = { Wolf_cells=50, Wolf_brick=30, Wolf_stein=50 }

    caves = { Wolf_cave=50 }

    outdoors = { Wolf_outdoors=50 }

    hallways = { Wolf_hall=50 }

    __pictures = { eagle1=50, hitler1=10 }

    OLD__exits = { skull_pillar=50, stone_pillar=8 }

    OLD__switches = { sw_wood=50, sw_blue=50, sw_hot=50 }

    bars = { bar_wood=50, bar_gray=50, bar_silver=50 }

    OLD__doors = { wolf_door=90, wolf_elev_door=5 }

    force_mon_probs = { ss_dude=70, demon=20, shooter=20, zombie=20, other=0 }

    ---??? weap_prefs = { chain=3, shotty=3, super=3 }

    style_list =
    {
      naturals = { none=40, few=60, some=10 }
    }
  }
}


--------------------------------------------------------------------
--  DOOM 1 / Ultimate DOOM
--------------------------------------------------------------------


DOOM1.ROOM_THEMES =
{
  ----- Tech Bases -------------------------

  D1_Tech_room =
  {
    walls =
    {
      STARTAN3=25, STARG2=20, STARTAN2=18, STARG3=11,
      STARBR2=5, STARGR2=10, STARG1=5, STARG2=5,
      SLADWALL=18, GRAY7=10, BROWN1=5,
      BROWNGRN=10, BROWN96=8, METAL1=1, GRAY5=3,

      COMPOHSO=10, STARTAN1=5, COMPTILE=5,
    }

    floors =
    {
      FLOOR0_1=50, FLOOR0_2=20, FLOOR0_3=50,
      FLOOR0_7=50, FLOOR3_3=50, FLOOR7_1=10,
      FLOOR4_5=50, FLOOR4_6=50, FLOOR4_8=50, FLOOR5_2=50,
      FLAT1=20, FLAT5=20, FLAT9=50, FLAT14=50,
      CEIL3_2=50,
    }

    ceilings =
    {
      CEIL5_1=50, CEIL5_2=50, CEIL3_3=50, CEIL3_5=50,
      FLAT1=50, FLAT4=50, FLAT18=50,
      FLOOR0_2=50, FLOOR4_1=50, FLOOR5_1=50, FLOOR5_4=20,
      TLITE6_5=2, TLITE6_6=2, CEIL1_2=2,
    }

    __corners =
    {
      STARGR1=40, METAL1=20, ICKWALL3=6,
      TEKWALL4=6, COMPTALL=3, COMPBLUE=3,

      COMPTILE=10,
    }
  }


  D1_Tech_hallway =
  {
    walls =
    {
      BROWN1=33, BROWNGRN=50, GRAY1=50, STARBR2=33
    }

    floors =
    {
      FLAT4=50, CEIL5_1=50, FLOOR1_1=50, FLOOR3_3=50
    }

    ceilings =
    {
      FLAT4=50, CEIL5_1=50, CEIL3_5=50, CEIL3_3=50
    }
  }


  D1_Tech_cave =
  {
    naturals =
    {
      ASHWALL=50,
      SP_ROCK1=50,
      GRAYVINE=50,
      TEKWALL4=3,
    }
  }


  D1_Tech_outdoors =
  {
    floors =
    {
      BROWN144=30, BROWN1=20, STONE=20,
      ASHWALL=5, FLAT10=5,
    }

    naturals =
    {
      ASHWALL=50,
      SP_ROCK1=50,
      GRAYVINE=50,
      STONE=50,
    }
  }


  ----- Hell / Gothic -------------------------

  D1_Marble_room =
  {
    walls =
    {
      MARBLE1=25, MARBLE2=10, MARBLE3=20,
      GSTVINE2=20, SLADWALL=10,
      SKINMET1=3, SKINMET2=3,

      SKINTEK1=15, SKINTEK2=15,
    }

    floors =
    {
      DEM1_5=15, DEM1_6=15, FLAT5_7=10, FLAT10=10,
      FLOOR7_1=10, FLAT1=10, FLOOR5_2=10,
    }

    ceilings =
    {
      FLAT1=10, FLAT10=10, FLAT5_5=10, FLOOR7_2=10,
    }

    __corners =
    {
      SKULWALL=8, SKULWAL3=7,
    }
  }


  D1_Marble_outdoors =
  {
    floors =
    {
      ASHWALL=20,
      FLAT5_6=10, FLAT10=20,
      SFLR6_1=10, MFLR8_2=20,
    }

    naturals =
    {
      ASHWALL=50, GRAYVINE=50,
      SP_ROCK1=50, ROCKRED1=90,
      SKSNAKE1=10, SKSNAKE2=10,
    }
  }


  D1_Hot_room =
  {
    walls =
    {
      SP_HOT1=25, GSTVINE1=17, STONE=10, SKINMET2=5, BROWN1=2,
      SKINCUT=2,

      SKINTEK1=10, SKINTEK2=10,
    }

    floors =
    {
      FLAT5_7=10, FLAT10=10, FLAT5_3=10,
      FLOOR7_1=10, FLAT1=10, FLOOR5_2=10,
    }

    ceilings =
    {
      FLAT1=10, FLOOR6_1=10, FLAT10=10, FLAT8=10,
    }

    __corners =
    {
      SKULWALL=10, SKULWAL3=10, REDWALL1=15,
    }
  }


  D1_Hot_outdoors =
  {
    floors =
    {
      FLAT5_6=10, ASHWALL=5, FLAT10=5,
      SFLR6_4=10, MFLR8_2=10,
    }

    naturals =
    {
      ASHWALL=50, GRAYVINE=50,
      SP_ROCK1=50, ROCKRED1=90,
      SKSNAKE1=10, SKSNAKE2=10,
    }
  }


  D1_Hell_cave =
  {
    naturals =
    {
      ROCKRED1=90,
      SKIN2=50, SKINFACE=50, SKSNAKE1=35, SKSNAKE2=35,
      FIREBLU1=50, FIRELAVA=50, 
    }
  }


  ---- Episode 2 --------------------------

  Deimos_room =
  {
    walls =
    {
      STARTAN3=10, STARG2=15, BROVINE=20, ICKWALL1=15,
      STARBR2=15, STARGR2=10, STARG1=5, STARG2=3, ICKWALL3=30,
      SLADWALL=10, GRAY7=20, BROWN1=5, GRAY1=15, BROVINE2=15,
      BROWNGRN=10, BROWN96=5, METAL1=15, GRAY5=15, STONE=10,

      STONE2=30, STARTAN1=5, STONE3=20,
    }

    floors =
    {
      FLOOR0_1=30, FLOOR0_2=40, FLOOR0_3=30, CEIL4_1=5,
      FLOOR0_7=10, FLOOR3_3=20, FLOOR7_1=20, CEIL_4_2=10,
      FLOOR4_1=30, FLOOR4_6=20, FLOOR4_8=50, FLOOR5_2=35,
      FLAT1=40, FLAT5=30, FLAT14=10, FLAT1_1=30, FLOOR1_6=3,
      FLAT1_2=30, FLOOR5_1=50, FLAT3=15, FLAT5_4=15,
    }

    ceilings =
    {
      CEIL5_1=30, CEIL3_3=70, CEIL3_5=50, CEIL4_1=10,
      FLAT1=30, FLAT4=20, FLAT19=30, FLAT8=15, FLAT5_4=20,
      FLOOR0_2=20, FLOOR4_1=50, FLOOR5_1=50, FLOOR5_4=10,
    }

    __corners =
    {
      STARGR1=40, METAL1=20, ICKWALL3=6, TEKWALL1=20,
      TEKWALL4=6, COMPTALL=3, COMPBLUE=3, STARTAN1=7,

      COMPTILE=10,
    }
  }

  Deimos_hallway =
  {
    walls =
    {
      BROWN1=33, BROWNGRN=50, BROVINE=20,
      GRAY1=50, GRAY5=33, ICKWALL1=30, ICKWALL3=30,
      STONE2=40, STONE3=50, METAL1=30
    }

    floors =
    {
      FLAT4=30, CEIL5_1=30, FLAT14=20, FLAT5_4=20
      FLOOR3_3=30, FLOOR4_8=40, FLOOR5_1=25,
    }

    ceilings =
    {
      FLAT4=50, CEIL5_1=50, CEIL3_5=50, CEIL3_3=50, FLAT19=20
    }
  }

  Deimos_cave =
  {
    naturals =
    {
      SP_ROCK1=90,
      ASHWALL=20, BROWNHUG=15,
      GRAYVINE=15,
    }
  }

  Deimos_outdoors =
  {
--Makes sense for high prob for SP_ROCK1 because the intermission screen shows
--Deimos has a desolate, gray ground.
    floors = { BROWN144=20, BROWN1=10, STONE=10 }

    naturals = { SP_ROCK1=60, ASHWALL=2, FLAT10=3 }
  }


  ---- Episode 4 --------------------------

  Flesh_room =
  {
    walls =
    {
      MARBLE1=10, MARBLE2=10, MARBLE3=10, WOOD1=30,
      GSTVINE2=12, SLADWALL=10, GSTONE1=15, WOOD5=20,
      SKINMET1=3, SKINMET2=3, GSTVINE1=12, WOOD3=15, STONE2=3,

      SKINTEK1=10, SKINTEK2=10, BROWNGRN=7, BROVINE2=5, STONE3=3,
    }

    floors =
    {
      DEM1_5=10, DEM1_6=10, FLAT5_7=12, FLAT10=12,
      FLOOR7_1=10, FLAT1=12, FLOOR5_2=10, FLAT5_8=10,
      FLOOR5_4=10, FLOOR5_3=10, FLAT5=10, FLAT5_4=15,
      FLOOR7_2=10, FLAT5_1=15, FLAT5_2=15, FLAT8=10,
    }

    ceilings =
    {
      FLAT1=10, FLAT10=10, FLAT5_5=10, FLOOR7_2=6, DEM1_6=10,
      FLOOR6_1=10, FLOOR6_2=10, MFLR8_1=12, FLAT5_4=10, SFLR6_1=5,
      SFLR6_2=5, CEIL1_1=5, FLAT5_1=12, FLAT5_2=12, FLAT8=8,
    }

    __corners =
    {
      SKULWALL=8, SKULWAL3=7, SKSNAKE1=5, SKSNAKE2=5, ASHWALL=5, METAL=15
    }
  }

  Flesh_cave =
  {
    naturals =
    {
      ROCKRED1=70, SP_ROCK1=50, BROWNHUG=15,
      SKIN2=10, SKINFACE=20, SKSNAKE1=5, SKSNAKE2=5,
      FIREBLU1=10, FIRELAVA=10, 
    }
  }

  Flesh_outdoors =
  {
    floors =
    {
      ASHWALL=12, FLAT5_7=10, FLAT1_1=15, FLAT5_4=10,
      FLAT10=20, FLAT5_8=10, MFLR8_4=10, FLOOR7_1=15,
      SFLR6_1=8, MFLR8_2=5, FLAT1_2=10, MFLR8_3=10,
    }

    naturals =
    {
      ASHWALL=30, GRAYVINE=30, SP_ROCK2=15,
      SP_ROCK1=50, ROCKRED1=50, BROWNHUG=10,
      SKSNAKE1=10, SKSNAKE2=10,
    }
  }
}


DOOM1.LEVEL_THEMES =
{
  doom_tech1 =
  {
    prob = 60

    liquids = { nukage=90, water=15, lava=10 }

    buildings = { D1_Tech_room=50 }
    hallways  = { D1_Tech_hallway=50 }
    caves     = { D1_Tech_cave=50 }
    outdoors  = { D1_Tech_outdoors=50 }

    __logos = { carve=5, pill=50, neon=50 }

    __pictures =
    {
      shawn1=10, tekwall1=4, tekwall4=2,
      lite5=30, lite5_05blink=10, lite5_10blink=10,
      liteblu4=30, liteblu4_05sync=10, liteblu4_10sync=10,
      compsta1=40, compsta1_blink=4,
      compsta2=40, compsta2_blink=4,
      redwall=5,

---!!!   planet1=20,  planet1_blink=8,
      compute1=20, compute1_blink=3,
---!!!   compute2=15, compute2_blink=2,
      litered=10,
    }

    OLD__exits = { stone_pillar=50 }

    OLD__switches = { sw_blue=50, sw_hot=50 }

    bars = { bar_silver=50, bar_gray=50 }

    OLD__doors =
    {
      silver=20, silver_fast=33, silver_once=2,
      bigdoor2=5, bigdoor2_fast=8, bigdoor2_once=5,
      bigdoor4=5, bigdoor4_fast=8, bigdoor4_once=5,
      bigdoor3=5,
    }

    ceil_lights =
    {
      TLITE6_5=50, TLITE6_6=30, TLITE6_1=30, FLOOR1_7=30,
      FLAT2=20,    CEIL3_4=10,  FLAT22=10,
    }

    big_lights = { TLITE6_5=30, TLITE6_6=30, FLAT17=30, CEIL3_4=30 }

    pillars = { metal1=70, tekwall4=20 }
    big_pillars = { big_red=50, big_blue=50 }

    crates = { crate1=50, crate2=50, comp=70, lite5=20 }

    style_list =
    {
      naturals = { none=30, few=70, some=30, heaps=2 }
    }
  }


  -- Deimos theme by Mr. Chris

  doom_deimos1 =
  {
    prob = 50

    liquids = { nukage=60, water=10, blood=20 }

    buildings = { Deimos_room=50 }
    caves     = { Deimos_cave=50 }
    outdoors  = { Deimos_outdoors=50 }
    hallways  = { Deimos_hallway=50 }

    -- Best facades would be STONE/2/3, BROVINE/2, BROWN1 and maybe a few others as I have not seen many
    -- other textures on the episode 2 exterior.
    facades =
    {
      STONE2=50, STONE3=50, BROVINE=30, BROVINE2=30,
      BROWN1=50,  -- etc...
    }

    __logos = { carve=5, pill=50, neon=50 }

    __pictures =
    {
      shawn1=10, tekwall1=4, tekwall4=2,
      lite5=20, lite5_05blink=10, lite5_10blink=10,
      liteblu4=30, liteblu4_05sync=10, liteblu4_10sync=10,
      compsta1=30, compsta1_blink=15,
      compsta2=30, compsta2_blink=15,

---!!!   planet1=20,  planet1_blink=8,
      compute1=20, compute1_blink=15,
---!!!   compute2=15, compute2_blink=2,
      litered=10,
    }

    OLD__exits = { stone_pillar=50 }

    OLD__switches = { sw_blue=50, sw_hot=50 }

    bars = { bar_silver=50, bar_gray=50 }

    OLD__doors =
    {
      silver=20, silver_fast=33, silver_once=2,
      bigdoor2=5, bigdoor2_fast=8, bigdoor2_once=5,
      bigdoor4=5, bigdoor4_fast=8, bigdoor4_once=5,
      bigdoor3=5,
    }

    ceil_lights =
    {
      TLITE6_5=50, TLITE6_6=30, TLITE6_1=30, FLOOR1_7=30, CEIL1_3=5,
      FLAT2=20, CEIL3_4=10, FLAT22=10, FLAT17=20, CEIL1_2=7,
    }

    big_lights = { TLITE6_5=30, TLITE6_6=30, FLAT17=30, CEIL3_4=30 }

    pillars = { metal1=70, tekwall4=20 }
    big_pillars = { big_red=50, big_blue=50 }

    crates = { crate1=50, crate2=50, comp=70, lite5=20 }

    style_list =
    {
      naturals = { none=40, few=70, some=20, heaps=2 }
    }
  }


  -- this is the greeny/browny/marbley Hell

  doom_hell1 =
  {
    prob = 40,

    liquids = { lava=30, blood=90, nukage=5 }

    keys = { ks_red=50, ks_blue=50, ks_yellow=50 }

    buildings = { D1_Marble_room=50 }
    outdoors  = { D1_Marble_outdoors=50 }
    caves     = { D1_Hell_cave=50 }


    FIXME_switch_doors = { Door_pink = 50, Door_vine = 50 }

    __logos = { carve=90, pill=50, neon=5 }

    __pictures =
    {
      marbface=10, skinface=10, firewall=20,
      spdude1=4, spdude2=4, spdude5=3, spine=2,

      skulls1=10, skulls2=10, spdude3=3, spdude6=3,
    }

    OLD__exits = { skin_pillar=40,
              demon_pillar2=10, demon_pillar3=10 }

    OLD__switches = { sw_marble=50, sw_vine=50, sw_wood=50 }

    bars = { bar_wood=50, bar_metal=50 }

    outer_fences = { ROCKRED1=25, SP_ROCK1=20, BROVINE2=10, GRAYVINE=10 }

    monster_prefs = { zombie=0.3, shooter=0.6, skull=2.0 }
  }


  -- this is the reddy/skinny/firey Hell

  doom_hell2 =
  {
    prob = 25,

    liquids = { lava=90, blood=40 }

    keys = { ks_red=50, ks_blue=50, ks_yellow=50 }

    buildings = { D1_Hot_room=50 }
    outdoors  = { D1_Hot_outdoors=50 }
    caves     = { D1_Hell_cave=50 }


    __logos = { carve=90, pill=50, neon=5 }

    __pictures =
    {
      marbfac2=10, marbfac3=10,
      spface1=2, firewall=20,
      spine=5,

      skulls1=20, skulls2=20,
    }

    OLD__exits = { skin_pillar=40,
              demon_pillar2=10, demon_pillar3=10 }

    OLD__switches = { sw_skin=50, sw_vine=50, sw_wood=50 }

    bars = { bar_wood=50, bar_metal=50 }

    outer_fences = { ROCKRED1=25, SP_ROCK1=20, BROVINE2=10, GRAYVINE=10 }

    monster_prefs = { zombie=0.3, shooter=0.6, skull=2.0 }
  }


  -- Thy Flesh Consumed by Mr. Chris
  -- Basically a modified version of doom_hell1 to match id's E4 better

  doom_flesh1 =
  {
    prob = 40,

    liquids = { lava=30, blood=50, nukage=10, water=20 }

    buildings = { Flesh_room=50 }
    caves     = { Flesh_cave=50 }
    outdoors  = { Flesh_outdoors=50 }

    __logos = { carve=90, pill=50, neon=5 }

    __pictures =
    {
      marbface=10, skinface=10, firewall=10,
      spdude1=5, spdude2=5, spdude5=5, spine=2,

      skulls1=8, skulls2=8, spdude3=3, spdude6=3,
    }

    keys = { ks_red=50, ks_blue=50, ks_yellow=50 }

    __exits = { skin_pillar=30, demon_pillar2=10 }

    __switches = { sw_marble=50, sw_vine=50, sw_wood=50 }

    __bars = { bar_wood=50, bar_metal=50 }

    outer_fences = { ROCKRED1=25, SP_ROCK1=20, BROVINE2=10, GRAYVINE=10, MARBLE3=10, BROWNHUG=20 }

    __crates = { crate1=0, crate2=0, comp=0, lite5=0, wood=50, ick=15, }

    monster_prefs =
    {
      zombie=0.6, shooter=0.8, skull=1.2,
      demon=2.0, spectre=1.2,
      imp=2.0, baron=1.5, caco=0.8
    }
  }
}


--------------------------------------------------------------------


OB_THEMES["tech"] =
{
  label = "Tech"
  priority = 8
  name_theme = "TECH"
  mixed_prob = 60
}

OB_THEMES["hell"] =
{
  label = "Hell"
  priority = 4
  name_theme = "GOTHIC"
  mixed_prob = 50
}

OB_THEMES["urban"] =
{
  label = "Urban"
  priority = 6
  game = "doom2"
  name_theme = "URBAN"
  mixed_prob = 50
}


-- themes specific to Doom II

OB_THEMES["wolf"] =
{
  label = "Wolfenstein",
  priority = 2
  game = "doom2"
  name_theme = "URBAN"

  -- this theme is special, hence no mixed_prob
  psycho_prob = 5
}


-- themes specific to Doom 1 / Ultimate DOOM

OB_THEMES["deimos"] =
{
  label = "Deimos"
  priority = 6
  game = "doom1"
  name_theme = "TECH"
  mixed_prob = 30
}


OB_THEMES["flesh"] =
{
  label = "Thy Flesh"
  priority = 2
  game = "ultdoom"
  name_theme = "GOTHIC"
  mixed_prob = 20
}


-- TNT Evilution themes

UNFINISHED["egypt"] =
{
  label = "Egypt"
  game = "tnt"
  name_theme = "GOTHIC"
  mixed_prob = 5
}

