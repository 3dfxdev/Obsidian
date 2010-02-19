---------------------------------------------------------------
--  PLANNING (NEW!) : Single Player
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2009 Andrew Apted
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

class LEVEL
{
  all_rooms  : array(ROOM) 
  all_conns  : array(CONN)
  all_arenas : array(ARENA)
  all_locks  : array(LOCK)

  free_tag  : number
  free_mark : number
  
  skyfence_h  -- height of fence at edge of map

  ....
}


--------------------------------------------------------------]]

require 'defs'
require 'util'


function alloc_tag()
  local result = LEVEL.free_tag
  LEVEL.free_tag = LEVEL.free_tag + 1
  return result
end
  
function alloc_mark()
  local result = LEVEL.free_mark
  LEVEL.free_mark = LEVEL.free_mark + 1
  return result
end


ROOM_CLASS =
{
  tostr = function(self)
    return string.format("%s_%s [%d,%d..%d,%d]",
        sel(self.parent, "SUB_ROOM", "ROOM"),
        self.id, self.sx1,self.sy1, self.sx2,self.sy2)
  end,

  contains_seed = function(self, x, y)
    if x < self.sx1 or x > self.sx2 then return false end
    if y < self.sy1 or y > self.sy2 then return false end
    return true
  end,

  has_lock = function(self, lock)
    for _,D in ipairs(self.conns) do
      if D.lock == lock then return true end
    end
    return false
  end,

  has_any_lock = function(self)
    for _,D in ipairs(self.conns) do
      if D.lock then return true end
    end
    return false
  end,

  has_lock_kind = function(self, kind)
    for _,D in ipairs(self.conns) do
      if D.lock and D.lock.kind == kind then return true end
    end
    return false
  end,

  has_sky_neighbor = function(self)
    for _,D in ipairs(self.conns) do
      local N = D:neighbor(self)
      if N.outdoor then return true end
    end
    return false
  end,

  valid_T = function(self, x, y)
    if x < self.tx1 or x > self.tx2 then return false end
    if y < self.ty1 or y > self.ty2 then return false end
    return true
  end,

  conn_area = function(self)
    local lx, ly = 999,999
    local hx, hy = 0,0

    for _,C in ipairs(self.conns) do
      local S = C:seed(self)
      lx = math.min(lx, S.sx)
      ly = math.min(ly, S.sy)
      hx = math.max(hx, S.sx)
      hy = math.max(hy, S.sy)
    end

    assert(lx <= hx and ly <= hy)

    return lx,ly, hx,hy
  end,

  is_near_exit = function(self)
    if self.purpose == "EXIT" then return true end
    for _,D in ipairs(self.conns) do
      local N = D:neighbor(self)
      if N.purpose == "EXIT" then return true end
    end
    return false
  end,
}



