------------------------------------------------------------------------
--  ROOM MANAGEMENT
------------------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2016 Andrew Apted
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


--class ROOM
--[[
    kind : keyword  -- "normal" (layoutable room, can place items)
                    -- "hallway"
                    -- "scenic" (unvisitable room)

    is_outdoor : bool  -- true for outdoor rooms / caves

    is_cave    : bool  -- true for caves (indoor or outdoor)


    areas = list(AREA)

    seeds = list(SEED)

    sx1, sy1, sx2, sy2  -- \ Seed range
    sw, sh, svolume     -- /

     size_limit   -- \  limits on ergonomic growth
    floor_limit   -- /


    conns : list(CONNS)   -- connections to other rooms

    quest : QUEST

    zone : ZONE

    peer : ROOM     -- links rooms created via symmetry


    goals    : list(GOAL)   -- what goals are here (e.g. keys)
    weapons  : list(NAME)   -- what weapons to place in this room
    items    : list(NAME)   -- what nice items to place
    closet_items : list     -- what items to use in secret closets


    floor_chunks : list(CHUNK)   -- chunks in a walkable area
     ceil_chunks : list(CHUNK)

    closets  : list(CHUNK)
    stairs   : list(CHUNK)
    joiners  : list(CHUNK)
    pieces   : list(CHUNK)  -- for hallways

    triggers : list(TRIGGER)  -- used for traps


    light_level : keyword    -- "bright", "normal", "dark" or "verydark"

    hallway : HALLWAY_INFO   -- for hallways only

    symmetry : SYMMETRY_INFO

    gx1, gy1, gx2, gy2   -- seed range while growing

    floor_mats[z] : name
     ceil_mats[z] : name

    guard_chunk : CHUNK   -- what a bossy monster is guarding
--]]


--class HALLWAY_INFO
--[[
    height : number   -- space between floor and ceiling

--]]


--class SPOT
--[[
    x1, y1, x2, y2, z1, z2   -- coordinate range

    mx, my, mz   -- middle point

    kind : keyword    -- "monster", "item", "big_item"
                      -- FIXME : what else?

    where : keyword   -- "floor", "closet",
                      -- "cage", "trap",

    closet : CLOSET_INFO    -- only present for closets
--]]


--class TRIGGER
--[[
    kind : keyword    -- "edge" or "spot"

    edge   : EDGE     -- place trigger near this edge (of a door/joiner/closet)
    spot   : CHUNK    -- place trigger around this floor chunk (of an item/switch)

    action : number   -- the "special" to use
    tag    : number   -- the tag for the trap-doors
--]]


------------------------------------------------------------------------


ROOM_CLASS = {}

function ROOM_CLASS.new()
  local id = alloc_id("room")

  local R =
  {
    id = id
    kind = "UNSET"
    name = string.format("ROOM_%d", id)

    svolume = 0
    total_inner_points = 0
    prelim_conn_num = 0
    num_windows = 0

    areas = {}
    seeds = {}
    conns = {}
    internal_conns = {}
    temp_areas = {}

    goals = {}
    teleporters = {}
    weapons = {}
    items = {}
    closet_items = {}

    mon_spots  = {}
    item_spots = {}
    big_spots  = {}
    entry_spots = {}
    important_spots = {}   -- from prefabs

    floor_chunks  = {}
     ceil_chunks  = {}
    liquid_chunks = {}

    closets = {}
    stairs  = {}
    joiners = {}
    pieces  = {}

    cages = {}
    traps = {}
    triggers = {}

    used_chunks = 0  -- includes closets

    floor_mats = {}
     ceil_mats = {}

    floor_groups = {}
     ceil_groups = {}

    solid_ents = {}
    sky_rects  = {}
    exclusions = {}
    avoid_mons = {}

    hazard_health = 0
  }

  table.set_class(R, ROOM_CLASS)
  table.insert(LEVEL.rooms, R)
  return R
end


function ROOM_CLASS.tostr(R)
  return assert(R.name)
end


function ROOM_CLASS.add_area(R, A)
  assert(R.kind != "DEAD")

  A.room = R
  A.is_outdoor = R.is_outdoor

  table.insert(R.areas, A)

  R.svolume = R.svolume + A.svolume
  R.total_inner_points = R.total_inner_points + #A.inner_points
end


function ROOM_CLASS.get_env(R)
  if R.kind == "hallway" then return "hallway" end

  if R.is_cave then return "cave" end

  if R.is_outdoor then return "outdoor" end

  return "building"
end


function ROOM_CLASS.rough_size(R)
  local count = 0

  each A in R.areas do
    count = count + #A.seeds
  end

  return count
end


function ROOM_CLASS.num_floors(R)
  local count = 0

  each A in R.areas do
    if A.mode == "floor" then
      count = count + 1
    end
  end

  return count
end


function ROOM_CLASS.kill_it(R)
  gui.debugf("Killing %s\n", R.name)

  -- sanity check
  each C in LEVEL.conns do
    if (C.A1.room == R and C.A2.room != R) or
       (C.A2.room == R and C.A1.room != R)
    then
      error("Killed a connected room!")
    end
  end

  table.kill_elem(LEVEL.rooms, R)

  -- remove from the trunk object
  table.kill_elem(R.trunk.rooms, R)

  each A in R.areas do
    gui.debugf("   kill %s\n", A.name)
    A:kill_it()
  end

  R.areas = nil

  R.name = "DEAD_" .. R.name
  R.kind = "DEAD"
  R.hallway = nil
  R.trunk = nil

  R.sx1   = nil
  R.areas = nil
end


function ROOM_CLASS.try_collect_seed(R, S)
  if not S.area then return end
  if S.area.room != R then return end

  S.room = R

  table.insert(R.seeds, S)

  -- update ROOM's bounding box

  R.sx1 = math.min(R.sx1 or  999, S.sx)
  R.sy1 = math.min(R.sy1 or  999, S.sy)
  R.sx2 = math.max(R.sx2 or -999, S.sx)
  R.sy2 = math.max(R.sy2 or -999, S.sy)
end


function ROOM_CLASS.collect_seeds(R)
  for sx = 1, SEED_W do
  for sy = 1, SEED_H do
    local S  = SEEDS[sx][sy]
    local S2 = S.top

    R:try_collect_seed(S)

    if S2 then R:try_collect_seed(S2) end
  end
  end

  if not R.sx1 then
    error("Room with no seeds!")
  end

  R.sw = R.sx2 - R.sx1 + 1
  R.sh = R.sy2 - R.sy1 + 1
end


function ROOM_CLASS.contains_seed(R, x, y)
  if x < R.sx1 or x > R.sx2 then return false end
  if y < R.sy1 or y > R.sy2 then return false end
  return true
end


function ROOM_CLASS.get_bbox(R)
  local S1 = SEEDS[R.sx1][R.sy1]
  local S2 = SEEDS[R.sx2][R.sy2]

  return S1.x1, S1.y1, S2.x2, S2.y2
end


---## function ROOM_CLASS.has_lock(R, lock)
---##   each C in R.conns do
---##     if C.lock == lock then return true end
---##   end
---##   return false
---## end


function ROOM_CLASS.has_any_lock(R)
  each C in R.conns do
    if C.lock then return true end
  end
  return false
end


---## function ROOM_CLASS.has_lock_kind(R, kind)
---##   each C in R.conns do
---##     if C.lock and C.lock.kind == kind then return true end
---##   end
---##   return false
---## end


function ROOM_CLASS.has_sky_neighbor(R)
  each C in R.conns do
    if C.A1.room == C.A2.room then continue end
    local N = C:other_room(A)
    if N.is_outdoor and N.mode != "void" then return true end
  end

  return false
end


function ROOM_CLASS.has_teleporter(R)
  each C in R.conns do
    if C.kind == "teleporter" then return true end
  end

  return false
end


function ROOM_CLASS.calc_walk_vol(R)
  local vol = 0

  each A in R.areas do
    if A.mode == "floor" or
      (A.chunk and A.chunk.kind == "area") or
      (A.chunk and A.chunk.kind == "stair")
    then
      A:calc_volume()
      vol = vol + A.svolume
    end
  end

  -- this should not happen
  if vol < 1 then vol = 1 end

  return vol
end


function ROOM_CLASS.total_conns(R, ignore_secrets)
  local count = 0

  each C in R.conns do
    if ignore_secrets and C.is_secret then
      continue
    end

    count = count + 1
  end

  return count
end


function ROOM_CLASS.is_unused_leaf(R)
  if R.kind == "hallway" then return false end

  if R.is_secret  then return false end
  if R.is_start   then return false end

  if R:total_conns("ignore_secrets") >= 2 then return false end

  if #R.goals   > 0 then return false end
  if #R.weapons > 0 then return false end

  return true
end


function secret_entry_conn(R, skip_room)
  -- find entry connection for a potential secret room
  -- skip_room is usually NIL

  each C in R.conns do
    if C.A1.room != C.A2.room and
       C.A1.room != skip_room and
       C.A2.room != skip_room
    then
      return C
    end
  end

  error("Cannot find entry conn for secret room")
end


function ROOM_CLASS.add_entry_spot(R, spot)
  table.insert(R.entry_spots, spot)

  if not R.entry_coord then
    local mx = (spot.x1 + spot.x2) / 2
    local my = (spot.y1 + spot.y2) / 2

    R.entry_coord = { x=mx, y=my, z=spot.z1 + 40, angle=spot.angle }
  end
end


function ROOM_CLASS.furthest_dist_from_entry(R)
  if not R.entry_coord then
    -- rough guess
    local S1 = SEEDS[R.sx1][R.sy1]
    local S2 = SEEDS[R.sx2][R.sy2]

    local w = S2.x2 - S1.x1
    local h = S2.y2 - S1.y1

    return math.max(w, h)
  end

  local result = 512

  local ex = R.entry_coord.x
  local ey = R.entry_coord.y

  for sx = R.sx1, R.sx2 do
  for sy = R.sy1, R.sy2 do
    local S = SEEDS[sx][sy]

    if S.room != R then continue end

    local ox = sel(S.x1 < ex, S.x1, S.x2)
    local oy = sel(S.y1 < ey, S.y1, S.y2)

    local dist = geom.dist(ex, ey, ox, oy)

    result = math.max(result, dist)
  end
  end

  return result
