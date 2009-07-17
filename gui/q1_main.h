//------------------------------------------------------------------------
//  LEVEL building - Quake 1 format
//------------------------------------------------------------------------
//
//  Oblige Level Maker
//
//  Copyright (C) 2006-2009 Andrew Apted
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//------------------------------------------------------------------------

#ifndef __OBLIGE_QUAKE1_H__
#define __OBLIGE_QUAKE1_H__


game_interface_c * Quake1_GameObject(void);


//------------------------------------------------------------------------
// INTERNAL API
//------------------------------------------------------------------------

class qLump_c;
class area_face_c;

class q1MapModel_c
{
public:
  float x1, y1, z1;
  float x2, y2, z2;

  area_face_c *x_face;
  area_face_c *y_face;
  area_face_c *z_face;

  s32_t nodes[4];

public:
   q1MapModel_c();
  ~q1MapModel_c();
};

extern std::vector<q1MapModel_c *> q1_all_mapmodels;


u16_t Q1_AddTexInfo(const char *texture, int flags, double *s4, double *t4);

// q1_bsp.cc

void Q1_BuildBSP(void);

void Q1_CreateModel(void);

// q1_clip.cc

s32_t Q1_CreateClipHull(int which, qLump_c *q1_clip);


#endif /* __OBLIGE_QUAKE1_H__ */

//--- editor settings ---
// vi:ts=2:sw=2:expandtab
