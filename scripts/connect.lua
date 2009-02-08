---------------------------------------------------------------
--  CONNECTIONS
----------------------------------------------------------------
--
--  Oblige Level Maker (C) 2006-2008 Andrew Apted
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

class CONN
{
  src    : source ROOM
  dest   : destination ROOM

  src_S  : source SEED
  dest_S : destination SEED

  dir    : direction 2/4/6/8 (from src_S to dest_S)

  conn_h : floor height for connection

  lock   : LOCK
}

--------------------------------------------------------------]]

require 'defs'
require 'util'


CONN_CLASS =
{
  neighbor = function(self, R)
    if R == self.src then
      return self.dest
    else
      return self.src
    end
  end,

  seed = function(self, R)
    if R == self.src then
      return self.src_S
    else
      return self.dest_S
    end
  end,

  tostr = function(self)
    if self.conn_h then
      return string.format("CONN%s[%d,%d -> %d,%d h:%s]",
             sel(self.lock, "-LOCK", ""),
             self.src.sx1, self.src.sy1, self.dest.sx1, self.dest.sy1,
             self.conn_h)
    else
      return string.format("CONN%s[%d,%d -> %d,%d]",
             sel(self.lock, "-LOCK", ""),
             self.src.sx1, self.src.sy1, self.dest.sx1, self.dest.sy1)
    end
  end,
}



-- Generator functions for "big branches" (mostly for large rooms
-- which deserve 3/4/5 exits).
-- 
-- Each function generates a list of configurations.  Each config
-- describes the exits for a single room, and is a list of tuples
-- in the form (x, y, dir) but unpacked.  NIL returned means that
-- the given size was not suitable for that pattern (e.g. a pure
-- cross requires an odd width and an odd height).
--
-- It is assumed that the caller will try all the four possible
-- mirrorings (none/X/Y/XY) and rotations (none/90) of each
-- configuration, and these generator functions are optimised
-- with that in mind.
--
-- The symmetry field can have the following keywords:
--   "x"  mirrored horizontally (i.e. left side = right side)
--   "y"  mirrored vertically
--   "xy" mirrored both horizontally and vertically
--   "r"  rotation symmetry (180 degrees)
--   "t"  transpose symmetry (square rooms only)
--


--- 2 way --->

function branch_gen_PC(long, deep)
  if long < 3 or long > 7 or (long % 2) == 0 or
     deep < 2 or deep > 7 or (long / deep) >= 3
  then
    return nil
  end

  local mx  = int((long+1)/2)

  return {{ mx,1,2, mx,deep,8 }}
end

function branch_gen_PA(long, deep)
  if long < 2 or long > 4 or deep < 2 or deep > 5 then
    return nil
  end

  return {{ 1,1,2, 1,deep,8 }}
end

function branch_gen_PR(long, deep)
  if long < 2 or deep < 1 or deep > 5 or
     (long*deep) >= 30 or (deep/long) > 2.1
  then
    return nil
  end

  local configs = {}
  local lee = int((long-2)/4)

  for x = 0,lee do
    table.insert(configs, { 1+x,1,2, long-x,deep,8 })
  end

  return configs
end

function branch_gen_PX(long, deep)
  if long < 3 or long > 5 or deep < 1 or deep > 5 then
    return nil
  end

  local configs = {}
  local mx = int(long/2)

  for b = 1,mx do for t = 2,long-1 do
    if not (deep == 1 and b == t) then
      table.insert(configs, { b,1,2, t,deep,8 })
    end
  end end

  return configs
end

function branch_gen_LS(long, deep)
  if long < 2 or long > 6 or deep ~= long then
    return nil
  end

  local configs = {}

  local lee = int((long-1)/2)

  for x = 0,lee do
    table.insert(configs, { 1,1+x,4, long-x,deep,8 })
  end

  return configs
end

function branch_gen_LX(long, deep)
  if long < 3 or deep < 1 or long==deep or (long*deep) >= 30 then
    return nil
  end

  local configs = {}

  local x_lee = int((long-2)/3)
  local y_lee = int((deep-1)/2)

  for x = 0,x_lee do for y = 0,y_lee do
    table.insert(configs, { 1,1+y,4, long-x-1,deep,8 })
  end end

  return configs
