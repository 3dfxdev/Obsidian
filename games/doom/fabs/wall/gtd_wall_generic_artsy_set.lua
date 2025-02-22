PREFABS.Wall_generic_artsy_bedazzled =
{
  file = "wall/gtd_wall_generic_artsy_set.wad",
  map = "MAP01",

  prob = 50,

  group = "gtd_generic_artsy_bedazzled",

  where = "edge",
  deep = 16,
  height = 128,

  bound_z1 = 0,
  bound_z2 = 128,

  z_fit = "top",
}

PREFABS.Wall_generic_alternating_colors =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP02",

  group = "gtd_generic_alt_colors",

  z_fit = {40,88},
}

PREFABS.Wall_generic_mid_band =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP03",

  group = "gtd_generic_mid_band",

  z_fit = "top",
}

PREFABS.Wall_generic_double_banded_ceil =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP04",

  group = "gtd_generic_double_banded_ceil",

  z_fit = {60,68},
}

PREFABS.Wall_frame_light_band =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP05",

  group = "gtd_generic_frame_light_band",

  theme = "!hell",

  z_fit = "top",
}

--
PREFABS.Wall_generic_artsy_frame_metal =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP06",

  group = "gtd_generic_frame_metal",

  theme = "!hell",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_frame_metal_hell =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP06",

  group = "gtd_generic_frame_metal",

  theme = "hell",

  tex_STEP4 = "METAL",
  tex_DOORSTOP = "METAL",
  flat_FLAT19 = "CEIL5_2",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_center_braced_ind =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP07",

  group = "gtd_generic_artsy_center_braced_ind",

  tex_WOODMET2 = "GRAY7",
  tex_METAL = "SHAWN2",
  flat_CEIL5_2 = "FLAT19",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_center_braced_hell =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP07",

  group = "gtd_generic_artsy_center_braced_hell",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_step1_banded_wall =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP08",

  group = "gtd_generic_artsy_step1_banded",

  z_fit = "top",
}

-- diagonals

PREFABS.Wall_generic_mid_band_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP13",

  group = "gtd_generic_mid_band",

  where = "diagonal",

  z_fit = "top",
}

PREFABS.Wall_generic_double_banded_ceil_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP14",

  group = "gtd_generic_double_banded_ceil",

  where = "diagonal",

  z_fit = {60,68},
}

PREFABS.Wall_generic_artsy_center_braced_ind_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP17",

  group = "gtd_generic_artsy_center_braced_ind",

  where = "diagonal",

  tex_WOODMET2 = "GRAY7",
  tex_METAL = "SHAWN2",
  flat_CEIL5_2 = "FLAT19",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_center_braced_hell_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP17",

  group = "gtd_generic_artsy_center_braced_hell",

  where = "diagonal",

  z_fit = "top",
}

PREFABS.Wall_generic_artsy_step1_banded_diagonal =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP18",

  group = "gtd_generic_artsy_step1_banded",

  where = "diagonal",

  z_fit = "top",
}

--

PREFABS.Wall_generic_artsy_slope_y_inset =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP09",

  engine = "zdoom",
  rank = 2,

  group = "gtd_generic_artsy_slope_y_inset"
}

PREFABS.Wall_generic_artsy_slope_y_inset_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP19",

  engine = "zdoom",
  rank = 2,

  group = "gtd_generic_artsy_slope_y_inset",

  where = "diagonal"
}

-- LIMIT-SAFE:

PREFABS.Wall_generic_artsy_slope_y_inset_limit =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP09",

  engine = "!zdoom",

  group = "gtd_generic_artsy_slope_y_inset",

  line_342 = 0
}

PREFABS.Wall_generic_artsy_slope_y_inset_diag_limit =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP19",

  engine = "!zdoom",

  group = "gtd_generic_artsy_slope_y_inset",

  where = "diagonal",

  line_342 = 0
}

--

PREFABS.Wall_generic_artsy_base_braced =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP10",

  group = "gtd_generic_artsy_base_braced",

  theme = "tech",

  z_fit = { 32,64 },

  tex_METAL = "SHAWN2",
  tex_CEIL5_2 = "FLAT23"
}

PREFABS.Wall_generic_artsy_base_braced_gothic =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP10",

  group = "gtd_generic_artsy_base_braced",

  z_fit = { 32,64 },

  theme = "!tech",
}

PREFABS.Wall_generic_artsy_base_braced_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP20",

  group = "gtd_generic_artsy_base_braced",

  theme = "tech",

  where = "diagonal",

  z_fit = { 32,64 },

  tex_METAL = "SHAWN2",
  tex_CEIL5_2 = "FLAT23",
}

PREFABS.Wall_generic_artsy_base_braced_gothic_diag =
{
  template = "Wall_generic_artsy_bedazzled",
  map = "MAP20",

  group = "gtd_generic_artsy_base_braced",

  theme = "!tech",

  where = "diagonal",

  z_fit = { 32,64 },
}

--