end


function ROOM_CLASS.usable_chunks(R)
  local num = #R.floor_chunks + #R.closets - R.used_chunks
  if num < 0 then num = 0 end
  return num
end


function ROOM_CLASS.add_solid_ent(R, id, x, y, z)
  -- the "id" can be a name or a number.
  -- for names, we can use the proper size and ignore passable ents.

  local info

  if type(id) != "number" then
    info = GAME.ENTITIES[id]
  end

  if not info then
    info = { r=32, h=96 }
  end

  if info.pass then return end

  local SOLID_ENT =
  {
    id = id

    x = x
    y = y
    z = z

    r = info.r
    h = info.h
  }

  table.insert(R.solid_ents, SOLID_ENT)
end


function ROOM_CLASS.spots_do_decor(R, floor_h)
  local low_h  = PARAM.spot_low_h
  local high_h = PARAM.spot_high_h

  each ent in R.solid_ents do
    local z1 = ent.z
    local z2 = ent.z + ent.h

    if z1 >= floor_h + high_h then continue end
    if z2 <= floor_h then continue end

    local content = SPOT_LEDGE
    if z1 >= floor_h + low_h then content = SPOT_LOW_CEIL end

    local x1, y1 = ent.x - ent.r, ent.y - ent.r
    local x2, y2 = ent.x + ent.r, ent.y + ent.r

    gui.spots_fill_box(x1, y1, x2, y2, content)
  end
end


function ROOM_CLASS.add_exclusion(R, kind, x1, y1, r, x2, y2)
  -- x2 and y2 are optional
  if x2 == nil then x2 = x1 end
  if y2 == nil then y2 = y1 end

  local area =
  {
    kind = kind

    x1 = x1 - r
    y1 = y1 - r
    x2 = x2 + r
    y2 = y2 + r
  }

  table.insert(R.exclusions, area)
end


function ROOM_CLASS.clip_spot_list(R, list, x1, y1, x2, y2, strict_mode)
  local new_list = {}

  each spot in list do
    if (spot.x2 <= x1) or (spot.x1 >= x2) or
       (spot.y2 <= y1) or (spot.y1 >= y2)
    then
      -- unclipped

    elseif strict_mode then
      -- drop this spot
      continue

    else
      local w1 = x1 - spot.x1
      local w2 = spot.x2 - x2

      local h1 = y1 - spot.y1
      local h2 = spot.y2 - y2

      -- totally clipped?
      if math.max(w1, w2, h1, h2) < 8 then
        continue
      end

      -- shrink the existing box (keep side with most free space)

      if w1 >= math.max(w2, h1, h2) then
        spot.x2 = spot.x1 + w1
      elseif w2 >= math.max(w1, h1, h2) then
        spot.x1 = spot.x2 - w2
      elseif h1 >= math.max(w1, w2, h2) then
        spot.y2 = spot.y1 + h1
      else
        spot.y1 = spot.y2 - h2
      end

      assert(spot.x2 > spot.x1)
      assert(spot.y2 > spot.y1)
    end

    table.insert(new_list, spot)
  end

  return new_list
end


function ROOM_CLASS.clip_spots(R, x1, y1, x2, y2)
  -- the given rectangle is where we _cannot_ have a spot

  assert(x1 < x2)
  assert(y1 < y2)

  -- enlarge the area a bit
  x1, y1 = x1 - 4, y1 - 4
  x2, y2 = x2 + 4, y2 + 4

  R.mon_spots  = R:clip_spot_list(R.mon_spots,  x1, y1, x2, y2)

---??  R.item_spots = R:clip_spot_list(R.item_spots, x1, y1, x2, y2)
---??  R.big_spots  = R:clip_spot_list(R.big_spots,  x1, y1, x2, y2, "strict")
end


function ROOM_CLASS.exclude_monsters(R)
  each box in R.exclusions do
    if box.kind == "keep_empty" then
      R:clip_spots(box.x1, box.y1, box.x2, box.y2)
    end
  end
end


------------------------------------------------------------------------


function Room_prepare_skies()
  --
  -- Each zone gets a rough sky height (dist from floors).
  -- The final sky height of each zone is determined later.
  --

  local function new_sky_add_h()
    if rand.odds(2)  then return 256 end
    if rand.odds(10) then return 192 end

    return 144
  end


  ---| Room_prepare_skies |---

  each Z in LEVEL.zones do
    Z.sky_add_h = new_sky_add_h()
  end
end



function Room_reckon_door_tex()

  local function visit_conn(C, E1, E2)
    if E1 == nil then return end
    assert(E2)

    local A1 = assert(E1.area)
    local A2 = assert(E2.area)

    for pass = 1,2 do
      E1.wall_mat = Junction_calc_wall_tex(A1, A2)

      A1, A2 = A2, A1
      E1, E2 = E2, E1
    end
  end


  local function visit_joiner(C)
    -- nothing needed
  end


  each C in LEVEL.conns do
    if C.kind == "edge" then
      visit_conn(C, C.E1, C.E2)
      visit_conn(C, C.F1, C.F2)

    elseif C.kind == "joiner" then
      visit_joiner(C)
    end
  end
end



function Room_reckon_doors()

  local  indoor_prob = style_sel("doors", 0, 15, 35,  65)
  local outdoor_prob = style_sel("doors", 0, 70, 90, 100)


  local function reqs_for_edge(C, E)
    -- requirements for the prefab
    local reqs =
    {
      kind = "door"

      seed_w = assert(E.long)
    }

    if geom.is_corner(E.dir) then
      reqs.where = "diagonal"
      reqs.seed_h = reqs.seed_w
    else
      reqs.where = "edge"
    end


    -- locked door?
    local LOCK = C.lock

    if LOCK then
      E.kind = "lock_door"

      if LOCK.kind == "intraroom" then
        reqs.key = "barred"
        E.lock_tag = assert(LOCK.tag)
      elseif #LOCK.goals == 2 then
        error("Locked double")
      elseif #LOCK.goals == 3 then
        error("Locked triple")
      elseif LOCK.goals[1].kind == "SWITCH" then
        reqs.switch = LOCK.goals[1].item
        E.lock_tag  = assert(LOCK.goals[1].tag)
      else
        reqs.key = LOCK.goals[1].item
      end

      C.is_door = true
      C.fresh_floor = true

      return reqs
    end


    -- secret door ?
    if C.is_secret then
      E.kind = "secret_door"

      C.is_door = true

      reqs.key = "secret"

      return reqs
    end


    -- special archways for caves FIXME
--[[
    local R1 = S.room
    local R2 = N.room

    if R2.is_cave and not R2.is_outdoor then
      R1, R2 = R2, R1
    end

    if R1.is_cave and not R1.is_outdoor then
      if R2.kind != "building" then
        B.fab_name = sel(woody, "Arch_woody", "Arch_viney")
        return reqs
      end
    end
--]]


    -- don't need anything between two outdoor rooms
    -- TODO : allow the arch if have "walls" touching both corners
--[[
    if C.R1.is_outdoor and C.R2.is_outdoor then
      E.kind = "nothing"
      return reqs
    end
--]]


    -- apply the random check
    local prob = indoor_prob
    if (C.R1.is_outdoor and not C.R2.is_cave) or
       (C.R2.is_outdoor and not C.R1.is_cave)
    then
      prob = outdoor_prob
    end

    if rand.odds(prob) then
      E.kind = "door"

      C.is_door = true
      C.fresh_floor = rand.odds(30)

      return reqs
    end


--[[  FIXME  (PROBABLY check prefab_def.delta_h after Fab_pick, NOT the following crud)

    -- support arches which have a step in them
    if (S.room.is_outdoor != N.room.is_outdoor) or rand.odds(50) then
      if THEME.archy_arches then return end
      if STYLE.steepness == "none" then return end

      if not (S.room.hallway or N.room.hallway) then
        if S == C.S1 then
          C.diff_h = 16
        else
          C.diff_h = -16
        end
        C.fresh_floor = true
      end
    end
--]]


    -- keep the current ARCH
    reqs.kind = "arch"

    return reqs
  end


  local function pick_edge_prefab(C)
    -- hack for unfinished games
    if THEME.no_doors then return end


    local E = C.E1
    local F = C.F1  -- used for split conns, usually NIL

    if E.kind != "arch" then
      E = C.E2
      F = C.F2
    end

    assert(E.kind == "arch")

    if F then assert(F.kind == "arch") end


    -- get orientation right, "front" of prefab faces earlier room
    local R1 = C.R1
    local R2 = C.R2

    if R1 != E.area.room then
      R1, R2 = R2, R1
    end

    if R1.lev_along > R2.lev_along then
      E.flip_it = true

      if F then F.flip_it = true end
    end


    local reqs = reqs_for_edge(C, E)

    if reqs then
gui.debugf("Reqs for arch from %s --> %s\n%s\n", C.R1.name, C.R2.name, table.tostr(reqs))

      reqs.env      = R1:get_env()
      reqs.neighbor = R2:get_env()

      E.prefab_def = Fab_pick(reqs)
    end

    -- use exact same thing on split conn
    if F then
      F.kind       = E.kind
      F.prefab_def = E.prefab_def
      F.lock_tag   = E.lock_tag
    end
  end


  local function pick_joiner_prefab(C)
    local chunk = assert(C.joiner_chunk)