end

function branch_gen_U2(long, deep)
  if long < 3 or deep < 1 or long < deep or deep > 4 then
    return nil
  end

  local configs = {}

  local x_lee = int((long-2)/4)

  for x = 0,x_lee do
    table.insert(configs, { 1+x,deep,8, long-x,deep,8 })
  end

  return configs
end


--- 3 way --->

function branch_gen_TC(long, deep)
  if long < 3 or deep < 1 or deep > 7 or (long % 2) == 0 or (long*deep) >= 42 then
    return nil
  end

  local configs = {}

  local mx  = int((long+1)/2)
  local lee = int((deep-1)/2)

  for y = 0,lee do
    table.insert(configs, { mx,1,2, 1,deep-y,4, long,deep-y,6 })
  end

  return configs
end

function branch_gen_TX(long, deep)
  if long < 4 or deep < 1 or deep > 7 or (long*deep) >= 42 then
    return nil
  end

  local configs = {}

  local mx    = int((long  )/2)
  local y_lee = int((deep-1)/2)

  for x = 2,mx do for y = 0,y_lee do
    table.insert(configs, { x,1,2, 1,deep-y,4, long,deep-y,6 })
  end end

  return configs
end

function branch_gen_TY(long, deep)
  if long < 3 or deep < 1 or deep > 5 or (long % 2) == 0 then
    return nil
  end

  local configs = {}

  local mx  = int((long+1)/2)
  local lee = int((long-2)/3)

  for x = 0,lee do
    table.insert(configs, { mx,1,2, 1+x,deep,8, long-x,deep,8 })
  end

  return configs
end

function branch_gen_F3(long, deep)
  if long < 4 or deep < 1 or (long/deep) < 2 then
    return nil
  end

  local configs = {}

  local mx    = int((long  )/2)
  local y_lee = int((deep-1)/2)

  for x = mx,long-2 do for y = 0,y_lee do
    table.insert(configs, { 1,1+y,4, x,deep,8, long,deep,8 })
  end end

  return configs
end

function branch_gen_M3(long, deep)
  if long < 5 or (long % 2) == 0 or long < deep or
     deep < 1 or deep > 5
  then
    return nil
  end

  local configs = {}

  local mx    = int((long+1)/2)
  local x_lee = int((long-3)/4)

  for x = 0,x_lee do
    table.insert(configs, { 1+x,1,2, mx,1,2, long-x,1,2 })
  end

  return configs
end


--- 4 way --->

function branch_gen_XC(long, deep)
  if long < 3 or (long % 2) == 0 or
     deep < 3 or (deep % 2) == 0
  then
     return nil
  end

  local mx = int((long+1)/2)
  local my = int((deep+1)/2)

  return {{ mx,1,2, mx,deep,8, 1,my,4, long,my,6 }}
end

function branch_gen_XT(long, deep)
  if long < 3 or deep < 3 or (long % 2) == 0 then
    return nil
  end

  local configs = {}
  local mx = int((long+1)/2)
  local my = int(deep/2)

  for y = 1,my do
    table.insert(configs, { mx,1,2, mx,deep,8, 1,y,4, long,y,6 })
  end

  return configs
end

function branch_gen_XX(long, deep)
  if long < 5 or deep < 3 or (long*deep) >= 50 then
    return nil
  end

  local configs = {}
  local mx = int(long/2)
  local my = int(deep/2)

  for x = 2,mx do for y = 1,my do
    table.insert(configs, { x,1,2, x,deep,8, 1,y,4, long,y,6 })
  end end

  return configs
end

function branch_gen_SW(long, deep)
  if long < 3 or deep < 3 then
    return nil
  end

  local configs = {}

  local x_lee = int((long-1)/4)
  local y_lee = int((deep-1)/4)

  for x = 0,x_lee do for y = 0,y_lee do
    table.insert(configs, { 1+x,1,2, long,1+y,6, long-x,deep,8, 1,deep-y,4 })
  end end

  return configs
