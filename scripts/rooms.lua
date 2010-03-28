----------------------------------------------------------------
--  Room Management
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2010 Andrew Apted
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

--[[ *** CLASS INFORMATION ***

class ROOM
{
  kind : keyword  -- "normal" (layout-able room)
                  -- "scenic" (unvisitable room)
                  -- "hallway", "stairwell", "small_exit"

  outdoor : bool  -- true for outdoor rooms
  natural : bool  -- true for cave/landscape areas
  scenic  : bool  -- true for scenic (unvisitable) areas

  conns : array(CONN)  -- connections with neighbor rooms
  entry_conn : CONN

  branch_kind : keyword

  hallway : HALLWAY_INFO   -- for hallways and stairwells

  symmetry : keyword   -- symmetry of room, or NIL
                       -- keywords are "x", "y", "xy"

  sx1, sy1, sx2, sy2  -- \ Seed range
  sw, sh, svolume     -- /

  floor_h, ceil_h : number

  purpose : keyword   -- usually NIL, can be "EXIT" etc... (FIXME)

  arena : ARENA


  --- plan_sp code only:

  lx1, ly1, lx2, ly2  -- coverage on the Land Map

  group_id : number  -- traversibility group

}


----------------------------------------------------------------


Room Layouting Notes
====================


DIAGONALS:
   How they work:

   1. basic model: seed is a liquid or walk area which has an
      extra piece stuck in it (the diagonal) which is
      either totally solid or same as a neighbouring higher floor.
      We first build the extra bit, then convert the seed to what
      it should be (change S.kind from "diagonal" --> "liquid" or "walk")
      and build the ceiling/floor normally.

   2. The '/' and '%' in patterns go horizontally, whereas
      the 'Z' and 'N' go vertically.  If the pattern is
      transposed then we exchange '/' with 'Z', '%' with 'N'.

   3. once the room is fully laid out, then we can process
      these diagonals and determine the main seed info
      (e.g. liquid) and the Stuckie piece (e.g. void).


--------------------------------------------------------------]]


require 'defs'
require 'util'


function Rooms_decide_outdoors()
  local function choose(R)
    if R.parent and R.parent.outdoor then return false end
    if R.parent then return rand_odds(5) end

    if R.natural then
      if not THEME.landscape_walls then return false end
    else
      if not THEME.courtyard_floors then return false end
    end

    if STYLE.skies == "none"   then return false end
    if STYLE.skies == "always" then return true end

    if R.natural then
      if STYLE.skies == "heaps" then return rand_odds(75) end
      return rand_odds(25)
    end

    -- we would prefer KEY locked doors to touch at least one
    -- indoor room.  However keys/switches are not decided yet,
    -- so the following is a compromise solution.
    if R:has_any_lock() and rand_odds(20) then return false end

    if R.children then
      if STYLE.skies == "few" then
        return rand_odds(33)
      else
        return rand_odds(80)
      end
    end

    if STYLE.skies == "heaps" then return rand_odds(50) end
    if STYLE.skies == "few"   then return rand_odds(5) end

    -- room on edge of map?
    if R.sx1 <= 2 or R.sy1 <= 2 or R.sx2 >= SEED_W-1 or R.sy2 >= SEED_H-1 then
      return rand_odds(30)
    end

    return rand_odds(10)
  end

  ---| Rooms_decide_outdoors |---

  for _,R in ipairs(LEVEL.all_rooms) do
    if R.outdoor == nil then
      R.outdoor = choose(R)
    end
    if R.outdoor then
      R.sky_h = SKY_H
    end
  end
end


function Rooms_select_textures()
  if not LEVEL.building_facades then
    LEVEL.building_facades = {}

    for num = 1,2 do
      local name = rand_key_by_probs(THEME.building_facades or THEME.building_walls)
      LEVEL.building_facades[num] = name
    end
  end

  if not LEVEL.building_walls then
    LEVEL.building_walls = {}

    for num = 1,3 do
      local name = rand_key_by_probs(THEME.building_walls)
      LEVEL.building_walls[num] = name
    end
  end

  if not LEVEL.courtyard_floors then
    LEVEL.courtyard_floors = {}

    if not THEME.courtyard_floors then
      LEVEL.courtyard_floors[1] = rand_key_by_probs(THEME.building_floors)
    else
      for num = 1,2 do
        local name = rand_key_by_probs(THEME.courtyard_floors)
        LEVEL.courtyard_floors[num] = name
      end
    end
  end

  -- TODO: caves and landscapes

  gui.printf("Selected room textures:\n")

  gui.printf("building_facades =\n%s\n\n", table_to_str(LEVEL.building_facades))
  gui.printf("building_walls =\n%s\n\n",   table_to_str(LEVEL.building_walls))
  gui.printf("courtyard_floors =\n%s\n\n", table_to_str(LEVEL.courtyard_floors))
end


function Room_setup_theme(R)
  if not R.outdoor then
    R.main_tex = rand_element(LEVEL.building_walls)
    return
  end

  if not R.arena.courtyard_floor then
    R.arena.courtyard_floor = rand_element(LEVEL.courtyard_floors)
  end

  R.main_tex = R.arena.courtyard_floor
end

function Room_setup_theme_Scenic(R)
  R.outdoor = true  -- ???

  --[[

  -- find closest non-scenic room
  local mx = int((R.sx1 + R.sx2) / 2)
  local my = int((R.sy1 + R.sy2) / 2)

  for dist = -SEED_W,SEED_W do
    if Seed_valid(mx + dist, my, 1) then
      local S = SEEDS[mx + dist][my][1]
      if S.room and S.room.kind == "scenic" and
         S.room.combo
---      and (not S.room.outdoor) == (not R.outdoor)
      then
        R.combo = S.room.combo
        -- R.outdoor = S.room.outdoor
        return
      end
    end

    if Seed_valid(mx, my + dist, 1) then
      local S = SEEDS[mx][my + dist][1]
      if S.room and S.room.kind == "scenic" and
         S.room.combo
---      and (not S.room.outdoor) == (not R.outdoor)
      then
        R.combo = S.room.combo
        R.outdoor = S.room.outdoor
        return
      end
    end
  end

  --]]

  -- fallback
  if R.outdoor then
    R.main_tex = rand_element(LEVEL.courtyard_floors)
  else
    R.main_tex = rand_element(LEVEL.building_walls)
  end
end

function Rooms_assign_facades()
  for i = 1,#LEVEL.all_rooms,4 do
    local R = LEVEL.all_rooms[i]
    R.facade = rand_element(LEVEL.building_facades)
  end

  local visits = shallow_copy(LEVEL.all_rooms)

  for loop = 1,10 do
    local changes = false

    rand_shuffle(visits);

    for _,R in ipairs(visits) do
      if R.facade then
        for _,N in ipairs(R.neighbors) do
          if not N.facade then 
            N.facade = R.facade
            changes = true
          end
        end -- for N
      elseif rand_odds(loop * loop) then
        R.facade = rand_element(LEVEL.building_facades)
      end
    end -- for R
  end -- for loop

  for _,R in ipairs(LEVEL.all_rooms) do
    assert(R.facade)
  end

  for _,R in ipairs(LEVEL.scenic_rooms) do
    if not R.facade then
      R.facade = rand_element(LEVEL.building_facades)
    end
  end
end

function Rooms_choose_themes()
  for _,R in ipairs(LEVEL.all_rooms) do
    Room_setup_theme(R)
  end
  for _,R in ipairs(LEVEL.scenic_rooms) do
    Room_setup_theme_Scenic(R)
  end

  Rooms_assign_facades()
end


