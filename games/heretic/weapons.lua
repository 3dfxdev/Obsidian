------------------------------------------------------------------------
--  HERETIC WEAPONS
------------------------------------------------------------------------
--
--  Copyright (C) 2006-2012 Andrew Apted
--  Copyright (C)      2008 Sam Trenholme
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
------------------------------------------------------------------------

HERETIC.WEAPONS =
{
  staff =
  {
    rate = 2.5
    damage = 12
    attack = "melee"
  }

  wand =
  {
    pref = 5
    rate = 3.1
    damage = 10
    attack = "hitscan"
    ammo = "crystal"
    per = 1
  }

  gauntlets =
  {
    id = 2005
    level = 1
    pref = 1
    add_prob = 5
    rate = 5.2
    damage = 8
    attack = "melee"
  }

  crossbow =
  {
    id = 2001
    level = 1
    pref = 30
    add_prob = 10
    rate = 1.3
    damage = 20
    attack = "missile"
    splash = {0,5}
    ammo = "arrow"
    per = 1
    give = { {ammo="arrow",count=10} }
  }

  claw =  -- aka blaster
  {
    id = 53
    level = 1
    pref = 50
    add_prob = 20
    rate = 2.9
    damage = 16
    attack = "missile"
    ammo = "claw_orb"
    per = 1
    give = { {ammo="claw_orb",count=30} }
  }

  hellstaff =  -- aka skullrod
  {
    id = 2004
    level = 3
    pref = 25
    add_prob = 20
    rate = 8.7
    damage = 12
    attack = "missile"
    ammo = "rune"
    per = 1
    give = { {ammo="rune",count=50} }
  }

  phoenix =
  {
    id = 2003
    level = 4
    pref = 25
    add_prob = 20
    rate = 1.7
    damage = 80
    attack = "missile"
    ammo = "flame_orb"
    per = 1
    give = { {ammo="flame_orb",count=2} }
  }

  firemace =
  {
    id = 2002
    level = 6
    pref = 5
    rate = 8.7
    damage = 8
    attack = "missile"
    ammo = "mace_orb"
    per = 1
    give = { {ammo="mace_orb",count=50} }
  }

  -- NOTES:
  --
  -- The Firemace has a 25% chance of NOT APPEARING in the level,
  -- which makes it practically useless as a general weapon for
  -- single player or co-op.  Hence it has no "add_prob".
  -- [ It may be better to define it as a NICE_ITEM which can
  --   appear in start rooms and secret closets... ]
  --
  -- No information here about weapons when the Tome-Of-Power is
  -- being used (such as different firing rates and ammo usage).
  -- Since that artifact can be used at any time by the player,
  -- OBLIGE cannot properly model it.
  --
}