end

function branch_gen_HP(long, deep)
  if long < 3 or deep < 2 then
    return nil
  end

  local configs = {}

  local b_lee = int((long-2)/3)
  local t_lee = int((long-2)/5)
  
  for b = 0,b_lee do for t = 0,t_lee do
    if b >= t then
      table.insert(configs, { 1+b,1,2, long-b,1,2, 1+t,deep,8, long-t,deep,8 })
    end
  end end

  return configs
end

function branch_gen_HT(long, deep)
  if long < 3 or deep < 2 or (long*deep) >= 50 then
    return nil
  end

  local configs = {}

  local x_lee = int((long-2)/3)
  local y_lee = int((deep-1)/2)
  
  for x = 0,x_lee do for y = 0,y_lee do
    table.insert(configs, { 1+x,1,2, long-x,1,2, 1,deep-y,4, long,deep-y,6 })
  end end

  return configs
end

function branch_gen_F4(long, deep)
  if long < 4 or deep < 4 then
    return nil
  end

  local configs = {}

  local x_dist = int((long)/2)
  local y_dist = int((deep)/2)

  local x_lee = int((long-1)/4)
  local y_lee = int((deep-1)/4)

  for x = 0,x_lee do for y = 0,y_lee do
    table.insert(configs, { 1,1+y,4, 1,1+y+y_dist,4, long-x,deep,8, long-x-x_dist,deep,8 })
  end end

  return configs
end


--- 5,6 way --->

function branch_gen_KY(long, deep)
  if long < 5 or deep < 3 or (long*deep) < 21 or (long % 2) == 0 then
    return nil
  end

  local configs = {}

  local mx    = int((long+1)/2)
  local x_lee = int((long-2)/3)
 
  for x = 0,x_lee do for y = 1,deep-1 do
    table.insert(configs, { mx,1,2, 1,y,4, long,y,6, 1+x,deep,8, long-x,deep,8 })
  end end

  return configs
end

function branch_gen_KT(long, deep)
  if long < 3 or deep < 4 or (long*deep) < 21 or (long % 2) == 0 then
    return nil
  end

  local configs = {}

  local mx    = int((long+1)/2)
  local my    = int(deep / 2)
  local t_lee = int((deep-2)/3)
 
  for t = 0,t_lee do for y = 1,my do
    table.insert(configs, { mx,1,2, 1,y,4, long,y,6, 1,deep-t,4, long,deep-t,6 })
  end end

  return configs
end

function branch_gen_M5(long, deep)
  if long < 5 or deep < 3 or (long % 2) == 0 or long < deep then
    return nil
  end

  local configs = {}

  local mx    = int((long+1)/2)
  local t_lee = int((long-4)/3)
--  local b_lee = int((long-3)/4)

  for b = 0,mx-2 do for t = 0,t_lee do
    table.insert(configs, { mx-1-b,1,2, mx+1+b,1,2, 1+t,deep,8, mx,deep,8, long-t,deep,8 })
  end end

  return configs
end

function branch_gen_GG(long, deep)
  if long < 5 or deep < 3 or (long*deep) < 21 or (long % 2) == 0 then
    return nil
  end

  local configs = {}

  local mx    = int((long+1)/2)
  local y_lee = int((deep-3)/2)
 
  for y = 0,y_lee do
    table.insert(configs, { mx,1,2, mx,deep,8, 1,1+y,4, 1,deep-y,4, long,1+y,6, long,deep-y,6 })
  end

  return configs
end