function Rooms_decide_hallways_II()
  -- Marks certain rooms to be hallways, using the following criteria:
  --   - indoor non-leaf room
  --   - prefer small rooms
  --   - prefer all neighbors are indoor
  --   - no purpose (not a start room, exit room, key room)
  --   - no teleporters
  --   - not the destination of a locked door (anti-climactic)

  local HALL_SIZE_PROBS = { 98, 84, 60, 40, 20, 10 }
  local HALL_SIZE_HEAPS = { 98, 95, 90, 70, 50, 30 }
  local REVERT_PROBS    = {  0,  0, 25, 75, 90, 98 }

  local function eval_hallway(R)
    if R.outdoor or R.natural or R.children or R.purpose then
      return false
    end

    if #R.teleports > 0 then return false end
    if R.num_branch < 2 then return false end
    if R.num_branch > 4 then return false end

    local outdoor_chance = 5
    local lock_chance    = 50

    if STYLE.hallways == "heaps" then
      outdoor_chance = 50
      lock_chance = 90
    end

    for _,C in ipairs(R.conns) do
      local N = C:neighbor(R)
      if N.outdoor and not rand_odds(outdoor_chance) then
        return false
      end

      if C.dest == R and C.lock and not rand_odds(lock_chance) then
        return false
      end
    end

    local min_d = math.min(R.sw, R.sh)

    if min_d > 6 then return false end

    if STYLE.hallways == "heaps" then
      return rand_odds(HALL_SIZE_HEAPS[min_d])
    end

    if STYLE.hallways == "few" and rand_odds(66) then
      return false end

    return rand_odds(HALL_SIZE_PROBS[min_d])
  end

  local function hallway_neighbors(R)
    local hall_nb = 0
    for _,C in ipairs(R.conns) do
      local N = C:neighbor(R)
      if N.hallway then hall_nb = hall_nb + 1 end
    end

    return hall_nb
  end

  local function surrounded_by_halls(R)
    local hall_nb = hallway_neighbors(R)
    return (hall_nb == #R.conns) or (hall_nb >= 3)
  end

  local function stairwell_neighbors(R)
    local swell_nb = 0
    for _,C in ipairs(R.conns) do
      local N = C:neighbor(R)
      if N.stairwell then swell_nb = swell_nb + 1 end
    end

    return swell_nb
  end

  local function locked_neighbors(R)
    local count = 0
    for _,C in ipairs(R.conns) do
      if C.lock then count = count + 1 end
    end

    return count
  end


  ---| Room_decide_hallways |---

  if not THEME.hallway_walls then
    gui.printf("Hallways disabled (no theme info)\n")
    return
  end

  if STYLE.hallways == "none" then
    return
  end

  for _,R in ipairs(LEVEL.all_rooms) do
    if eval_hallway(R) then
gui.debugf("  Made Hallway @ %s\n", R:tostr())
      R.kind = "hallway"
      R.hallway = { }
      R.outdoor = nil
    end
  end

  -- large rooms which are surrounded by hallways are wasted,
  -- hence look for them and revert them back to normal.
  for _,R in ipairs(LEVEL.all_rooms) do
    if R.hallway and surrounded_by_halls(R) then
      local min_d = math.min(R.sw, R.sh)

      assert(min_d <= 6)

      if rand_odds(REVERT_PROBS[min_d]) then
        R.kind = "normal"
        R.hallway = nil
gui.debugf("Reverted HALLWAY @ %s\n", R:tostr())
      end
    end
  end

  -- decide stairwells
  for _,R in ipairs(LEVEL.all_rooms) do
    if R.hallway and R.num_branch == 2 and
       not R.purpose and not R.weapon and
       stairwell_neighbors(R) == 0 and
       locked_neighbors(R) == 0 and
       THEME.stairwell
    then
      local hall_nb = hallway_neighbors(R) 

      local prob = 80
      if hall_nb >= 2 then prob = 2  end
      if hall_nb == 1 then prob = 40 end

      if rand_odds(prob) then
        R.kind = "stairwell"
      end
    end
  end -- for R

  -- we don't need archways where two hallways connect
  for _,C in ipairs(LEVEL.all_conns) do
    if not C.lock and C.src.hallway and C.dest.hallway then
      local S = C.src_S
      local T = C.dest_S
      local dir = S.conn_dir

      if S.border[S.conn_dir].kind == "arch" or
         T.border[T.conn_dir].kind == "arch"
      then
        S.border[S.conn_dir].kind = "nothing"
        T.border[T.conn_dir].kind = "nothing"
      end
    end
  end -- for C
end


function Rooms_setup_symmetry()
  -- The 'symmetry' field of each room already has a value
  -- (from the big-branch connection system).  Here we choose
  -- whether to keep that, expand it (rare) or discard it.
  --
  -- The new value applies to everything made in the room
  -- (as much as possible) from now on.

  local function prob_for_match(old_sym, new_sym)
    if old_sym == new_sym then
      return sel(old_sym == "xy", 8000, 400)

    elseif new_sym == "xy" then
      -- rarely upgrade from NONE --> XY symmetry
      return sel(old_sym, 30, 3)

    elseif old_sym == "xy" then
      return 150

    else
      -- rarely change from X --> Y or vice versa
      return sel(old_sym, 6, 60)
    end
  end

  local function prob_for_size(R, new_sym)
    local prob = 200

    if new_sym == "x" or new_sym == "xy" then
      if R.sw <= 2 then return 0 end
      if R.sw <= 4 then prob = prob / 2 end

      if R.sw > R.sh * 3.1 then return 0 end
      if R.sw > R.sh * 2.1 then prob = prob / 3 end
    end

    if new_sym == "y" or new_sym == "xy" then
      if R.sh <= 2 then return 0 end
      if R.sh <= 4 then prob = prob / 2 end

      if R.sh > R.sw * 3.1 then return 0 end
      if R.sh > R.sw * 2.1 then prob = prob / 3 end
    end

    return prob
  end

  local function decide_layout_symmetry(R)
    R.conn_symmetry = R.symmetry

    -- We discard 'R' rotate and 'T' transpose symmetry (for now...)
    if not (R.symmetry == "x" or R.symmetry == "y" or R.symmetry == "xy") then
      R.symmetry = nil
    end

    if STYLE.symmetry == "none" then return end

    local SYM_LIST = { "x", "y", "xy" }

    local syms  = { "none" }
    local probs = { 100 }

    if STYLE.symmetry == "few"   then probs[1] = 500 end
    if STYLE.symmetry == "heaps" then probs[1] = 10  end

    for _,sym in ipairs(SYM_LIST) do
      local p1 = prob_for_size(R, sym)
      local p2 = prob_for_match(R.symmetry, sym)

      if p1 > 0 and p2 > 0 then
        table.insert(syms, sym)
        table.insert(probs, p1*p2/100)
      end
    end

    local index = rand_index_by_probs(probs)

    R.symmetry = sel(index > 1, syms[index], nil)
  end

  local function mirror_horizontally(R)
    if R.sw >= 2 then
      for y = R.sy1, R.sy2 do
        for dx = 0, int((R.sw-2) / 2) do
          local LS = SEEDS[R.sx1 + dx][y][1]
          local RS = SEEDS[R.sx2 - dx][y][1]

          if LS.room == R and RS.room == R then
            LS.x_peer = RS
            RS.x_peer = LS
          end
        end
      end
    end
  end

  local function mirror_vertically(R)
    if R.sh >= 2 then
      for x = R.sx1, R.sx2 do
        for dy = 0, int((R.sh-2) / 2) do
          local BS = SEEDS[x][R.sy1 + dy][1]
          local TS = SEEDS[x][R.sy2 - dy][1]

          if BS.room == R and TS.room == R then
            BS.y_peer = TS
            TS.y_peer = BS
          end
        end
      end
    end
  end


  --| Rooms_setup_symmetry |--

  for _,R in ipairs(LEVEL.all_rooms) do
    decide_layout_symmetry(R)

    gui.debugf("Final symmetry @ %s : %s --> %s\n", R:tostr(),
               tostring(R.conn_symmetry), tostring(R.symmetry))

    if R.symmetry == "x" or R.symmetry == "xy" then
      R.mirror_x = true
    end

    if R.symmetry == "y" or R.symmetry == "xy" then
      R.mirror_y = true
    end

    -- we ALWAYS setup the x_peer / y_peer refs
    mirror_horizontally(R)
    mirror_vertically(R)
  end
end


function Rooms_reckon_doors()
  local DEFAULT_PROBS = {}

  local function door_chance(R1, R2)
    local door_probs = THEME.door_probs or
                       GAME.door_probs or
                       DEFAULT_PROBS

    if R1.outdoor and R2.outdoor then
      return door_probs.out_both or 0

    elseif R1.outdoor or R2.outdoor then
      return door_probs.out_diff or 80

    elseif R1.kind == "stairwell" or R2.kind == "stairwell" then
      return door_probs.stairwell or 1

    elseif R1.hallway and R2.hallway then
      return door_probs.hall_both or 2

    elseif R1.hallway or R2.hallway then
      return door_probs.hall_diff or 60

    elseif R1.main_tex ~= R2.main_tex then
      return door_probs.combo_diff or 40

    else
      return door_probs.normal or 20
    end
  end


  ---| Rooms_reckon_doors |---

  for _,C in ipairs(LEVEL.all_conns) do
    for who = 1,2 do
      local S = sel(who == 1, C.src_S, C.dest_S)
      local N = sel(who == 2, C.src_S, C.dest_S)
      assert(S)

      if S.conn_dir then
        assert(N.conn_dir == 10-S.conn_dir)

        local B  = S.border[S.conn_dir]
        local B2 = N.border[N.conn_dir]

        -- ensure when going from outside to inside that the arch/door
        -- is made using the building combo (NOT the outdoor combo)
        if B.kind == "arch" and
           ((S.room.outdoor and not N.room.outdoor) or
            (S.room == N.room.parent))
        then
          -- swap borders
          S, N = N, S

          S.border[S.conn_dir] = B
          N.border[N.conn_dir] = B2
        end

        if B.kind == "arch" and GAME.doors and not B.tried_door then
          B.tried_door = true

          local prob = door_chance(C.src, C.dest)

          if S.conn.lock and S.conn.lock.kind ~= "NULL" then
            B.kind = "lock_door"
            B.lock = S.conn.lock

            -- FIXME: smells like a hack!!
            if B.lock.item and string.sub(B.lock.item, 1, 4) == "bar_" then
              B.kind = "bars"
            end

          elseif rand_odds(prob) then
            B.kind = "door"

          elseif (STYLE.fences == "none" or STYLE.fences == "few") and
                 C.src.outdoor and C.dest.outdoor then
            B.kind = "nothing"
          end
        end

      end
    end -- for who
  end -- for C
end


function Rooms_synchronise_skies()
  -- make sure that any two outdoor rooms which touch have the same sky_h

  for loop = 1,10 do
    local changes = false

    for x = 1,SEED_W do for y = 1,SEED_H do
      local S = SEEDS[x][y][1]
      if S and S.room and S.room.sky_h then
        for side = 2,8,2 do
          local N = S:neighbor(side)
          if N and N.room and N.room ~= S.room and N.room.sky_h and
             S.room.sky_h ~= N.room.sky_h
          then
            S.room.sky_h = math.max(S.room.sky_h, N.room.sky_h)
            N.room.sky_h = S.room.sky_h
            changes = true
          end
        end -- for side
      end
    end end -- for x, y

    if not changes then break; end
  end -- for loop
end


function Rooms_border_up()

  local function make_map_edge(R, S, side)

    if R.outdoor then
      S.border[side].kind = "sky_fence"
      S.thick[side] = 48
    else
      S.border[side].kind = "wall"
      S.border[side].can_fake_sky = true
      S.thick[side] = 24
    end
  end

  local function make_border(R1, S, R2, N, side)

    if R1 == R2 then
      -- same room : do nothing
      S.border[side].kind = "nothing"
      return
    end


    if R1.outdoor and R2.natural then
      S.border[side].kind = "fence"

    elseif R1.natural and R2.outdoor then
      S.border[side].kind = "nothing"

    elseif R1.outdoor then
      if R2.outdoor or R2.natural then
        S.border[side].kind = "fence"
      else
        S.border[side].kind = "facade"
        S.border[side].facade = R2.facade
      end

--###   if N.kind == "small_exit" then
--###     S.border[side].kind = "nothing"
--###   end

      if N.kind == "liquid" and R2.outdoor and
        (S.kind == "liquid" or R1.arena == R2.arena)
        --!!! or (N.room.kind == "scenic" and safe_falloff(S, side))
      then
        S.border[side].kind = "nothing"
      end

      if STYLE.fences == "none" and R1.arena == R2.arena and R2.outdoor and
         (S.kind ~= "liquid" or S.floor_h == N.floor_h)
      then
        S.border[side].kind = "nothing"
      end

    else -- R1 indoor

      if R2.parent == R1 and not R2.outdoor then
        S.border[side].kind = "nothing"
        return
      end

      S.border[side].kind = "wall"
      S.thick[side] = 24

      -- liquid arches are a kind of window
      if S.kind == "liquid" and N.kind == "liquid" and
         (S.floor_h == N.floor_h) and rand_odds(50)
      then
        S.border[side].kind = "liquid_arch"
        return
      end
    end
  end


  local function border_up(R)
    for x = R.sx1, R.sx2 do for y = R.sy1, R.sy2 do
      local S = SEEDS[x][y][1]
      if S.room == R then
        for side = 2,8,2 do
          if not S.border[side].kind then  -- don't clobber connections
            local N = S:neighbor(side)
  
            if not (N and N.room) then
              make_map_edge(R, S, side)
            else
              make_border(R, S, N.room, N, side)
            end
          end

          assert(S.border[side].kind)
        end -- for side
      end
    end end -- for x, y
  end


  local function get_border_list(R)
    local list = {}

    for x = R.sx1, R.sx2 do for y = R.sy1, R.sy2 do
      local S = SEEDS[x][y][1]
      if S.room == R and not
         (S.kind == "void" or S.kind == "diagonal" or
          S.kind == "tall_stair")
      then
        for side = 2,8,2 do
          if S.border[side].kind == "wall" then
            table.insert(list, { S=S, side=side })
          end
        end -- for side
      end
    end end -- for x, y

    return list
  end

  local function score_window_side(R, side, border_list)
    local min_c1, max_f1 = 999, -999
    local min_c2, max_f2 = 999, -999

    local total   = 0
    local scenics = 0
    local doors   = 0
    local futures = 0
    local entry   = 0

    local info = { side=side, seeds={} }

    for _,C in ipairs(R.conns) do
      local S = C:seed(R)
      local B = S.border[side]

      if S.conn_dir == side then
        -- never any windows near a locked door
        if B.kind == "lock_door" then
          return nil
        end

        if B.kind == "door" or B.kind == "arch" then
          doors = doors + 1
        end

        if C == R.entry_conn then
          entry = 1
        end
      end
    end


    for _,bd in ipairs(border_list) do
      local S = bd.S
      local N = S:neighbor(side)

      total = total + 1

      if (bd.side == side) and S.floor_h and
         (N and N.room and N.room.outdoor) and N.floor_h
      -- (N.kind == "walk" or N.kind == "liquid")
      then
        table.insert(info.seeds, S)

        if N.kind == "scenic" then
          scenics = scenics + 1
        end

        if S.room.arena and N.room.arena and (S.room.arena.id < N.room.arena.id) then
          futures = futures + 1
        end
        
        min_c1 = math.min(min_c1, assert(S.ceil_h or R.ceil_h))
        min_c2 = SKY_H

        max_f1 = math.max(max_f1, S.floor_h)
        max_f2 = math.max(max_f2, N.floor_h)

        if N.room.natural then
          max_f2 = math.max(max_f2, N.room.cave_floor_h + 128)
        end
      end 
    end  -- for bd


    -- nothing possible??
    local usable = #info.seeds

    if usable == 0 then return end

    local min_c = math.min(min_c1, min_c2)
    local max_f = math.max(max_f1, max_f2)

    if min_c - max_f < 95 then return end

    local score = 200 + gui.random() * 20

    -- primary score is floor drop off
    score = score + (max_f1 - max_f2)

    score = score + (min_c  - max_f) / 8
    score = score - usable * 22

    if scenics >= 1 then score = score + 120 end
    if entry   == 0 then score = score + 60 end

    if doors   == 0 then score = score + 20 end
    if futures == 0 then score = score + 10 end

    gui.debugf("Window score @ %s ^%d --> %d\n", R:tostr(), side, score)

    info.score = score


    -- implement the window style
    if (STYLE.windows == "few"  and score < 350) or
       (STYLE.windows == "some" and score < 260)
    then
      return nil
    end


    -- determine height of window
    if (min_c - max_f) >= 192 and rand_odds(20) then
      info.z1 = max_f + 64
      info.z2 = min_c - 64
      info.is_tall = true
    elseif (min_c - max_f) >= 160 and rand_odds(60) then
      info.z1 = max_f + 32
      info.z2 = min_c - 24
      info.is_tall = true
    elseif (max_f1 < max_f2) and rand_odds(30) then
      info.z1 = min_c - 80
      info.z2 = min_c - 32
    else
      info.z1 = max_f + 32
      info.z2 = max_f + 80
    end

    -- determine width & doubleness
    local thin_chance = math.min(6, usable) * 20 - 40
    local dbl_chance  = 80 - math.min(3, usable) * 20

    if usable >= 3 and rand_odds(thin_chance) then
      info.width = 64
    elseif usable <= 3 and rand_odds(dbl_chance) then
      info.width = 192
      info.mid_w = 64
    elseif info.is_tall then
      info.width = rand_sel(80, 128, 192)
    else
      info.width = rand_sel(20, 128, 192)
    end

    if info.width > PARAM.seed_size-32 then
       info.width = PARAM.seed_size-32
    end

    return info
  end

  local function add_windows(R, info, border_list)
    local side = info.side

    for _,S in ipairs(info.seeds) do
      S.border[side].kind = "window"

      S.border[side].win_width = info.width
      S.border[side].win_mid_w = info.mid_w
      S.border[side].win_z1    = info.z1
      S.border[side].win_z2    = info.z2

      local N = S:neighbor(side)
      assert(N and N.room)

      N.border[10-side].kind = "nothing"
    end -- for S
  end

  local function pick_best_side(poss)
    local best

    for side = 2,8,2 do
      if poss[side] and (not best or poss[best].score < poss[side].score) then
        best = side
      end
    end

    return best
  end

  local function decide_windows(R, border_list)
    if R.outdoor or R.natural or R.kind ~= "normal" then return end
    if R.semi_outdoor then return end
    if STYLE.windows == "none" then return end

    local poss = {}

    for side = 2,8,2 do
      poss[side] = score_window_side(R, side, border_list)
    end

    for loop = 1,2 do
      local best = pick_best_side(poss)

      if best then
        add_windows(R, poss[best], border_list)

        poss[best] = nil

        -- remove the opposite side too
        poss[10-best] = nil
      end
    end
  end


  local function select_picture(R, v_space, index)
    v_space = v_space - 16
    -- FIXME: needs more v_space checking

    if not THEME.logos then
      error("Game is missing logo skins")
    end

    if rand_odds(sel(LEVEL.has_logo,7,40)) then
      LEVEL.has_logo = true
      return rand_key_by_probs(THEME.logos)
    end

    if R.has_liquid and index == 1 and rand_odds(75) then
      if THEME.liquid_pics then
        return rand_key_by_probs(THEME.liquid_pics)
      end
    end

    local pic_tab = {}

    local pictures = THEME.pictures

    if pictures then
      for name,prob in pairs(pictures) do
        local info = GAME.pictures[name]
        if info and info.height <= v_space then
          pic_tab[name] = prob
        end
      end
    end

    if not table_empty(pic_tab) then
      return rand_key_by_probs(pic_tab)
    end

    -- fallback
    return rand_key_by_probs(THEME.logos)
  end

  local function install_pic(R, bd, pic_name, v_space)
    skin = assert(GAME.pictures[pic_name])

    -- handles symmetry

    for dx = 1,sel(R.mirror_x, 2, 1) do
      for dy = 1,sel(R.mirror_y, 2, 1) do
        local S    = bd.S
        local side = bd.side

        if dx == 2 then
          S = S.x_peer
          if not S then break; end
          if is_horiz(side) then side = 10-side end
        end

        if S and dy == 2 then
          S = S.y_peer
          if not S then break; end
          if is_vert(side) then side = 10-side end
        end

        local B = S.border[side]

        if B.kind == "wall" and S.floor_h then
          local raise = skin.raise or 32
          if raise + skin.height > v_space-4 then
            raise = int((v_space - skin.height) / 2)
          end
          B.kind = "picture"
          B.pic_skin = skin
          B.pic_z1 = S.floor_h + raise
        end

      end -- for dy
    end -- for dx
  end

  local function decide_pictures(R, border_list)
    if R.outdoor or R.natural or R.kind ~= "normal" then return end
    if R.semi_outdoor then return end

    -- filter border list to remove symmetrical peers, seeds
    -- with pillars, etc..  Also determine vertical space.
    local new_list = {}

    local v_space = 999

    for _,bd in ipairs(border_list) do
      local S = bd.S
      local side = bd.side

      if (R.mirror_x and S.x_peer and S.sx > S.x_peer.sx) or
         (R.mirror_y and S.y_peer and S.sy > S.y_peer.sy) or
         (S.content == "pillar") or (S.kind == "lift")
      then
        -- skip it
      else
        table.insert(new_list, bd)

        local h = (S.ceil_h or R.ceil_h) - S.floor_h
        v_space = math.min(v_space, h)
      end
    end

    if #new_list == 0 then return end


    -- deice how many pictures we want
    local perc = rand_element { 20,30,40 }

    if STYLE.pictures == "heaps" then perc = 50 end
    if STYLE.pictures == "few"   then perc = 10 end

    -- FIXME: support "none" but also force logos to appear
    if STYLE.pictures == "none"  then perc =  7 end

    local count = int(#border_list * perc / 100)

    gui.debugf("Picture count @ %s --> %d\n", R:tostr(), count)

    if R.mirror_x then count = int(count / 2) + 1 end
    if R.mirror_y then count = int(count / 2) end


    -- select one or two pictures to use
    local pics = {}
    pics[1] = select_picture(R, v_space, 1)
    pics[2] = pics[1]

    if #border_list >= 12 then
      -- prefer a different pic for #2
      for loop = 1,3 do
        pics[2] = select_picture(R, v_space, 2)
        if pics[2].pic_w ~= pics[1].pic_w then break; end
      end
    end

    gui.debugf("Selected pics: %s %s\n", pics[1], pics[2])


    for loop = 1,count do
      if #new_list == 0 then break; end

      -- FIXME !!!! SELECT GOOD SPOT
      local b_index = rand_irange(1, #new_list)

      local bd = table.remove(new_list, b_index)
      
      install_pic(R, bd, pics[1 + (loop-1) % 2], v_space)
    end -- for loop
  end


  ---| Rooms_border_up |---
  
  for _,R in ipairs(LEVEL.all_rooms) do
    border_up(R)
  end
  for _,R in ipairs(LEVEL.scenic_rooms) do
    border_up(R)
  end

  for _,R in ipairs(LEVEL.all_rooms) do
    decide_windows( R, get_border_list(R))
    decide_pictures(R, get_border_list(R))
  end
end


function Room_make_ceiling(R)

  local function outdoor_ceiling()
    if R.floor_max_h then
      R.sky_h = math.max(R.sky or SKY_H, R.floor_max_h + 128)
    end
  end

  local function periph_size(PER)
    if PER[2] then return 3 end
    if PER[1] then return 2 end
    if PER[0] then return 1 end
    return 0
  end

  local function get_max_drop(side, offset)
    local drop_z
    local x1,y1, x2,y2 = side_coords(side, R.tx1,R.ty1, R.tx2,R.ty2, offset)

    for x = x1,x2 do for y = y1,y2 do
      local S = SEEDS[x][y][1]
      if S.room == R then

        local f_h
        if S.kind == "walk" then
          f_h = S.floor_h
        elseif S.kind == "stair" or S.kind == "lift" then
          f_h = math.max(S.stair_z1, S.stair_z2)
        elseif S.kind == "curve_stair" or S.kind == "tall_stair" then
          f_h = math.max(S.x_height, S.y_height)
        end

        if f_h then
          local diff_h = (S.ceil_h or R.ceil_h) - (f_h + 144)

          if diff_h < 1 then return nil end

          if not drop_z or (diff_h < drop_z) then
            drop_z = diff_h
          end
        end
      end
    end end -- for x, y

    return drop_z
  end

  local function add_periph_pillars(side, offset)
    if not THEME.periph_pillar_mat then
      return
    end

    local info = add_pegging(get_mat(THEME.periph_pillar_mat))

    local x1,y1, x2,y2 = side_coords(side, R.tx1,R.ty1, R.tx2,R.ty2, offset)

    if is_vert(side) then x2 = x2-1 else y2 = y2-1 end

    local x_dir = sel(side == 6, -1, 1)
    local y_dir = sel(side == 8, -1, 1)

    for x = x1,x2 do for y = y1,y2 do
      local S = SEEDS[x][y][1]

      -- check if all neighbors are in same room
      local count = 0

      for dx = 0,1 do for dy = 0,1 do
        local nx = x + dx * x_dir
        local ny = y + dy * y_dir

        if Seed_valid(nx, ny, 1) and SEEDS[nx][ny][1].room == R then
          count = count + 1
        end
      end end -- for dx,dy

      if count == 4 then
        local w = 12

        local px = sel(x_dir < 0, S.x1, S.x2)
        local py = sel(y_dir < 0, S.y1, S.y2)

        Trans_quad(info, px-w, py-w, px+w, py+w, -EXTREME_H, EXTREME_H)
        
        R.has_periph_pillars = true

        -- mark seeds [crude way to prevent stuck masterminds]
        for dx = 0,1 do for dy = 0,1 do
          local nx = x + dx * x_dir
          local ny = y + dy * y_dir

          SEEDS[nx][ny][1].solid_corner = true
        end end -- for dx,dy
      end
    end end -- for x, y
  end

  local function create_periph_info(side, offset)
    local t_size = sel(is_horiz(side), R.tw, R.th)

    if t_size < (3+offset*2) then return nil end

    local drop_z = get_max_drop(side, offset)

    if not drop_z or drop_z < 30 then return nil end

    local PER = { max_drop=drop_z }

    if t_size == (3+offset*2) then
      PER.tight = true
    end

    if R.pillar_rows then
      for _,row in ipairs(R.pillar_rows) do
        if row.side == side and row.offset == offset then
          PER.pillars = true
        end
      end
    end

    return PER
  end

  local function merge_periphs(side, offset)
    local P1 = R.periphs[side][offset]
    local P2 = R.periphs[10-side][offset]

    if not (P1 and P2) then return nil end

    if P1.tight and rand_odds(90) then return nil end

    return
    {
      max_drop = math.min(P1.max_drop, P2.max_drop),
      pillars  = P1.pillars or P2.pillars
    }
  end

  local function decide_periphs()
    -- a "periph" is a side of the room where we might lower
    -- the ceiling height.  There is a "outer" one (touches the
    -- wall) and an "inner" one (next to the outer one).

    R.periphs = {}

    for side = 2,8,2 do
      R.periphs[side] = {}

      for offset = 0,2 do
        local PER = create_periph_info(side, offset)
        R.periphs[side][offset] = PER
      end
    end


    local SIDES = { 2,4 }
    if (R.th > R.tw) or (R.th == R.tw and rand_odds(50)) then
      SIDES = { 4,2 }
    end
    if rand_odds(10) then  -- swap 'em
      SIDES[1], SIDES[2] = SIDES[2], SIDES[1]
    end

    for idx,side in ipairs(SIDES) do
      if (R.symmetry == "xy" or R.symmetry == sel(side==2, "y", "x")) or
         R.pillar_rows and is_parallel(R.pillar_rows[1].side, side) or
         rand_odds(50)
      then
        --- Symmetrical Mode ---

        local PER_0 = merge_periphs(side, 0)
        local PER_1 = merge_periphs(side, 1)

        if PER_0 and PER_1 and rand_odds(sel(PER_1.pillars, 70, 10)) then
          PER_0 = nil
        end

        if PER_0 then PER_0.drop_z = PER_0.max_drop / idx end
        if PER_1 then PER_1.drop_z = PER_1.max_drop / idx / 2 end

        R.periphs[side][0] = PER_0 ; R.periphs[10-side][0] = PER_0
        R.periphs[side][1] = PER_1 ; R.periphs[10-side][1] = PER_1
        R.periphs[side][2] = nil   ; R.periphs[10-side][2] = nil

        if idx==1 and PER_0 and not R.pillar_rows and rand_odds(50) then
          add_periph_pillars(side)
          add_periph_pillars(10-side)
        end
      else
        --- Funky Mode ---

        -- pick one side to use   [FIXME]
        local keep = rand_sel(50, side, 10-side)

        for n = 0,2 do R.periphs[10-keep][n] = nil end

        local PER_0 = R.periphs[keep][0]
        local PER_1 = R.periphs[keep][1]

        if PER_0 and PER_1 and rand_odds(5) then
          PER_0 = nil
        end

        if PER_0 then PER_0.drop_z = PER_0.max_drop / idx end
        if PER_1 then PER_1.drop_z = PER_1.max_drop / idx / 2 end

        R.periphs[keep][2] = nil

        if idx==1 and PER_0 and not R.pillar_rows and rand_odds(75) then
          add_periph_pillars(keep)

        --??  if PER_1 and rand_odds(10) then
        --??    add_periph_pillars(keep, 1)
        --??  end
        end
      end
    end
  end

  local function calc_central_area()
    R.cx1, R.cy1 = R.tx1, R.ty1
    R.cx2, R.cy2 = R.tx2, R.ty2

    for side = 2,8,2 do
      local w = periph_size(R.periphs[side])

          if side == 4 then R.cx1 = R.cx1 + w
      elseif side == 6 then R.cx2 = R.cx2 - w
      elseif side == 2 then R.cy1 = R.cy1 + w
      elseif side == 8 then R.cy2 = R.cy2 - w
      end
    end

    R.cw, R.ch = box_size(R.cx1, R.cy1, R.cx2, R.cy2)

    assert(R.cw >= 1)
    assert(R.ch >= 1)
  end

  local function install_periphs()
    for x = R.tx1, R.tx2 do for y = R.ty1, R.ty2 do
      local S = SEEDS[x][y][1]
      if S.room == R then
      
        local PX, PY

            if x == R.tx1   then PX = R.periphs[4][0]
        elseif x == R.tx2   then PX = R.periphs[6][0]
        elseif x == R.tx1+1 then PX = R.periphs[4][1]
        elseif x == R.tx2-1 then PX = R.periphs[6][1]
        elseif x == R.tx1+2 then PX = R.periphs[4][2]
        elseif x == R.tx2-2 then PX = R.periphs[6][2]
        end

            if y == R.ty1   then PY = R.periphs[2][0]
        elseif y == R.ty2   then PY = R.periphs[8][0]
        elseif y == R.ty1+1 then PY = R.periphs[2][1]
        elseif y == R.ty2-1 then PY = R.periphs[8][1]
        elseif y == R.ty1+2 then PY = R.periphs[2][2]
        elseif y == R.ty2-2 then PY = R.periphs[8][2]
        end

        if PX and not PX.drop_z then PX = nil end
        if PY and not PY.drop_z then PY = nil end

        if PX or PY then
          local drop_z = math.max((PX and PX.drop_z) or 0,
                                  (PY and PY.drop_z) or 0)

          S.ceil_h = R.ceil_h - drop_z
        end

      end -- if S.room == R
    end end -- for x, y
  end

  local function fill_xyz(ch, is_sky, c_tex, c_light)
    for x = R.cx1, R.cx2 do for y = R.cy1, R.cy2 do
      local S = SEEDS[x][y][1]
      if S.room == R then
      
        S.ceil_h  = ch
        S.is_sky  = is_sky
        S.c_tex   = c_tex
        S.c_light = c_light

      end -- if S.room == R
    end end -- for x, y
  end

  local function add_central_pillar()
    -- big rooms only
    if R.cw < 3 or R.ch < 3 then return end

    -- centred only
    if (R.cw % 2) == 0 or (R.ch % 2) == 0 then return end

    local skin_names = THEME.big_pillars or THEME.pillars
    if not skin_names then return end


    local mx = R.cx1 + int(R.cw / 2)
    local my = R.cy1 + int(R.ch / 2)

    local S = SEEDS[mx][my][1]

    -- seed is usable?
    if S.room ~= R or S.content then return end
    if not (S.kind == "walk" or S.kind == "liquid") then return end

    -- neighbors the same?
    for side = 2,8,2 do
      local N = S:neighbor(side)
      if not (N and N.room == S.room and N.kind == S.kind) then
        return
      end
    end

    -- OK !!
    local which = rand_key_by_probs(skin_names)

    S.content = "pillar"
    S.pillar_skin = assert(GAME.pillars[which])

    R.has_central_pillar = true

    gui.debugf("Central pillar @ (%d,%d) skin:%s\n", S.sx, S.sy, which)
  end

  local function central_niceness()
    local nice = 2

    for x = R.cx1, R.cx2 do for y = R.cy1, R.cy2 do
      local S = SEEDS[x][y][1]
      
      if S.room ~= R then return 0 end
      
      if S.kind == "void" or ---#  S.kind == "diagonal" or
         S.kind == "tall_stair" or S.content == "pillar"
      then
        nice = 1
      end
    end end -- for x, y

    return nice
  end

  local function test_cross_beam(dir, x1,y1, x2,y2, mode)
    -- FIXME: count usable spots, return false for zero

    for x = x1,x2 do for y = y1,y2 do
      local S = SEEDS[x][y][1]
      assert(S.room == R)

      if S.kind == "lift" or S.kind == "tall_stair" or S.raising_start then
        return false
      end

      if mode == "light" and (S.kind == "diagonal") then
        return false
      end
    end end -- for x, y

    return true
  end

  local function add_cross_beam(dir, x1,y1, x2,y2, mode)
    local skin
    
    if mode == "light" then
      if not R.arena.ceil_light then return end
      skin = { w=R.lite_w, h=R.lite_h, lite_f=R.arena.ceil_light, trim=THEME.light_trim }
    end

    for x = x1,x2 do for y = y1,y2 do
      local S = SEEDS[x][y][1]
      local ceil_h = S.ceil_h or R.ceil_h

      if ceil_h and S.kind ~= "void" then
        if mode == "light" then
          if S.content ~= "pillar" then
            Build_ceil_light(S, ceil_h, skin)
          end
        else
          Build_cross_beam(S, dir, 64, ceil_h - 16, THEME.beam_mat)
        end
      end
    end end -- for x, y
  end

  local function decide_beam_pattern(poss, total, mode)
    if table_empty(poss) then return false end

    -- FIXME !!!
    return true
  end

  local function criss_cross_beams(mode)
    if not THEME.beam_mat then return false end

    if R.children then return false end

    R.lite_w = 64
    R.lite_h = 64

    local poss = {}

    if R.cw > R.ch or (R.cw == R.ch and rand_odds(50)) then
      -- vertical beams

      if rand_odds(20) then R.lite_h = 192 end
      if rand_odds(10) then R.lite_h = 128 end
      if rand_odds(30) then R.lite_h = R.lite_w end

      for x = R.cx1, R.cx2 do
        poss[x - R.cx1 + 1] = test_cross_beam(8, x, R.ty1, x, R.ty2, mode)
      end

      if not decide_beam_pattern(poss, R.cx2 - R.cx1 + 1, mode) then
        return false
      end

      for x = R.cx1, R.cx2 do
        if poss[x - R.cx1 + 1] then
          add_cross_beam(8, x, R.ty1, x, R.ty2)
        end
      end

    else -- horizontal beams

      if rand_odds(20) then R.lite_w = 192 end
      if rand_odds(10) then R.lite_w = 128 end
      if rand_odds(30) then R.lite_w = R.lite_h end

      for y = R.cy1, R.cy2 do
        poss[y - R.cy1 + 1] = test_cross_beam(6, R.tx1, y, R.tx2, y, mode)
      end

      if not decide_beam_pattern(poss, R.cy2 - R.cy1 + 1, mode) then
        return false
      end

      for y = R.cy1, R.cy2 do
        if poss[y - R.cy1 + 1] then
          add_cross_beam(6, R.tx1, y, R.tx2, y, mode)
        end
      end
    end

    return true
  end

  local function corner_supports()
    if not THEME.corner_supports then
      return false
    end

    local mat = rand_key_by_probs(THEME.corner_supports)

    local SIDES = { 1, 7, 3, 9 }

    -- first pass only checks if possible
    for loop = 1,2 do
      local poss = 0

      for where = 1,4 do
        local cx = sel((where <= 2), R.tx1, R.tx2)
        local cy = sel((where % 2) == 1, R.ty1, R.ty2)
        local S = SEEDS[cx][cy][1]
        if S.room == R and not S.conn and
           (S.kind == "walk" or S.kind == "liquid")
        then

          poss = poss + 1

          if loop == 2 then
            local skin = { w=24, beam_w=mat, x_offset=0 }
            ---## if R.has_lift or (R.id % 5) == 4 then
            ---##   skin = { w=24, beam_w="SUPPORT3", x_offset=0 }
            ---## end
            Build_corner_beam(S, SIDES[where], skin)
          end

        end
      end

      if poss < 3 then return false end
    end

    return true
  end

  local function do_central_area()
    calc_central_area()

    local has_sky_nb = R:has_sky_neighbor()

    if R.has_periph_pillars and not has_sky_nb and rand_odds(16) then
      fill_xyz(R.ceil_h, true)
      R.semi_outdoor = true
      return
    end


    if (R.tw * R.th) <= 18 and rand_odds(20) then
      if corner_supports() and rand_odds(35) then return end
    end


    if not R.arena.ceil_light and THEME.ceil_lights then
      R.arena.ceil_light = rand_key_by_probs(THEME.ceil_lights)
    end

    local beam_chance = style_sel("beams", 0, 5, 25, 75)

    if rand_odds(beam_chance) then
      if criss_cross_beams("beam") then return end
    end

    if rand_odds(42) then
      if criss_cross_beams("light") then return end
    end


    -- shrink central area until there are nothing which will
    -- get in the way of a ceiling prefab.
    local nice = central_niceness()

gui.debugf("Original @ %s over %dx%d -> %d\n", R:tostr(), R.cw, R.ch, nice)

    while nice < 2 and (R.cw >= 3 or R.ch >= 3) do
      
      if R.cw > R.ch or (R.cw == R.ch and rand_odds(50)) then
        assert(R.cw >= 3)
        R.cx1 = R.cx1 + 1
        R.cx2 = R.cx2 - 1
      else
        assert(R.ch >= 3)
        R.cy1 = R.cy1 + 1
        R.cy2 = R.cy2 - 1
      end

      R.cw, R.ch = box_size(R.cx1, R.cy1, R.cx2, R.cy2)

      nice = central_niceness()
    end
      
gui.debugf("Niceness @ %s over %dx%d -> %d\n", R:tostr(), R.cw, R.ch, nice)


    add_central_pillar()

    if nice ~= 2 or not THEME.big_lights then return end

      local ceil_info  = get_mat(R.main_tex)
      local sky_info   = get_sky()
      local brown_info = get_mat(rand_key_by_probs(THEME.building_ceilings))

      local light_name = rand_key_by_probs(THEME.big_lights)
      local light_info = get_mat(light_name)
      light_info.b_face.light = 0.85

      -- lighting effects
      -- (They can break lifts, hence the check here)
      if not R.has_lift then
            if rand_odds(10) then light_info.sec_kind = 8
        elseif rand_odds(6)  then light_info.sec_kind = 3
        elseif rand_odds(3)  then light_info.sec_kind = 2
        end
      end

    local trim   = THEME.ceiling_trim
    local spokes = THEME.ceiling_spoke

    if STYLE.lt_swapped ~= "none" then
      trim, spokes = spokes, trim
    end

    if STYLE.lt_trim == "none" or (STYLE.lt_trim == "some" and rand_odds(50)) then
      trim = nil
    end
    if STYLE.lt_spokes == "none" or (STYLE.lt_spokes == "some" and rand_odds(70)) then
      spokes = nil
    end

    if R.cw == 1 or R.ch == 1 then
      fill_xyz(R.ceil_h+32, false, light_name, 0.75)
      return
    end

    local shape = rand_sel(30, "square", "round")

    local w = 96 + 140 * (R.cw - 1)
    local h = 96 + 140 * (R.ch - 1)
    local z = (R.cw + R.ch) * 8

    Build_sky_hole(R.cx1,R.cy1, R.cx2,R.cy2, shape, w, h,
                   ceil_info, R.ceil_h,
                   sel(not has_sky_nb and not R.parent and rand_odds(60), sky_info,
                       rand_sel(75, light_info, brown_info)), R.ceil_h + z,
                   trim, spokes)
  end

  local function indoor_ceiling()
    if R.natural or R.kind ~= "normal" then
      return
    end

    assert(R.floor_max_h)

    local avg_h = int((R.floor_min_h + R.floor_max_h) / 2)
    local min_h = R.floor_max_h + 128

    local tw = R.tw or R.sw
    local th = R.th or R.sh

    local approx_size = (2 * math.min(tw, th) + math.max(tw, th)) / 3.0
    local tallness = (approx_size + rand_range(-0.6,1.6)) * 64.0

    if tallness < 128 then tallness = 128 end
    if tallness > 448 then tallness = 448 end

    R.tallness = int(tallness / 32.0) * 32

    gui.debugf("Tallness @ %s --> %d\n", R:tostr(), R.tallness)
 
    R.ceil_h = math.max(min_h, avg_h + R.tallness)

    R.ceil_tex = rand_key_by_probs(THEME.building_ceilings)

-- [[
    decide_periphs()
    install_periphs()

    do_central_area()
--]]

--[[
    if R.tx1 and R.tw >= 7 and R.th >= 7 then

      Build_sky_hole(R.tx1,R.ty1, R.tx2,R.ty2,
                     "round", w, h,
                     outer_info, R.ceil_h,
                     nil, R.ceil_h , ---  + z,
                     metal, nil)

      w = 96 + 110 * (R.tx2 - R.tx1 - 4)
      h = 96 + 110 * (R.ty2 - R.ty1 - 4)

      outer_info.b_face.texture = "F_SKY1"
      outer_info.b_face.light = 0.8

      Build_sky_hole(R.tx1+2,R.ty1+2, R.tx2-2,R.ty2-2,
                     "round", w, h,
                     outer_info, R.ceil_h + 96,
                     inner_info, R.ceil_h + 104,
                     metal, silver)
    end

    if R.tx1 and R.tw == 4 and R.th == 4 then
      local w = 256
      local h = 256

      for dx = 0,1 do for dy = 0,0 do
        local tx1 = R.tx1 + dx * 2
        local ty1 = R.ty1 + dy * 2

        local tx2 = R.tx1 + dx * 2 + 1
        local ty2 = R.ty1 + dy * 2 + 3

        Build_sky_hole(tx1,ty1, tx2,ty2,
                       "square", w, h,
                       outer_info, R.ceil_h,
                       inner_info, R.ceil_h + 36,
                       metal, metal)
      end end -- for dx, dy
    end

    if R.tx1 and (R.tw == 3 or R.tw == 5) and (R.th == 3 or R.th == 5) then
      for x = R.tx1+1, R.tx2-1, 2 do
        for y = R.ty1+1, R.ty2-1, 2 do
          local S = SEEDS[x][y][1]
          if not (S.kind == "void" or S.kind == "diagonal") then
            Build_sky_hole(x,y, x,y, "square", 160,160,
                           metal,      R.ceil_h+16,
                           inner_info, R.ceil_h+32,
                           nil, silver)
          end
        end -- for y
      end -- for x
    end
--]]
  end


  ---| Room_make_ceiling |---

  if R.outdoor then
    outdoor_ceiling()
  else
    indoor_ceiling()
  end
end


function Room_add_crates(R)

  -- NOTE: temporary crap!
  -- (might be slightly useful for finding big spots for masterminds)

  local function test_spot(S, x, y)
    for dx = 0,1 do for dy = 0,1 do
      local N = SEEDS[x+dx][y+dy][1]
      if not N or N.room ~= S.room then return false end

      if N.kind ~= "walk" or not N.floor_h then return false end

      if math.abs(N.floor_h - S.floor_h) > 0.5 then return false end
    end end -- for dx, dy

    return true
  end

  local function find_spots()
    local list = {}

    for x = R.tx1, R.tx2-1 do for y = R.ty1, R.ty2-1 do
      local S = SEEDS[x][y][1]
      if S.room == R and S.kind == "walk" and S.floor_h then
        if test_spot(S, x, y) then
          table.insert(list, { S=S, x=x, y=y })
        end
      end
    end end -- for x, y

    return list
  end


  --| Room_add_crates |--

  if STYLE.crates == "none" then return end

  if R.natural then return end
  if R.kind ~= "normal" then return end

  local skin
  local skin_names

  if R.outdoor then
    -- FIXME: don't separate them
    skin_names = THEME.out_crates
  else
    skin_names = THEME.crates
  end

  if not skin_names then return end
  skin = assert(GAME.crates[rand_key_by_probs(skin_names)])

  local chance

  if STYLE.crates == "heaps" then
    chance = sel(R.outdoor, 25, 40)
    if rand_odds(20) then chance = chance * 2 end
  else
    chance = sel(R.outdoor, 15, 25)
    if rand_odds(10) then chance = chance * 3 end
  end

  for _,spot in ipairs(find_spots()) do
    if rand_odds(chance) then
      spot.S.solid_corner = true
      local z_top = spot.S.floor_h + (skin.h or 64)
      Build_crate(spot.S.x2, spot.S.y2, z_top, skin, R.outdoor)
    end
  end
end


function Room_build_cave(R)
  local flood = R.flood

  local w_tex  = R.cave_tex
  local w_info = get_mat(w_tex)
  local high_z = EXTREME_H

  local base_x = SEEDS[R.sx1][R.sy1][1].x1
  local base_y = SEEDS[R.sx1][R.sy1][1].y1

  local function WALL_brush(data, coords)
    Trans_brush(data.info, coords, data.z1 or -EXTREME_H, data.z2 or EXTREME_H)

    if data.shadow_info then
      local sh_coords = shadowify_brush(coords, 40)
      Trans_brush(data.shadow_info, sh_coords, -EXTREME_H, (data.z2 or EXTREME_H) - 4)
    end
  end

  local function FC_brush(data, coords)
    if data.f_info then
      Trans_brush(data.f_info, coords, -EXTREME_H, data.f_z)
    end
    if data.c_info then
      Trans_brush(data.c_info, coords, data.c_z, EXTREME_H)
    end
  end

  local function choose_tex(last, tab)
    local tex = rand_key_by_probs(tab)
    if tex == last then tex = rand_key_by_probs(tab) end
    if tex == last then tex = rand_key_by_probs(tab) end
    return tex
  end

  -- DO WALLS --

  local data = { info=w_info, ftex=w_tex, ctex=w_tex }

  if R.is_lake then
    data.info = get_liquid()
    data.info.delta_z = rand_sel(70, -48, -72)
    data.z2 = R.cave_floor_h + 8
  end

  if R.outdoor and not R.is_lake and R.cave_floor_h + 144 < SKY_H and rand_odds(88) then
    data.z2 = R.cave_floor_h + rand_sel(65, 80, 144)
  end

  if PARAM.outdoor_shadows and R.outdoor and not R.is_lake then
    data.shadow_info = get_light(-1)
  end

  for id,reg in pairs(flood.regions) do
    if id > 0 then
      if LEVEL.liquid and not R.is_lake and reg.cells > 4 and
         rand_odds(50) and Cave_region_is_island(flood, reg)
      then
        -- create a lava/nukage pit
        local pit = get_liquid()
        pit.delta_z = rand_sel(70, -52, -76)

        Cave_render(flood, id, base_x, base_y, WALL_brush,
                    { info=pit, z2=R.cave_floor_h+8 })
      else
        -- make walls normally
        Cave_render(flood, id, base_x, base_y, WALL_brush, data, THEME.square_caves)
      end
    end
  end

  if R.is_lake then return end
  if THEME.square_caves then return end
  if PARAM.simple_caves then return end


  local walkway = Cave_negate(R.flood)

  local ceil_h = R.cave_floor_h + R.cave_h

  -- TODO: @ pass 3, 4 : come back up (ESP with liquid)

  for i = 1,rand_index_by_probs({ 10,10,70 })-1 do
    walkway = Cave_shrink(walkway, false)

    if rand_odds(sel(i==1, 20, 50)) then
      walkway = Cave_shrink(walkway, false)
    end

    Cave_remove_dots(walkway)

    -- DO FLOOR and CEILING --

    data = {}


    if R.outdoor then
      data.ftex = choose_tex(data.ftex, THEME.landscape_trims or THEME.landscape_walls)
    else
      data.ftex = choose_tex(data.ftex, THEME.cave_trims or THEME.cave_walls)
    end

    data.f_info = get_mat(data.ftex)

    if LEVEL.liquid and i==2 and rand_odds(60) then  -- TODO: theme specific prob
      data.f_info = get_liquid()

      -- FIXME: this bugs up monster/pickup/key spots
      if rand_odds(0) then
        data.f_trim.delta_z = -(i * 10 + 40)
      end
    end

    if not data.f_info.delta_z then
      data.f_info.delta_z = -(i * 10)
    end

    data.f_z = R.cave_floor_h + i

    data.c_info = nil

    if not R.outdoor then
      data.c_info = w_info

      if i==2 and rand_odds(60) then
        data.c_info = get_sky()
      elseif rand_odds(50) then
        data.c_info = get_mat(data.ftex)
      elseif rand_odds(4.9*20) then
        data.ctex = choose_tex(data.ctex, THEME.cave_trims or THEME.cave_walls)
        data.c_info = get_mat(data.ctex)
      end

      data.c_info.delta_z = int((0.6 + (i-1)*0.3) * R.cave_h)

      data.c_z = ceil_h - i
    end


    Cave_render(walkway, - flood.largest_empty.id, base_x, base_y,
                FC_brush, data)
  end
end


function Room_build_seeds(R)

  local function do_teleporter(S)
    -- TEMP HACK SHIT

    local idx = S.sx - S.room.sx1 + 1

if idx < 1 then return end

    if idx > #S.room.teleports then return end

    local TELEP = S.room.teleports[idx]


    local mx = int((S.x1 + S.x2)/2)
    local my = int((S.y1 + S.y2)/2)

    local x1 = mx - 32
    local y1 = my - 32
    local x2 = mx + 32
    local y2 = my + 32

    local z1 = (S.floor_h or R.floor_h) + 16

    local tag = sel(TELEP.src == S.room, TELEP.src_tag, TELEP.dest_tag)
    assert(tag)


gui.printf("do_teleport\n")
    local gate_info = get_mat(THEME.teleporter_mat)
    gate_info.sec_tag = tag

    Trans_quad(gate_info, x1,y1, x2,y2, -EXTREME_H, z1)

    Trans_entity("teleport_spot", (x1+x2)/2, (y1+y2)/2, z1, { angle=0 })
  end


  local function dir_for_wotsit(S)
    local dirs  = {}
    local missing_dir
  
    for dir = 2,8,2 do
      local N = S:neighbor(dir)
      if N and N.room == R and N.kind == "walk" and
         N.floor_h and math.abs(N.floor_h - S.floor_h) < 17
      then
        table.insert(dirs, dir)
      else
        missing_dir = dir
      end
    end

    if #dirs == 1 then return dirs[1] end

    if #dirs == 3 then return 10 - missing_dir end

    if S.room.entry_conn then
      local entry_S = S.room.entry_conn:seed(S.room)
      local exit_dir = assert(entry_S.conn_dir)

      if #dirs == 0 then return exit_dir end

      for _,dir in ipairs(dirs) do
        if dir == exit_dir then return exit_dir end
      end
    end

    if #dirs > 0 then
      return rand_element(dirs)
    end

    return rand_irange(1,4)*2
  end

  local function player_angle(S)
    if R.sh > R.sw then
      if S.sy > (R.sy1 + R.sy2) / 2 then 
        return 270
      else
        return 90
      end
    else
      if S.sx > (R.sx1 + R.sx2) / 2 then 
        return 180
      else
        return 0
      end
    end
  end

  local function do_purpose(S)
    local sx, sy = S.sx, S.sy

    local z1 = S.floor_h or R.floor_h
    local z2 = S.ceil_h  or R.ceil_h or SKY_H

    local mx, my = S:mid_point()

    if R.purpose == "START" then
      local angle = player_angle(S)
      local dist = 56

      if PARAM.raising_start and R.svolume >= 20 and not R.natural
         and THEME.raising_start_switch and rand_odds(25)
      then
        gui.debugf("Raising Start made\n")

        local skin =
        {
          f_tex = S.f_tex or R.main_tex,
          switch_w = THEME.raising_start_switch,
        }

        Build_raising_start(S, 6, z1, skin)
        angle = 0

        S.no_floor = true
        S.raising_start = true
        R.has_raising_start = true
      else
        local skin = { floor="O_BOLT", x_offset=36, y_offset=-8, peg=true }
        Build_pedestal(S, z1, skin)
      end

      Trans_entity("player1", mx, my, z1, { angle=angle })

      if GAME.things["player2"] then
        Trans_entity("player2", mx - dist, my, z1, { angle=angle })
        Trans_entity("player3", mx + dist, my, z1, { angle=angle })
        Trans_entity("player4", mx, my - dist, z1, { angle=angle })
      end

      -- save position for the demo generator
      LEVEL.player_pos =
      {
        S=S, R=R, x=mx, y=my, z=z1, angle=angle,
      }

      -- never put monsters next to the start spot
      for dir = 2,8,2 do
        local N = S:neighbor(dir)
        if N and N.room == R then
          N.no_monster = true
        end
      end

    elseif R.purpose == "EXIT" and OB_CONFIG.game == "quake" then
      local skin = { floor="SLIP2", wall="SLIPSIDE" }

      Build_quake_exit_pad(S, z1 + 16, skin, LEVEL.next_map)

    elseif R.purpose == "EXIT" then
      local CS = R.conns[1]:seed(R)
      local dir = dir_for_wotsit(S)

      if R.outdoor and THEME.out_exits then
        -- FIXME: use single one for a whole episode
        local skin_name = rand_key_by_probs(THEME.out_exits)
        local skin = assert(GAME.exits[skin_name])
        Build_outdoor_exit_switch(S, dir, z1, skin)

      elseif THEME.exits then
        -- FIXME: use single one for a whole episode
        local skin_name = rand_key_by_probs(THEME.exits)
        local skin = assert(GAME.exits[skin_name])
        Build_exit_pillar(S, z1, skin)
      end

    elseif R.purpose == "KEY" then
      local LOCK = assert(R.lock)

      if rand_odds(15) and THEME.lowering_pedestal_skin then
        local z_top = math.max(z1+128, R.floor_max_h+64)
        if z_top > z2-32 then
           z_top = z2-32
        end

        Build_lowering_pedestal(S, z_top, THEME.lowering_pedestal_skin)

        Trans_entity(LOCK.item, mx, my, z_top)
      else
        if rand_odds(98) then
          local skin = { floor=THEME.pedestal_mat }
          Build_pedestal(S, z1, skin)
        end
        Trans_entity(LOCK.item, mx, my, z1)
      end

    elseif R.purpose == "SWITCH" then
      local LOCK = assert(R.lock)
gui.debugf("SWITCH ITEM = %s\n", LOCK.item)
      local INFO = assert(GAME.switches[LOCK.item])
      Build_small_switch(S, dir_for_wotsit(S), z1, INFO.skin, LOCK.tag)

    else
      error("Layout_one: unknown purpose! " .. tostring(R.purpose))
    end
  end


  local function do_weapon(S)
    local sx, sy = S.sx, S.sy

    local z1 = S.floor_h or R.floor_h
    local z2 = S.ceil_h  or R.ceil_h or SKY_H

    local mx, my = S:mid_point()

    local weapon = assert(S.content_weapon)

    if R.hallway or R == LEVEL.start_room then
      Trans_entity(weapon, mx, my, z1)

    elseif rand_odds(40) and THEME.lowering_pedestal_skin2 then
      local z_top = math.max(z1+80, R.floor_max_h+40)
      if z_top > z2-32 then
         z_top = z2-32
      end

      Build_lowering_pedestal(S, z_top, THEME.lowering_pedestal_skin2)

      Trans_entity(weapon, mx, my, z_top)
    else
      local skin = { floor=THEME.pedestal_mat }
      Build_pedestal(S, z1, skin)

      Trans_entity(weapon, mx, my, z1)
    end

    gui.debugf("Placed weapon '%s' @ (%d,%d,%d)\n", weapon, mx, my, z1)
  end


  local function vis_mark_wall(S, side)
    gui.debugf("VIS %d %d %s\n", S.sx, S.sy, side)
  end

  local function vis_seed(S)
    if S.kind == "void" then
      -- vis_mark_solid(S)
      return;
    end

    for side = 2,8,2 do
      local N = S:neighbor(side)
      local B_kind = S.border[side].kind

      if not N or N.kind == "void" or
         B_kind == "wall" or B_kind == "picture" or
         B_kind == "sky_fence"
      then
        vis_mark_wall(S, side)
      end
    end
  end

  local function Split_quad(S, info, x1,y1, x2,y2, z1,z2)
    local prec = GAME.lighting_precision or "medium"
    if R.outdoor then prec = "low" end
    if S.content == "wotsit" then prec = "low" end

    if prec == "high" then
      for i = 0,5 do for k = 0,5 do
        local ax = int((x1*i+x2*(6-i)) / 6)
        local ay = int((y1*k+y2*(6-k)) / 6)
        local bx = int((x1*(i+1)+x2*(5-i)) / 6)
        local by = int((y1*(k+1)+y2*(5-k)) / 6)
        
        Trans_quad(info, ax,ay, bx,by, z1,z2)
      end end

    elseif prec == "medium" then
      local ax = int((x1*2+x2) / 3)
      local ay = int((y1*2+y2) / 3)
      local bx = int((x1+x2*2) / 3)
      local by = int((y1+y2*2) / 3)

      Trans_quad(info, x1,y1, ax,ay, z1,z2)
      Trans_quad(info, ax,y1, bx,ay, z1,z2)
      Trans_quad(info, bx,y1, x2,ay, z1,z2)

      Trans_quad(info, x1,ay, ax,by, z1,z2)
      Trans_quad(info, ax,ay, bx,by, z1,z2)
      Trans_quad(info, bx,ay, x2,by, z1,z2)

      Trans_quad(info, x1,by, ax,y2, z1,z2)
      Trans_quad(info, ax,by, bx,y2, z1,z2)
      Trans_quad(info, bx,by, x2,y2, z1,z2)

    else
      Trans_quad(info, x1,y1, x2,y2, z1,z2)
    end
  end


  local function build_seed(S)
    if S.already_built then
      return
    end

    vis_seed(S)

    local x1 = S.x1
    local y1 = S.y1
    local x2 = S.x2
    local y2 = S.y2

    local z1 = S.floor_h or R.floor_h or (S.conn and S.conn.conn_h) or 0
    local z2 = S.ceil_h  or R.ceil_h or R.sky_h or SKY_H

    assert(z1 and z2)


    local w_tex = S.w_tex or R.main_tex
    local f_tex = S.f_tex or R.main_tex
    local c_tex = S.c_tex or sel(R.outdoor, "_SKY", R.ceil_tex)

    if R.kind == "hallway" then
      w_tex = assert(LEVEL.hall_tex)
    elseif R.kind == "stairwell" then
      w_tex = assert(LEVEL.well_tex)
    end

    local o_tex = w_tex

    if S.conn_dir then
      local N = S:neighbor(S.conn_dir)

      if N.room.hallway then
        o_tex = LEVEL.hall_tex
      elseif N.room.stairwell then
        o_tex = LEVEL.well_tex
      elseif not N.room.outdoor and N.room ~= R.parent then
        o_tex = N.w_tex or N.room.main_tex
      elseif N.room.outdoor and not (R.outdoor or R.natural) then
        o_tex = R.facade or w_tex
      end
    end


    -- FIXME: put this elsewhere
    if not LEVEL.outer_fence_tex then
      if THEME.outer_fences then
        LEVEL.outer_fence_tex = rand_key_by_probs(THEME.outer_fences)
      end
    end


    local sec_kind


    -- coords for solid block floor and ceiling
    local fx1, fy1 = x1, y1
    local fx2, fy2 = x2, y2

    local cx1, cy1 = x1, y1
    local cx2, cy2 = x2, y2

    local function shrink_floor(side, len)
      if side == 2 then fy1 = fy1 + len end
      if side == 8 then fy2 = fy2 - len end
      if side == 4 then fx1 = fx1 + len end
      if side == 6 then fx2 = fx2 - len end
    end

    local function shrink_ceiling(side, len)
      if side == 2 then cy1 = cy1 + len end
      if side == 8 then cy2 = cy2 - len end
      if side == 4 then cx1 = cx1 + len end
      if side == 6 then cx2 = cx2 - len end
    end

    local function shrink_both(side, len)
      shrink_floor(side, len)
      shrink_ceiling(side, len)
    end


    -- SIDES

    for side = 2,8,2 do
      local N = S:neighbor(side)

      if R.outdoor and N and N.room and not N.room.outdoor then
        local dist = 24 + int((z2 - z1) / 4)
        if dist > 160 then dist = 160 end
        Build_shadow(S, side, dist)
      end

      local border = S.border[side]
      local B_kind = S.border[side].kind

      -- hallway hack
      if R.hallway and not (S.kind == "void") and
         ( (B_kind == "wall")
          or
           (S:neighbor(side) and S:neighbor(side).room == R and
            S:neighbor(side).kind == "void")
         )
      then
        local skin = { wall=LEVEL.hall_tex, trim1=THEME.hall_trim1, trim2=THEME.hall_trim2 }
        Build_detailed_hall(S, side, z1, z2, skin)

        S.border[side].kind = nil
        B_kind = nil
      end

      if B_kind == "wall" and R.kind ~= "scenic" then  -- FIXME; scenic check is bogus
        Build_wall(S, side, w_tex)
        shrink_both(side, 4)
      end

      if B_kind == "facade" then
        Build_facade(S, side, S.border[side].facade)
      end

      if B_kind == "window" then
        local B = S.border[side]
        local skin = { wall=w_tex, side_t=THEME.window_side_mat or w_tex, facade=R.facade or w_tex }
        -- skin.floor = f_tex

        Build_window(S, side, B.win_width, B.win_mid_w,
                     B.win_z1, B.win_z2, skin)
        shrink_both(side, 4)
      end

      if B_kind == "picture" then
        local B = S.border[side]
        B.pic_skin.wall = w_tex

        Build_picture(S, side, B.pic_z1, B.pic_z2, B.pic_skin)
        shrink_both(side, 4)
      end

      if B_kind == "fence"  then
        local skin = { h=30, wall=w_tex, floor=f_tex }
        Build_fence(S, side, R.fence_h or ((R.floor_h or z1)+skin.h), skin)
        shrink_floor(side, 4)
      end

      if B_kind == "sky_fence" then
        local z_top = math.max(LEVEL.skyfence_h, (S.room.floor_max_h or S.room.floor_h or 400) + 48)
        local z_low = LEVEL.skyfence_h - 64
        local skin = { fence_w=LEVEL.outer_fence_tex }

        Build_sky_fence(S, side, z_top, z_low, skin)
        shrink_floor(side, 4)
      end

      if B_kind == "arch" then
        local z = assert(S.conn and S.conn.conn_h)
        local skin = { wall=w_tex, floor=f_tex, other=o_tex, break_t=THEME.track_mat }

        Build_archway(S, side, z, z+112, skin)
        shrink_ceiling(side, 4)

        if R.outdoor and N.room.outdoor then
          Build_shadow(S,  side, 96)
          Build_shadow(S, -side, 96)
        end

        assert(not S.conn.already_made_lock)
        S.conn.already_made_lock = true
      end

      if B_kind == "liquid_arch" then
        local skin = { wall=w_tex, floor=f_tex, other=o_tex, break_t=THEME.track_mat }
        local z_top = math.max(R.liquid_h + 80, N.room.liquid_h + 48)

        Build_archway(S, side, z1, z_top, skin)
        shrink_ceiling(side, 4)
      end

      if B_kind == "door" then
        local z = assert(S.conn and S.conn.conn_h)

        -- FIXME: better logic for selecting doors
        local doors = THEME.doors
        if not doors then
          error("Game is missing doors table")
        end

        local door_name = rand_key_by_probs(doors)
        local skin = assert(GAME.doors[door_name])

        local skin2 = { inner=w_tex, outer=o_tex }

        assert(skin.track)
        assert(skin.step_w)

        Build_door(S, side, z, skin, skin2, 0)
        shrink_ceiling(side, 4)

        assert(not S.conn.already_made_lock)
        S.conn.already_made_lock = true
      end

      if B_kind == "lock_door" then
        local z = assert(S.conn and S.conn.conn_h)

        local LOCK = assert(S.border[side].lock)
        local skin = assert(GAME.doors[LOCK.item])

--if not skin.track then gui.printf("%s", table_to_str(skin,1)); end
        assert(skin.track)

        local skin2 = { inner=w_tex, outer=o_tex }

        local reversed = (S == S.conn.dest_S)

        Build_door(S, side, S.conn.conn_h, skin, skin2, LOCK.tag, reversed)
        shrink_ceiling(side, 4)

        assert(not S.conn.already_made_lock)
        S.conn.already_made_lock = true
      end

      if B_kind == "bars" then
        local LOCK = assert(S.border[side].lock)
        local skin = assert(GAME.doors[LOCK.item])

        local z_top = math.max(R.floor_max_h, N.room.floor_max_h) + skin.bar_h
        local ceil_min = math.min(R.ceil_h or SKY_H, N.room.ceil_h or SKY_H)

        if z_top > ceil_min-32 then
           z_top = ceil_min-32
        end

        Build_lowering_bars(S, side, z_top, skin, LOCK.tag)

        assert(not S.conn.already_made_lock)
        S.conn.already_made_lock = true
      end
    end -- for side


    if S.sides_only then return end


    -- DIAGONALS

    if S.kind == "diagonal" then

      local diag_info = get_mat(w_tex, S.stuckie_ftex) ---### , c_tex)

      Build_diagonal(S, S.stuckie_side, diag_info, S.stuckie_z)

      S.kind = assert(S.diag_new_kind)

      if S.diag_new_z then
        S.floor_h = S.diag_new_z
        z1 = S.floor_h
      end
      
      if S.diag_new_ftex then
        S.f_tex = S.diag_new_ftex
        f_tex = S.f_tex
      end
    end


    -- CEILING

    if S.kind ~= "void" and not S.no_ceil and 
       (S.is_sky or c_tex == "_SKY")
    then

      Trans_quad(get_sky(), x1,y1, x2,y2, z2, EXTREME_H)

    elseif S.kind ~= "void" and not S.no_ceil then
      local info = get_mat(S.u_tex or c_tex or w_tex, c_tex)
      info.b_face.light = S.c_light

      Trans_quad(info, cx1,cy1, cx2,cy2, z2, EXTREME_H)


      -- FIXME: this does not belong here
      if R.hallway and LEVEL.hall_lights then
        local x_num, y_num = 0,0

        for side = 2,8,2 do
          local N = S:neighbor(side)
          if N and N.room == R and N.kind ~= "void" then
            if side == 2 or side == 8 then
              y_num = y_num + 1
            else
              x_num = x_num + 1
            end
          end
        end

        if x_num == 1 and y_num == 1 and LEVEL.hall_lite_ftex then
          Build_ceil_light(S, z2, { lite_f=LEVEL.hall_lite_ftex, trim=THEME.light_trim })
        end
      end
    end


    -- FIXME: decide this somewhere else
    if not LEVEL.step_skin then
      if not THEME.steps then
        error("Game is missing step skins.") 
      else
        local name = rand_key_by_probs(THEME.steps)
        LEVEL.step_skin = GAME.steps[name] or {}
      end

      if not THEME.lifts then
        -- OK
      else
        local name = rand_key_by_probs(THEME.lifts)
        LEVEL.lift_skin = GAME.lifts[name] or {}
      end
    end


    -- FLOOR
    if S.kind == "void" then

      if S.solid_feature and THEME.building_corners then
        if not R.corner_tex then
          R.corner_tex = rand_key_by_probs(THEME.building_corners)
        end
        w_tex = R.corner_tex
      end

      Trans_quad(get_mat(w_tex), x1,y1, x2,y2, -EXTREME_H, EXTREME_H);

    elseif S.kind == "stair" then
      local skin2 = { wall=S.room.main_tex, floor=S.f_tex or S.room.main_tex }

      Build_niche_stair(S, LEVEL.step_skin, skin2)

    elseif S.kind == "curve_stair" then
      Build_low_curved_stair(S, LEVEL.step_skin, S.x_side, S.y_side, S.x_height, S.y_height)

    elseif S.kind == "tall_stair" then
      Build_tall_curved_stair(S, LEVEL.step_skin, S.x_side, S.y_side, S.x_height, S.y_height)

    elseif S.kind == "lift" then
      local skin2 = { wall=S.room.main_tex, floor=S.f_tex or S.room.main_tex }
      local tag = alloc_tag()

      Build_lift(S, LEVEL.lift_skin, skin2, tag)

    elseif S.kind == "popup" then
      -- FIXME: monster!!
      local skin = { wall=w_tex, floor=f_tex }
      Build_popup_trap(S, z1, skin, "revenant")

    elseif S.kind == "liquid" then
      assert(LEVEL.liquid)
      local info = get_liquid()

      Trans_quad(info, fx1,fy1, fx2,fy2, -EXTREME_H, z1)

    elseif not S.no_floor then

      local info = get_mat(S.l_tex or w_tex, f_tex)
      info.sec_kind = sec_kind

      Split_quad(S, info, fx1,fy1, fx2,fy2, -EXTREME_H, z1)
    end


    -- PREFABS

    if S.content == "pillar" then
      Build_pillar(S, z1, z2, assert(S.pillar_skin))
    end

    if S.content == "wotsit" and S.content_kind == "WEAPON" then
      do_weapon(S)
    elseif S.content == "wotsit" then
      do_purpose(S)
    end


    -- restore diagonal kind for monster/item code
    if S.diag_new_kind then
      S.kind = "diagonal"
    end

  end -- build_seed()


  ---==| Room_build_seeds |==---

  if R.cave then
    Room_build_cave(R)
  end

  for x = R.sx1,R.sx2 do for y = R.sy1,R.sy2 do
    local S = SEEDS[x][y][1]
    if S.room == R then
      build_seed(S)
    end
  end end -- for x, y
end


function Rooms_build_all()

  gui.printf("\n--==| Rooms_build_all |==--\n\n")

---  Test_room_fabs()

  Rooms_select_textures()
  Rooms_decide_outdoors()
  Rooms_choose_themes()

  Quest_choose_keys()
  Quest_add_keys()

  Rooms_decide_hallways_II()
  Rooms_setup_symmetry()
  Rooms_reckon_doors()

  if PARAM.tiled then
    -- this is as far as we go for TILE based games
    -- (code in tiler.lua will now kick in).
    return
  end

  for _,R in ipairs(LEVEL.all_rooms) do
    Layout_one(R)
    Room_make_ceiling(R)
    Room_add_crates(R)
  end

  for _,R in ipairs(LEVEL.scenic_rooms) do
    Layout_scenic(R)
    Room_make_ceiling(R)
  end

  Rooms_synchronise_skies()

  Rooms_border_up()

  for _,R in ipairs(LEVEL.scenic_rooms) do Room_build_seeds(R) end
  for _,R in ipairs(LEVEL.all_rooms)    do Room_build_seeds(R) end
end