--stderrf("Joiner chunk:\n%s\n", table.tostr(chunk))
    local A1 = chunk.from_area
    local A2 = chunk.dest_area

    local reqs = Chunk_base_reqs(chunk, chunk.from_dir)

    reqs.kind  = "joiner"
    reqs.shape = assert(chunk.shape)

    reqs.env      = A1.room:get_env()
    reqs.neighbor = A2.room:get_env()

    local LOCK = C.lock

    if LOCK then
      if LOCK.kind == "intraroom" then
        reqs.key = "barred"
      elseif #LOCK.goals == 2 then
        error("Locked double")
      elseif #LOCK.goals == 3 then
        error("Locked triple")
      elseif LOCK.goals[1].kind == "SWITCH" then
        reqs.switch = LOCK.goals[1].item
      else
        reqs.key = LOCK.goals[1].item
      end
    end

    if C.is_secret then
      reqs.key = "secret"
    end

    chunk.prefab_def = Fab_pick(reqs)

    -- should we flip the joiner?
    if A1.room.lev_along > A2.room.lev_along then
      if chunk.shape == "I" then
        chunk.flipped = true
      else
        -- FIXME L SHAPES, do what??
      end
    end

    if (chunk.prefab_def.can_flip and rand.odds(35))
    then
      chunk.flipped = not chunk.flipped
    end

    -- this is needed when the environment on each side is important,
    -- such as the joiner connecting a normal room to a cave.
    if chunk.prefab_def.force_flip != nil then
      chunk.flipped = chunk.prefab_def.force_flip
    end

    if chunk.flipped then
      -- reverse from_dir, swap from_area and dest_area
      Chunk_flip(chunk)
    end
  end


  local function visit_conn(C)
    if C.kind == "edge" then
      pick_edge_prefab(C)
    elseif C.kind == "joiner" then
      pick_joiner_prefab(C)
    end
  end


  ---| Room_reckon_doors |---

  each C in LEVEL.conns do
    visit_conn(C)
  end
end



function Room_detect_porches(R)
  --
  -- A "porch" is typically an area of an outdoor room that neighbors a
  -- building and will be given a solid low ceiling and some pillars to
  -- hold it up, and a floor higher than any nearby areas of the room.
  --
  -- It can also be used indoors (what previous code called a "periph").
  --
  -- Another use case is an outdoor hallway which is mostly surrounded
  -- by outdoor areas, and is higher than those areas.
  --

  local best_A
  local best_score


  local function set_as_porch(A)
    A.is_porch = true

    -- Note : keeping 'is_outdoor' on the area
  end


  local function detect_hallway_porch()
    -- keep it simple, ignore merged hallways
    if #R.areas > 1 then return false end

    local HA = R.areas[1]

    each edge in HA.edge_loops[1] do
      local N = edge.S:neighbor(edge.dir)

      if not (N and N.area) then return false end

      local A2 = N.area

      if A2.mode == "scenic" then
        -- ok
        continue
      end

      local R2 = A2.room
      assert(R2 != R)

      if not R2 then
        -- no void, thanks
        return false
      end

      -- same zone?
      if R2.zone != R.zone then
        -- ok
        continue
      end

      -- TODO : if hallway is large, allow a few edges
      if not R2.is_outdoor then
         return false
      end

      -- floor check
      if HA.floor_h + 64 < (A2.floor_h or 0) then
        return false
      end
    end

    gui.debugf("Hallway %s is now a PORCH\n", R.name)

    set_as_porch(HA)

    return true
  end


  local function eval_porch(A, mode)
    -- mode is either "indoor" or "outdoor"

    if A.mode != "floor" then return -1 end

    if A.pool_hack then return -1 end

    -- size check : never too much of room
    if A.svolume > R.svolume / 2 then return -1 end

    -- shape check : we want high twistiness, low openness
    if A.openness > 0.3 then return -1 end

    -- should not be surrounded by another area
    if #A.neighbors < 2 then return -1 end

    -- FIXME.....

    local score = 100 + A.svolume - A.openness * 100

    -- tie break
    return score + gui.random()
  end


  local function detect_normal_porch(mode)
    -- only one per room, so pick best
    best_A = nil
    best_score = 0

    each A in R.areas do
      local score = eval_porch(A, "indoor")

      if score > best_score then
        best_A = A
        best_score = score
      end
    end

    if best_A then
      set_as_porch(best_A)

      gui.debugf("Made %s into a PORCH\n", best_A.name)
    end
  end


  ---| Room_detect_porches |---

-- FIXME : porches disabled due to blocking pillars
do return end

  local prob = style_sel("porches", 0, 25, 50, 75)

  if not rand.odds(prob) then
    return
  end

---??  if R.kind == "hallway" then
---??    detect_hallway_porch()

  if R.is_outdoor then
    detect_normal_porch("outdoor")

  else
    detect_normal_porch("indoor")
  end
end



function Room_border_up()
  --
  -- Decide the default bordering between any two adjacent areas.
  -- [ This default can be overridden by EDGE objects, e.g. for doors ]
  --

  local omit_fence_prob = rand.pick({ 10,50,90 })


  local function area_can_window(A)
    if not A.room then return false end
    if not A.floor_h then return false end

    if A.mode == "void" then return false end
    if A.chunk and A.chunk.kind != "area" then return false end

    if A.room.kind == "hallway" then return false end

    return true
  end


  local function check_window_heights(A1, A2)
    local c1 = A1.ceil_h
    local c2 = A2.ceil_h

    if not c1 or not c2 then return false end

    local max_f = math.max(A1.floor_h, A2.floor_h)
    local min_c = math.min(c1, c2)

    return (min_c - max_f) >= 128
  end


  local function can_make_window(A1, A2)
    -- disable windows into caves [ for now... ]
    if A1.room and A1.room.is_cave then return false end
    if A2.room and A2.room.is_cave then return false end

    if A1.is_outdoor and not A2.is_outdoor then
       A1, A2 = A2, A1
    end

    if area_can_window(A1) and
       area_can_window(A2) and
       check_window_heights(A1, A2)
    then
      return true
    end
  end


  local function should_make_window(A1, A2)
    local prob = style_sel("windows", 0, 20, 50, 80)

    if not A1.is_outdoor and not A2.is_outdoor then prob = prob / 3 end

    if A1.zone != A2.zone then prob = prob / 5 end

    if not rand.odds(prob) then return false end

    if not can_make_window(A1, A2) then return false end

    return true
  end


  local function can_omit_fence(A1, A2)
    if not (A1.mode == "floor" and A1.room) then return false end
    if not (A2.mode == "floor" and A2.room) then return false end

    -- start rooms need protection from monsters in neighbor rooms
    if (A1.room and A1.room.is_start) or (A2.room and A2.room.is_start) then
      if rand.odds(80) then return false end
    end

    if A1.room.lev_along > A2.room.lev_along then
      return A1.floor_h > A2.floor_h + 78
    else
      return A2.floor_h > A1.floor_h + 78
    end
  end


  local function visit_junction(junc)
    local A1 = junc.A1
    local A2 = junc.A2

    assert(A1 != A2)


    -- already decided?
    if junc.E1 then return end


    -- handle edge of map
    -- [ normal rooms should not touch the edge ]

    if A2 == "map_edge" then
      Junction_make_map_edge(junc)
      return
    end


    -- zones : gotta keep 'em separated

    if A1.zone != A2.zone then
      if should_make_window(A1, A2) then
        Junction_make_window(junc)
        return
      end

      Junction_make_wall(junc)
      return
    end


    -- void --

    if A1.mode == "void" or A2.mode == "void" then
      Junction_make_wall(junc)
      return
    end


    -- closets --

    if (A1.mode == "chunk" and A1.chunk.place == "whole") or
       (A2.mode == "chunk" and A2.chunk.place == "whole")
    then
      Junction_make_wall(junc)
      return
    end

    -- scenic to scenic --

    if A2.room and not A1.room then
      A1, A2 = A2, A1
    end

    if not A1.room then
      -- nothing needed if both building or both outdoor
      if (not A1.is_outdoor) != (not A2.is_outdoor) then
        Junction_make_wall(junc)
      end

      return
    end


    -- room to scenic --

    if not A2.room then
      -- TODO Sometimes make windows?  [ probably do elsewhere... ]

      Junction_make_wall(junc)
      return
    end


    -- the same room --

    if A1.room == A2.room then
---???      -- this needed for closets and joiners  FIXME WRONG [ REALLY ?? ]
---???      if (not A1.is_outdoor) != (not A2.is_outdoor) then
---???        Junction_make_wall(junc)
---???      end

      return
    end


    -- fences --

    if A1.is_outdoor and A2.is_outdoor then
      -- occasionally omit it when big height difference
      if can_omit_fence(A1, A2) and rand.odds(omit_fence_prob) then
        Junction_make_empty(junc)
      else
        Junction_make_fence(junc)
      end

      return
    end


    -- windows --

    if should_make_window(A1, A2) then
      Junction_make_window(junc)
      return
    end


    -- when in doubt, block it out!

    Junction_make_wall(junc)
  end


  ---| Room_border_up |---

  each _,junc in LEVEL.area_junctions do
    if junc.E1 == nil then
      visit_junction(junc)
    end
  end
end



function Room_determine_spots()

  -- Algorithm:
  --
  -- For each area of each room:
  --
  --   1. initialize grid to be LEDGE.
  --
  --   2. CLEAR the polygons for area's floor.  This will produce areas
  --      which are somewhat too large.
  --
  --   3. use draw_line to set edges of area to LEDGE again, fixing the
  --      "too large" problem of the above step.
  --
  --   4. use the CSG code to kill any blocking brushes.
  --      This step creates the WALL cells.
  --


  local function spots_for_area(R, A, mode)
    -- the 'mode' is normally NIL, can also be "cage" or "trap"
    if not mode then mode = A.mode end

    -- get bbox of room
    local rx1, ry1, rx2, ry2 = area_get_bbox(A)

    -- initialize grid to "ledge"
    gui.spots_begin(rx1 - 48, ry1 - 48, rx2 + 48, ry2 + 48, A.floor_h, SPOT_LEDGE)

    -- clear polygons making up the floor
    each brush in A.floor_brushes do
      gui.spots_fill_poly(brush, SPOT_CLEAR)
    end

    -- set the edges of the area
    each E in A.side_edges do
      gui.spots_draw_line(E.x1, E.y1, E.x2, E.y2, SPOT_LEDGE)
    end

    -- remove decoration entities
    R:spots_do_decor(A.floor_h)

    -- remove walls and blockers (using nearby brushes)
    gui.spots_apply_brushes()

--- gui.spots_dump("Spot dump in " .. R.name .. "/" .. A.mode)

    -- add the spots to the room
    local item_spots = {}
    local  mon_spots = {}

    gui.spots_get_items(item_spots)
    gui.spots_get_mons(mon_spots)