BIG_BRANCH_KINDS =
{
  -- pass through (one side to the other), perfectly centered
  PC = { conn=2, prob=40, func=branch_gen_PC, symmetry="x" },

  -- pass through, along one side
  PA = { conn=2, prob= 8, func=branch_gen_PA, symmetry="y" },

  -- pass through, rotation symmetry
  PR = { conn=2, prob=50, func=branch_gen_PR, symmetry="r" },

  -- pass through, garden variety
  PX = { conn=2, prob= 3, func=branch_gen_PX },

  -- L shape for square room (transpose symmetrical)
  LS = { conn=2, prob=100, func=branch_gen_LS, symmetry="t" },

  -- L shape, garden variety
  LX = { conn=2, prob= 3, func=branch_gen_LX },

  -- U shape, both exits on a single wall
  U2 = { conn=2, prob= 1, func=branch_gen_U2, symmetry="x" },


  -- T shape, centered main stem, leeway for side stems
  TC = { conn=3, prob=200, func=branch_gen_TC, symmetry="x" },

  -- like TC but main stem not centered
  TX = { conn=3, prob= 50, func=branch_gen_TX },

  -- Y shape, two exits parallel to single centered entry
  TY = { conn=3, prob=120, func=branch_gen_TY, symmetry="x" },

  -- F shape with three exits (mainly for rooms at corner of map)
  F3 = { conn=3, prob=  2, func=branch_gen_F3 },

  -- three exits along one wall, middle is centered
  M3 = { conn=3, prob=  5, func=branch_gen_M3, symmetry="x" },


  -- Cross shape, all stems perfectly centered
  XC = { conn=4, prob=2000, func=branch_gen_XC, symmetry="xy" },

  -- Cross shape, centered main stem, leeway for side stems
  XT = { conn=4, prob=300, func=branch_gen_XT, symmetry="x" },

  -- Cross shape, no stems are centered
  XX = { conn=4, prob=100, func=branch_gen_XX },

  -- H shape, parallel entries/exits at the four corners
  HP = { conn=4, prob= 60, func=branch_gen_HP, symmetry="x" },

  -- like HP but exits are perpendicular to entry dir
  HT = { conn=4, prob= 60, func=branch_gen_HT, symmetry="x" },

  -- Swastika shape
  SW = { conn=4, prob= 100, func=branch_gen_SW, symmetry="r" },

  -- F shape with two exits on each wall
  F4 = { conn=4, prob=  5, func=branch_gen_F4 },


  -- five-way star shapes
  KY = { conn=5, prob=150, func=branch_gen_KY, symmetry="x" },
  KT = { conn=5, prob=150, func=branch_gen_KT, symmetry="x" },

  -- two exits at bottom and three at top, all parallel
  M5 = { conn=5, prob= 40, func=branch_gen_M5, symmetry="x" },


  -- gigantic six-way shapes
  GG = { conn=6, prob=350, func=branch_gen_GG, symmetry="x" },
}


function Test_Branch_Gen(name)
  local info = assert(BIG_BRANCH_KINDS[name])

  local function dump_exits(config, W, H)
    local DIR_CHARS = { [2]="|", [8]="|", [4]=">", [6]="<" }

    local P = array_2D(W+2, H+2)

    for y = 0,H+1 do for x = 0,W+1 do
      P[x+1][y+1] = sel(box_contains_point(1,1,W,H, x,y), "#", " ")
    end end

    for idx = 1,#config,3 do
      local x   = config[idx+0]
      local y   = config[idx+1]
      local dir = config[idx+2]

      assert(x, y, dir)
      assert(box_contains_point(1,1,W,H, x,y))

      local nx, ny = nudge_coord(x, y, dir)
      assert(nx==0 or nx==W+1 or ny==0 or ny==H+1)

      if P[nx+1][ny+1] ~= " " then
        gui.printf("spot: (%d,%d):%d to (%d,%d)\n", x,y,dir, nx,ny)
        error("Bad branch!")
      end

      P[nx+1][ny+1] = DIR_CHARS[dir] or "?"
    end

    for y = H+1,0,-1 do
      for x = 0,W+1 do
        gui.printf("%s", P[x+1][y+1])
      end
      gui.printf("\n")
    end
    gui.printf("\n")
  end

  for deep = 1,9 do for long = 1,9 do
    gui.printf("==== %s %dx%d ==================\n\n", name, long, deep)

    local configs = info.func(long, deep)
    if not configs then
      gui.printf("Unsupported size\n\n")
    else
      for _,CONF in ipairs(configs) do
        dump_exits(CONF, long, deep)
      end
    end
  end end -- deep, long
end