function Plan_CreateRooms()
  
  -- creates rooms out of contiguous areas on the land-map

  local room_map

  local function valid_R(x, y)
    return 1 <= x and x <= LEVEL.W and
           1 <= y and y <= LEVEL.H
  end

  local function dump_rooms()
    local function room_char(R)
      if not R then return '.' end
      if R.is_scenic then return '=' end
      if R.kind == "nature" then return '/' end
      local n = 1 + (R.id % 26)
      return string.sub("ABCDEFGHIJKLMNOPQRSTUVWXYZ", n, n)
    end

    --- dump_rooms ---

    gui.printf("\n")
    gui.printf("Room Map\n")

    for y = LEVEL.H,1,-1 do
      local line = "  "
      for x = 1,LEVEL.W do
        line = line .. room_char(room_map[x][y])
      end
      gui.printf("%s\n", line)
    end
    gui.printf("\n")
  end

  local function calc_width(bx, big_w)
    local w = 0
    for x = bx,bx+big_w-1 do
      w = w + LEVEL.col_W[x]
    end
    return w
  end

  local function calc_height(by, big_h)
    local h = 0
    for y = by,by+big_h-1 do
      h = h + LEVEL.row_H[y]
    end
    return h
  end

  local function add_neighbor(R, side, N)
    -- check if already there
    for _,O in ipairs(R.neighbors) do
      if O == N then return end
    end

    table.insert(R.neighbors, N)
  end

  local function choose_big_size(bx, by)
    local raw = rand_key_by_probs(BIG_ROOM_TABLE)

    local big_w = int(raw / 10)
    local big_h =    (raw % 10)

    if rand_odds(50) then
      big_w, big_h = big_h, big_w
    end

    -- make sure it fits
    if bx+big_w-1 > LEVEL.W then big_w = LEVEL.W - bx + 1 end
    if by+big_h-1 > LEVEL.H then big_h = LEVEL.H - by + 1 end

    assert(big_w > 0 and big_h > 0)

    -- prefer to put big rooms away from the edge
    if (bx == 1 or bx+big_w-1 == LEVEL.W or
        by == 1 or by+big_h-1 == LEVEL.H)
        and rand_odds(50)
    then
      big_w, big_h = 1, 1
    end

    -- prevent excessively large rooms 
    while calc_width(bx, big_w) > 11 do
      big_w = big_w - 1
    end

    while calc_height(by, big_h) > 11 do
      big_h = big_h - 1
    end

    -- never use the whole map
    if big_w >= LEVEL.W and big_h >= LEVEL.H then
      big_w = big_w - 1
      big_h = big_h - 1
    end

    assert(big_w > 0 and big_h > 0)

    -- any other rooms in the way?
    for x = bx,bx+big_w-1 do for y=by,by+big_h-1 do
      if room_map[x][y] then
        return 1, 1
      end
    end end

    return big_w, big_h
  end


  local function replace_room(R, N)
    for x = 1,LEVEL.W do for y = 1,LEVEL.H do
      if room_map[x][y] == R then
         room_map[x][y] = N
      end
    end end -- for x, y
  end

  local function plonk_new_natural(last_x, last_y)
    if last_x then
      local LAST = room_map[last_x][last_y]
      local SIDES = { 2,4,6,8 }
      rand_shuffle(SIDES)
      for _,side in ipairs(SIDES) do
        local nx, ny = nudge_coord(last_x, last_y, side)
        if valid_R(nx, ny) then
          local R = room_map[nx][ny]
          if R and R.kind == "building" then
            R.kind = "nature"
            R.nature_parent = LAST.nature_parent or LAST
            return nx, ny
          end
        end
      end -- for side
    end

    -- no previous room, search randomly
    -- (doesn't matter if we don't find any room to convert)

    for loop = 1, 2*(LEVEL.W + LEVEL.H) do
      local x = rand_irange(1, LEVEL.W)
      local y = rand_irange(1, LEVEL.H)
      local R = room_map[x][y]

      if R and R.kind == "building" then
        R.kind = "nature"
        return x, y
      end
    end
  end

  local function make_naturals(room_num)
    if room_num <= 4 then return end

    local count = int(room_num / 2)
    local last_x, last_y

    for i = 1,count do
      local x, y = plonk_new_natural(last_x, last_y)

      if rand_odds(85) then
        last_x, last_y = x, y
      else
        last_x, last_y = nil, nil
      end
    end
  end


  ---| Plan_CreateRooms |---

  room_map = array_2D(LEVEL.W, LEVEL.H)

  local id = 1

  local col_x = { 2 }  -- one border seed
  local col_y = { 2 }

  for x = 2,LEVEL.W do col_x[x] = col_x[x-1] + LEVEL.col_W[x-1] end
  for y = 2,LEVEL.H do col_y[y] = col_y[y-1] + LEVEL.row_H[y-1] end


  local visits = {}

  for x = 1,LEVEL.W do for y = 1,LEVEL.H do
    table.insert(visits, { x=x, y=y })
  end end

  rand_shuffle(visits)

  for _,vis in ipairs(visits) do
    local bx, by = vis.x, vis.y
    
    if not room_map[bx][by] then
      local ROOM = { id=id, kind="building", conns={}, }
      id = id + 1

      set_class(ROOM, ROOM_CLASS)

      local big_w, big_h = choose_big_size(bx, by)

      ROOM.big_w = big_w
      ROOM.big_h = big_h

      -- determine coverage on seed map
      ROOM.sw = calc_width (bx, big_w)
      ROOM.sh = calc_height(by, big_h)

      ROOM.sx1 = col_x[bx]
      ROOM.sy1 = col_y[by]

      ROOM.sx2 = ROOM.sx1 + ROOM.sw - 1
      ROOM.sy2 = ROOM.sy1 + ROOM.sh - 1

      for x = bx,bx+big_w-1 do for y = by,by+big_h-1 do
        room_map[x][y] = ROOM
      end end

      gui.debugf("%s\n", ROOM:tostr())
    end
  end

  LEVEL.last_id = id

  make_naturals(id)

  dump_rooms()


  -- determines neighboring rooms of each room
  -- (including diagonals, which may touch after nudging)
  
  for x = 1,LEVEL.W do for y = 1,LEVEL.H do
    local R = room_map[x][y]
    
    if not R.neighbors then
      table.insert(LEVEL.all_rooms, R)
      R.neighbors = {}
    end

    for side = 1,9 do if side ~= 5 then
      local nx, ny = nudge_coord(x, y, side)
      if valid_R(nx, ny) then
        local N = room_map[nx][ny]
        if N ~= R then
          add_neighbor(R, side, N)
        end
      end
    end end -- for side / if ~= 5
  end end -- for x, y
