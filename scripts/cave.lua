------------------------------------------------------------------------
--  CAVES and MAZES
------------------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2009-2017 Andrew Apted
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
------------------------------------------------------------------------


--class CELL_INFO
--[[
    W, H  -- size (# of cells)

    x1, y1, x2, y2  -- bounding coords

    sx1, sy1, sx2, sy2  -- seed range


    area : AREA   -- link back to normal area

    walk_chunks : list(CHUNK)  -- all places the player MUST be able
                               -- walk to (conns, goals, etc...)

    map : AUTOMATA  -- marks which parts are usable:
                    --    nil : never touched (e.g. other rooms)
                    --    -1  : forced off [ empty ]
                    --    +1  : forced on  [ wall ]
                    --     0  : normal processing

    diagonals : array   -- marks which cells are on a diagonal seed
                        -- (using the numbers 1/3/7/9)

    blocks : array(CAVE_AREA)  -- info for each 64x64 block
                               -- [ used for the final rendering of cells ]


    --- Cave specific fields ---

    cave : AUTOMATA   -- the raw generated cave

    step_mode   : keyword  -- "walkway", "up", "down", "mixed"

    liquid_mode : keyword  -- "none", "some", "lake"

    sky_mode    : keyword  -- "none"
                           -- "some" (indoor rooms only)
                           -- "low_wall", "high_wall"  (outdoor rooms)

    torch_mode  : keyword  -- "none", "few", "some"

    floors : list(CAVE_AREA)
    lakes  : list(CAVE_AREA)

    wall   : CAVE_AREA
    fence  : CAVE_AREA
--]]


--class CAVE_AREA
--[[
    --
    -- This info describes a group of cells.
    --

    cx1, cy1, cx2, cy2   -- cell bounding box

    floor_h    -- floor height
    floor_mat  -- floor material

    ceil_h     -- ceiling height
    ceil_mat   -- ceiling material

    is_wall   : boolean  -- true for solid walls
    is_fence  : boolean  -- true for a lake fence
    is_liquid : boolean  -- true for a liquid floor
    is_sky    : boolean  -- true for a sky ceiling

    is_waterfall : boolean

    goal_type : keyword      -- set if area contains a goal

    neighbors : list(CAVE_AREA)  -- only used for visitable floors

    host_spots : list(BBOX)  -- spots which can host a torch/prefab

    -- stuff for walkways only
    children : list[CAVE_AREA]
--]]


CELL_CORNERS = { 1,3,9,7 }


function Cave_brush(info, x, y)
  local bx = info.x1 + (x - 1) * 64
  local by = info.y1 + (y - 1) * 64

  local coords = {}

  local diag_map = info.diagonals

  each side in CELL_CORNERS do
    -- create a triangle when cell straddles a diagonal seed
    if diag_map[x][y] == 10 - side then continue end

    local dx, dy = geom.delta(side)

    local fx = bx + sel(dx < 0, 0, 64)
    local fy = by + sel(dy < 0, 0, 64)

    local cx =  x + sel(dx < 0, 0, 1)
    local cy =  y + sel(dy < 0, 0, 1)

    fx = fx + (info.delta_x_map[cx][cy] or 0)
    fy = fy + (info.delta_y_map[cx][cy] or 0)

    table.insert(coords, { x=fx, y=fy })
  end

  return coords
end



function Cave_is_edge(S, dir)
  local N = S:raw_neighbor(dir)

  if not N then return true end

  if N.room != S.room then return true end

  -- check for dead closets
  if N.area and N.area.mode == "void" then return true end

  -- edge of a closet?
  if N.chunk and N.chunk.kind == "closet" then
    return dir != (10 - N.chunk.from_dir)
  end

  -- edge of a joiner?
  if N.chunk and N.chunk == "joiner" then
    if dir == (10 - N.chunk.from_dir) then return false end
    if dir == (10 - N.chunk.dest_dir) then return false end
    return true
  end

  return false
end



function Cave_setup_info(R, area)
  -- R can be NIL (for scenic areas outside of map)

  local info =
  {
    lakes  = {}
    lights = {}
  }

  -- find the area to use
  if not area then
    each A in R.areas do
      if A.mode == "nature" then
        assert(info.area == nil)
        area = A
      end
    end

    assert(area)
  end

  info.area  = area
  area.cells = info

  -- determine extent of cells
  info.sx1, info.sy1, info.sx2, info.sy2 = area:calc_seed_bbox()

  info.W = 2 * (info.sx2 - info.sx1 + 1)
  info.H = 2 * (info.sy2 - info.sy1 + 1)

  info.x1 = SEEDS[info.sx1][info.sy1].x1
  info.y1 = SEEDS[info.sx1][info.sy1].y1

  info.x2 = SEEDS[info.sx2][info.sy2].x2
  info.y2 = SEEDS[info.sx2][info.sy2].y2

--stderrf("setup_info %d x %d : %s\n", info.W, info.H, area.name)

  info.map = AUTOMATA_CLASS.new(info.W, info.H)

  info.diagonals = table.array_2D(info.W, info.H)
  info.blocks    = table.array_2D(info.W, info.H)

  info.floors = {}

  local WALL_AREA =
  {
    is_wall = true
  }

  info.wall = WALL_AREA

  return info
end



function Cave_collect_walk_chunks(R, info)

  local function cave_box_for_seed(sx, sy)
    local box =
    {
      cx1 = (sx - R.sx1) * 2 + 1
      cy1 = (sy - R.sy1) * 2 + 1
    }

    box.cx2 = box.cx1 + 1
    box.cy2 = box.cy1 + 1

    return box
  end


  local function cave_box_for_chunk(chunk)
    chunk.cx1 = (chunk.sx1 - info.sx1) * 2 + 1
    chunk.cy1 = (chunk.sy1 - info.sy1) * 2 + 1

    chunk.cx2 = chunk.cx1 + chunk.sw * 2 - 1
    chunk.cy2 = chunk.cy1 + chunk.sh * 2 - 1
  end


  local function walk_for_edge(E)
    local sx1 = E.S.sx
    local sy1 = E.S.sy

    local sx2 = sx1
    local sy2 = sy1

    if E.long > 1 then
      local along_dir = geom.RIGHT[E.dir]
      sx2, sy2 = geom.nudge(sx1, sy1, along_dir, E.long - 1)
--[[
stderrf("EDGE : %s dir=%d ---> along:%d (%d %d) .. (%d %d)\n",
E.S.name, E.dir, along_dir, sx1,sy1, sx2,sy2)
--]]
    end

    if sx2 < sx1 then sx1, sx2 = sx2, sx1 end
    if sy2 < sy1 then sy1, sy2 = sy2, sy1 end

    local WC = Chunk_new("cave_walk", sx1, sy1, sx2, sy2)

    cave_box_for_chunk(WC)

--[[
if E.long > 1 then
stderrf("ROOM @ (%d %d)\n", info.sx1, info.sy1)
stderrf("-----> cells (%d %d) .. (%d %d)\n", WC.cx1, WC.cy1, WC.cx2, WC.cy2)
end
assert(map:valid_cell(WC.cx1, WC.cy1))
assert(map:valid_cell(WC.cx2, WC.cy2))
--]]

    table.insert(info.walk_chunks, WC)

    return WC
  end


  local function walk_for_connection(C)
    -- teleporters will be handled elsewhere (e.g. as a floor_chunk)
    if C.kind == "teleporter" then return end

    local E = C:edge_for_room(R)
    assert(E)

--[[
if C.kind == "joiner" then
stderrf("Joiner walk in %s.....\n", R.name)
stderrf("   conn  : %s --> %s\n", C.R1.name, C.R2.name)
stderrf("   edge1 : %s dir:%d\n", C.E1.S.name, C.E1.dir)
stderrf("   edge2 : %s dir:%d\n", C.E2.S.name, C.E2.dir)
end
--]]

    WC = walk_for_edge(E)

    WC.walk_kind = "conn"
    WC.walk_conn = C
  end


  local function walk_for_floor_chunk(chunk)
    -- ignore unused floor chunks
    if not chunk.content_kind then return end

    cave_box_for_chunk(chunk)

    chunk.walk_kind = "floor"

    if chunk.sw >= 2 and chunk.sh >= 2 then
      chunk.walk_shrinkage = 2
    end

    table.insert(info.walk_chunks, chunk)
  end


  local function walk_for_closet(chunk)
    -- ignore unused closets
    if not chunk.content_kind then return end
    if chunk.content_kind == "void" then return end

    local E = assert(chunk.edges[1])

    local WC = walk_for_edge(E)

    WC.walk_kind   = "closet"
    WC.walk_closet = chunk
  end


  local function walk_chunks_to_points()
    info.point_list = {}

    each chunk in info.walk_chunks do
      assert(chunk.cx1)

      local POINT =
      {
        x = math.i_mid(chunk.cx1, chunk.cx2)
        y = math.i_mid(chunk.cy1, chunk.cy2)
      }

      table.insert(info.point_list, POINT)
    end

    assert(#info.point_list > 0)
  end


  ---| Cave_collect_walk_chunks |---

  info.walk_chunks = {}

  each C in R.conns do
    walk_for_connection(C)
  end

  each chunk in R.floor_chunks do
    walk_for_floor_chunk(chunk)
  end

  each chunk in R.closets do
    walk_for_closet(chunk)
  end

  walk_chunks_to_points()
end



function Cave_map_usable_area(info)

  local cells = info.map.cells

  local bbox = {}


  local function cell_within_triangle(diag_mode, dx, dy)
    if diag_mode == 1 then return not (dx == 1 and dy == 1) end
    if diag_mode == 3 then return not (dx == 0 and dy == 1) end
    if diag_mode == 7 then return not (dx == 1 and dy == 0) end
    if diag_mode == 9 then return not (dx == 0 and dy == 0) end

    error("bad diag_mode")
  end


  local function cell_touches_diagonal(diag_mode, dx, dy)
    local val = dx * 10 + dy

    if diag_mode == 1 or diag_mode == 9 then
      return (val == 1) or (val == 10)
    else
      return (val == 0) or (val == 11)
    end
  end


  local function visit_seed(S, sx, sy)
    local cx1 = (S.sx - info.sx1) * 2 + 1
    local cy1 = (S.sy - info.sy1) * 2 + 1
    local cx2 = cx1 + 1
    local cy2 = cy1 + 1

    bbox.cx1 = math.min(bbox.cx1 or  9999, cx1)
    bbox.cy1 = math.min(bbox.cy1 or  9999, cy1)
    bbox.cx2 = math.max(bbox.cx2 or -9999, cx2)
    bbox.cy2 = math.max(bbox.cy2 or -9999, cy2)

    -- update diagonal grid for cave
    local diag_mode

    if S.diagonal then
      diag_mode = S.diagonal

      if S.area != info.area then
        diag_mode = 10 - diag_mode
      end
    end

    for dx = 0, 1 do
    for dy = 0, 1 do
      local cx = cx1 + dx
      local cy = cy1 + dy

      if (diag_mode == nil) or cell_within_triangle(diag_mode, dx, dy) then
        cells[cx][cy] = 0
      end

      if diag_mode and cell_touches_diagonal(diag_mode, dx, dy) then
        info.diagonals[cx][cy] = diag_mode
      end
    end -- cx, cy
    end
  end


  ---| Cave_map_usable_area |---

  for sx = info.sx1, info.sx2 do
  for sy = info.sy1, info.sy2 do
    local S = SEEDS[sx][sy]

    -- this ignores different rooms, AND closets and joiners too
    if S.area == info.area or
       (S.top and S.top.area == info.area)
    then
      visit_seed(S, sx, sy)
    end
  end -- sx, sy
  end
end



function Cave_clear_walk_chunks(info)
  each chunk in info.walk_chunks do
    assert(chunk.cx1)

    info.map:fill(chunk.cx1, chunk.cy1, chunk.cx2, chunk.cy2, -1)
  end
end



function Cave_generate_cave(R, info)

  local is_lake = (info.liquid_mode == "lake")

  -- this contains where walls and must-be-clear spots are
  local map = info.map

  -- this is the generated 2d cave
  local cave


  local function set_whole(S, value)
    local cx = (S.sx - info.sx1) * 2 + 1
    local cy = (S.sy - info.sy1) * 2 + 1

    map:fill(cx, cy, cx+1, cy+1, value)
  end


  local function set_side(S, side, value)
    local cx = (S.sx - info.sx1) * 2 + 1
    local cy = (S.sy - info.sy1) * 2 + 1

    local x1,y1, x2,y2 = geom.side_coords(side, cx,cy, cx+1,cy+1)

    map:fill(x1, y1, x2, y2, value)
  end


  local function set_corner(S, side, value)
    local cx = (S.sx - info.sx1) * 2 + 1
    local cy = (S.sy - info.sy1) * 2 + 1

    local nx, ny = geom.pick_corner(side, cx, cy, cx+1, cy+1)

    map:set(nx, ny, value)
  end


  local function mark_boundaries()
    -- this also sets most parts of the cave to zero
    -- [ zero means "can make cave here" ]

    for sx = info.sx1, info.sx2 do
    for sy = info.sy1, info.sy2 do
      local S = SEEDS[sx][sy]

      -- this ignores different rooms, AND closets and joiners too
      if S.area != info.area then continue end

      for dir = 2,8,2 do
        if Cave_is_edge(S, dir) then
          set_side(S, dir, sel(is_lake, -1, 1))
        end

        -- in lake mode, clear whole seeds that touch edge of map
        -- (i.e. which will have a sky border next to them)
        if is_lake and S:need_lake_fence(dir) then
          set_whole(S, -1)
        end
      end

      each dir in geom.CORNERS do
        if Cave_is_edge(S, dir) then
          -- lakes require whole seed to be cleared (esp. at "innie corners")
          if is_lake then
            set_whole(S, -1)
          else
            set_corner(S, dir, 1)
          end
        end
      end

    end -- sx, sy
    end
  end


  local function check_need_wall(S, dir)
    -- don't clobber connections

    local N = S:neighbor(dir)

    if not (N and N.room) then return true end

    if N.room == R then return false end

    return true
  end


  local function add_needed_cave_walls(S)
    -- a seed has been cleared, but it may need a wall or fence on
    -- one of the sides...

    for dir = 2,8,2 do
      if check_need_wall(S, dir) then
        -- merely mark it here, handled by border_up()
--FIXME        S.border[dir].cave_gap = true
      end
    end
  end


  local function is_fully_interior(S)
    each dir in geom.ALL_DIRS do
      if Cave_is_edge(S, dir) then return false end
    end

    return true
  end


  local function clear_some_seeds()
    for sx = info.sx1, info.sx2 do
    for sy = info.sy1, info.sy2 do
      local S = SEEDS[sx][sy]

      if S.area != info.area then continue end

      if rand.odds(10) and is_fully_interior(S) then
        set_whole(S, -1)
      end
    end
    end
  end


  local function is_cave_good(cave)
    -- check that all important parts are connected

    if not cave:validate_conns(info.point_list) then
      gui.debugf("cave failed connection check\n")
      return false
    end

    local p1 = info.point_list[1]

    cave.empty_id = cave.flood[p1.x][p1.y]

    assert(cave.empty_id)
    assert(cave.empty_id < 0)

    if not cave:validate_size(cave.empty_id) then
      gui.debugf("cave failed size check\n")
      return false
    end

    return true
  end


  local function generate_cave()
    map:dump(R.name .. " Empty Cave:")

    local solid_prob = 38

    if is_lake then
      solid_prob = 58
    end

    local MAX_LOOP = 20

    for loop = 1,MAX_LOOP do
      gui.debugf("Trying to make a cave: loop %d\n", loop)

      cave = map:copy()

      if loop >= MAX_LOOP then
        gui.printf("Failed to generate a usable cave! (%s)\n", R.name)

        -- emergency fallback
        cave:gen_empty()

        cave:flood_fill()

        is_cave_good(cave)  -- set empty_id
        break
      end

      cave:generate(solid_prob)

      cave:dump("Generated Cave:")

      cave:remove_dots()
      cave:flood_fill()

      if is_cave_good(cave) then
        break;
      end

      -- randomly clear some seeds in the room.
      -- After each iteration the number of cleared cells will keep
      -- increasing, making it more likely to generate a valid cave.
      clear_some_seeds()
    end

    info.cave = cave

    if not is_lake then
      cave:solidify_pockets()
    end

    cave:dump("Filled Cave:")

    cave:find_islands()
  end


  ---| Cave_generate_cave |---

  mark_boundaries()

  Cave_clear_walk_chunks(info)

  generate_cave()
end



function Cave_area_host_parts(R, A)
  --|
  --| figure out if this area can host something inside it
  --| (e.g. a torch or a cage prefab).
  --|
  --| stores a list of cell ranges in 'host_spots' field.
  --|

  local info = R.cave_info

  A.host_spots = {}

  -- TODO
end



function Cave_create_areas(R, info)
  --|
  --| sub-divide the floor of the cave into areas of differing heights.
  --|

  local cave = info.cave

  local is_lake = (info.liquid_mode == "lake")

  -- groups are areas (rectangles) belonging to portals or importants
  -- and must be kept distinct (at the same height).
  local group_list
  local group_map


  local function install_area(A, template, mul, empty_ok)
    for cx = 1, info.W do
    for cy = 1, info.H do
      if ((template:get(cx, cy) or 0) * mul) > 0 then
        info.blocks[cx][cy] = A

        A.cx1 = math.min(A.cx1 or  9999, cx)
        A.cy1 = math.min(A.cy1 or  9999, cy)

        A.cx2 = math.max(A.cx2 or -9999, cx)
        A.cy2 = math.max(A.cy2 or -9999, cy)
      end
    end
    end

    if not A.cx1 and not empty_ok then
      error("Cave install_area: no cells!")
    end
  end


  local function copy_cave_without_fences()
    local new_cave = info.cave:copy()

    if info.fence then
      for cx = 1, info.W do
      for cy = 1, info.H do
        local A = info.blocks[cx][cy]

        if A and A.is_fence then
          new_cave:set(cx, cy, nil)
        end
      end
      end
    end

    return new_cave
  end


  local function apply_walk_chunks(map)
    each chunk in info.walk_chunks do
      local cx1, cy1 = chunk.cx1, chunk.cy1
      local cx2, cy2 = chunk.cx2, chunk.cy2

      if chunk.walk_shrinkage == 2 then
        map:fill(cx1 + 1, cy1 + 1, cx2 - 1, cy2 - 1, 1)
      else
        map:fill(cx1, cy1, cx2, cy2, 1)
      end
    end
  end


  local function compute_floor_sinks(SINK1, SINK2, R, AREA)
    -- sometimes make sink1 be liquid but sink2 be solid
    if info.liquid_mode == "some" and rand.odds(25) then
      SINK1.floor_dz  = -12
      SINK1.is_liquid = true

      SINK2.floor_dz  = -4
      SINK2.floor_mat = AREA.floor_mat
      return
    end

    -- sometimes make a completely liquid floor [ if non-damaging ]
    if info.liquid_mode == "heaps" and not LEVEL.liquid.damage and rand.odds(25) then
       AREA.is_liquid = true
      SINK1.is_liquid = true
      SINK2.is_liquid = true

      SINK1.floor_dz = 0
      SINK2.floor_dz = 0

      -- occasionally some islands
      if rand.odds(30) then
        SINK2.is_liquid = nil
        SINK2.floor_mat = R.floor_mat
        SINK2.floor_dz  = 8
      end

      return
    end


    SINK1.floor_dz  = -8
    SINK1.floor_mat = R.alt_floor_mat

    if info.liquid_mode == "heaps" then
      SINK1.is_liquid = true
    end

    -- when no liquid, often make a larger area of the alternate floor
    if info.liquid_mode == "none" and rand.odds(50) then
      SINK2.floor_dz  = SINK1.floor_dz
      SINK2.floor_mat = SINK1.floor_mat
      return
    end


    SINK2.floor_dz  = -16
    SINK2.floor_mat = AREA.floor_mat

    if info.liquid_mode != "none" then
      SINK2.is_liquid = true
    end

    -- when both sinks are liquid, synchronise floor heights
    if SINK1.is_liquid and SINK2.is_liquid then
      SINK1.floor_dz = -12
      SINK2.floor_dz = SINK1.floor_dz
    end
  end


  local function compute_ceiling_sinks(SINK1, SINK2, R, AREA)
    local bump1 = rand.pick({ 48,64,80,96 })
    local bump2 = rand.pick({ 48,64,80,96 })

    SINK1.ceil_dz  = bump1
    SINK2.ceil_dz  = bump1 + bump2

    SINK1.ceil_mat = R.alt_ceil_mat
    SINK2.ceil_mat = R.ceil_mat

    if rand.odds(10) then
      SINK1.ceil_mat, SINK2.ceil_mat = SINK2.ceil_mat, SINK1.ceil_mat
    end

    if info.sky_mode == "heaps" then
      SINK1.is_sky = true
    end

    if info.sky_mode != "none" then
      SINK2.is_sky = true

      -- no big need to synchronise skies (as per liquids)
    end
  end


  local function make_walkway()
    --
    -- We have one main area, always walkable.
    -- The indentation / liquid / sky bits are considered to be
    -- modifications of the main area.
    --

    assert(info.liquid_mode != "lake")

    local AREA =
    {
      neighbors = {}
      children  = {}

      floor_mat = R.floor_mat
       ceil_mat = R.ceil_mat
    }

    table.insert(info.floors, AREA)

    each WC in info.walk_chunks do
      WC.cave_area = AREA
    end

    install_area(AREA, cave, -1)

    -- this fixes MON_TELEPORT spots [ so they blend in ]
    info.area.floor_mat = AREA.floor_mat
    info.area.ceil_mat  = AREA.ceil_mat


    -- compute properties of each sink
    local SINK1 = {}
    local SINK2 = {}

    compute_floor_sinks  (SINK1, SINK2, R, AREA)
    compute_ceiling_sinks(SINK1, SINK2, R, AREA)


    -- actually install the sinks...
    local walk_way = copy_cave_without_fences()

    apply_walk_chunks(walk_way)

    walk_way:negate()
    walk_way:shrink8(true)
    walk_way:remove_dots()

    install_area(SINK1, walk_way, 1, "empty_ok")

    table.insert(AREA.children, SINK1)

    -- shrink the walkway further
    walk_way:shrink8(true)
    walk_way:remove_dots()

    install_area(SINK2, walk_way, 1, "empty_ok")

    table.insert(AREA.children, SINK2)
  end


  local function add_group_to_map(G)
    table.insert(group_list, G)

    for x = G.cx1, G.cx2 do
    for y = G.cy1, G.cy2 do
      group_map.cells[x][y] = G
    end
    end
  end


  local function remove_group_from_map(G)
    table.kill_elem(group_list, G)

    for x = G.cx1, G.cx2 do
    for y = G.cy1, G.cy2 do
      group_map.cells[x][y] = nil
    end
    end
  end


  local function create_group_map()
    group_list = {}

    group_map = AUTOMATA_CLASS.blank_copy(info.cave)

---##  each G in R.cave_imps do
---##    add_group_to_map(G)
---##  end
  end


  local function grow_step_areas()

    local pos_list = { }

    pos_list[1] =
    {
      x = info.point_list[1].x
      y = info.point_list[1].y
    }


    local free  = copy_cave_without_fences()
    local f_cel = free.cells

    local step
    local s_cel
    local size

    local cw = free.w
    local ch = free.h

    -- current bbox : big speed up by limiting the scan area
    local cx1, cy1
    local cx2, cy2

    local touched_groups


    -- mark free areas with zero instead of negative
    for fx = 1, cw do
    for fy = 1, ch do
      if (f_cel[fx][fy] or 0) < 0 then
        f_cel[fx][fy] = 0
      end
    end
    end


    local function touch_a_group(G)
      remove_group_from_map(G)

      table.insert(touched_groups, G)

      -- add the whole group to the current step
      for x = G.cx1, G.cx2 do
      for y = G.cy1, G.cy2 do
        s_cel[x][y] = 1
        f_cel[x][y] = 1

        size = size + 1
      end
      end

      -- update bbox
      cx1 = math.min(cx1, G.cx1)
      cy1 = math.min(cy1, G.cy1)

      cx2 = math.max(cx2, G.cx2)
      cy2 = math.max(cy2, G.cy2)
    end


    local function grow_add(x, y)
      s_cel[x][y] = 1
      f_cel[x][y] = 1

      size = size + 1

      -- update bbox
      if x < cx1 then cx1 = x end
      if x > cx2 then cx2 = x end

      if y < cy1 then cy1 = y end
      if y > cy2 then cy2 = y end

      if group_map.cells[x][y] then
        touch_a_group(group_map.cells[x][y])
      end
    end


    local function grow_horiz(y, prob)
      for x = cx1, cx2 do
        if x > 1 and s_cel[x][y] == 1 and s_cel[x-1][y] == 0 and f_cel[x-1][y] == 0 and rand.odds(prob) then
          grow_add(x-1, y)
        end
      end

      for x = cx2, cx1, -1 do
        if x < cw and s_cel[x][y] == 1 and s_cel[x+1][y] == 0 and f_cel[x+1][y] == 0 and rand.odds(prob) then
          grow_add(x+1, y)
        end
      end
    end


    local function grow_vert(x, prob)
      for y = cy1, cy2 do
        if y > 1 and s_cel[x][y] == 1 and s_cel[x][y-1] == 0 and f_cel[x][y-1] == 0 and rand.odds(prob) then
          grow_add(x, y-1)
        end
      end

      for y = cy2, cy1, -1 do
        if y < ch and s_cel[x][y] == 1 and s_cel[x][y+1] == 0 and f_cel[x][y+1] == 0 and rand.odds(prob) then
          grow_add(x, y+1)
        end
      end
    end


    local function grow_it(prob)
      for y = cy1, cy2 do
        grow_horiz(y, prob)
      end

      for x = cx1, cx2 do
        grow_vert(x, prob)
      end
    end


    local function grow_an_area(cx, cy, prev_A)

-- free:dump("Free:")

      step  = AUTOMATA_CLASS.blank_copy(free)
      s_cel = step.cells

      step:set_all(0)

      size = 0

      touched_groups = {}

      cx1 = cx ; cx2 = cx
      cy1 = cy ; cy2 = cy

      -- set initial point
      grow_add(cx, cy)

      local count = rand.pick { 3, 4, 5 }

      grow_it(100)

      for loop = 1, count do
        grow_it(50)
      end

      if size < 4 or #touched_groups > 0 then
        grow_it(100)
        grow_it(40)
      end

step:dump("Step:")

      -- when the step is too small, merge it into previous area
      if size < 4 and prev_A then

        install_area(prev_A, step, 1)

      else
        local AREA =
        {
          neighbors = {}
        }

        table.insert(info.floors, AREA)

        install_area(AREA, step, 1)

        prev_A = AREA
      end


      -- remember area of covered groups (e.g. for outgoing heights)
      each G in touched_groups do
        G.area = prev_A

        if G.portal then
          prev_A.goal_type = "portal"
        else
          prev_A.goal_type = "important"
        end
      end


      -- find new positions for growth

      for x = cx1, cx2 do
      for y = cy1, cy2 do
        if s_cel[x][y] != 1 then continue end

        for dir = 2,8,2 do
          local nx, ny = geom.nudge(x, y, dir)
          if free:valid_cell(nx, ny) and f_cel[nx][ny] == 0 then
            table.insert(pos_list, { x=nx, y=ny, prev=prev_A })
          end
        end
      end -- x, y
      end
    end


    --| grow_step_areas |--

    while #pos_list > 0 do
      local pos = table.remove(pos_list, rand.irange(1, #pos_list))

      -- ignore out-of-date positions
      if f_cel[pos.x][pos.y] != 0 then continue end

      grow_an_area(pos.x, pos.y, pos.prev)
    end
  end


  local function determine_touching_areas()
    local W = info.W
    local H = info.H

    for x = 1, W do
    for y = 1, H do
      local A1 = info.blocks[x][y]

      if not (A1 and A1.neighbors) then continue end

      for dir = 2,4,2 do
        local nx, ny = geom.nudge(x, y, dir)

        if not cave:valid_cell(nx, ny) then continue end

        local A2 = info.blocks[nx][ny]

        if not (A2 and A2.neighbors) then continue end

        if A2 != A1 then
          table.add_unique(A1.neighbors, A2)
          table.add_unique(A2.neighbors, A1)
        end
      end
    end  -- x, y
    end

    -- verify all areas touch at least one other
    if #info.floors > 1 then
      each A in info.floors do
        assert(not table.empty(A.neighbors))
      end
    end
  end


  local function set_walls()
    assert(info.wall)

    for x = 1, info.W do
    for y = 1, info.H do
      local val = cave:get(x, y)

      if (val or 0) > 0 then
        info.blocks[x][y] = info.wall
      end
    end
    end
  end


  ---| Cave_create_areas |---

  if info.step_mode == "walkway" then
    make_walkway()
  else
    create_group_map()

    grow_step_areas()

    if #group_list > 0 then
      error("Cave steps failed to cover all important chunks\n")
    end
  end

  determine_touching_areas()

  if not is_lake then
    set_walls()
  end
end



function Cave_bunch_areas(R, mode)
  --|
  --| this picks a bunch of step areas which will become either liquid
  --| or sky (depending on 'mode' parameter).
  --|

  local info = R.cave_info


  local function setup()
    each A in info.floors do
      if A.goal_type then A.near_bunch = 0 end
    end
  end


  local function pick_start_area()
    local poss = {}

    each A in info.floors do
      if not A.near_bunch then
        table.insert(poss, A)
      end
    end

    if table.empty(poss) then return nil end

    return rand.pick(poss)
  end


  local function touches_the_list(N, list, except)
    each N2 in N.neighbors do
      if list[N2] and N2 != except then
        return true
      end
    end

    return false
  end


  local function grow_bunch(list)
    local poss = {}

    each A,_ in list do
      each N in A.neighbors do
        if list[N] then continue end
        if N.near_bunch then continue end

        if touches_the_list(N, list, A) then continue end

        table.insert(poss, N)
      end
    end

    if table.empty(poss) then return false end

    local A2 = rand.pick(poss)

    list[A2] = 1

    return true
  end


  local function install_bunch(list)
    local head_A

    each A,_ in list do
      if not head_A then head_A = A end

      if mode == "sky"    then A.sky_bunch    = head_A ; A.is_sky    = true end
      if mode == "liquid" then A.liquid_bunch = head_A ; A.is_liquid = true end

      A.near_bunch = 0

      each N in A.neighbors do
        if not N.near_bunch or N.near_bunch > 1 then
          N.near_bunch = 1
        end
      end
    end

    -- extra health to compensate player for crossing the river
    if mode == "liquid" and LEVEL.liquid.damage then
      R.hazard_health = R.hazard_health + 20
    end
  end


  local function clear()
    each A in info.floors do
      A.near_bunch = nil
    end
  end


  ---| Cave_bunch_areas |---

  if info.step_mode == "walkway" then return end
  if info.liquid_mode == "lake"  then return end

  if mode == "sky"    and info.sky_mode    != "some" then return end
  if mode == "liquid" and info.liquid_mode != "some" then return end

  setup()

  local try_count = int(#info.floors / rand.sel(50, 8, 14))

  for i = 1, try_count do
    local A1 = pick_start_area()

    if not A1 then break; end  -- nothing is possible

    local list = { [A1] = 1 }

    while grow_bunch(list) and rand.odds(64) do
      -- keep growing...
    end

    if table.size(list) >= 2 then
      install_bunch(list)
    end
  end

  clear()
end



function Cave_heights_near_area(R, A)
  local info = R.cave_info
  local cave = info.cave

  local min_floor_h =  9e9
  local max_floor_h = -9e9

  local min_ceil_h =  9e9
  local max_ceil_h = -9e9

  for x = 1, info.W do
  for y = 1, info.H do
    for dir = 2,4 do
      local nx, ny = geom.nudge(x, y, dir)

      if not cave:valid_cell(nx, ny) then continue end

      local A1 = info.blocks[x][y]
      local A2 = info.blocks[nx][ny]

      if (A2 == A) then
        A1, A2 = A2, A1
      end

      if not A2 or (A1 != A) or (A2 == A) then continue end

      if A2.floor_h then
        min_floor_h = math.min(min_floor_h, A2.floor_h)
        max_floor_h = math.max(max_floor_h, A2.floor_h)
      end

      if A2.ceil_h then
        min_ceil_h = math.min(min_ceil_h, A2.ceil_h)
        max_ceil_h = math.max(max_ceil_h, A2.ceil_h)
      end
    end
  end -- x, y
  end

  if min_floor_h > max_floor_h then
    min_floor_h = nil
    max_floor_h = nil
  end

  if min_ceil_h > max_ceil_h then
    min_ceil_h = nil
    max_ceil_h = nil
  end

  return min_floor_h, max_floor_h,
         min_ceil_h,  max_ceil_h
end



function Cave_floor_heights(R, entry_h)
  assert(entry_h)

  local info = R.cave_info


  local z_change_prob = rand.sel(15, 40, 10)

  if info.step_mode == "up" or info.step_mode == "down" then
    z_change_prob = 0
  end


  local function floor_for_river(bunch_A, h)
    assert(not bunch_A.floor_h)

    local diff_h = 16

    -- determine minimum of all areas touching the river
    each A in info.floors do
      if A.liquid_bunch != bunch_A then continue end

      each N in A.neighbors do
        if N.liquid_bunch then continue end

        if N.floor_h then
          h = math.min(h, N.floor_h - diff_h)
        end
      end
    end

    each A in info.floors do
      if A.liquid_bunch == bunch_A then
        A.floor_h = h
      end
    end

    return h
  end


  local function spread_river_banks(bunch_A, h)
    --| ensure all areas touching the river get a floor height now
    --| (to prevent those areas becoming lower than the river).

    each A in info.floors do
      if A.liquid_bunch != bunch_A then continue end

      each N in A.neighbors do
        if N.liquid_bunch then continue end

        if not N.floor_h then
          N.floor_h = h + rand.pick({8, 16, 24})
        end
      end
    end
  end


  local function visit_area(A, z_dir, h)
    --|
    --| recursively spread floors heights into each area
    --|

    assert(not A.visited)
    A.visited = true

    if rand.odds(z_change_prob) then
      z_dir = - z_dir
    end


    -- floor --

    if A.floor_h then
      h = A.floor_h
    elseif A.liquid_bunch then
      h = floor_for_river(A.liquid_bunch, h)
    else
      A.floor_h = h
    end


    if A.liquid_bunch then
      spread_river_banks(A.liquid_bunch, h)
    end


    -- ceiling --

    if R.is_outdoor and false then  --!!!!!!
      -- no ceil_h (done later using sky_rects)
    elseif A.goal_type then
      A.ceil_h = h + 192
    else
      A.ceil_h = h + R.walkway_height
    end


    rand.shuffle(A.neighbors)

    each N in A.neighbors do
      if not N.visited then
        local new_h = h + z_dir * rand.sel(35, 8, 16)
        visit_area(N, z_dir, new_h)
      end
    end
  end


  local function find_entry_area()
--[[ FIXME
    each imp in R.cave_imps do
      assert(imp.area)
      if imp.conn and imp.conn.conn_h then
        return imp.area
      end
    end
--]]

    return rand.pick(info.floors)
  end


  local function transfer_heights()
    -- transfer heights to importants and portals
    -- FIXME
    each imp in R.cave_imps do
      assert(imp.area)
      assert(imp.area.floor_h)

      local G = imp.goal
      local C = imp.conn

      if G then
        G.z1 = imp.area.floor_h
        G.z2 = G.z1 + 160

        G.S.floor_h = G.z1
      end

      if C then
        local S = C:get_seed(R)
        S.floor_h = imp.area.floor_h

        if not C.conn_h then
          C.conn_h  = imp.area.floor_h
        end
      end
    end
  end


  local function update_min_max_floor()
    R.floor_min_h = entry_h
    R.floor_max_h = entry_h

    each A in info.floors do
      R.floor_min_h = math.min(R.floor_min_h, A.floor_h)
      R.floor_max_h = math.max(R.floor_max_h, A.floor_h)
    end
  end


  local function update_walk_ways()
    each A in info.floors do
      if not A.children then continue end

      each SINK in A.children do
        SINK.floor_h = A.floor_h + SINK.floor_dz

        if A.ceil_h then
          SINK.ceil_h = A.ceil_h + SINK.ceil_dz
        end
      end
    end
  end


  local function update_fences()
    if info.liquid_mode == "lake" then
      info.fence.floor_h = R.floor_max_h + 96
      info. wall.floor_h = info.fence.floor_h

      R.cave_fence_z = info.fence.floor_h

    elseif info.sky_mode == "low_wall" then
      info.wall.floor_h = R.floor_max_h + 80

      R.cave_fence_z = info.wall.floor_h

    else
      -- do not need a cave_fence_z
    end
  end


  local function update_lakes()
    for pass = 1,4 do
      each A in info.lakes do
        if not A.floor_h then

          local f_h = Cave_heights_near_area(R, A)

          if f_h then
            A.floor_h = f_h - rand.pick({ 8, 16, 24 })
          elseif pass == 4 then
            error("Lake failed to get a height")
          end

        end
      end
    end
  end


  local function ceiling_for_sky_bunch(bunch_A)
    local h = bunch_A.ceil_h or 0

    each A in info.floors do
      if A.sky_bunch != bunch_A then continue end

      each N in A.neighbors do
        if N.sky_bunch then continue end

        if N.ceil_h then
          h = math.max(h, N.ceil_h)
        end
      end
    end

    h = h + rand.pick({ 32,48,64,96 })

    each A in info.floors do
      if A.sky_bunch == bunch_A then
        A.ceil_h = h
      end
    end
  end


  local function update_sky_bunches()
    each A in info.floors do
      if A.sky_bunch == A then
        ceiling_for_sky_bunch(A)
      end
    end
  end


  ---| Cave_floor_heights |---

  local z_dir

  if info.step_mode == "up" then
    z_dir = 1
  elseif info.step_mode == "down" then
    z_dir = -1
  else
    z_dir = rand.sel(37, 1, -1)
  end

  -- TEMP RUBBISH
  info.area.floor_h = entry_h
  info.area.ceil_h  = entry_h + R.walkway_height

  local entry_area = find_entry_area()

  visit_area(entry_area, z_dir, entry_h)

--TODO : only needed for caves with varying floor heights
--       [ currently caves are always flat ]
--  transfer_heights()

  update_min_max_floor()
  update_walk_ways()
  update_fences()
  update_lakes()
  update_sky_bunches()
end



function Cave_fill_lakes(R)
  local info = R.cave_info
  local cave = info.cave


  local function add_lake(id, reg)

    -- FIXME: if reg.size < 16 then emptify_region()

    local LAKE =
    {
      is_liquid = true

      region = reg

      cx1 = reg.x1
      cy1 = reg.y1
      cx2 = reg.x2
      cy2 = reg.y2
    }

    table.insert(info.lakes, LAKE)

    for x = LAKE.cx1, LAKE.cx2 do
    for y = LAKE.cy1, LAKE.cy2 do
      if cave.flood[x][y] == id then
        info.blocks[x][y] = LAKE
      end
    end
    end
  end


  local function handle_island(id, reg)

    -- TODO: if large, keep as island and add bridge to nearby ground

    add_lake(id, reg)
  end


  ---| Cave_fill_lakes |---

  if info.liquid_mode != "lake" then return end

  -- determine region id for the main walkway
  local p1 = info.point_list[1]

  local path_id = cave.flood[p1.x][p1.y]

  each id,reg in cave.regions do
    if (id > 0) then
      add_lake(id, reg)
    end

    if (id < 0) and (id != path_id) then
      handle_island(id, reg)
    end
  end
end



function Cave_lake_fences(R)
  local info = R.cave_info

  local function install_fence_post(cx1, cy1, cx2, cy2, dir, along_dir, i, deep)
    if along_dir == 6 then
      cx1 = cx1 + (i - 1)
      cx2 = cx1
    else
      cy1 = cy1 + (i - 1)
      cy2 = cy1
    end

        if dir == 2 then cy2 = cy1 + (deep - 1)
    elseif dir == 8 then cy1 = cy2 - (deep - 1)
    elseif dir == 4 then cx2 = cx1 + (deep - 1)
    elseif dir == 6 then cx1 = cx2 - (deep - 1)
    end

    for x = cx1, cx2 do
    for y = cy1, cy2 do
      info.blocks[x][y] = info.fence
    end
    end
  end


  local function try_fence_run(S, dir)
    if not S.lake_fences then S.lake_fences = {} end

    -- already done?
    if S.lake_fences[dir] then return end

    local along_dir = geom.vert_sel(dir, 6, 8)

    local count = 1

    local S1 = S
    local S2 = S:neighbor(along_dir)

    while S2 do
      if S2.room != R then break; end

      assert(not (S2.lake_fences and S2.lake_fences[dir]))

      if not S2:need_lake_fence(dir) then break; end

      if not S2.lake_fences then S2.lake_fences = {} end

      count = count + 1

      S2 = S2:neighbor(along_dir)
    end

    --- OK, install it ---

    for i = 1, count do
      local N = S:neighbor(along_dir, i - 1)

      N.lake_fences[dir] = true  -- prevent visiting again
    end

    local S2 = S:neighbor(along_dir, count - 1)

    local cx1 = 1 + (S.sx - R.sx1) * 2
    local cy1 = 1 + (S.sy - R.sy1) * 2

    local cx2 = 1 + (S2.sx - R.sx1) * 2 + 1
    local cy2 = 1 + (S2.sy - R.sy1) * 2 + 1

    assert(cx2 > cx1 and cy2 > cy1)

    -- starting depth
    local deep = rand.sel(50, 1, 2)

    for i = 1, count * 3 do
      install_fence_post(cx1, cy1, cx2, cy2, dir, along_dir, i, deep)

      -- pick next depth
      deep = rand.sel(50, 1, 2)
    end
  end


  local function do_innie_corners()
    -- the mark boundaries logic assures that the whole seed at an
    -- "innie corner" is cleared (and walkable).  Here we ensure there
    -- is a single fence block touching that corner, to make the lake
    -- fence flow nicely around the innie corner.

    for x = R.sx1, R.sx2 do
    for y = R.sy1, R.sy2 do
      local S = SEEDS[x][y]
      if S.room != R then continue end

      cx1 = (x - R.sx1) * 2 + 1
      cy1 = (y - R.sy1) * 2 + 1

      each dir in geom.CORNERS do
        if not Cave_is_edge(S, dir) then continue end

        local A_dir = geom. LEFT_45[dir]
        local B_dir = geom.RIGHT_45[dir]

        local A = S:neighbor(A_dir)
        local B = S:neighbor(B_dir)

        if not A or (A.room != S.room) then continue end
        if not B or (B.room != S.room) then continue end

        if A:need_lake_fence(B_dir) or
           B:need_lake_fence(A_dir)
        then
          local cx, cy = geom.pick_corner(dir, cx1, cy1, cx1+1, cy1+1)
          info.blocks[cx][cy] = info.fence
        end

      end

    end -- x, y
    end
  end


  --| Cave_lake_fences |--

  if info.liquid_mode != "lake" then
    return
  end

  local FENCE =
  {
    is_fence = true

    -- floor_h
  }

  info.fence = FENCE

  for x = R.sx1, R.sx2 do
  for y = R.sy1, R.sy2 do
    local S = SEEDS[x][y]

    if S.room != R then continue end

    for dir = 2,8,2 do
      if S:need_lake_fence(dir) then
        try_fence_run(S, dir)
      end
    end

  end -- sx, sy
  end

  do_innie_corners()
end



function Cave_make_waterfalls(R)
  --| this checks if two lakes can be connected by a short run of
  --| intermediate cells.

  local info = R.cave_info
  local cave = info.cave


  local function can_still_traverse(cx, cy, dir)
    -- see if cells on each side has same floor

    local A_dir = geom.LEFT [dir]
    local B_dir = geom.RIGHT[dir]

    local ax, ay = geom.nudge(cx, cy, A_dir)
    local bx, by = geom.nudge(cx, cy, B_dir)

    if not cave:valid_cell(ax, ay) then return false end
    if not cave:valid_cell(bx, by) then return false end

    local A = info.blocks[ax][ay]
    local B = info.blocks[bx][by]

    if not A or not B then return false end

    if A.is_wall or not A.floor_h then return false end
    if B.is_wall or not B.floor_h then return false end

    return math.abs(A.floor_h - B.floor_h) < 4
  end


  local function try_from_loc(lake, x, y, dir)
    if info.blocks[x][y] != lake then
      return false
    end

    local nx, ny = geom.nudge(x, y, dir)

    if not cave:valid_cell(nx, ny) then return false end

    local B = info.blocks[nx][ny]

    if not B or B == lake then return false end

    if B.is_liquid or B.is_fence or B.is_wall then return false end

    local length = 1
    local max_length = 4

    for dist = 2, 9 do
      if length > max_length then return false end

      local ox, oy = geom.nudge(x, y, dir, dist)

      if not cave:valid_cell(ox, oy) then return false end

      local B2 = info.blocks[ox][oy]

      if not B2 or B2 == lake then return false end

      -- found another lake?
      if B2.liquid then
        if lake.floor_h - B2.floor_h < 50 then return false end
        break;
      end

      if B.is_fence or B.is_wall then return false end

      length = length + 1
    end

    -- check player can traverse (somewhere along the new channel)

    local trav_count = 0

    for dist = 1, length do
      local ox, oy = geom.nudge(x, y, dir, dist)

      if can_still_traverse(ox, oy, dir) then
        trav_count = trav_count + 1
      end
    end

    if trav_count == 0 then return false end

    -- OK --

    for dist = 1, length do
      local ox, oy = geom.nudge(x, y, dir, dist)

      info.blocks[ox][oy] = lake
    end

    return true
  end


  local function try_waterfall(lake, dir)
    local cx1, cy1 = lake.cx1, lake.cy1
    local cx2, cy2 = lake.cx2, lake.cy2

    if dir == 2 then cy2 = math.min(lake.cy2, cy1 + 2) end
    if dir == 8 then cy1 = math.max(lake.cy1, cy2 - 2) end
    if dir == 4 then cx2 = math.min(lake.cx2, cx1 + 2) end
    if dir == 6 then cx1 = math.max(lake.cx1, cx2 - 2) end

    for x = cx1, cx2 do
    for y = cy1, cy2 do
      if try_from_loc(lake, x, y, dir, dist) then
        return true
      end
    end -- x, y
    end

    return false
  end


  local function connect_pools()
    each lake in info.lakes do
      local w, h = geom.group_size(lake.cx1, lake.cy1, lake.cx2, lake.cy2)

      -- too large?
      -- we skip the main lake (only test cases beginning at a pool)
      if w > 15 or h > 15 then continue end

      local DIRS = { 2,4,6,8 }
      rand.shuffle(DIRS)

      each dir in DIRS do
        if try_waterfall(lake, dir) then
          break;
        end
      end
    end
  end


  local function cells_are_fences(cx1, cy1, cx2, cy2)
    for x = cx1, cx2 do
    for y = cy1, cy2 do
      assert(cave:valid_cell(x, y))
      local B = info.blocks[x][y]
      if not (B and B.is_fence) then return false end
    end
    end

    return true
  end


  local function check_side_floors(cx, cy, dir, walk_A)
    dir = geom.RIGHT[dir]

    for pass = 1, 2 do
      local nx, ny = geom.nudge(cx, cy, dir)

      if not cave:valid_cell(nx, ny) then return false end

      local N = info.blocks[nx][ny]
      if not N then return false end

      -- allow fences
      if N.is_fence then continue end

      -- this check prevents odd-looking falls (want only a single side of
      -- the LOW_POOL to be visible)
      if N.is_liquid then return false end

      if N.is_wall or not N.floor_h then return false end

      if N != walk_A then return false end

      dir = 10 - dir
    end

    return true
  end


  local function attempt_a_fence_fall(cx, cy, dir)
    -- create a string describing what we can see
    local str = ""

    local low_floor
    local liq_area

    for i = 0, 7 do
      local nx, ny = geom.nudge(cx, cy, dir, i)
      if not cave:valid_cell(nx, ny) then return false end

      local BL = info.blocks[nx][ny]
      if not BL or BL.is_wall or BL.goal_type then return false end

      -- do not join onto a previously built waterfall
      if BL.is_waterfall then return false end

      if BL.is_fence then
        str = str .. "F"
      elseif BL.is_liquid then
        str = str .. "L"
        liq_area = BL
      elseif BL.floor_h then
        str = str .. "W"

        if not low_floor then
          low_floor = BL
        else
          if BL != low_floor then return end
        end

        if not check_side_floors(nx, ny, dir, BL) then
          return false
        end

      else
        return false
      end
    end


    -- check if possible
    if not string.match(str, "F+W+L") then
      return false
    end

    assert(low_floor)
    assert(liq_area)

    if low_floor.floor_h - liq_area.floor_h < 50 then
      return false  -- the "falls" would be too low
    end

    -- random chance of not making it
    if rand.odds(50) then
      return false
    end


    -- OK, do it --

    local F1 = info.blocks[cx][cy]
    assert(F1.floor_h)

    local HIGH_POOL =
    {
      is_liquid  = true
      is_waterfall = true
      floor_h = F1.floor_h - 16
    }

    local LOW_POOL =
    {
      is_liquid  = true
      is_waterfall = true
      floor_h = low_floor.floor_h - 12
    }

    info.blocks[cx][cy] = HIGH_POOL

    for i = 1, 7 do
      local ch = string.sub(str, i+1, i+1)
      local nx, ny = geom.nudge(cx, cy, dir, i)

      if ch == 'L' then break; end

      if ch == 'F' and i == 1 and string.sub(str, 3, 3) == 'F' then
        info.blocks[nx][ny] = HIGH_POOL
        continue
      end

      info.blocks[nx][ny] = LOW_POOL
    end

    return true
  end


  local function try_fence_fall(S, dir)
    -- Note: 'dir' faces inwards (away from fence)

    local along_dir = geom.vert_sel(dir, 6, 8)

    -- must be at edge of room
    local N = S:neighbor(10 - dir)
    if N and N.room == R then return end

    -- we only try pairs of seeds along the edge
    if geom.is_vert(dir) then
      if (S.sx % 2) == 0 then return end
    else
      if (S.sy % 2) == 0 then return end
    end

    -- check second seed in pair
    local S2 = S:neighbor(along_dir)
    if not (S2 and S2.room == R) then return end

    local N2 = S2:neighbor(10 - dir)
    if N2 and N2.room == R then return end


    local cx1 = 1 + (S.sx - R.sx1) * 2
    local cy1 = 1 + (S.sy - R.sy1) * 2

    if dir == 4 then cx1 = cx1 + 1 end
    if dir == 2 then cy1 = cy1 + 1 end

    local cx2, cy2 = cx1, cy1

    -- we test middle four cells in the seed pair
    if geom.is_vert(dir) then
      cx1 = cx1 + 1
      cx2 = cx1 + 3
    else
      cy1 = cy1 + 1
      cy2 = cy1 + 3
    end

    -- all these cells should be fences : verify
    if not cells_are_fences(cx1, cy1, cx2, cy2) then
      return
    end

    local deltas = { 0,1,2,3 }
    rand.shuffle(deltas)

    for i = 1, 4 do
      local cx, cy = geom.nudge(cx1, cy1, along_dir, i - 1)

      if attempt_a_fence_fall(cx, cy, dir) then
        -- yay!
        return
      end
    end
  end


  local function fence_falls()
    for x = R.sx1, R.sx2 do
    for y = R.sy1, R.sy2 do
      local S = SEEDS[x][y]

      if S.room != R then continue end

      for dir = 2,8,2 do
        try_fence_fall(S, dir)
      end

    end -- sx, sy
    end
  end


  ---| Cave_make_waterfalls |---

  if info.liquid_mode != "lake" then return end

  connect_pools()

  fence_falls()
end



function Cave_decorations(R)
  --|
  --| add torches (etc)
  --|

  local info = R.cave_info
  local cave = info.cave


  local function block_is_bounded(x, y, A, dir)
    local nx, ny = geom.nudge(x, y, dir)

    if not cave:valid_cell(nx, ny) then return true end

    local N = info.blocks[nx][ny]

    if not (N and N.floor_h) then return true end
    if N.is_wall or N.is_fence or N.is_liquid then return true end

    if math.abs(N.floor_h - A.floor_h) > 16 then return true end

    return false
  end


  local function usable_corner(x, y)
    local A = info.blocks[x][y]

    if not (A and A.floor_h) then return false end

    -- analyse neighborhood of cell
    local nb_str = ""

    for dir = 1,9 do
      if block_is_bounded(x, y, A, dir) then
        nb_str = nb_str .. "1"
      else
        nb_str = nb_str .. "0"
      end
    end

    -- match neighborhood string
    -- Note: each '.' in the pattern means "Dont Care"

    return string.match(nb_str, "^11.100.00$") or
           string.match(nb_str, "^.1100100.$") or
           string.match(nb_str, "^.0010011.$") or
           string.match(nb_str, "^00.001.11$")
  end


  local function find_corner_locs()
    local locs = {}

    for x = 2, info.W - 1 do
    for y = 2, info.H - 1 do
      if usable_corner(x, y) then
        table.insert(locs, { cx=x, cy=y })
      end
    end
    end

    return locs
  end


  local function select_torch()
    local tab = R.theme.torches or THEME.cave_torches

    if not tab then return end

    return rand.key_by_probs(tab)
  end


  local function kill_nearby_locs(list, x, y)
    each loc in list do
      if math.abs(loc.cx - x) <= 2 and
         math.abs(loc.cy - y) <= 2
      then
        loc.dead = true
      end
    end
  end


  local function add_torch(x, y, torch_ent)
    local A = info.blocks[x][y]
    assert(A and A.floor_h)

    local mx = info.x1 + (x-1) * 64 + 32
    local my = info.y1 + (y-1) * 64 + 32

    Trans.entity(torch_ent, mx, my, A.floor_h) ---??  { cave_light=48 })

    R:add_solid_ent(torch_ent, mx, my, A.floor_h)

    table.insert(info.lights, { x=mx, y=my, z=A.floor_h + 64 })
  end


  local function place_torches_in_corners(prob)
    local torch_ent = select_torch()

    if not torch_ent then return end

    local locs = find_corner_locs()

    rand.shuffle(locs)

    local perc  = sel(info.torch_mode == "few", 5, 12)
    local quota = #locs * perc / 100

    quota = quota * rand.range(0.8, 1.2)
    quota = int(quota + gui.random())

    -- very rarely add lots of torches
    if info.torch_mode != "few" and rand.odds(1) then
      quota = #locs / 2
    end

    while quota > 0 do
      if table.empty(locs) then break; end

      local loc = table.remove(locs, 1)
      if loc.dead then continue end

      add_torch(loc.cx, loc.cy, torch_ent)

      -- prevent adding a torch in a neighbor cell, since that can
      -- block the player's path.
      kill_nearby_locs(locs, loc.cx, loc.cy)

      quota = quota - 1
    end
  end


  ---| Cave_decorations |---

  if info.torch_mode != "none" then
    place_torches_in_corners()
  end
end



function Cave_decide_properties(R, info)
  --
  --  V7 NOTES
  -- ==========
  --
  -- (1) Outdoor caves are disabled, including the "lake" mode.
  --
  --     This is partly because I think a better system for outdoor
  --     rooms is necessary, which uses this cave system, but plans
  --     areas in a more deliberate way -- e.g. placing a river, or
  --     having porches in front of entrances to buildings.
  --
  --     This new "landscape" system would probably be used for the
  --     border areas of the map too.  Investigation into this idea
  --     is planned for a later time.
  --
  -- (2) Only flat caves are currently generated.
  --
  --     Getting the other STEP_MODES working again is non-trivial.
  --     But I also think that the steppy caves are too random, and
  --     an approach of making a small number of distinct areas which
  --     border each other (and connect via cavey stairs or a lift
  --     prefab) is going to better results.
  --


  -- step mode --

  info.step_mode = "walkway"

  -- liquid mode --

  local LIQUID_MODES = { none=60, some=30, heaps=10 }

  if not LEVEL.liquid then
    info.liquid_mode = "none"
  else
    local factor = style_sel("liquids", 33, 3, 1, 0.3)

    LIQUID_MODES.none = LIQUID_MODES.none * factor

    info.liquid_mode = rand.key_by_probs(LIQUID_MODES)
  end

  -- sky mode --

  local SKY_MODES = { none=60, some=40, heaps=40 }

  if R.light_level == "verydark" then SKY_MODES.none = 300 end
  if R.light_level == "bright"   then SKY_MODES.none = 10 end

  info.sky_mode = rand.key_by_probs(SKY_MODES)

  -- torch mode --

  local TORCH_MODES = { none=60, few=40, some=20 }

  if R.light_level == "bright" or
     (info.sky_mode != "none" and not LEVEL.is_dark) or
     info.liquid_mode != "none"
  then
    -- we have another source of light (sky or liquid)
    info.torch_mode = "none"

  else
    if R.light_level == "verydark" then TORCH_MODES.none = 10 end
    if R.light_level == "dark"     then TORCH_MODES.none = 20 end

    info.torch_mode = rand.key_by_probs(TORCH_MODES)
  end

  if info.torch_mode != "none" then
    info.cave_lighting = 1
  end

  -- extra health for damaging liquid
  if info.liquid_mode != "none" and LEVEL.liquid.damage then
    R.hazard_health = R.hazard_health + R.svolume * 0.7
  end

  gui.debugf("Cave properties in %s\n", R.name)
  gui.debugf("    step_mode : %s\n", info.step_mode)
  gui.debugf("  liquid_mode : %s\n", info.liquid_mode)
  gui.debugf("     sky_mode : %s\n", info.sky_mode)
  gui.debugf("   torch_mode : %s\n", info.torch_mode)
end



function Cave_build_room(R, entry_h)

  local info = Cave_setup_info(R)

  R.cave_info = info

  Cave_collect_walk_chunks(R, info)

  Cave_decide_properties(R, info)

  Cave_map_usable_area(info)

  Cave_generate_cave(R, info)

---  Cave_lake_fences(R)
---  Cave_fill_lakes(R)

  Cave_create_areas(R, info)

---  Cave_bunch_areas(R, "liquid")
---  Cave_bunch_areas(R, "sky")

  Cave_floor_heights(R, entry_h)

---  Cave_make_waterfalls(R)

  Cave_decorations(R)
end



function Cave_build_a_park(R, entry_h)

  local info


  local function temp_install_floor(FL)
    for cx = 1, info.W do
    for cy = 1, info.H do
      local val = info.map.cells[cx][cy]

      if val == nil then continue end

      info.blocks[cx][cy] = FL

      FL.cx1 = math.min(FL.cx1 or  9999, cx)
      FL.cy1 = math.min(FL.cy1 or  9999, cy)
      FL.cx2 = math.max(FL.cx2 or -9999, cx)
      FL.cy2 = math.max(FL.cy2 or -9999, cy)
    end -- sx, sy
    end
  end


  local function do_parky_stuff()
    local FLOOR =
    {
      neighbors = {}
      children  = {}

      floor_mat = R.floor_mat
       ceil_mat = "_SKY"

      -- TEMP RUBBISH
      floor_h   = entry_h
      ceil_h    = entry_h + 256
    }

    info.FLOOR = FLOOR

    table.insert(info.floors, FLOOR)
  end


  ---| Cave_build_a_park |---

  info = Cave_setup_info(R)

  R.cave_info = info

  Cave_collect_walk_chunks(R, info)

  Cave_map_usable_area(info)
  Cave_clear_walk_chunks(info)

  -- TEMP RUBBISH
  info.area.floor_h = entry_h
  info.area.ceil_h  = entry_h + 256

  do_parky_stuff()

  temp_install_floor(info.FLOOR)
end



function Cave_build_a_scenic_vista(area)

  local info


  local function temp_install_floor(FL)
    for cx = 1, info.W do
    for cy = 1, info.H do
      local val = info.map.cells[cx][cy]

      if val == nil then continue end

      info.blocks[cx][cy] = FL

      FL.cx1 = math.min(FL.cx1 or  9999, cx)
      FL.cy1 = math.min(FL.cy1 or  9999, cy)
      FL.cx2 = math.max(FL.cx2 or -9999, cx)
      FL.cy2 = math.max(FL.cy2 or -9999, cy)
    end -- sx, sy
    end
  end


  local function do_scenic_stuff()
    local FLOOR =
    {
      neighbors = {}
      children  = {}

      floor_mat = "FWATER1"
       ceil_mat = "_SKY"

      -- TEMP RUBBISH
      floor_h   = -73
      ceil_h    = 255
    }

    info.FLOOR = FLOOR

    table.insert(info.floors, FLOOR)

    -- TEMP RUBBISH
    info.area.floor_h = FLOOR.floor_h
    info.area.ceil_h  = FLOOR.ceil_h
  end


  ---| Cave_build_a_scenic_vista |---

  assert(area.mode == "scenic")

  info = Cave_setup_info(R, area)

  Cave_map_usable_area(info)

  do_scenic_stuff()

  temp_install_floor(info.FLOOR)
end



function Cave_outdoor_borders()
  --
  -- This adds sky fences where outdoor cave rooms touch the edge
  -- of the map.  It also adds them for outdoor rooms where the
  -- border pieces touch the edge of the map (which simplifies
  -- the design of border pieces).
  --
  -- These sky fences sit outside of any room seeds.  Hence they
  -- must occur at the real edge of the map -- otherwise the
  -- contents of normal seeds would muck them up.
  --

  local function need_sky_border(S, dir)
    -- really at edge of map?
    local N = S:neighbor(dir)

    if not (not N or N.free) then return false end

    if S.map_border then
      return S.map_border.kind != "solid"
    end

    local R = S.room

    if not R then return false end

    -- FIXME
    if R.kind == "outdoor" then return true end
    if R.kind == "scenic" and R.is_outdoor then return true end

    if not R.is_cave then return false end

    local info = R.cave_info

    return info.liquid_mode == "lake" or
           info.sky_mode == "low_wall"
  end


  local function build_sky_border(S, dir)
    local R = S.room
    if S.map_border then R = S.map_border.room end
    assert(R)

    local f_mat = assert(R.main_tex)
    local f_h   = R.floor_min_h - 256

    local x1, y1 = S.x1, S.y1
    local x2, y2 = S.x2, S.y2

    if dir == 2 then y2 = y1 ; y1 = y1 - 16 end
    if dir == 8 then y1 = y2 ; y2 = y2 + 16 end
    if dir == 4 then x2 = x1 ; x1 = x1 - 16 end
    if dir == 6 then x1 = x2 ; x2 = x2 + 16 end

    local brush = brushlib.quad(x1, y1, x2, y2)
    table.insert(brush, { t=f_h, reachable=true })
    brushlib.set_mat(brush, f_mat, f_mat)

    Trans.brush(brush)

    Trans.sky_quad(x1, y1, x2, y2, f_h + 4)
  end


  local function is_seed_outdoor(S)
    if S.room then return S.room.is_outdoor end

    if S.map_border then return true end

    return false
  end


  local function add_range_for_outdoor(sx1, sy1, sx2, sy2)
    for x = sx1, sx2 do
    for y = sy1, sy2 do
      SEEDS[x][y].sun_done = true
    end
    end

    local S1 = SEEDS[sx1][sy1]
    local S2 = SEEDS[sx2][sy2]

    local ent =
    {
      id = "oblige_box"

      box_type = "outdoor"

      x1 = S1.x1
      y1 = S1.y1
      x2 = S2.x2
      y2 = S2.y2
    }

    -- send it directly to the CSG [ no exporting to .map ]
    gui.add_entity(ent)
  end


  local function test_range_for_outdoor(sx, sy, sw, sh)
    local sx2 = sx + sw - 1
    local sy2 = sy + sh - 1

    if not Seed_valid(sx2, sy2) then return false end

    for x = sx, sx2 do
    for y = sy, sy2 do
      local S = SEEDS[x][y]
      if S.sun_done then return false end
      if not is_seed_outdoor(S) then return false end
    end
    end

    add_range_for_outdoor(sx, sy, sx2, sy2)

    return true
  end


  local function send_outdoor_areas(S, sx, sy)
    -- tell the CSG code which areas are outdoor, so it can limit
    -- the expensive Sun lighting tests to those areas.

    if S.sun_done then return end

    if not is_seed_outdoor(S) then return end

    if test_range_for_outdoor(sx, sy, 3, 3) or
       test_range_for_outdoor(sx, sy, 2, 2) or
       test_range_for_outdoor(sx, sy, 1, 1)
    then
       -- OK
    end
  end


  ---| Cave_outdoor_borders |---

  for sx = 1, SEED_W do
  for sy = 1, SEED_TOP do
    local S = SEEDS[sx][sy]

    for dir = 2,8,2 do
      if need_sky_border(S, dir) then
        build_sky_border(S, dir)
      end
    end

    send_outdoor_areas(S, sx, sy)

  end -- sx, sy
  end
end