function Connect_Rooms()

  -- Guidelines:
  -- 1. prefer a "wide" bond between ground areas of same kind.
  -- 2. prefer not to connect ground areas of different kinds.
  -- 3. prefer ground areas not to be leafs
  -- 4. prefer big rooms to have 3 or more connections.
  -- 5. prefer small isolated rooms to be leafs (1 connection).

  local function merge_groups(id1, id2)
    if id1 > id2 then id1,id2 = id2,id1 end

    for _,R in ipairs(PLAN.all_rooms) do
      if R.c_group == id2 then
        R.c_group = id1
      end
    end
  end

  local function min_group_id()
    local result
    
    for _,R in ipairs(PLAN.all_rooms) do
      if not result or R.c_group < result then
        result = R.c_group
      end
    end

    return assert(result)
  end

  local function group_size(id)
    local result = 0

    for _,R in ipairs(PLAN.all_rooms) do
      if R.c_group == id then
        result = result + 1
      end
    end

    return assert(result)
  end

  local function swap_groups(id1, id2)
    assert(id1 ~= id2)

    for _,R in ipairs(PLAN.all_rooms) do
      if R.c_group == id1 then
        R.c_group = id2
      elseif R.c_group == id2 then
        R.c_group = id1
      end
    end
  end

  local function connect_seeds(S, T, dir)
    assert(not (S.room and S.room.kind == "scenic"))
    assert(not (T.room and T.room.kind == "scenic"))

    S.border[dir].kind    = "arch"
    T.border[10-dir].kind = "straddle"

    S.thick[dir] = 24
    T.thick[10-dir] = 24

gui.debugf("connect_seeds R(%s,%s) S(%d,%d) grp:%d --> R(%s,%s) S(%d,%d) grp:%d\n",
S.room.sx1,S.room.sy1, S.sx,S.sy, S.room.c_group,
T.room.sx1,T.room.sy1, T.sx,T.sy, T.room.c_group)

    merge_groups(S.room.c_group, T.room.c_group)

    local CONN = { dir=dir, src=S.room, dest=T.room, src_S=S, dest_S=T }

    set_class(CONN, CONN_CLASS)

    assert(not S.conn and not S.conn_dir)
    assert(not T.conn and not T.conn_dir)

    S.conn = CONN
    T.conn = CONN

    S.conn_dir = dir
    T.conn_dir = 10-dir

    S.conn_peer = T
    T.conn_peer = S

    table.insert(PLAN.all_conns, CONN)

    table.insert(S.room.conns, CONN)
    table.insert(T.room.conns, CONN)

    return CONN
  end


  local function morph_size(MORPH, R)
    if MORPH >= 4 then
      return R.sh, R.sw
    else
      return R.sw, R.sh
    end
  end

  local function morph_dir(MORPH, dir)
    if dir == 5 then
      return 5
    end

    if (MORPH % 2) >= 1 then
      if (dir == 4) or (dir == 6) then dir = 10-dir end
    end

    if (MORPH % 4) >= 2 then
      if (dir == 2) or (dir == 8) then dir = 10-dir end
    end

    if MORPH >= 4 then
      dir = rotate_cw90(dir)
    end

    return dir
  end

  local function morph_coord(MORPH, R, x, y, long, deep)
    assert(1 <= x and x <= long)
    assert(1 <= y and y <= deep)

    if (MORPH % 2) >= 1 then
      x = long+1 - x
    end

    if (MORPH % 4) >= 2 then
      y = deep+1 - y
    end

    if MORPH >= 4 then
      x, y = y, long+1-x
    end

    return R.sx1 + (x-1), R.sy1 + (y-1)
  end

  local function morph_symmetry(MORPH, sym)
    if sym == "x" then
      return sel(MORPH >= 4, "y", "x")
    end

    if sym == "y" then
      return sel(MORPH >= 4, "x", "y")
    end

    -- no change for XY, R and T kinds
    return sym
  end

  local function dump_new_conns(conns)
    gui.debugf("NEW CONNS:\n")
    for _,C in ipairs(conns) do
      gui.debugf("  S(%d,%d) --> S(%d,%d)  dir:%d\n", C.S.sx,C.S.sy, C.N.sx,C.N.sy, C.dir)
    end
  end

  local function try_configuration(MORPH, R, K, config, long, deep)
    assert(R.c_group)

    local groups_seen = {}
    local conns = {}

    groups_seen[R.c_group] = true