end



function Plan_MergeNatural()
 
  local function merge_one_natural(src, dest)
    gui.printf("Merging Natural: %s --> %s\n", src:tostr(), dest:tostr())

    dest.sx1 = math.min(src.sx1, dest.sx1)
    dest.sy1 = math.min(src.sy1, dest.sy1)

    dest.sx2 = math.max(src.sx2, dest.sx2)
    dest.sy2 = math.max(src.sy2, dest.sy2)

    dest.sw = dest.sx2 - dest.sx1 + 1
    dest.sh = dest.sy2 - dest.sy1 + 1
    dest.svolume = dest.sw * dest.sh  -- not accurate

    -- NB: connections are not established yet

    for x = src.sx1,src.sx2 do for y = src.sy1,src.sy2 do
      local S = SEEDS[x][y][1]
      if S.room == src then
         S.room = dest
      end
    end end -- for x, y
  end

  ---| Plan_MergeNatural |---

  local room_list = LEVEL.all_rooms
  LEVEL.all_rooms = {}

  for _,R in ipairs(room_list) do
    if R.nature_parent then
      -- this room is NOT added back into all_rooms list
      merge_one_natural(R, R.nature_parent)
    else
      table.insert(LEVEL.all_rooms, R)
    end
  end
end



------------------------------------------------------------------------


function Room_side_len(R, side)
  if (side == 2 or side == 8) then
    return R.sx2 + 1 - R.sx1
  else
    return R.sy2 + 1 - R.sy1
  end
end

function Room_side_coord(R, side, i)
  local x, y

      if side == 2 then x, y = R.sx1 + (i-1), R.sy1
  elseif side == 8 then x, y = R.sx1 + (i-1), R.sy2
  elseif side == 4 then x, y = R.sx1, R.sy1 + (i-1)
  elseif side == 6 then x, y = R.sx2, R.sy1 + (i-1)
  else
    error("Bad side for Room_side_coord!")
  end

  return x, y
end


function Plan_Nudge()
  -- This resizes rooms by moving certain borders either one seed
  -- outward or one seed inward.  There are various constraints,
  -- in particular each room must remain a rectangle shape (so we
  -- disallow nudges that would create an L shaped room).
  --
  -- Big rooms must be handled first, because small rooms are
  -- never able to nudge a big border.

  local function volume_after_nudge(R, side, grow)
    if (side == 6 or side == 4) then
      return (R.sw + grow) * R.sh
    else
      return R.sw * (R.sh + grow)
    end
  end

  local function depth_after_nudge(R, side, grow)
    return sel(side == 6 or side == 4, R.sw, R.sh) + grow
  end

  local function allow_nudge(R, side, grow, N, list)

    -- above or below a sidewards nudge?
    if (side == 6 or side == 4) then
      if N.sy1 > R.sy2 then return true end
      if R.sy1 > N.sy2 then return true end
    else
      if N.sx1 > R.sx2 then return true end
      if R.sx1 > N.sx2 then return true end
    end

    -- opposite side?
    if side == 6 and (N.sx2 < R.sx2) then return true end
    if side == 4 and (N.sx1 > R.sx1) then return true end
    if side == 8 and (N.sy2 < R.sy2) then return true end
    if side == 2 and (N.sy1 > R.sy1) then return true end

    if (side == 6 or side == 4) then
      if (N.sy1 < R.sy1) or (N.sy2 > R.sy2) then return false end
    else
      if (N.sx1 < R.sx1) or (N.sx2 > R.sx2) then return false end
    end

    -- the nudge is possible (pushing the neighbor also)

    if N.no_nudge or N.nudges[10-side] then return false end

