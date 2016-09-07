--
-- Various crates
--


-- a small crate, 64x64 in size

PREFABS.Crate_small_brown =
{
  file   = "decor/crates1.wad"
  map    = "MAP01"

  prob   = 20

  where  = "point"
  size   = 64

  bound_z1 = 0
}


PREFABS.Crate_small_gray =
{
  template = "Crate_small_brown"

   tex_CRATE1  = "CRATE2"
  flat_CRATOP2 = "CRATOP1"
}


-- a tall narrow crate

PREFABS.Crate_tall_brown =
{
  file   = "decor/crates1.wad"
  map    = "MAP02"

  prob   = 8

  where  = "point"
  size   = 64
  height = 160

  bound_z1 = 0
}


-- a medium-size crate (96x96)

PREFABS.Crate_medium_gray =
{
  file   = "decor/crates1.wad"
  map    = "MAP03"

  prob   = 8

  where  = "point"
  size   = 96

  bound_z1 = 0
}


-- a group of three and a half crates

PREFABS.Crate_group_medium =
{
  file   = "decor/crates1.wad"
  map    = "MAP04"

  prob   = 300

  where  = "point"
  size   = 128
  height = 160

  bound_z1 = 0
}