-- gui.debugf("TRY configuration: %s\n", table_to_str(config))

    -- see if the pattern can be used on this room
    -- (e.g. all exits go somewhere and are different groups)

    local hit_conns = 0

    for idx = 1,#config,3 do
      local x   = config[idx+0]
      local y   = config[idx+1]
      local dir = config[idx+2]

      x, y = morph_coord(MORPH, R, x, y, long, deep)
      dir  = morph_dir(MORPH, dir)

      local nx, ny = nudge_coord(x, y, dir)

      if not Seed_valid(nx, ny, 1) then return false end

      local S = SEEDS[ x][ y][1]
      local N = SEEDS[nx][ny][1]

      if S.room ~= R then return false end

      -- handle hits on existing connections
      local existing = false

      if S.conn then
        if S.conn_dir == dir then
          existing = true
        else
          return false -- only one connection per seed!
        end
      end

      if existing then
        hit_conns = hit_conns + 1
      else
        if not N.room or
           not N.room.c_group or
           N.room.kind == "scenic" or
           N.room.branch_kind or
           groups_seen[N.room.c_group] or
           N.conn -- only one connection per seed!
        then
          return false
        end

        -- OK --

        groups_seen[N.room.c_group] = true

        table.insert(conns, { S=S, N=N, dir=dir })
      end
    end

    if hit_conns ~= #R.conns then
      return false
    end

    -- OK, all points were possible, do it for real

gui.debugf("USING CONFIGURATION: %s\n", K)
gui.debugf("hit_conns = %d\n", hit_conns)

    R.branch_kind = K

    if BIG_BRANCH_KINDS[K].symmetry then
      R.symmetry = morph_symmetry(MORPH, BIG_BRANCH_KINDS[K].symmetry)
    end

    dump_new_conns(conns)

    for _,C in ipairs(conns) do
      connect_seeds(C.S, C.N, C.dir)
    end

    return true
  end

  local function try_branch_big_room(R, K)

    gui.debugf("TRYING CONFIGURATION: %s\n", K)

    -- There are THREE morph steps, done in this order:
    -- 1. either rotate the pattern clockwise or not
    -- 2. either flip the pattern horizontally or not
    -- 3. either flip the pattern vertically or not

    local info = assert(BIG_BRANCH_KINDS[K])

    local rotates = { 0, 4 }
    local morphs  = { 0, 1, 2, 3 }

    rand_shuffle(rotates)

    for _,ROT in ipairs(rotates) do
      local long, deep = morph_size(ROT, R)
      local configs = info.func(long, deep)

      if configs then
        rand_shuffle(configs)
        for _,CONF in ipairs(configs) do
          rand_shuffle(morphs)

          for _,SUB in ipairs(morphs) do
            local MORPH = ROT + SUB  -- the full morph

            if try_configuration(MORPH, R, K, CONF, long, deep) then
              gui.debugf("Config %s (MORPH:%d) successful @ %s\n",
                         K, MORPH, R:tostr())
              return true -- SUCCESS
            end
          end -- SUB
        end -- CONF
      end
    end -- ROT