---##   if volume_after_nudge(N, 10-side, -grow) < 3 then return false end

    if depth_after_nudge(N, 10-side, -grow) < 2 then return false end

--???    if side == 6 then assert(N.sx1 == R.sx2+1) end
--???    if side == 4 then assert(N.sx2 == R.sx1-1) end
--???    if side == 8 then assert(N.sy1 == R.sy2+1) end
--???    if side == 2 then assert(N.sy2 == R.sy1-1) end

    table.insert(list, { room=N, side=10-side, grow=-grow })

    return true
  end

  local function try_nudge_room(R, side, grow)
    -- 'grow' is positive to nudge outward, negative to nudge inward

    -- Note: any shrinkage must pull neighbors too

    if not grow then
      grow = rand_sel(75,1,-1)
    end

gui.debugf("Trying to nudge room %dx%d, side:%d grow:%d\n", R.sw, R.sh, side, grow)

    if R.no_nudge then return false end

--[[
    if R.no_grow   and grow > 0 then return false end
    if R.no_shrink and grow < 0 then return false end
--]]

    -- already moved this border?
    if R.nudges[side] then return false end

    -- would get too small?  or too big?
    local new_d = depth_after_nudge(R, side, grow)

    if new_d < 2 or new_d > 13 then return false end

    -- side sits on border of the map?
--[[
    if (side == 2 and R.ly1 == 1) or
       (side == 4 and R.lx1 == 1) or
       (side == 6 and R.lx2 == LAND_W) or
       (side == 8 and R.ly2 == LAND_H)
    then
      return false
    end
--]]

    local push_list = {}

    for _,K in ipairs(R.neighbors) do
      if not allow_nudge(R, side, grow, K, push_list) then return false end
    end

    -- Nudge is OK!
    gui.printf("Nudging %s side:%d grow:%d\n", R:tostr(), side, grow)

    table.insert(push_list, { room=R, side=side, grow=grow })

    for _,push in ipairs(push_list) do
      local R = push.room

          if push.side == 2 then R.sy1 = R.sy1 - push.grow
      elseif push.side == 8 then R.sy2 = R.sy2 + push.grow
      elseif push.side == 4 then R.sx1 = R.sx1 - push.grow
      elseif push.side == 6 then R.sx2 = R.sx2 + push.grow
      end

      -- fix up seed size
      R.sw, R.sh = box_size(R.sx1, R.sy1, R.sx2, R.sy2)

      assert(not R.nudges[push.side])
      R.nudges[push.side] = true
    end

    return true
  end

  local function nudge_big_rooms()
    local rooms = {}

    for _,R in ipairs(LEVEL.all_rooms) do
      if R.big_w > 1 or R.big_h > 1 then
        R.big_volume = R.big_w * R.big_h
        table.insert(rooms, R)
      end
    end

    if #rooms == 0 then return end

    table.sort(rooms, function(A, B) return A.big_volume > B.big_volume end)

    local sides = { 2,4,6,8 }

    for _,R in ipairs(rooms) do
      rand_shuffle(sides)
      for _,side in ipairs(sides) do
        local depth = sel(side==4 or side==6, R.sw, R.sh)
        if (depth % 2) == 0 then
          if not (rand_odds(30) and try_nudge_room(R, side, 1)) then
            try_nudge_room(R, side, -1)
          end
        end
      end
      R.no_nudge = true
    end
  end

  local function get_NE_corner_rooms(R)

    local E, N, NE -- East, North, NorthEast

    for _,K in ipairs(R.neighbors) do

      if K.sx2 == R.sx2 and K.sy1 > R.sy2 then N = K end
      if K.sy2 == R.sy2 and K.sx1 > R.sx2 then E = K end

      if K.sx1 > R.sx2 and K.sy1 > R.sy2 then NE = K end
    end

    return E, N, NE
  end

  local function nudge_the_rest()
    local rooms = {}
    for _,R in ipairs(LEVEL.all_rooms) do
      if R.big_w == 1 and R.big_h == 1 then
        table.insert(rooms, R)
      end
    end

    local sides = { 2,4,6,8 }

    for pass = 1,2 do
      rand_shuffle(rooms)
      for _,R in ipairs(rooms) do
        rand_shuffle(sides)
        for _,side in ipairs(sides) do
          if rand_odds(30) then
            try_nudge_room(R, side)
          end
        end
      end -- R in all_rooms
    end -- pass
  end


  ---| Plan_Nudge |---

  for _,R in ipairs(LEVEL.all_rooms) do
    R.nudges = {}
  end

  nudge_big_rooms()
  nudge_the_rest()
