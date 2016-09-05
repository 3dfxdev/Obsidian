--
-- Wall with horizontal band
--

GROUPS.wall_mid_band =
{
  env = "building"

  theme = "tech"
}


PREFABS.Wall_midband =
{
  file   = "wall/mid_band.wad"
  map    = "MAP01"

  where  = "edge"
  deep   = 16
  height = 96

  group  = "mid_band"

  bound_z1 = 0
  bound_z2 = 80

  z_fit  = "top"
}


PREFABS.Wall_midband_diag =
{
  file   = "wall/mid_band.wad"
  map    = "MAP02"

  where  = "diagonal"
  height = 96

  group  = "mid_band"

  bound_z1 = 0
  bound_z2 = 80

  z_fit  = "top"
}


PREFABS.Wall_midband2 =
{
  template = "Wall_midband"

  group  = "mid_band2"

  tex_LITE3 = "LITEBLU4"
}

PREFABS.Wall_midband2_diag =
{
  template = "Wall_midband_diag"

  group  = "mid_band2"

  tex_LITE3 = "LITEBLU4"
}