gui.debugf("Failed\n")
    return false
  end

  local function branch_big_rooms()
    local rooms = {}

    for _,R in ipairs(PLAN.all_rooms) do
      if R.svolume >= 1 and (R.kind == "building") and not R.parent then
        R.k_score = sel((R.sw%2)==1 and (R.sh%2)==1, 5, 0) + R.svolume + gui.random()
        table.insert(rooms, R)
      end
    end

    if #rooms == 0 then return end

    table.sort(rooms, function(A, B) return A.k_score > B.k_score end)

    local big_bra_chance = rand_key_by_probs { [99] = 80, [50]=15, [10]=5 }
    gui.printf("Big Branch Mode: %d%%\n", big_bra_chance)

    for _,R in ipairs(rooms) do
      if (#R.conns <= 2) and rand_odds(big_bra_chance) then
        gui.debugf("Branching BIG %s k_score: %1.3f\n", R:tostr(), R.k_score)

        local kinds = {}
        for N,info in pairs(BIG_BRANCH_KINDS) do
          kinds[N] = assert(info.prob)
        end

        while not table_empty(kinds) do
          local K = assert(rand_key_by_probs(kinds))

          kinds[K] = nil  -- don't try this branch kind again

          if try_branch_big_room(R, K) then
            break; -- SUCCESS
          end
        end -- while kinds
      end
    end -- for R in rooms
  end

  local function make_scenic(R)
    -- Note: connections must be handled elsewhere

    gui.debugf("Making %s SCENIC\n", R:tostr())
    assert(R.kind ~= "scenic")

    R.scenic_kind = R.kind
    R.kind = "scenic"

    -- move the room to the scenic list

    for index,N in ipairs(PLAN.all_rooms) do
      if N == R then
        table.remove(PLAN.all_rooms, index)
        R.c_group = -1
        break;
      end
    end

    assert(R.c_group == -1)
    
    table.insert(PLAN.scenic_rooms, R)
  end

  local function make_conn_scenic(C)
    local found

    for index,N in ipairs(PLAN.all_conns) do
      if N == C then
        table.remove(PLAN.all_conns, index)
        found = true
        break;
      end
    end

    assert(found)

    table.insert(PLAN.scenic_conns, C)

    ---## C.src_S.conn  = nil; C.src_S.conn_dir  = nil
    ---## C.dest_S.conn = nil; C.dest_S.conn_dir = nil
  end

  local function try_emergency_connect(R, x, y, dir)
    local nx, ny = nudge_coord(x, y, dir)

    if not Seed_valid(nx, ny, 1) then return false end

    local S = SEEDS[ x][ y][1]
    local N = SEEDS[nx][ny][1]

    assert(S.room == R)
    assert(N.room ~= R)

    if not N.room or
       not N.room.c_group or
       N.room.kind == "scenic" or
       N.room.c_group == R.c_group
    then
      return false
    end

    -- only one connection per seed!
    if S.conn or N.conn  then return false end

    connect_seeds(S, N, dir)

    R.branch_kind = "EM"
--  R.old_sym  = R.symmetry
    R.symmetry = nil

    N.room.branch_kind = "EM"
    N.room.symmetry = nil

    return true
  end

  local function force_room_branch(R)
    gui.debugf("Emergency connection in %s\n", R:tostr())

    local try_list = {}

    for x = R.sx1,R.sx2 do
      if SEEDS[x][R.sy1][1].room == R then
        table.insert(try_list, { x=x, y=R.sy1, dir=2 })
      end
      if SEEDS[x][R.sy2][1].room == R then
        table.insert(try_list, { x=x, y=R.sy2, dir=8 })
      end
    end
    for y = R.sy1,R.sy2 do
      if SEEDS[R.sx1][y][1].room == R then
        table.insert(try_list, { x=R.sx1, y=y, dir=4 })
      end
      if SEEDS[R.sx2][y][1].room == R then
        table.insert(try_list, { x=R.sx2, y=y, dir=6 })
      end
    end

    -- FIXME: find all possible, use best one
    rand_shuffle(try_list)

    for _,L in ipairs(try_list) do
      if try_emergency_connect(R, L.x, L.y, L.dir) then
        return true -- OK
      end
    end

    -- this is not necesarily bad, it could be a group of rooms
    -- where only one of them can make a connection.
    gui.debugf("FAILED!\n")
    return false
  end

  local function handle_isolate(R, join_chance)
    if rand_odds(join_chance) or R.parent then
      if force_room_branch(R) then
        return -- OK
      end
    end

    make_scenic(R)
  end

  local function handle_rebel_group(list, rebel_id, min_g)

    -- if this group is bigger than the main group, swap them
    if group_size(rebel_id) > group_size(min_g) then
      gui.debugf("Crowning rebel group %d (x%d) -> %d (x%d)\n",
          rebel_id, group_size(rebel_id), min_g, group_size(min_g))

      swap_groups(rebel_id, min_g)
    end

    local join_chance = 99
    if PLAN.scenic_mode == "heaps" then join_chance = 51 end

    local rebels = table_subset_w_field(list, "c_group", rebel_id)
    assert(#rebels > 0)
    gui.debugf("#rebels : %d\n", #rebels)

    if rand_odds(join_chance) then
      -- try the least important rooms first
      for _,R in ipairs(rebels) do
        R.rebel_cost = sel(R.symmetry, 500, 0) + R.svolume + gui.random()
      end

      table.sort(rebels, function(A,B) return A.rebel_cost < B.rebel_cost end)

      for _,R in ipairs(rebels) do
        if force_room_branch(R) then
          gui.debugf("Branched rebel group %d (now %d)\n", rebel_id, R.c_group)
          return -- OK
        end
      end
    end

    -- make all of them scenic, need to kill the connections
    gui.debugf("Killing rebel group %d (%d rooms)\n", rebel_id, #rebels)

    -- use a copy since we modify the original list
    local c_copy = shallow_copy(PLAN.all_conns)

    for _,C in ipairs(c_copy) do
      if C.src.c_group == rebel_id then
        assert(C.dest.c_group == rebel_id)
        make_conn_scenic(C)
      end
    end

    for _,R in ipairs(rebels) do
      make_scenic(R)
    end
  end

  local function branch_the_rest()
    local min_g = min_group_id()

    -- use a copy since PLAN.all_rooms may be modified
    local list = shallow_copy(PLAN.all_rooms)

    local join_chance = 50
    if PLAN.scenic_mode == "few"   then join_chance = 95 end
    if PLAN.scenic_mode == "heaps" then join_chance =  5 end
    if PLAN.join_all then join_chance = 100 end

    gui.debugf("Join Chance: %d\n", join_chance)

    repeat
      local changed = false

      for _,R in ipairs(list) do
        if R.c_group ~= min_g and R.kind ~= "scenic" then
          if #R.conns == 0 then
            handle_isolate(R, join_chance)
          else
            handle_rebel_group(list, R.c_group, min_g)
          end

          -- minimum group_id may have changed
          min_g = min_group_id()
          changed = true
        end
      end -- for R
    until not changed
  end

  local function has_scenic_neigbour(R)
    for _,N in ipairs(R.neighbors) do
      if N.kind == "scenic" then return true end
    end
    return false
  end
    
  local function sprinkle_scenics()
    -- select some rooms as scenic rooms
    if PLAN.scenic_mode == "few" then return end

    local side_prob = sel(PLAN.scenic_mode == "heaps", 60, 10)
    local mid_prob  = sel(PLAN.scenic_mode == "heaps", 20, 3)

    local list = shallow_copy(PLAN.all_rooms)
    rand_shuffle(list)

    for _,R in ipairs(list) do
      local is_side
      if R.sx1 <= 2 or R.sy1 <= 2 or R.sx2 >= SEED_W-1 or R.sy2 >= SEED_H-1 then
        is_side = true
      end

      if rand_odds(sel(is_side, side_prob, mid_prob)) and
         not has_scenic_neigbour(R)
      then
        make_scenic(R)
      end
    end -- for R
  end


  --==| Connect_Rooms |==--

  gui.printf("\n--==| Connect_Rooms |==--\n\n")

  for c_group,R in ipairs(PLAN.all_rooms) do
    R.c_group = c_group
  end


  PLAN.scenic_mode = rand_key_by_probs { few=30, some=50, heaps=10 }
  gui.printf("Scenic Mode: %s\n", PLAN.scenic_mode)

  sprinkle_scenics()


  branch_big_rooms()
  branch_the_rest()

---#  for _,R in ipairs(PLAN.all_rooms) do assert(R.kind ~= "scenic") end
---#  for _,C in ipairs(PLAN.all_conns) do
---#    assert(C.src.kind ~= "scenic")
---#    assert(C.dest.kind ~= "scenic")
---#  end
end