end




function Plan_SubRooms()
  local id = LEVEL.last_id + 1

  --                    1  2  3   4   5   6   7   8+
  local SUB_CHANCES = { 0, 0, 1,  3,  6, 10, 20, 30 }
  local SUB_HEAPS   = { 0, 0, 6, 20, 40, 60, 75, 90 }

  local function can_fit(R, x, y, w, h)
    if w >= R.sw or h >= R.sh then return nil end

    if x+w > R.sx2 or y+h > R.sy2 then return nil end

    local touches_wall = false
    if x == R.sx1 or x+w == R.sx2 or y == R.sy1 or y+h == R.sy2 then
      touches_wall = true
    end
    
    for sx = x,x+w-1 do for sy = y,y+h-1 do
      local S = SEEDS[sx][sy][1]
      if S.room ~= R then return nil end
    end end -- sx, sy

    local touches_other = nil

    for sx = x-1,x+w do for sy = y-1,y+h do
      if Seed_valid(sx, sy, 1) then
        local S = SEEDS[sx][sy][1]
        if S.room and S.room.parent == R then

          -- don't allow new sub-room to touch more than one
          -- existing sub-room, since it is possible to split
          -- the room into separate parts that way.
          if touches_other and touches_other ~= S.room then
            return nil
          end

          touches_other = S.room
        end
      end
    end end -- sx, sy

    -- if it touches the outside wall, make sure it does NOT touch
    -- another sub-room (otherwise the room could be split into
    -- two separated parts, which is bad).
    -- TODO: smarter test
    if touches_wall and touches_other then
      return nil
    end

    if STYLE.islands == "heaps" then
      if touches_wall  then return 10 end
      if touches_other then return 40 end
      return 200
    end

    -- probability based on volume ratio
    local vr = w * h * 3 / R.svolume
    if vr < 1 then vr = 1 / vr end

    return 200 / (vr * vr)
  end

  local function try_add_sub_room(parent)
    local infos = {}
    local probs = {}
    for x = parent.sx1,parent.sx2 do for y = parent.sy1,parent.sy2 do
      for w = 2,6 do
        local prob = can_fit(parent, x, y, w, w)
        if prob then
          local INFO = { x=x, y=y, w=w, h=w, islandy=islandy }

          -- make rectangles sometimes
          if INFO.w >= 3 and rand_odds(30) then
            INFO.w = INFO.w - 1
            if rand_odds(50) then INFO.x = INFO.x + 1 end
          elseif INFO.h >= 3 and rand_odds(30) then
            INFO.h = INFO.h - 1
            if rand_odds(50) then INFO.y = INFO.y + 1 end
          end

          table.insert(infos, INFO)
          table.insert(probs, prob)
        end
      end
    end end -- x, y

    if #infos == 0 then return end

    local info = infos[rand_index_by_probs(probs)]

    -- actually add it !
    local ROOM =
    {
      id=id, kind="building", conns={},
      big_w=1, big_h=1,
    }

    id = id + 1

    set_class(ROOM, ROOM_CLASS)

    ROOM.parent = parent
    ROOM.neighbors = { }  -- ???

    ROOM.sx1 = info.x
    ROOM.sy1 = info.y

    ROOM.sx2 = info.x + info.w - 1
    ROOM.sy2 = info.y + info.h - 1

    ROOM.sw, ROOM.sh = box_size(ROOM.sx1, ROOM.sy1, ROOM.sx2, ROOM.sy2)
    ROOM.svolume = ROOM.sw * ROOM.sh

    ROOM.is_island = (ROOM.sx1 > parent.sx1) and (ROOM.sx2 < parent.sx2) and
                     (ROOM.sy1 > parent.sy1) and (ROOM.sy2 < parent.sy2)

    table.insert(LEVEL.all_rooms, ROOM)

    if not parent.children then parent.children = {} end
    table.insert(parent.children, ROOM)

    parent.svolume = parent.svolume - ROOM.svolume

    -- update seed map
    for sx = ROOM.sx1,ROOM.sx2 do
      for sy = ROOM.sy1,ROOM.sy2 do
        SEEDS[sx][sy][1].room = ROOM
      end
    end
  end


  ---| Plan_SubRooms |---

  Seed_dump_rooms()

  if STYLE.subrooms == "none" then return end

  local chance_tab = sel(STYLE.subrooms == "some", SUB_CHANCES, SUB_HEAPS)

  for _,R in ipairs(LEVEL.all_rooms) do
    if not R.parent and not (R.kind == "nature") then
      local min_d = math.max(R.sw, R.sh)
      if min_d > 8 then min_d = 8 end

      if rand_odds(chance_tab[min_d]) then
        try_add_sub_room(R)

        if min_d >= 5 and rand_odds(10) then try_add_sub_room(R) end
        if min_d >= 6 and rand_odds(65) then try_add_sub_room(R) end
        if min_d >= 7 and rand_odds(25) then try_add_sub_room(R) end
        if min_d >= 8 and rand_odds(90) then try_add_sub_room(R) end
      end
    end
  end

  LEVEL.last_id = id

  Seed_dump_rooms()