--  stderrf("mon_spots @ %s floor:%d : %d\n", R.name, f_h, #mon_spots)

    -- this is mainly for traps
    if A.mon_focus then
      each spot in mon_spots do
        spot.face = A.mon_focus
      end
    end

    -- for large cages/traps, adjust quantities
    if mode == "cage" or mode == "trap" then
      each spot in mon_spots do
        spot.use_factor = 1.0 / (A.svolume ^ 0.64)
      end
    end

    if mode == "cage" then
gui.debugf("ADDING CAGE IN %s : %d spots\n", R.name, #mon_spots)
      table.insert(R.cages, { mon_spots=mon_spots })

    elseif mode == "trap" then
      table.insert(R.traps, { mon_spots=mon_spots })
      table.append(R.item_spots, item_spots)

    else
      -- do not place items in damaging liquids
      -- [ we skip monsters too because we can place big items in a mon spot ]
      if A.mode != "liquid" then
        table.append(R.item_spots, item_spots)
        table.append(R.mon_spots,  mon_spots)
      end
    end

    gui.spots_end()

--- DEBUG:
--- stderrf("AREA_%d has %d mon spots, %d item spots\n", A.id, #mon_spots, #item_spots)
  end


  local function spots_in_room(R)
    if R.is_cave then
      Cave_determine_spots(R)
      return
    end

    each A in R.areas do
      spots_for_area(R, A)
    end
  end


  local function entry_spot_for_conn(R, C)
    -- FIXME : entry_spot_for_conn
  end


  local function find_entry_spots(R)
    if R.entry_conn then
      entry_spot_for_conn(R, C)
    end

    -- TODO : start pad, teleporter pad

    -- TODO : closets
  end


  ---| Room_determine_spots |---

  each R in LEVEL.rooms do
    spots_in_room(R)

    R:exclude_monsters()

    find_entry_spots(R)
  end

--[[
  -- handle cages and traps
  each A in LEVEL.areas do
    if A.mode == "cage" or A.mode == "trap" then
      local R = assert(A.room)
      spots_for_area(R, A, A.mode)
    end
  end
--]]
end


------------------------------------------------------------------------


function walkable_svolume()
  local vol = 0

  each A in LEVEL.areas do
    if A.mode == "normal" then
      vol = vol + A.svolume
    end
  end

  return vol
end


function sort_areas_by_volume()
  -- biggest first

  local list = table.copy(LEVEL.areas)

  each A in list do A.sort_rand = gui.random() end

  table.sort(list, function(A, B) return A.svolume + A.sort_rand > B.svolume + B.sort_rand end)

  return list
end



--[[ UNUSED CAVE-GRID SYSTEM......

function create_cave_grid()
  --
  -- We divide the map into a large 3x3 grid.
  -- Each section is either "cavey" or non-cavey.
  -- Rooms which TOUCH a cavey section become actual caves.
  --

  local function set_a_cave_section()
    -- this try to avoid the middle section
    local COORDS = { 6, 1, 6 }

    for loop = 1,100 do
      local cx = rand.key_by_probs(COORDS)
      local cy = rand.key_by_probs(COORDS)

      if not LEVEL.cave_grid[cx][cy] then
        LEVEL.cave_grid[cx][cy] = true
        return
      end
    end
  end


  --| Room_create_cave_grid |--

  LEVEL.cave_grid_sx1 = int(SEED_W * 0.35)
  LEVEL.cave_grid_sx2 = int(SEED_W * 0.65)

  LEVEL.cave_grid_sy1 = int(SEED_H * 0.35)
  LEVEL.cave_grid_sy2 = int(SEED_H * 0.65)

  LEVEL.cave_grid = table.array_2D(3, 3)


  -- determine # of cells to become cavey

  local cave_skip  = style_sel("caves", 100, 50, 25, 0)

  if rand.odds(cave_skip) then
    gui.printf("Cave quota: skipped for level.\n")
    return
  end

  local cave_low   = style_sel("caves", 0, 1.2, 2.4, 4.4)
  local cave_high  = style_sel("caves", 0, 3.2, 4.8, 9.2)

  local cave_qty   = int(rand.range(cave_low, cave_high))

  gui.printf("Cave quota: %d sections (%d%% of map).\n", cave_qty, int(cave_qty * 100 / 9))

  for i = 1, cave_qty do
    set_a_cave_section()
  end
end


function calc_cave_section(sx, sy)
  local cx = 2
  local cy = 2

  if sx <= LEVEL.cave_grid_sx1 then cx = 1 end
  if sx >= LEVEL.cave_grid_sx2 then cx = 3 end

  if sy <= LEVEL.cave_grid_sy1 then cx = 1 end
  if sy >= LEVEL.cave_grid_sy2 then cy = 3 end

  return cx, cy
end


function touches_cave_section(sx1, sy1, sx2, sy2)
  local cx1, cy1 = calc_cave_section(sx1, sy1)
  local cx2, cy2 = calc_cave_section(sx2, sy2)

  for x = cx1, cx2 do
  for y = cy1, cy2 do
    if LEVEL.cave_grid[x][y] then return true end
  end
  end

  return false
end

................ --]]



function Room_set_kind(R, kind, is_outdoor, is_cave)
  R.kind = kind

  if kind == "hallway" then
    R.name = string.format("HALLWAY_%d", R.id)
    R.hallway = R.hallway or {}
  end

  R.is_outdoor = is_outdoor
  R.is_cave    = is_cave

  each A in R.areas do
    A.is_outdoor = R.is_outdoor
  end
end



function Room_choose_kind(R, last_R)
  -- these outdoor probs carefully chosen so that:
  --    few   is about 15%
  --    some  is about 35%
  --    heaps is about 75%
  local out_prob

  if not last_R then
    out_prob = style_sel("outdoors", 0, 15, 30, 75)
  elseif last_R.is_outdoor then
    out_prob = style_sel("outdoors", 0,  7, 20, 70)
  else
    out_prob = style_sel("outdoors", 0, 20, 40, 90)
  end

  local is_outdoor = rand.odds(out_prob)

  -- compute a bbox from the sprout (roughly where next room will be)
  -- and check it against cave grid
--[[ FIXME : use current room bbox
  local S = P.S

  local fx, fy = geom.nudge(S.sx, S.sy, P.dir, 4)
  local rx, ry = geom.nudge(S.sx, S.sy, geom.RIGHT[P.dir], P.long + 2)
  local lx, ly = geom.nudge(S.sx, S.sy, geom. LEFT[P.dir], 2)

  local sx1 = math.min(fx, lx, rx)
  local sy1 = math.min(fy, ly, ry)
  local sx2 = math.max(fx, lx, rx)
  local sy2 = math.max(fy, ly, ry)

  local is_cave = touches_cave_section(sx1, sy1, sx2, sy2)
--]]

  return is_outdoor, false  -- is_cave
end



function Room_choose_size(R)
  -- decides whether room will be "big" or not.
  -- room kind (building, cave, etc) should have been set already.

  local prob

  if R.is_cave then
    prob = 100
  elseif R.is_outdoor then
    prob = style_sel("big_rooms", 0, 10, 20, 50)
  else
    prob = style_sel("big_rooms", 0, 20, 40, 80)
  end

  if rand.odds(prob) then
    R.is_big = true
  end

  if R.is_cave then
    R.size_limit  = SEED_W * rand.pick({ 3.0, 4.0, 5.0 })
    R.floor_limit = 2

  elseif R.is_big then
    R. size_limit = SEED_W * 4.4
    R.floor_limit = rand.pick({ 9,10,11,12 })

  else
    R. size_limit = SEED_W * 2.7
    R.floor_limit = rand.pick({ 4,5,5,6,6,7 })
  end
end


------------------------------------------------------------------------


function Room_floor_ceil_heights()
  --
  -- Computes the floor and ceiling heights of all the areas of
  -- each room, including liquids and closets.
  --

  -- Note: the 'entry_h' field also serves as a "visited already" flag

  local TRAVERSE_H = 80


  local function set_floor(A, h)
    A.floor_h = h
  end


  local function set_ceil(A, h)
    A.ceil_h = h
  end


  local function areaconn_other(IC, A)
    if IC.A1 == A then return IC.A2 end
    if IC.A2 == A then return IC.A1 end

    return nil
  end


  local function prob_for_new_floor_group(A1, A2)
    local vol_1 = A1.svolume / sel(A1.room.symmetry, 2, 1)
    local vol_2 = A2.svolume / sel(A2.room.symmetry, 2, 1)

    -- TODO

    return 0
  end


  local function visit_floor_area(R, A, grp)
    if grp == "new" then
      grp = { id=alloc_id("floor_group") }
    end

    A.floor_group = grp

    each IC in R.internal_conns do
      local A2 = areaconn_other(IC, A)

      if not A2 then continue end
      if A2.floor_group then continue end

      -- stair connections *must* use another group.
      -- direct connections generally use the same group.

      if IC.kind != "direct" or rand.odds(prob_for_new_floor_group(A, A2)) then
        visit_floor_area(R, A2, "new")
      else
        visit_floor_area(R, A2, A.floor_group)
      end
    end
  end


  local function group_floors(R)
    if R.kind == "hallway" then return end

    local start_area

    repeat
      start_area = rand.pick(R.areas)
    until start_area.mode == "floor"

    visit_floor_area(R, start_area, "new")
  end


  local function merge_floor_groups(R, group1, group2)
    if group1.id > group2.id then
      group1, group2 = group2, group1
    end

    each A in R.areas do
      if A.floor_group == group2 then
         A.floor_group =  group1
      end
    end

    group2.id = "DEAD"
  end


  local function do_floor_groups_touch(R, group1, group2)
    each A3 in R.areas do
    each A4 in R.areas do
      if A3.floor_group == group1 and
         A4.floor_group == group2 and
         A3:touches(A4)
      then
        return true
      end
    end
    end

    return false
  end


  local function try_regroup_floors(R, A1, A2)
    local group1 = A1.floor_group
    local group2 = A2.floor_group

    if not (group1 and group2) then return end

    if group1 == group2 then return end

    if group1.h != group2.h then return end

    if do_floor_groups_touch(R, group1, group2) then
      merge_floor_groups(R, group1, group2)
    end
  end


  local function regroup_floors(R)
    -- after setting floor heights in the room, this checks if two
    -- groups which touch each other have the same height

    for pass = 1, 3 do
      each A1 in R.areas do
      each A2 in R.areas do
        try_regroup_floors(R, A1, A2)
      end
      end
    end

    each A in R.areas do
      if A.floor_group then
        table.add_unique(R.floor_groups, A.floor_group)
      end
    end

    each group in R.floor_groups do
      Area_inner_points_for_group(R, group, "floor")
    end
  end


  local function ceilings_must_stay_separated(R, A1, A2)
    assert(A1 != A2)

    each IC in R.internal_conns do
      if (IC.A1 == A1 and IC.A2 == A2) or
         (IC.A1 == A2 and IC.A2 == A1)
      then
        if IC.foobie_bletch then return false end

        return (IC.kind == "direct")
      end
    end

--[[
    if not A1:touches(A2) then return false end

    return (A1.floor_group == A2.floor_group)
--]]
    return false
  end


  local function merge_ceil_groups(R, group1, group2)
    if group1.id > group2.id then
      group1, group2 = group2, group1
    end

-- stderrf("%s : merging ceil %d --> %d\n", R.name, group2.id, group1.id)

    each A in R.areas do
      if A.ceil_group == group2 then
         A.ceil_group =  group1
      end
    end

    group2.id = "DEAD"
  end


  local function try_merge_ceil_groups(R, group1, group2)
    assert(group1 != group2)

    local do_touch = false

    each A1 in R.areas do
    each A2 in R.areas do
      if A1.ceil_group != group1 then continue end
      if A2.ceil_group != group2 then continue end

      if ceilings_must_stay_separated(R, A1, A2) then return false end

      if A1:touches(A2) then do_touch = true end

      each IC in R.internal_conns do
        if (IC.A1 == A1 and IC.A2 == A2) or
           (IC.A1 == A2 and IC.A2 == A1)
        then
          do_touch = true
        end
      end
    end  -- A1, A2
    end

    if not do_touch then return false end

    merge_ceil_groups(R, group1, group2)
    return true
  end


  local function group_ceiling_pass(R)
    local groups = {}

    each A in R.areas do
      if A.ceil_group then
        table.add_unique(groups, A.ceil_group)
      end
    end

    if #groups < 2 then return false end

    rand.shuffle(groups)

    for i = 2, #groups do
    for k = 1, i - 1 do
      if try_merge_ceil_groups(R, groups[i], groups[k]) then
        return true
      end
    end
    end

    return false
  end


  local function group_ceilings(R)
    if R.is_outdoor then return end

    each A in R.areas do
      if A.mode == "floor" then
        A.ceil_group = { id=alloc_id("ceil_group") }
      end
    end

--[[
    -- pick some internal connections that should BLAH BLAH
    each IC in R.internal_conns do
      if IC.kind == "stair" or rand.odds(30) then
        IC.same_ceiling = true
      end
    end
--]]

    for loop = 1, 20 do
      group_ceiling_pass(R)
    end

    -- handle stairs
    each A in R.areas do
      if A.chunk and A.chunk.kind == "stair" and not A.chunk.prefab_def.plain_ceiling then
        local N1 = A.chunk.from_area
        local N2 = A.chunk.dest_area

        if N1.floor_h < N2.floor_h then
          A.ceil_group = N1.ceil_group
        else
          A.ceil_group = N2.ceil_group
        end
      end
    end


    each A in R.areas do
      if A.ceil_group then
        table.add_unique(R.ceil_groups, A.ceil_group)
      end
    end

    each group in R.ceil_groups do
      Area_inner_points_for_group(R, group, "ceil")
    end
  end


  local function usable_delta_h(R, from_h, h)
    if not rand.odds(R.delta_up_chance) then
      h = - h
    end

    if R.delta_limit_mode == "positive" then
      if from_h + h <= 0 then h = - h end
    else
      if from_h + h >= 0 then h = - h end
    end

    return from_h + h
  end


  local function pick_direct_delta_h(R, from_h, A1, A2)
    if STYLE.steepness == "none" then
      return from_h
    end

    -- only change height if floor_groups are different
    if A1.floor_group and A1.floor_group == A2.floor_group then
      return from_h
    end

    local h = 8

    return usable_delta_h(R, from_h, h)
  end


  local function pick_stair_delta_h(R, from_h, chunk)
    local h = chunk.prefab_def.delta_h
    assert(h)

    return usable_delta_h(R, from_h, h)
  end


  local function pick_stair_prefab(chunk)
    local A = chunk.area
    local R = A.room

    local reqs = Chunk_base_reqs(chunk, chunk.from_dir)

    reqs.kind  = "stairs"
    reqs.shape = assert(chunk.shape)

    if A.room then
      reqs.env = A.room:get_env()
    end

    -- prevent small areas connected with a lift
    -- [ FIXME : this is broken due to deep staircases ]
    if false then
      local vol_1 = chunk.from_area.svolume / sel(R.symmetry, 2, 1)
      local vol_2 = chunk.dest_area.svolume / sel(R.symmetry, 2, 1)

      if vol_1 < 7 or vol_2 < 7 then
        reqs.max_delta_h = 32
      end
    end

    local def = Fab_pick(reqs)

    -- handle symmetrical rooms AND stair groups

    for pass = 1, 2 do
      local K2 = sel(pass == 1, chunk, chunk.peer)
      if not K2 then continue end

      if K2.stair_group then
        each K3 in K2.stair_group.chunks do
          K3.prefab_def = def
        end
      else
        K2.prefab_def = def
      end
    end

    assert(chunk.prefab_def)
  end


  local function flow_through_room(A, cur_delta_h)
    gui.debugf("flow_through_room: delta %d --> %s\n", cur_delta_h, A.name)

    A.delta_h = cur_delta_h

    if A.floor_group then
      -- sanity check
      if A.floor_group.delta_h and A.floor_group.delta_h != cur_delta_h then
        error("floor group got different heights")
      end

      A.floor_group.delta_h = cur_delta_h
    end

    local R = A.room

    each C in R.internal_conns do
      local A2 = areaconn_other(C, A)

      -- not connected to this area?
      if not A2 then continue end

      assert(A2.room == A.room)

      if A2.delta_h then
        continue
      end

-- stderrf("Passing through intl conn '%s' %s<-->%s\n", C.kind, A.name, A2.name)

      if C.kind == "direct" then
        flow_through_room(A2, pick_direct_delta_h(R, cur_delta_h, A, A2))
        continue
      end

--stderrf("Visiting stair in %s\n", C.stair_chunk.area.name)

      assert(C.kind == "stair")
      assert(C.stair_chunk)

      assert(not C.stair_chunk.prefab_def)

      pick_stair_prefab(C.stair_chunk)

      local new_delta = pick_stair_delta_h(R, cur_delta_h, C.stair_chunk)

      flow_through_room(A2, new_delta)
    end
  end


  local function fix_stair_dirs(R)
    each chunk in R.stairs do
      local A = assert(chunk.area)

      local A1 = assert(chunk.from_area)
      local A2 = assert(chunk.dest_area)

-- stderrf("STAIR in %s : off %s --> face %s\n", A.name, A1.name, A2.name)

      assert(A1.floor_h)
      assert(A2.floor_h)

      set_floor(A, math.min(A1.floor_h, A2.floor_h))

      A.stair_top_h = math.max(A1.floor_h, A2.floor_h)

-- stderrf("STAIR %s : off %d --> %d  (us: %d)\n", A.name, A1.floor_h, A2.floor_h, A.floor_h)

      if A1.floor_h > A2.floor_h then
        Chunk_flip(chunk)
      end
    end
  end


  local function room_add_steps(R)
    -- NOT USED ATM [ should be done while flowing through room ]

    each C in R.internal_conns do
      local A1 = C.A1
      local A2 = C.A2

      if C.kind == "stair" then continue end

      -- ignore pools
      if A1.pool_hack or A2.pool_hack then continue end

      local diff = math.abs(A1.floor_h - A2.floor_h)
      if diff <= PARAM.jump_height then continue end

      -- FIXME : generally build single staircases (a la V6 and earlier)

      local junc = Junction_lookup(A1, A2)

      Junction_make_steps(junc)
    end
  end


  local function pick_start_area(R)
    local list = {}

    each A in R.areas do
      if A.mode == "floor" then
        table.insert(list, A)
      end
    end

    return rand.pick(list)
  end


  local function process_room(R, entry_area)
    local start_area = pick_start_area(R)

    R.delta_limit_mode = rand.sel(50, "positive", "negative")
    R.delta_up_chance  = 50

    if rand.odds(70) then
      if R.delta_limit_mode == "positive" then
        R.delta_up_chance = 90
      else
        R.delta_up_chance = 10
      end
    end

    -- recursively flow delta heights from a random starting area

    gui.debugf("ASSIGN DELTAS IN %s\n", R.name)

    flow_through_room(start_area, 0)

    local adjust_h = 0

    if entry_area then adjust_h = assert(entry_area.delta_h) end

    -- compute the actual floor heights, ensuring entry_area stays the same
    each A in R.areas do
      if A.delta_h then
        set_floor(A, R.entry_h + A.delta_h - adjust_h)
      end

--    stderrf("%s %s = %s : floor_h = %s\n", R.name, A.name, tostring(A.mode), tostring(A.floor_h))
    end

    fix_stair_dirs(R)
  end


  local function OLD__categorize_hall_shape(S, enter_dir, leave_dir, z_dir, z_size)
    local info =
    {
      dir = enter_dir
      delta_h = sel(z_size == "big", 48, 24)

      z_dir = z_dir
      z_size = z_size
      z_offset = 0
    }

    if leave_dir == enter_dir then
      info.shape = "I"

    elseif leave_dir == geom.LEFT[enter_dir] then
      info.shape = "C"
      info.mirror = false

    elseif leave_dir == geom.RIGHT[enter_dir] then
      info.shape = "C"
      info.mirror = true

    else
      error("weird hallway dirs")
    end

    if z_dir < 0 then
      if info.shape == "I" then
        info.dir = 10 - info.dir
      else
        if info.mirror then
          info.dir = geom.LEFT[info.dir]
        else
          info.dir = geom.RIGHT[info.dir]
        end

        info.mirror = not info.mirror
      end

      info.z_offset = - info.delta_h
    end

    return info
  end


  local function OLD__flow_through_hallway(R, S, enter_dir, floor_h)

-- stderrf("flow_through_hallway @ %s : %s\n", S.name, R.name)

    table.insert(R.hallway.path, S)

    S.floor_h = floor_h
    S.hall_visited = true

    R.hallway.max_h = math.max(R.hallway.max_h, floor_h)
    R.hallway.min_h = math.min(R.hallway.min_h, floor_h)

    -- collect where we can go next + where can exit
    local next_dirs = {}
    local exit_dirs = {}

    local saw_fixed = false

    each dir in geom.ALL_DIRS do
      local N = S:neighbor(dir)

      if not (N and N.area) then continue end

      if N.area.room != R then
        if N.area.room == R.hallway.R1 then R.hallway.touch_R1 = R.hallway.touch_R1 + 1 end
        if N.area.room == R.hallway.R2 then R.hallway.touch_R2 = R.hallway.touch_R2 + 1 end

-- FIXME
--???        if S.border[dir].conn and not N.area.room.entry_h then
--???          table.insert(exit_dirs, dir)
--???        end
        continue
      end

      if N.not_path then continue end
      if N.hall_visited then continue end

      -- Note: this assume fixed diagonals never branch elsewhere
      if N.fixed_diagonal then
        if not N.floor_h then
          table.insert(R.hallway.path, N)  -- needed for ceilings
          N.floor_h = floor_h
          N.hall_visited = true
        end

        saw_fixed = true
        continue
      end

      table.insert(next_dirs, dir)
    end

    -- all done?
    local total = #next_dirs + #exit_dirs

    if total == 0 then
      return
    end

    -- branching?
    if total > 1 then
      R.hallway.branched = true

      each dir in next_dirs do
        flow_through_hallway(R, S:neighbor(dir), dir, floor_h)
      end

      return
    end

    -- a single direction --

    local dir = next_dirs[1] or exit_dirs[1]

    if not S.diagonal and not saw_fixed and not S:has_door_edge() then
      S.hall_piece = categorize_hall_shape(S, enter_dir, dir, R.hallway.z_dir, R.hallway.z_size)

      floor_h = floor_h + S.hall_piece.delta_h * S.hall_piece.z_dir

      R.hallway.max_h = math.max(R.hallway.max_h, floor_h)
      R.hallway.min_h = math.min(R.hallway.min_h, floor_h)
    end

    if #next_dirs > 0 then
      return flow_through_hallway(R, S:neighbor(dir), dir, floor_h)
    end
  end


  local function OLD__hallway_other_end(R, entry_R)
    -- if the hallway has multiple exits, then one is picked arbitrarily

    each C in R.conns do
      local R2 = sel(C.A1.room == R, C.A2.room, C.A1.room)

      if R2 != entry_R then return R2 end
    end

    error("hallway error : cannot find other end")
  end


  local function do_hallway_ceiling(R)
--[[
    if R.is_outdoor then
      -- will be zone.sky_h

      -- FIXME: workaround for odd bug [ outdoors non-sync? ]
      R.areas[1].is_outdoor = true
      return
    end

    R.areas[1].ceil_h = R.areas[1].floor_h + R.hallway.height

    each S in R.hallway.path do
      if R.hallway.parent then
        S.ceil_h = R.areas[1].ceil_h
      else
        S.ceil_h = S.floor_h + R.hallway.height
      end
    end
--]]
  end


  local function process_hallway(R, conn)
    -- Note: this would be a problem if player starts could exist in a hallway
    assert(conn)

    R.hallway.max_h = R.entry_h
    R.hallway.min_h = R.entry_h

--[[
    local S, S_dir
    local from_A

    if conn.A1.room == R then
      S = conn.S1
      S_dir = 10 - conn.dir
      from_A = conn.A2
    else
      assert(conn.A2.room == R)
      S = conn.S2
      S_dir = conn.dir
      from_A = conn.A1
    end

    assert(S)
    assert(S_dir)

    R.hallway.height = 96

    R.hallway.path = {}

    R.hallway.R1 = from_A.room
    R.hallway.R2 = hallway_other_end(R, from_A.room)

    R.hallway.touch_R1 = 0
    R.hallway.touch_R2 = 0


    local flat_prob = sel(R.is_outdoor, 5, 20)

--??  if #R.areas > 1 or rand.odds(flat_prob) then
    if true then
      -- our flow logic cannot handle multiple areas [ which is not common ]
      -- hence these cases become a single flat hallway

      each A in R.areas do
        A.floor_h = R.entry_h

        if not A.is_outdoor then
          A.ceil_h = A.floor_h + R.hallway.height
        end
      end

      R.hallway.flat = true
      return
    end


    -- decide vertical direction and steepness

    R.hallway.z_dir  = rand.sel(R.zone.hall_up_prob, 1, -1)
    R.hallway.z_size = rand.sel(3, "big", "small")

    if R.hallway.z_size == "big" then
      -- steep stairs need a bit more headroom
      R.hallway.height = R.hallway.height + 24
    end


    flow_through_hallway(R, S, S_dir, R.entry_h)

    -- check all parts got a height
    each S in R.areas[1].seeds do
      if S.not_path then continue end
      assert(S.floor_h)
    end

    -- transfer heights to neighbors
    each C in R.conns do
      local N

      if C.A1.room == C.A2.room then continue end

      error("this is broken...")

      if C.A1.room == R then
        S = C.S1
        N = C.S2
      else
        assert(C.A2.room == R)
        S = C.S2
        N = C.S1
      end

      if not N.area.room.entry_h then
        local next_f = assert(S.floor_h)
        if S.hall_piece then next_f = next_f + S.hall_piece.delta_h * S.hall_piece.z_dir end
        N.area.room.next_f = next_f
      end
    end
--]]

    -- use highest floor for "the" floor_h (so that fences are high enough)
    set_floor(R.areas[1], R.hallway.max_h)

    each P in R.pieces do
      set_floor(P.area, R.hallway.max_h)

      -- FIXME TEMP RUBBISH
      P.prefab_def = assert(PREFABS.Vent_p1)
    end

    -- set ceiling heights
    do_hallway_ceiling(R)
  end


  local function process_cave(R)
    Cave_build_room(R, R.entry_h)
  end


  local function maintain_material_across_conn(C)
    if C.kind != "edge" then return false end

    if C.R1.is_cave or C.R2.is_cave then return false end
    if C.R1.kind == "hallway" or C.R2.kind == "hallway" then return false end

    if C.A1.floor_h    != C.A2.floor_h then return false end
    if C.R1.is_outdoor != C.R2.is_outdoor then return false end

    if not (C.E1.kind == "nothing" or C.E1.kind == "arch") then return false end
    if not (C.E2.kind == "nothing" or C.E2.kind == "arch") then return false end

    return true
  end


  local function select_floor_mats(R, entry_conn)
    if not R.theme.floors then return end

    -- maintain floor material if same height and no door
    if entry_conn and maintain_material_across_conn(entry_conn) then
      local A1 = entry_conn.A1
      local A2 = entry_conn.A2

      if not A1.floor_mat then
        A1, A2 = A2, A1
      end

      if A1.floor_mat then
        assert(A1.floor_h)

        R.floor_mats[A1.floor_h] = A1.floor_mat
      end
    end

    each A in R.areas do
      if A.mode != "floor" then continue end

      if A.pool_hack then continue end

      assert(A.floor_h)

      if A.peer and A.peer.floor_mat then
        A.floor_mat = A.peer.floor_mat
        continue
      end

      if not R.floor_mats[A.floor_h] then
        R.floor_mats[A.floor_h] = rand.key_by_probs(R.theme.floors)
      end

      A.floor_mat = assert(R.floor_mats[A.floor_h])
    end
  end


  local function select_ceiling_mats(R)
    -- outdoor rooms do not require ceiling materials
    if R.is_outdoor then return end

    local tab = R.theme.ceilings or R.theme.floors
    assert(tab)

    each A in R.areas do
      if A.is_outdoor then continue end
      if A.is_porch   then continue end

      if A.mode != "floor" then continue end

      assert(A.ceil_h)

      if A.peer and A.peer.ceil_mat then
        A.ceil_mat = A.peer.ceil_mat
        continue
      end

      if not R.ceil_mats[A.ceil_h] then
        R.ceil_mats[A.ceil_h] = rand.key_by_probs(tab)
      end

      A.ceil_mat = assert(R.ceil_mats[A.ceil_h])
    end
  end


  local function do_joiner(R, C, next_h)
    local chunk = assert(C.joiner_chunk)
    assert(chunk.prefab_def)

    if chunk.place == "whole" then
      chunk.area.is_outdoor = nil
    end

    local delta_h = chunk.prefab_def.delta_h or 0

    local flipped = chunk.flipped
    if chunk.area.room != R then flipped = not flipped end

    if flipped then delta_h = - delta_h end

    local joiner_h = math.min(next_h, next_h + delta_h)

    set_floor(C.joiner_chunk.area, joiner_h)

-- stderrf("  setting joiner in %s to %d\n", C.joiner_chunk.area.name, C.joiner_chunk.area.floor_h)
-- stderrf("  loc: (%d %d)\n", C.joiner_chunk.sx1, C.joiner_chunk.sy1)

    return next_h + delta_h
  end


  local function visit_room(R, entry_h, entry_area, prev_room, via_conn)
    group_floors(R)

    if entry_area then
      assert(entry_area.room == R)
      assert(entry_area.mode != "joiner")
    end

    -- handle start rooms and teleported-into rooms
    if not entry_h then
      entry_h = rand.irange(0, 4) * 64
    end

    R.entry_h = entry_h

    if via_conn then
      via_conn.door_h = entry_h
    end

--[[  do this elsewhere?
    if R.kind != "hallway" then
      Room_detect_porches(R)
    end
--]]

    if R.kind == "hallway" then
      process_hallway(R, via_conn)

    elseif R.is_cave then
      process_cave(R)

    else
      process_room(R, entry_area)
      select_floor_mats(R, via_conn)
    end

    -- recurse to neighbors
    each C in R.conns do
      if C.is_cycle then continue end

      local R2, A2, A1
      if C.R1 == R then R2 = C.R2 else R2 = C.R1 end
      if C.R1 == R then A2 = C.A2 else A2 = C.A1 end
      if C.R1 == R then A1 = C.A1 else A1 = C.A2 end

      -- already visited it?
      if R2.entry_h then continue end

      gui.debugf("Recursing though %s (%s)\n", C.name, C.kind)
-- if C.kind != "teleporter"then
-- stderrf("  %s / %s ---> %s / %s\n", A1.name, A1.mode, A2.name, A2.mode)
-- end

      if C.kind == "teleporter" then
        visit_room(R2, nil, nil, R, C)
        continue
      end

      assert(A1.mode != "joiner")
      assert(A2.mode != "joiner")

      assert(A1.floor_h)

      local next_h = A1.floor_h

      if C.kind == "joiner" then
        next_h = do_joiner(R, C, next_h)
      end

      visit_room(R2, next_h, A2, R, C)
    end
  end


  local function do_liquid_areas(R)
    each A in R.areas do
      if A.mode == "liquid" then
        local N = A:lowest_neighbor()

        if not N then
          error("failed to find liquid neighbor")
        end

        A.floor_h  = N.floor_h - 16
        A.ceil_h   = N.ceil_h
        A.ceil_mat = N.ceil_mat
      end
    end
  end


  local function get_cage_neighbor(A)
    local N = A:highest_neighbor()

    if N then return N end

    each N2 in A.neighbors do
      if N2.mode == "liquid" then return N2 end
    end

    error("failed to find cage neighbor")
  end


  local function kill_start_cages(R)
    -- turn closets in start rooms into a plain floor

    each A in R.areas do
      if A.mode != "cage" then continue end

      local N

      if A.peer and A.peer.floor_h then
        N = A.peer
      else
        N = get_cage_neighbor(A)
      end

      A.mode = N.mode

      A.floor_h   = N.floor_h
      A.floor_mat = N.floor_mat

      A.ceil_h    = N.ceil_h
      A.ceil_mat  = N.ceil_mat
    end
  end


  local function add_cage_lighting(R, A)
    if not R.cage_light_fx then
      --  8 = oscillates
      -- 17 = flickering
      -- 12 = flashes @ 1 hz
      -- 13 = flashes @ 2 hz
      R.cage_light_fx = rand.pick({ 0,8,12,13,17 })
    end

    if R.cage_light_fx == 0 then
      -- no effect
      A.bump_light = 32
      return
    end

    A.bump_light = 48
    A.sector_fx  = R.cage_light_fx
  end


  local function do_a_cage(R, A)
    -- for symmetry, ensure second cage is same as first
    if A.peer and A.peer.floor_h then
      local P = A.peer

      A.floor_h   = P.floor_h
      A.floor_mat = P.floor_mat

      A.ceil_h    = P.ceil_h
      A.ceil_mat  = P.ceil_mat

      A.bump_light = P.bump_light
      A.sector_fx  = P.sector_fx

      if table.has_elem(R.cage_rail_areas, P) then
        table.insert(R.cage_rail_areas, A)
      end

      return
    end

    local N = get_cage_neighbor(A)

    if not N.cage_floor_h then
      N.cage_floor_h = N.floor_h + rand.pick({40,56,72})
    end

    A.floor_h  = N.cage_floor_h
    if N.ceil_h then
      A.floor_h = math.min(A.floor_h, N.ceil_h - 64)
    end

    A.ceil_h   = A.floor_h + 72
    A.ceil_mat = N.ceil_mat

    if A.is_outdoor then
      A.floor_mat = LEVEL.cliff_mat
    else
      A.floor_mat = A.zone.cage_mat
    end
    assert(A.floor_mat)

    -- fancy cages
    if A.cage_mode or (#A.seeds >= 4 and rand.odds(50)) then
      A.floor_mat = A.zone.cage_mat

      table.insert(R.cage_rail_areas, A)

      if not R.is_outdoor then
        if N.ceil_h and N.ceil_h > A.ceil_h + 72 then
          A.ceil_h = N.ceil_h
        else
          A.ceil_mat = A.floor_mat
        end

        add_cage_lighting(R, A)
      end
    end
  end


  local function do_cage_areas(R)
    if R.is_start then
      kill_start_cages(R)
      return
    end

    R.cage_rail_areas = {}

    each A in R.areas do
      if A.mode == "cage" then
        do_a_cage(R, A)
      end
    end
  end


  local function do_stairs(R)
    each chunk in R.stairs do
      local A = chunk.area

      if A.is_outdoor then
        A.ceil_h = A.floor_h + 256
        continue
      end

      local N = chunk.from_area
      assert(N.ceil_h)

      A.ceil_h   = N.ceil_h
      A.ceil_mat = N.ceil_mat
    end
  end


  local function do_closets(R)
    each chunk in R.closets do
      local A = chunk.area

      assert(chunk.from_area)
      A.floor_h = assert(chunk.from_area.floor_h)

      if chunk.place == "whole" then
        A.is_outdoor = nil
      end
    end
  end


  local function calc_max_floor(R)
    R.max_floor_h = -7777

    each A in R.areas do
      if A.floor_h then
        R.max_floor_h = math.max(R.max_floor_h, A.floor_h)

        if A.floor_group then A.floor_group.h = A.floor_h end
      end
    end
  end


  local function check_joiner_nearby_h(A)
    each C in LEVEL.conns do
      if C.kind == "joiner" and (C.A1 == A or C.A2 == A) then
        return C.joiner_chunk.prefab_def.nearby_h
      end
    end

    return nil
  end


  local function calc_ceil_stuff(R, group)
    group.vol = 0

    each A in R.areas do
      if A.ceil_group == group then
        group.vol = group.vol + A.svolume

        group.min_floor_h = math.N_min(A.floor_h, group.min_floor_h)
        group.max_floor_h = math.N_max(A.floor_h, group.max_floor_h)
      end
    end

    if R.symmetry then group.vol = group.vol / 2 end

    assert(group.max_floor_h)

    group.min_h = 96

    each A in R.areas do
      if A.ceil_group == group and A:has_conn() then
        -- TODO : get nearby_h from arch/door prefab  [ but it aint picked yet... ]
        local min_h = A.floor_h + 128 - group.max_floor_h
        group.min_h = math.max(group.min_h, min_h)

        min_h = check_joiner_nearby_h(A)
        if min_h then
          min_h = A.floor_h + min_h - group.max_floor_h
          group.min_h = math.max(group.min_h, min_h)
        end
      end
    end

--[[
    stderrf("%s : ceil group %d : vol=%d  min=%d  max=%d\n", R.name, group.id,
        group.vol, group.min_floor_h, group.max_floor_h)
--]]
  end


  local function calc_a_ceiling_height(R, group)
    local add_h

        if group.vol <  8 then add_h = 96
    elseif group.vol < 16 then add_h = 128
    elseif group.vol < 32 then add_h = 160
    elseif group.vol < 48 then add_h = 192
    else                       add_h = 256
    end

    if add_h > 128 and group.max_floor_h >= group.min_floor_h + 64 then
      add_h = add_h - 32
    end

    add_h = math.max(group.min_h, add_h)

    group.h = group.max_floor_h + add_h
  end


  local function ceil_ensure_traversibility(R)
    -- ensure enough vertical room for player to travel between two
    -- internally connected areas

    each IC in R.internal_conns do
      local A1 = IC.A1
      local A2 = IC.A2

      local top_z = math.max(A1.floor_h, A2.floor_h)

      if A1.stair_top_h then top_z = math.max(top_z, A1.stair_top_h) end
      if A2.stair_top_h then top_z = math.max(top_z, A2.stair_top_h) end

      top_z = top_z + TRAVERSE_H

      if A1.ceil_group then
        while A1.ceil_group.h < top_z do A1.ceil_group.h = A1.ceil_group.h + 32 end
      else
        A1.traverse_ceil_h = top_z
      end

      if A2.ceil_group then
        while A2.ceil_group.h < top_z do A2.ceil_group.h = A2.ceil_group.h + 32 end
      else
        A2.traverse_ceil_h = top_z
      end
    end
  end


  local function ceiling_group_heights(R)
    --
    -- Notes:
    --   a major requirement is the ceiling groups which neighbor
    --   each other (incl. via a stair) get a unique ceil_h.
    --
    --   a lesser goal is that larger ceiling groups get a higher
    --   ceiling than smaller ones.
    --

    local groups = {}

    each A in R.areas do
      if A.ceil_group then
        table.add_unique(groups, A.ceil_group)
      end
    end

    each group in groups do
      calc_ceil_stuff(R, group)
    end

    rand.shuffle(groups)

    each group in groups do
      calc_a_ceiling_height(R, group)
    end

    ceil_ensure_traversibility(R)

    -- TODO if largest ceil-group is same as a neighbor, raise by 32 until different
  end


  local function do_ceilings(R)
    group_ceilings(R)

    if not R.is_outdoor then
      ceiling_group_heights(R)
    end

    each A in R.areas do
      if A.mode != "floor" then continue end

      -- outdoor heights are done later, get a dummy now
      if A.is_outdoor then
        A.ceil_h = A.floor_h + R.zone.sky_add_h - 8
        continue
      end

      if A.peer and A.peer.ceil_h then
        A.ceil_h = A.peer.ceil_h
        continue
      end

      if A.ceil_group then
        set_ceil(A, assert(A.ceil_group.h))
        continue
      end

      local height = rand.pick({ 128, 192,192,192, 256,320 })

      if A.is_porch then
        height = 144
      end

---## if not A.floor_h then
---## gui.debugf("do_ceilings : no floor_h in %s %s in %s\n", A.name, A.mode, A.room.name)
---## end
      assert(A.floor_h)

      local new_h = R.max_floor_h + 128

      if A.traverse_ceil_h then new_h = math.max(new_h, A.traverse_ceil_h) end

      set_ceil(A, new_h)
    end

    -- now pick textures
    select_ceiling_mats(R)
  end


  local function sanity_check()
    each R in LEVEL.rooms do
      if not R.entry_h then
--[[ "fubar" debug stuff
R.entry_h = -77
each A in R.areas do A.floor_h = R.entry_h end
end
--]]
        error("Room did not get an entry_h")
      end
    end
  end


  ---| Room_floor_ceil_heights |---

  -- give each zone a preferred hallway z_dir  [ NOT USED ATM ]
  each Z in LEVEL.zones do
    Z.hall_up_prob = rand.sel(70, 80, 20)
  end

  local first = LEVEL.start_room or LEVEL.blue_base or LEVEL.rooms[1]

  -- recursively visit all rooms
  visit_room(first)

  -- sanity check : all rooms were visited
  sanity_check()

  each R in LEVEL.rooms do
    calc_max_floor(R)

    if not R.is_cave then
      regroup_floors(R)

      do_ceilings(R)
      do_liquid_areas(R)
    end

    do_cage_areas(R)
    do_stairs(R)

    do_closets(R)
  end
end



function Room_add_cage_rails()
  -- this must be called AFTER scenic borders are finished, since
  -- otherwise we won't know the floor_h of border areas.

  local function rails_in_cage(A)
    each N in A.neighbors do
      if N.zone != A.zone then continue end

      -- don't place railings on higher floors (it looks silly)
      if N.floor_h and N.floor_h > A.floor_h then continue end

      if true then
        local junc = Junction_lookup(A, N)

        junc.rail_mat   = "MIDBARS3"
        junc.rail_block = true
      end
    end
  end


  ---| Room_add_cage_rails |---

  each R in LEVEL.rooms do
    if R.cage_rail_areas then
      each A in R.cage_rail_areas do
        rails_in_cage(A)
      end
    end
  end
end



function Room_set_sky_heights()

  local function do_area(A)
    local sky_h = A.floor_h + A.zone.sky_add_h

    A.zone.sky_h = math.N_max(A.zone.sky_h, sky_h)

    if A.is_porch then
      A.zone.sky_h = math.max(A.zone.sky_h, A.ceil_h + 48)
    end
  end


  ---| Room_set_sky_heights |---

  each A in LEVEL.areas do
    -- visit all normal, outdoor areas
    if A.floor_h and A.is_outdoor and not A.is_boundary then
      do_area(A)

      -- include nearby buildings in same zone
      -- [ TODO : perhaps limit to where areas share a window or doorway ]
--???      each N in A.neighbors do
--???        if N.zone == A.zone and N.floor_h and not N.is_outdoor and not N.is_boundary then
--???          do_area(N)
--???        end
--???      end
    end
  end

  -- ensure every zone gets a sky_h
  each Z in LEVEL.zones do
    if not Z.sky_h then
      Z.sky_h = 0
      Z.no_outdoors = true
    end
  end

  -- transfer final results into areas

  each A in LEVEL.areas do
    if A.floor_h and A.is_outdoor and not A.is_porch then
      A.ceil_h = A.zone.sky_h
    end
  end
end



function Room_add_sun()
  -- game check
  if not GAME.ENTITIES["sun"] then return end

  local sun_r = 25000
  local sun_h = 40000

  -- nine lights in the sky, one is "the sun" and the rest provide
  -- ambient light (to keep outdoor areas from getting too dark).

  local dim = 4
  local bright = 40

  for i = 1,10 do
    local angle = i * 36 - 18

    local x = math.sin(angle * math.pi / 180.0) * sun_r
    local y = math.cos(angle * math.pi / 180.0) * sun_r

    local level = sel(i == 2, bright, dim)

    Trans.entity("sun", x, y, sun_h, { light=level })
  end

  Trans.entity("sun", 0, 0, sun_h, { light=dim })
end



function Room_add_camera()
  -- this is used for Quake intermissions

  -- game check
  if not GAME.ENTITIES["camera"] then return end

  -- TODO
end



function Room_pool_hacks__OLD()

  local function similar_room(A1, A2)
    local R1 = A1.room
    local R2 = A2.room

    if R1 == R2 then return true end

    return false
  end


  local function can_become_pool(A)
    if not A.room then return false end
    if A.is_porch then return false end

    -- room is too simple?
    if #A.room.areas < 2 then return false end

    -- too small?
    if A.svolume < 2 then return false end

    -- external connection?
    each C in A.room.conns do
      if C.A1 == A or C.A2 == A then return false end
    end

    -- check number of "roomy" neighbors
    local count = 0

    each N in A.neighbors do
      if N.room and similar_room(A, N) then
        count = count + 1
      end
    end

    return (count < 2)
  end

  ---| Room_pool_hacks |---

  if not LEVEL.liquid then return end

  local prob = style_sel("liquids", 0, 20, 40, 80);

  if prob == 0 then return end

  each A in LEVEL.areas do
    if not A.room then continue end

    if can_become_pool(A) and rand.odds(prob) then
      A.pool_hack = true
    end
  end
end


------------------------------------------------------------------------


function Room_build_all()

  gui.printf("\n--==|  Build Rooms |==--\n\n")

  -- place importants early as traps need to know where they are.
  Layout_place_all_importants()

  Layout_indoor_lighting()

  -- this does traps, and may add switches which lock a door / joiner
  Layout_add_traps()
  Layout_decorate_rooms(1)

  -- do doors before floor heights, they may have a delta_h (esp. joiners)
  Room_reckon_door_tex()
  Room_reckon_doors()
  Room_prepare_skies()

  Room_floor_ceil_heights()
  Room_set_sky_heights()

  -- this does other stuff (crates, free-standing cages, etc..)
  Layout_decorate_rooms(2)

  Layout_liquid_stuff()
  Layout_create_scenic_borders()

  Room_border_up()

  Layout_finish_scenic_borders()
  Room_add_cage_rails()

  Layout_handle_corners()
  Layout_outdoor_shadows()

  Render_set_all_properties()

  -- we must build importants after "normal" area geometry, since we
  -- rely on world traces to determine player facing directions.
  Render_all_areas()

  -- this does other decorative prefabs too
  Render_importants()
  Render_triggers()

  Room_determine_spots()

  Room_add_sun()
  Room_add_camera()
end


------------------------------------------------------------------------
--  STUFF FOR TESTING THE CSG CODE
------------------------------------------------------------------------

function Quake3_test()

--- Trans.set({ rotate=30 })

  local F = brushlib.quad(0, 128, 256, 384,  -24, 0)
  local C = brushlib.quad(0, 128, 256, 384,  192, 208)

  local W = brushlib.quad(0,   128,  32, 384,  0, 192)
  local E = brushlib.quad(224, 128, 256, 384,  0, 192)
  local S = brushlib.quad(0,   128, 256, 144,  0, 192)
  local N = brushlib.quad(0,   370, 256, 384,  0, 192)


  -- slope test --

  if false then
    F = brushlib.quad(32, 144, 224, 370, -256,   0)
    C = brushlib.quad(32, 144, 224, 370,  192, 512)

    W = brushlib.quad(0,   128,  32, 384, -256, 512)
    E = brushlib.quad(224, 128, 256, 384, -256, 512)
    S = brushlib.quad(0,   128, 256, 144, -256, 512)
    N = brushlib.quad(0,   370, 256, 384, -256, 512)

    brushlib.slope_top(F, 0.3, 0.0, 1.0)

    brushlib.slope_bottom(C, 0.0, 0.7, -1.0)
  end


  local F_tex = "base_floor/clang_floor_s2"
  local C_tex = "cosmo_floor/bfloor3"
  local W_tex = "gothic_block/blocks15"

  brushlib.set_tex(F, F_tex, F_tex)
  brushlib.set_tex(C, C_tex, C_tex)

  brushlib.set_tex(N, W_tex, W_tex)
  brushlib.set_tex(S, W_tex, W_tex)
  brushlib.set_tex(E, W_tex, W_tex)
  brushlib.set_tex(W, W_tex, W_tex)


  Trans.brush(F) ; Trans.brush(C)
  Trans.brush(S) ; Trans.brush(N)
  Trans.brush(W) ; Trans.brush(E)


  Trans.entity("player1", 80, 256, 130)
  Trans.entity("light",   80, 256, 160, { light=200 })


  -- corner test --

  if false then
    local P_tex = "base_trim/pewter_shiney"

    local P = brushlib.quad(128, 256, 224, 370, 0, 170)

    brushlib.set_tex(P, P_tex, P_tex)

--  brushlib.slope_top(P, -1, -1, 1.4)

    Trans.brush(P)
  end


  -- clip test --

  if false then
    local P_tex = "common/clip"

    local P = brushlib.quad(192, 140, 224, 370, 0, 31)

    brushlib.set_tex(P, P_tex, P_tex)
    brushlib.set_kind(P, "clip")

    Trans.brush(P)
  end


  -- liquid test --

  if false then
    local L_tex = "liquids/hydrowater"

    gui.property("water_shader", L_tex)

    local L = brushlib.quad(0, 128, 256, 384, -1024, 64)

    brushlib.set_tex(L, "nothing", "nothing")
    brushlib.set_kind(L, "liquid", { detail=1, medium="water" })

    -- only top face should have a real texture
    each coord in L do
      if coord.t then
         coord.tex = L_tex
      end
    end

    Trans.brush(L)
  end


  -- model test --

  if false then
    -- create an entity table.
    -- the 'link_id' field must be unique, and links brushes to the entity.
    -- the coordinates will be unused.
    local ent =
    {
      id = "func_static"

      link_id = "m1"

      x = 0
      y = 0
      z = 0
    }

    raw_add_entity(ent)

    local M_tex = "base_trim/pewter_shiney"
    local M = brushlib.quad(170, 260, 210, 310, 30, 100)

    brushlib.slope_top(M, -0.5, -0.5, 1.0)

    brushlib.set_tex (M, M_tex, M_tex)
    brushlib.set_kind(M, "solid", { link_entity=ent.link_id })

    Trans.brush(M)
  end
end


function Quake3_conversion()
  each B in all_brushes do
    if B[1].m != "xxxliquid" then
      Trans.brush(B)
    end
  end

  each E in all_entities do
    if E.id != "nothing" then
      raw_add_entity(E)
    end
  end
end