end


function Plan_MakeSeeds()

  local function plant_rooms()
    for _,R in ipairs(LEVEL.all_rooms) do
      for sx = R.sx1,R.sx2 do for sy = R.sy1,R.sy2 do
        assert(Seed_valid(sx, sy, 1))
        local S = SEEDS[sx][sy][1]
        assert(not S.room) -- no overlaps please!
        S.room = R
        S.kind = "walk"
      end end -- for sx,sy
    end -- for R

    for _,R in ipairs(LEVEL.scenic_rooms) do
      for sx = R.sx1,R.sx2 do for sy = R.sy1,R.sy2 do
        local S = SEEDS[sx][sy][1]
        if not S.room then -- overlap is OK for scenics
          S.room = R
          S.kind = "liquid"
          S.f_tex = "LAVA1"  -- TEMP CRUD !!!!
        end
      end end -- for sx,sy
    end -- for R
  end

  local function fill_holes()
    local sc_list = shallow_copy(LEVEL.scenic_rooms)
    rand_shuffle(sc_list)

    for _,R in ipairs(sc_list) do
      local nx1,ny1 = R.sx1,R.sy1
      local nx2,ny2 = R.sx2,R.sy2

      for x = R.sx1-1, R.sx2+1 do for y = R.sy1-1, R.sy2+1 do
        if Seed_valid(x, y, 1) and not R:contains_seed(x, y) then
          local S = SEEDS[x][y][1]
          if not S.room then
            S.room = R
            if x < R.sx1 then nx1 = x end
            if y < R.sy1 then ny1 = y end
            if x > R.sx2 then nx2 = x end
            if y > R.sy2 then ny2 = y end
          end
        end
      end end -- for x,y

      R.sx1, R.sy1 = nx1, ny1
      R.sx2, R.sy2 = nx2, ny2

      R.sw, R.sh = box_size(R.sx1, R.sy1, R.sx2, R.sy2)
    end -- for R
  end


  ---| Plan_MakeSeeds |---

  local max_sx = 1
  local max_sy = 1

  for _,R in ipairs(LEVEL.all_rooms) do
    max_sx = math.max(max_sx, R.sx2)
    max_sy = math.max(max_sy, R.sy2)

    R.svolume = R.sw * R.sh
  end

  -- one border seed
  max_sx = max_sx + 1
  max_sy = max_sy + 1

  Seed_init(max_sx, max_sy, 1)

  plant_rooms()
  fill_holes()
end


function Plan_determine_size()

  local function show_sizes(name, t, N)
    name = name .. ": "
    for i = 1,N do
      name = name .. tostring(t[i]) .. " "
    end
    gui.debugf("%s\n", name)
  end

  local function get_column_sizes(W, limit)
    local cols = {}

    assert(2 + W*2 <= limit)

    for loop = 1,100 do
      local total = 2  -- border seeds around level

      for x = 1,W do
        cols[x] = rand_index_by_probs(ROOM_SIZE_TABLE)
        total = total + cols[x]
      end

      if total <= limit then
        return cols  -- OK!
      end
    end

    -- emergency fallback
    gui.printf("Using emergency column sizes.\n")

    for x = 1,W do cols[x] = 2 end

    return cols
  end


  ---| Plan_determine_size |---

  local W, H  -- number of rooms

  local ob_size = OB_CONFIG.size

  -- there is no real "progression" when making a single level
  -- hence use mixed mode instead.
  if ob_size == "prog" and OB_CONFIG.length == "single" then
    ob_size = "mixed"
  end

  if ob_size == "mixed" then
    W = 2 + rand_index_by_probs { 1,4,7,4,2,1 }
    H = 2 + rand_index_by_probs { 4,7,4,2,1 }

    if W < H then W, H = H, W end

  elseif ob_size == "prog" then
    local n = 1 + LEVEL.ep_along * 8.9

    n = int(n)
    if n < 1 then n = 1 end
    if n > 9 then n = 9 end

    local WIDTHS  = { 3,4,4, 5,5,6, 6,7,7 }
    local HEIGHTS = { 3,3,4, 4,5,5, 6,6,7 }

    W = WIDTHS[n]
    H = HEIGHTS[n]

  else
    local WIDTHS  = { small=4, normal=6, large=7 }
    local HEIGHTS = { small=3, normal=4, large=7 }

    W = WIDTHS[ob_size]
    H = HEIGHTS[ob_size]

    if not W then
      error("Unknown size keyword: " .. tostring(ob_size))
    end

    if rand_odds(30) then W = W - 1 end
  end

  LEVEL.W = W
  LEVEL.H = H

if TESTING_QUAKE_II then
  LEVEL.W = 1
  LEVEL.H = 2
  LEVEL.join_all = true
end

  gui.printf("Land size: %dx%d\n", LEVEL.W, LEVEL.H)


  -- initial sizes of rooms in each row and column
  local cols = {}
  local rows = {}

  local limit = PARAM.seed_limit or 48

  cols = get_column_sizes(W, limit)
  rows = get_column_sizes(H, limit)
  
  LEVEL.col_W = cols
  LEVEL.row_H = rows

  show_sizes("col_W", cols, LEVEL.W)
  show_sizes("row_H", rows, LEVEL.H)
end


function Plan_rooms_sp()

  gui.printf("\n--==| Plan_rooms_sp |==--\n\n")

  assert(LEVEL.ep_along)

  LEVEL.all_rooms = {}
  LEVEL.all_conns = {}

  LEVEL.scenic_rooms = {}
  LEVEL.scenic_conns = {}

  LEVEL.free_tag  = 1
  LEVEL.free_mark = 1

  Plan_determine_size()

  Plan_CreateRooms()
  Plan_Nudge()

  -- must create the seeds _AFTER_ nudging
  Plan_MakeSeeds()
  Plan_MergeNatural()

  Plan_SubRooms()

  for _,R in ipairs(LEVEL.all_rooms) do
    gui.printf("Final %s   size: %dx%d\n", R:tostr(), R.sw,R.sh)
  end


  LEVEL.skyfence_h = rand_sel(50, 192, rand_sel(50, 64, 320))

end -- Plan_rooms_sp

