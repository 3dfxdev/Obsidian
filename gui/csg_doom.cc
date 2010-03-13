//------------------------------------------------------------------------
//  CSG 2.5D : DOOM and DUKE NUKEM output
//------------------------------------------------------------------------
//
//  Oblige Level Maker
//
//  Copyright (C) 2006-2010 Andrew Apted
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

#include "headers.h"
#include "hdr_fltk.h"
#include "hdr_ui.h"  // ui_build.h

#include <algorithm>

#include "lib_file.h"
#include "lib_util.h"
#include "main.h"

#include "ui_chooser.h"

#include "csg_main.h"
#include "dm_extra.h"
#include "dm_glbsp.h"
#include "dm_wad.h"
#include "nk_level.h"
#include "nk_structs.h"  // flags


class nk_wall_c;


// Properties
char *dm_error_tex;

int solid_exfloor;    // disabled if <= 0
int liquid_exfloor;

extern bool wad_hexen;  // FIXME


#define VOID_INDEX  -2

static int extrafloor_tag;
static int extrafloor_slot;



class sector_info_c;
class linedef_info_c;


class extrafloor_c
{
public:
  // dummy sector
  sector_info_c * dummy_sec;

  std::string w_tex;

  std::vector<sector_info_c *> users;

public:
  extrafloor_c() : dummy_sec(NULL), w_tex(), users()
  { }

  ~extrafloor_c()
  { } 

  bool Match(const extrafloor_c *other) const;
};


class sector_info_c 
{
public:
  int f_h;
  int c_h;

  std::string f_tex;
  std::string c_tex;
  
  int light;
  int special;
  int tag;
  int mark;

  std::vector<extrafloor_c *> exfloors;

  int index;
  
public:
  sector_info_c() : f_h(0), c_h(0), f_tex(), c_tex(),
                    light(255), special(0), tag(0), mark(0),
                    exfloors(), index(-1)
  { }

  ~sector_info_c()
  { }

  bool SameExtraFloors(const sector_info_c *other) const
  {
    if (exfloors.size() != other->exfloors.size())
      return false;

    for (unsigned int i = 0; i < exfloors.size(); i++)
    {
      extrafloor_c *E1 = exfloors[i];
      extrafloor_c *E2 = other->exfloors[i];

      if (E1 == E2)
        continue;

      if (! E1->Match(E2))
        return false;
    }

    return true;
  }

  bool Match(const sector_info_c *other) const
  {
    return (f_h == other->f_h) &&
           (c_h == other->c_h) &&
           (light == other->light) &&
           (special == other->special) &&
           (tag  == other->tag)  &&
           (mark == other->mark) &&
           (strcmp(f_tex.c_str(), other->f_tex.c_str()) == 0) &&
           (strcmp(c_tex.c_str(), other->c_tex.c_str()) == 0) &&
           SameExtraFloors(other);
  }

  int Write()
  {
    if (index < 0)
    {
      for (unsigned int k = 0; k < exfloors.size(); k++)
      {
//!!!! FIXME        WriteExtraFloor(this, exfloors[k]);
      }

      index = DM_NumSectors();

      DM_AddSector(f_h, f_tex.c_str(),
                   c_h, c_tex.c_str(),
                   light, special, tag);
    }

    return index;
  }
};


bool extrafloor_c::Match(const extrafloor_c *other) const
{
  if (strcmp(w_tex.c_str(), other->w_tex.c_str()) != 0)
    return false;

  SYS_ASSERT(dummy_sec && other->dummy_sec);

  return dummy_sec->Match(other->dummy_sec);
}


class vertex_info_c 
{
public:
  int x, y;

  int index;

  // keep track of a few (but not all) linedefs touching this vertex.
  // this is used to detect colinear lines which can be merged.
  // (later it may be used for horizontal texture alignment)
  linedef_info_c *lines[4];
 
public:
  vertex_info_c() : x(0), y(0), index(-1)
  {
    lines[0] = lines[1] = lines[2] = lines[3] = NULL;
  }

  ~vertex_info_c()
  { }

  void AddLine(linedef_info_c *L)
  {
    for (int i=0; i < 4; i++)
      if (! lines[i])
      {
        lines[i] = L; return;
      }
  }

  void ReplaceLine(linedef_info_c *old_L, linedef_info_c *new_L)
  {
    for (int i=0; i < 4; i++)
      if (lines[i] == old_L)
      {
        lines[i] = new_L;
        return;
      }
  }

  bool HasLine(const linedef_info_c *L) const
  {
    for (int i=0; i < 4; i++)
      if (lines[i] == L)
        return true;

    return false;
  }

  linedef_info_c *SecondLine(const linedef_info_c *L) const
  {
    if (lines[2])  // three or more lines?
      return NULL;

    if (! lines[1])  // only one line?
      return NULL;

    if (lines[0] == L)
      return lines[1];

    SYS_ASSERT(lines[1] == L);
    return lines[0];
  }

  int Write()
  {
    if (index < 0)
    {
      index = DM_NumVertexes();

      DM_AddVertex(x, y);
    }

    return index;
  }
};


class sidedef_info_c 
{
public:
  std::string lower;
  std::string mid;
  std::string upper;

  int x_offset;
  int y_offset;

  sector_info_c * sector;

  int index;
 
public:
  sidedef_info_c() : lower("-"), mid("-"), upper("-"),
                     x_offset(0), y_offset(0),
                     sector(NULL), index(-1)
  { }

  ~sidedef_info_c()
  { }

  int Write();

  inline bool SameTex(const sidedef_info_c *T) const
  {
    return (strcmp(mid  .c_str(), T->mid  .c_str()) == 0) &&
           (strcmp(lower.c_str(), T->lower.c_str()) == 0) &&
           (strcmp(upper.c_str(), T->upper.c_str()) == 0);
  }
};


class linedef_info_c 
{
public:
  vertex_info_c *start;  // NULL means "unused linedef"
  vertex_info_c *end;

  sidedef_info_c *front;
  sidedef_info_c *back;

  int flags;
  int type;   // 'special' in Hexen format
  int tag;

  u8_t args[5];

  double length;

  // similar linedef touching our start (end) vertex, or NULL if none.
  // only takes front sidedefs into account.
  // used for texture aligning.
  linedef_info_c *sim_prev;
  linedef_info_c *sim_next;

nk_wall_c *nk_front;
nk_wall_c *nk_back;

public:
  linedef_info_c() : start(NULL), end(NULL),
                     front(NULL), back(NULL),
                     flags(0), type(0), tag(0), length(0),
                     sim_prev(NULL), sim_next(NULL),
                     nk_front(NULL), nk_back(NULL)
  {
    args[0] = args[1] = args[2] = args[3] = args[4] = 0;
  }

  ~linedef_info_c()
  { }

  void CalcLength()
  {
    length = ComputeDist(start->x, start->y, end->x, end->y);
  }

  inline vertex_info_c *OtherVertex(const vertex_info_c *V) const
  {
    if (start == V)
      return end;

    SYS_ASSERT(end == V);
    return start;
  }

  inline bool Valid() const
  {
    return (start != NULL);
  }

  void Kill()
  {
    start = end = NULL;
  }

  void Flip()
  {
    std::swap(start, end);
    std::swap(front, back);
  }

  inline bool ShouldFlip() const
  {
    if (! front)
      return true;

    if (! back)
      return false;

    sector_info_c *F = front->sector;
    sector_info_c *B = back->sector;

    if (F->f_h != B->f_h) return (F->f_h > B->f_h);
    if (F->c_h != B->c_h) return (F->c_h < B->c_h);

    return false;
  }

  void Write();

  inline bool CanMergeSides(const sidedef_info_c *A, const sidedef_info_c *B) const
  {
    if (! A || ! B)
      return (!A && !B);

    if (A->sector != B->sector)
      return false;

    // X offsets not done here

    if (A->y_offset != B->y_offset &&
        A->y_offset != IVAL_NONE   &&
        B->y_offset != IVAL_NONE)
      return false;

    return A->SameTex(B);
  }

  bool ColinearWith(const linedef_info_c *B) const
  {
    int adx = end->x - start->x;
    int ady = end->y - start->y;

    int bdx = B->end->x - B->start->x;
    int bdy = B->end->y - B->start->y;

    return (adx * bdy == bdx * ady);
  }

  bool CanMerge(const linedef_info_c *B) const
  {
    if (! ColinearWith(B))
      return false;

    // test sidedefs
    sidedef_info_c *B_front = B->front;
    sidedef_info_c *B_back  = B->back;

///---  if ((V == end) == (V == B->end))
///---    std::swap(B_front, B_back);

    if (! CanMergeSides(back,  B_back) ||
        ! CanMergeSides(front, B_front))
      return false;

    if (  front->x_offset == IVAL_NONE ||
        B_front->x_offset == IVAL_NONE)
      return true;

    int diff = B_front->x_offset - (front->x_offset + I_ROUND(length));

    // the < 4 accounts for precision loss after multiple merges
    return abs(diff) < 4; 
  }

  void Merge(linedef_info_c *B)
  {
    SYS_ASSERT(B->start == end);

    end = B->end;

    B->end->ReplaceLine(B, this);

    // fix X offset on back sidedef
    if (back && back->x_offset != IVAL_NONE)
      back->x_offset += I_ROUND(B->length);

    B->Kill();

    CalcLength();
  }

  bool isFrontSimilar(const linedef_info_c *P) const
  {
    if (! back && ! P->back)
      return (strcmp(front->mid.c_str(), P->front->mid.c_str()) == 0);

    if (back && P->back)
      return front->SameTex(P->front);

    const linedef_info_c *L = this;

    if (back)
      std::swap(L, P);

    // now L is single sided and P is double sided.

///---  if (P->mid[0] != '-')
///---    return false;

    // allow either upper or lower to match
    return (strcmp(L->front->mid.c_str(), P->front->lower.c_str()) == 0) ||
           (strcmp(L->front->mid.c_str(), P->front->upper.c_str()) == 0);
  }

  // here "greedy" means that from one side, both the upper and the lower
  // will be visible at the same time.
  inline bool isGreedy() const
  {
    if (! back)
      return false;

    int f1_h = front->sector->f_h;
    int f2_h = back ->sector->f_h;

    int c1_h = front->sector->c_h;
    int c2_h = back ->sector->c_h;

    return (f1_h < f2_h && c2_h < c1_h) ||
           (f1_h > f2_h && c2_h > c1_h);
  }
};



static std::vector<vertex_info_c *>  dm_vertices;
static std::vector<linedef_info_c *> dm_linedefs;
static std::vector<sidedef_info_c *> dm_sidedefs;

static std::vector<sector_info_c *>  dm_sectors;
static std::vector<extrafloor_c *>   dm_exfloors;


void DM_FreeLevelStuff(void)
{
  int i;

  for (i=0; i < (int)dm_vertices.size(); i++) delete dm_vertices[i];
  for (i=0; i < (int)dm_linedefs.size(); i++) delete dm_linedefs[i];
  for (i=0; i < (int)dm_sidedefs.size(); i++) delete dm_sidedefs[i];
  for (i=0; i < (int)dm_sectors .size(); i++) delete dm_sectors [i];
  for (i=0; i < (int)dm_exfloors.size(); i++) delete dm_exfloors[i];

  dm_vertices.clear();
  dm_linedefs.clear();
  dm_sidedefs.clear();
  dm_sectors. clear();
  dm_exfloors.clear();
}


int sidedef_info_c::Write()  
{
  if (index < 0)
  {
    SYS_ASSERT(sector);

    int sec_index = sector->Write();

    index = DM_NumSidedefs();

    DM_AddSidedef(sec_index, lower.c_str(), mid.c_str(),
                  upper.c_str(), x_offset & 1023, y_offset);
  }

  return index;
}


void linedef_info_c::Write()
{
  SYS_ASSERT(start && end);

  int v1 = start->Write();
  int v2 = end  ->Write();

  int f = front ? front->Write() : -1;
  int b = back  ? back ->Write() : -1;

  DM_AddLinedef(v1, v2, f, b, type, flags, tag, args);
}


void DM_WriteDoom(void);  // forward


void CSG2_Doom_TestBrushes(void)
{
  // for debugging only: each csg_brush_c becomes a single
  // sector on the map.
 
  DM_StartWAD("brush_test.wad");
  DM_BeginLevel();

  for (unsigned int k = 0; k < all_brushes.size(); k++)
  {
    csg_brush_c *P = all_brushes[k];
    
    int sec_idx = DM_NumSectors();

    DM_AddSector(I_ROUND(P->z1), P->b_face->tex.c_str(),
                 I_ROUND(P->z2), P->t_face->tex.c_str(),
                 192, 0, 0);

    int side_idx = DM_NumSidedefs();

    DM_AddSidedef(sec_idx, "-", P->w_face->tex.c_str(), "-", 0, 0);

    int vert_base = DM_NumVertexes();

    for (int j1 = 0; j1 < (int)P->verts.size(); j1++)
    {
      int j2 = (j1 + 1) % (int)P->verts.size();

      area_vert_c *v1 = P->verts[j1];
   // area_vert_c *v2 = P->verts[j2];

      DM_AddVertex(I_ROUND(v1->x), I_ROUND(v1->y));

      DM_AddLinedef(vert_base+j2, vert_base+j1, side_idx, -1,
                    0, 1 /*impassible*/, 0, NULL /* args */);
    }
  }

  DM_EndLevel("MAP01");
  DM_EndWAD();
}

void CSG2_Doom_TestClip(void)
{
  // for Quake1 debugging only....

  DM_StartWAD("clip_test.wad");
  DM_BeginLevel();

  DM_WriteDoom();

  DM_EndLevel("MAP01");
  DM_EndWAD();
}

void DM_TestRegions(void)
{
  // for debugging only: each merge_region becomes a single
  // sector on the map.

  unsigned int i;

  for (i = 0; i < mug_vertices.size(); i++)
  {
    merge_vertex_c *V = mug_vertices[i];
    
    V->index = (int)i;

    DM_AddVertex(I_ROUND(V->x), I_ROUND(V->y));
  }


  for (i = 0; i < mug_regions.size(); i++)
  {
    merge_region_c *R = mug_regions[i];

    R->index = (int)i;

    const char *flat = "FLAT1";
 
    DM_AddSector(0,flat, 144,flat, 255,(int)R->brushes.size(),(int)R->gaps.size());

    const char *tex = R->faces_out ? "COMPBLUE" : "STARTAN3";

    DM_AddSidedef(R->index, tex, "-", tex, 0, 0);
  }


  for (i = 0; i < mug_segments.size(); i++)
  {
    merge_segment_c *S = mug_segments[i];

    SYS_ASSERT(S);
    SYS_ASSERT(S->start);

    DM_AddLinedef(S->start->index, S->end->index,
                  S->front ? S->front->index : -1,
                  S->back  ? S->back->index  : -1,
                  0, 1 /*impassible*/, 0,
                  NULL /* args */);
  }
}


//------------------------------------------------------------------------


static void MakeExtraFloor(merge_region_c *R, sector_info_c *sec,
                           merge_gap_c *T, merge_gap_c *B)
{
  // find the brush which we will use for the side texture
  csg_brush_c *MID = NULL;
  double best_h = 0;

  // FIXME use f_sides/b_sides (FindSideFace)
  for (unsigned int j = 0; j < R->brushes.size(); j++)
  {
    csg_brush_c *A = R->brushes[j];

    if (A->z1 > B->t_brush->z1 - EPSILON &&
        A->z2 < T->b_brush->z2 + EPSILON)
    {
      double h = A->z2 - A->z1;

      // TODO: priorities

//      if (MID && fabs(h - best_h) < EPSILON)
//      { /* same height, prioritise */ }

      if (h > best_h)
      {
        best_h = h;
        MID = A;
      }
    }
  }

  SYS_ASSERT(MID);


  extrafloor_c *EF = new extrafloor_c;

  dm_exfloors.push_back(EF);

  EF->w_tex = MID->w_face->tex;

  EF->users.push_back(sec);


  EF->dummy_sec = new sector_info_c;

  EF->dummy_sec->f_h = I_ROUND(B->t_brush->z1);
  EF->dummy_sec->c_h = I_ROUND(T->b_brush->z2);

  EF->dummy_sec->f_tex = B->t_brush->b_face->tex.c_str();
  EF->dummy_sec->c_tex = T->b_brush->t_face->tex.c_str();

  // FIXME !!!! light, special


  sec->exfloors.push_back(EF);
}


static void MakeSector(merge_region_c *R)
{
  // completely solid (no gaps) ?
  if (R->gaps.size() == 0)
  {
    R->index = 0;
    return;
  }

  csg_brush_c *B = R->gaps.front()->b_brush;
  csg_brush_c *T = R->gaps.back() ->t_brush;


  R->index = (int)dm_sectors.size();

  sector_info_c *S = new sector_info_c;

  dm_sectors.push_back(S);


  S->f_h = I_ROUND(B->z2 + B->delta_z);
  S->c_h = I_ROUND(T->z1 + T->delta_z);

  if (S->c_h < S->f_h)
      S->c_h = S->f_h;

  S->f_tex = B->t_face->tex;
  S->c_tex = T->b_face->tex;

  if (T->bkind == BKIND_Sky)
    S->light = (int)(255 * T->b_face->light);
  else
  {
    // FIXME: TEMP CRUD
    int min_light = 96; //!!!!!!  (S->c_h - S->f_h < 150) ? 128 : 144;

    S->light = (int)(256 * MAX(T->b_face->light, B->t_face->light));
    S->light = MAX(min_light, S->light);
  }

  S->mark = MAX(B->mark, T->mark);

  // floors have priority over ceilings
  if (B->sec_kind > 0)
    S->special = B->sec_kind;
  else if (T->sec_kind > 0)
    S->special = T->sec_kind;
  else
    S->special = 0;

  if (B->sec_tag > 0)
    S->tag = B->sec_tag;
  else if (T->sec_tag > 0)
    S->tag = T->sec_tag;
  else
    S->tag = 0;


  if (T->bkind == BKIND_Sky)  // FIXME temp hack
    S->special |= 0x10000;


  // handle Lighting brushes

  for (unsigned int i = 0; i < R->brushes.size(); i++)
  {
    csg_brush_c *B = R->brushes[i];

    if (B->bkind != BKIND_Light)
      continue;

    if (B->z2 < S->f_h+1 || B->z1 > S->c_h-1)
      continue;

      // TODO: perhaps have a single 'brush.light' field
      int light = (int)(256 * MAX(B->b_face->light, B->t_face->light));

      if (S->light < light)
          S->light = light;
  }

  if (S->light > 255)
      S->light = 255;


  // find brushes floating in-between --> make extrafloors

  // Note: top-to-bottom is the most natural order, because when
  // the engine adds an extrafloor into a sector, the upper part
  // remains the same and the lower part gets the new properties
  // (lighting/special) from the extrafloor.

  for (unsigned int g = R->gaps.size() - 1; g > 0; g--)
  {
    merge_gap_c *T = R->gaps[g];
    merge_gap_c *B = R->gaps[g-1];

    if (solid_exfloor > 0)
    {
      MakeExtraFloor(R, S, T, B);
    }
    else
    {
      LogPrintf("WARNING: discarding extrafloor brush (top:%s side:%s)\n",
                T->b_brush->t_face->tex.c_str(),
                T->b_brush->w_face->tex.c_str());
    }
  }
}

static void CoalesceSectors(void)
{
  for (int loop=0; loop < 99; loop++)
  {
    int changes = 0;

    for (unsigned int i = 0; i < mug_segments.size(); i++)
    {
      merge_segment_c *S = mug_segments[i];

      if (! S->front || ! S->back)
        continue;

      if (S->front->index <= 0 || S->back->index <= 0)
        continue;
      
      // already merged?
      if (S->front->index == S->back->index)
        continue;

      sector_info_c *F = dm_sectors[S->front->index];
      sector_info_c *B = dm_sectors[S->back ->index];

      if (F->Match(B))
      {
        S->front->index = MIN(S->front->index, S->back->index);
        S->back ->index = S->front->index;

        changes++;
      }
    }

// fprintf(stderr, "CoalesceSectors: changes = %d\n", changes);

    if (changes == 0)
      return;
  }
}

static void CoalesceExtraFloors(void)
{
  for (int loop=0; loop < 99; loop++)
  {
    int changes = 0;

    for (unsigned int i = 0; i < mug_segments.size(); i++)
    {
      merge_segment_c *S = mug_segments[i];

      if (! S->front || ! S->back)
        continue;

      if (S->front->index <= 0 || S->back->index <= 0)
        continue;

      sector_info_c *F = dm_sectors[S->front->index];
      sector_info_c *B = dm_sectors[S->back ->index];
      
      for (unsigned int j = 0; j < F->exfloors.size(); j++)
      for (unsigned int k = 0; k < B->exfloors.size(); k++)
      {
        extrafloor_c *E1 = F->exfloors[j];
        extrafloor_c *E2 = B->exfloors[k];

        // already merged?
        if (E1 == E2)
          continue;

        if (! E1->Match(E2))
          continue;

        // don't merge with special stuff
        if (F->tag < 9000 || B->tag < 9000)
          continue;
        
        // limit how many sectors we can share
        if (E1->users.size() + E2->users.size() > 8)
          continue;

        // choose one of them. Using the minimum pointer is a
        // bit arbitrary, but is repeatable and transitive.
        extrafloor_c * EF    = MIN(E1, E2);
        extrafloor_c * other = MAX(E1, E2);

        F->exfloors[j] = EF;
        B->exfloors[k] = EF;

        // transfer the users
        while (other->users.size() > 0)
        {
          EF->users.push_back(other->users.back());
          other->users.pop_back();
        }

        changes++;
      }
    }

// fprintf(stderr, "CoalesceExtraFloors: changes = %d\n", changes);

    if (changes == 0)
      break;
  }
}

static void AssignExtraFloorTags(void)
{
  for (unsigned int j = 0; j < mug_regions.size(); j++)
  {
    merge_region_c *R = mug_regions[j];

    if (R->index <= 0)
      continue;

    sector_info_c *S = dm_sectors[R->index];

    if (S->exfloors.size() > 0 && S->tag <= 0)
    {
      S->tag = extrafloor_tag++;
    }
  }
}

static void CreateSectors(void)
{
  extrafloor_tag  = 9000;
  extrafloor_slot = 0;

  dm_sectors.clear();

  // #0 represents VOID (never written to map lump)
  dm_sectors.push_back(new sector_info_c);

  for (unsigned int i = 0; i < mug_regions.size(); i++)
  {
    merge_region_c *R = mug_regions[i];

    MakeSector(R);
  }

  CoalesceSectors();

  AssignExtraFloorTags();

  CoalesceExtraFloors();
}


//------------------------------------------------------------------------

static vertex_info_c * MakeVertex(merge_vertex_c *MV)
{
  if (MV->index >= 0)
    return dm_vertices[MV->index];

  // create new one
  vertex_info_c * V = new vertex_info_c;

  MV->index = (int)dm_vertices.size();

  dm_vertices.push_back(V);

  V->x = I_ROUND(MV->x); 
  V->y = I_ROUND(MV->y);

  return V;
}


static void WriteExtraFloor(sector_info_c *sec, extrafloor_c *EF)
{
#if 0  ///  FIXME  FIXME

  if (EF->sec->index >= 0)
    return;

  EF->sec->index = DM_NumSectors();

  DM_AddSector(EF->sec->f_h, EF->sec->f_tex.c_str(),
               EF->sec->c_h, EF->sec->c_tex.c_str(),
               EF->sec->light, EF->sec->special, EF->sec->tag);


  extrafloor_slot++;


  int x1 = bounds_x1 +       (extrafloor_slot % 32) * 64;
  int y1 = bounds_y1 - 128 - (extrafloor_slot / 32) * 64;

  if (extrafloor_slot & 1024) x1 += 2200;
  if (extrafloor_slot & 2048) y1 -= 2200;

  if (extrafloor_slot & 4096)
    Main_FatalError("Too many extrafloors! (over %d)\n", extrafloor_slot);

  int x2 = x1 + 32;
  int y2 = y1 + 32;

  int xm = x1 + 16;
  int ym = y1 + 16;

  bool morev = (EF->users.size() > 4);

  int vert_ref = DM_NumVertexes();

  if (true)  DM_AddVertex(x1, y1);
  if (morev) DM_AddVertex(x1, ym);

  if (true)  DM_AddVertex(x1, y2);
  if (morev) DM_AddVertex(xm, y2);

  if (true)  DM_AddVertex(x2, y2);
  if (morev) DM_AddVertex(x2, ym);

  if (true)  DM_AddVertex(x2, y1);
  if (morev) DM_AddVertex(xm, y1);

 
  int side_ref = DM_NumSidedefs();

  DM_AddSidedef(EF->sec->index, "-", EF->w_tex.c_str(), "-", 0, 0);


  int vert_num = morev ? 8 : 4;

  for (int n = 0; n < vert_num; n++)
  {
    int type = 0;
    int tag  = 0;

    if (n < (int)EF->users.size())
    {
      type = solid_exfloor;
      tag  = EF->users[n]->tag;

      SYS_ASSERT(tag > 0);
    }

    DM_AddLinedef(vert_ref + (n), vert_ref + ((n+1) % vert_num),
                  side_ref, -1 /* side2 */,
                  type, 1 /* impassible */,
                  tag, NULL /* args */);
  }
#endif
}



static int NaturalXOffset(linedef_info_c *G, int side)
{
  double along;
  
  if (side == 0)
    along = AlongDist(0, 0,  G->start->x, G->start->y, G->end->x, G->end->y);
  else
    along = AlongDist(0, 0,  G->end->x, G->end->y, G->start->x, G->start->y);

  return I_ROUND(- along);
}

static int CalcXOffset(merge_segment_c *G, int side, area_vert_c *V, double x_offset) 
{
  double along = 0;
  
  if (V)
  {
    if (side == 0)
      along = ComputeDist(V->x, V->y, G->start->x, G->start->y);
    else
      along = ComputeDist(V->x, V->y, G->end->x, G->end->y);
  }

  return (int)(along + x_offset);
}

static int CalcRailYOffset(area_vert_c *rail, int base_h)
{
  int y_offset = I_ROUND(rail->parent->z1) - base_h;

  return y_offset;   ///--- MAX(0, y_offset);
}


static sidedef_info_c * MakeSidedef(merge_segment_c *G, int side,
                       merge_region_c *F, merge_region_c *B,
                       area_vert_c *rail,
                       bool *l_peg, bool *u_peg)
{
  if (! (F && F->index > 0))
    return NULL;

///  int index = (int)dm_sidedefs.size();

  sidedef_info_c *SD = new sidedef_info_c;

  dm_sidedefs.push_back(SD);

  sector_info_c *S = dm_sectors[F->index];

  SD->sector = S;

  // the 'natural' X/Y offsets
  SD->x_offset = IVAL_NONE;  //--- NaturalXOffset(G, side);
  SD->y_offset = - S->c_h;

  if (B && B->index > 0)
  {
    sector_info_c *BS = dm_sectors[B->index];

#if 0  // OLD WAY
    double fz = (S->f_h + BS->f_h) / 2.0;
    double cz = (S->c_h + BS->c_h) / 2.0;

    area_vert_c *l_vert = CSG2_FindSideVertex(G, fz, side == 1, true);
    area_vert_c *u_vert = CSG2_FindSideVertex(G, cz, side == 1, true);

    area_face_c *lower_W = CSG2_FindSideFace(G, fz, side == 1, l_vert);
    area_face_c *upper_W = CSG2_FindSideFace(G, cz, side == 1, u_vert);
#else
    csg_brush_c *l_brush = B->gaps.front()->b_brush;
    csg_brush_c *u_brush = B->gaps.back() ->t_brush;

    SYS_ASSERT(l_brush && u_brush);

    area_vert_c *l_vert = G->FindSide(l_brush);
    area_vert_c *u_vert = G->FindSide(u_brush);

    area_face_c *lower_W = (l_vert && l_vert->w_face) ? l_vert->w_face : l_brush->w_face;
    area_face_c *upper_W = (u_vert && u_vert->w_face) ? u_vert->w_face : u_brush->w_face;

    SYS_ASSERT(lower_W && upper_W);
#endif

    area_face_c *rail_W = rail ? rail->w_face : NULL;

    if (lower_W && lower_W->peg) *l_peg = true;
    if (upper_W && upper_W->peg) *u_peg = true;

    SD->lower = lower_W ? lower_W->tex.c_str() : dm_error_tex ? dm_error_tex : "-";
    SD->upper = upper_W ? upper_W->tex.c_str() : dm_error_tex ? dm_error_tex : "-";

    if (rail_W)
    {
      SD->mid = rail_W->tex.c_str();

      *l_peg = false;
    }

    if (rail_W && rail_W->x_offset != FVAL_NONE)
      SD->x_offset = CalcXOffset(G, side, rail, rail_W->x_offset);
    else if (lower_W && lower_W->x_offset != FVAL_NONE)
      SD->x_offset = CalcXOffset(G, side, l_vert, lower_W->x_offset);
    else if (upper_W && upper_W->x_offset != FVAL_NONE)
      SD->x_offset = CalcXOffset(G, side, u_vert, upper_W->x_offset);

    if (rail_W)
      SD->y_offset = CalcRailYOffset(rail, MAX(S->f_h, BS->f_h));
    else if (lower_W && lower_W->y_offset != FVAL_NONE)
      SD->y_offset = (int)lower_W->y_offset;
    else if (upper_W && upper_W->y_offset != FVAL_NONE)
      SD->y_offset = (int)upper_W->y_offset;
  }
  else  // one-sided line
  {
    double mz = (S->f_h + S->c_h) / 2.0;

    area_vert_c *m_vert = CSG2_FindSideVertex(G, mz, side == 1, true);
    area_face_c *mid_W  = CSG2_FindSideFace(  G, mz, side == 1, m_vert);

    if (mid_W && mid_W->peg)
      *l_peg = true;

    SD->mid = mid_W ? mid_W->tex.c_str() : dm_error_tex ? dm_error_tex : "-";

    if (mid_W && mid_W->x_offset != FVAL_NONE)
      SD->x_offset = CalcXOffset(G, side, m_vert, mid_W->x_offset);

    if (mid_W && mid_W->y_offset != FVAL_NONE)
      SD->y_offset = (int)mid_W->y_offset;
  }

  return SD;
}


static area_vert_c *FindSpecialVert(merge_segment_c *G)
{
  sector_info_c *FS = NULL;
  sector_info_c *BS = NULL;

  if (G->front && G->front->index > 0)
    FS = dm_sectors[G->front->index];

  if (G->back && G->back->index > 0)
    BS = dm_sectors[G->back->index];

  if (!BS && !FS)
    return NULL;

  int min_f = +9999;
  int max_c = -9999;

  if (FS)
  {
    min_f = MIN(min_f, FS->f_h);
    max_c = MAX(max_c, FS->c_h);
  }

  if (BS)
  {
    min_f = MIN(min_f, BS->f_h);
    max_c = MAX(max_c, BS->c_h);
  }

  min_f -= 2;
  max_c += 2;


  area_vert_c *minor = NULL;


  for (int side = 0; side < 2; side++)
  {
    unsigned int count = (side == 0) ? G->f_sides.size() : G->b_sides.size();

    for (unsigned int k=0; k < count; k++)
    {
      area_vert_c *V = (side == 0) ? G->f_sides[k] : G->b_sides[k];

      if (V->parent->bkind == BKIND_Rail)
        continue;

      if (V->parent->z1 < (double)max_c &&
          V->parent->z2 > (double)min_f)
      {
/*
DebugPrintf("SEGMENT (%1.0f,%1.0f) --> (%1.0f,%1.0f) SIDE:%d LINE_KIND:%d\n",
            G->start->x, G->start->y, G->end  ->x, G->end  ->y,
            side, V->line_kind);
DebugPrintf("   BRUSH RANGE: %1.0f --> %1.0f  tex:%s\n",
            V->parent->z1, V->parent->z2, V->parent->w_face->tex.c_str());
DebugPrintf("   FS: %p  f_h:%d c_h:%d f_tex:%s\n",
            FS, FS ? FS->f_h : -1, FS ? FS->c_h : -1, FS ? FS->f_tex.c_str() : "");
DebugPrintf("   BS: %p  f_h:%d c_h:%d f_tex:%s\n",
            BS, BS ? BS->f_h : -1, BS ? BS->c_h : -1, BS ? BS->f_tex.c_str() : "");
*/
        if (V->line_kind != 0)
          return V;

        if (V->line_flags || V->line_tag != 0)
          minor = V;
      }
    }
  }

  return minor;
}

static area_vert_c *FindRailVert(merge_segment_c *G)
{
  sector_info_c *FS = NULL;  // FIXME: duplicate code
  sector_info_c *BS = NULL;

  if (G->front && G->front->index > 0)
    FS = dm_sectors[G->front->index];

  if (G->back && G->back->index > 0)
    BS = dm_sectors[G->back->index];

  if (!BS && !FS)
    return NULL;

  int min_f = +9999;
  int max_c = -9999;

  if (FS)
  {
    min_f = MIN(min_f, FS->f_h);
    max_c = MAX(max_c, FS->c_h);
  }

  if (BS)
  {
    min_f = MIN(min_f, BS->f_h);
    max_c = MAX(max_c, BS->c_h);
  }

  min_f -= 2;
  max_c += 2;


  for (int side = 0; side < 2; side++)
  {
    unsigned int count = (side == 0) ? G->f_sides.size() : G->b_sides.size();

    for (unsigned int k=0; k < count; k++)
    {
      area_vert_c *V = (side == 0) ? G->f_sides[k] : G->b_sides[k];

      if (V->parent->bkind != BKIND_Rail)
        continue;

      if (! V->w_face)
        continue;

      if (V->parent->z1 < (double)max_c &&
          V->parent->z2 > (double)min_f)
      {
        return V;
      }
    }
  }

  return NULL;
}




static void MakeLinedefs(void)
{
  for (unsigned int i = 0; i < mug_segments.size(); i++)
  {
    merge_segment_c *G = mug_segments[i];

    SYS_ASSERT(G);
    SYS_ASSERT(G->start);

    if (! (G->front && G->front->index > 0) &&
        ! (G->back  && G-> back->index > 0))
      continue;

    // skip segments which would become zero length linedefs
    if (I_ROUND(G->start->x) == I_ROUND(G->end->x) &&
        I_ROUND(G->start->y) == I_ROUND(G->end->y))
      continue;

    area_vert_c *spec = FindSpecialVert(G);

    area_vert_c *rail = FindRailVert(G);

    // if same sector on both sides, skip the line, unless
    // we have a rail texture or a special line.
    if (! rail && ! spec && G->front && G->back && G->front->index == G->back->index)
    {
      continue;
    }


    linedef_info_c *L = new linedef_info_c;

    dm_linedefs.push_back(L);

    L->start = MakeVertex(G->start);
    L->end   = MakeVertex(G->end);

    L->start->AddLine(L);
    L->end  ->AddLine(L);

    L->CalcLength();


    bool l_peg = false;
    bool u_peg = false;

    L->front = MakeSidedef(G, 0, G->front, G->back, rail, &l_peg, &u_peg);
    L->back  = MakeSidedef(G, 1, G->back, G->front, rail, &l_peg, &u_peg);

    SYS_ASSERT(L->front || L->back);

    // TODO: a way to ensure a certain orientation (two-sided lines only)
    if (L->ShouldFlip())
      L->Flip();


    if (! L->back)
      L->flags |= MLF_BlockAll;
    else
      L->flags |= MLF_TwoSided | MLF_LowerUnpeg | MLF_UpperUnpeg;

    if (l_peg) L->flags ^= MLF_LowerUnpeg;
    if (u_peg) L->flags ^= MLF_UpperUnpeg;

    if (rail)
    {
      L->flags |= rail->line_flags;

      if (rail->line_kind)
      {
        L->type = rail->line_kind;
        L->tag  = rail->line_tag;

        // FIXME: rail->line_args
      }
    }

    if (spec)
    {
      L->flags |= spec->line_flags;

      L->type = spec->line_kind;
      L->tag  = spec->line_tag;

      // FIXME !!!!  spec->line_args
    }
  }
}


static void WriteLinedefs(void)
{
  // this triggers everything else (Sidedefs, Sectors, Vertices) to be
  // written as well.

  for (int i = 0; i < (int)dm_linedefs.size(); i++)
    if (dm_linedefs[i]->Valid())
      dm_linedefs[i]->Write();
}


static void CheckThingOption(const char *name, const char *value,
                             int *options)
{
  bool enable = ! (value[0] == '0' || tolower(value[0]) == 'f');

  // skill flags default to 1, hence only need to clear them
  if (StringCaseCmp(name, "skill_easy") == 0 && !enable)
    *options &= ~MTF_Easy;
  if (StringCaseCmp(name, "skill_medium") == 0 && !enable)
    *options &= ~MTF_Medium;
  if (StringCaseCmp(name, "skill_hard") == 0 && !enable)
    *options &= ~MTF_Hard;

  // mode flags are negated (1 means "no")
  if (StringCaseCmp(name, "mode_sp") == 0 && !enable)
    *options |= ~MTF_NotSP;
  if (StringCaseCmp(name, "mode_coop") == 0 && !enable)
    *options |= ~MTF_NotCOOP;
  if (StringCaseCmp(name, "mode_dm") == 0 && !enable)
    *options |= ~MTF_NotDM;

  // other flags...
  if (StringCaseCmp(name, "ambush") == 0 && enable)
    *options |= MTF_Ambush;
  
  // TODO: HEXEN FLAGS
}

static void WriteThings(void)
{
  // ??? first iterate over entity lists in merge_gaps

  for (unsigned int j = 0; j < all_entities.size(); j++)
  {
    entity_info_c *E = all_entities[j];

    int type = atoi(E->name.c_str());

    if (type <= 0)
    {
      LogPrintf("WARNING: bad doom entity number: '%s'\n",  E->name.c_str());
      continue;
    }

    double h = 0; // FIXME!!! proper height (above ground)


    // parse entity properties
    int angle   = 0;
    int options = 7;
    int tid     = 0;
    int special = 0;

    std::map<std::string, std::string>::iterator MI;
    for (MI = E->props.begin(); MI != E->props.end(); MI++)
    {
      const char *name  = MI->first.c_str();
      const char *value = MI->second.c_str();

      if (StringCaseCmp(name, "angle") == 0)
        angle = atoi(value);
      else if (StringCaseCmp(name, "tid") == 0)
        tid = atoi(value);
      else if (StringCaseCmp(name, "special") == 0)
        special = atoi(value);
      else
        CheckThingOption(name, value, &options);
    }

    DM_AddThing(I_ROUND(E->x), I_ROUND(E->y), I_ROUND(h), type,
                angle, options, tid, special,
                NULL /* FIXME: args */);
  }
}


static void TryMergeLine(linedef_info_c *A)
{
  vertex_info_c *V = A->end;

  linedef_info_c *B = V->SecondLine(A);

  if (! B)
    return;

  // we only handle the case where B's start == A's end
  // (which is still the vast majority of mergeable cases)

  if (V != B->start)
    return;

  SYS_ASSERT(B->Valid());

  if (A->CanMerge(B))
    A->Merge(B);
}


static void MergeColinearLines(void)
{
  for (int pass = 0; pass < 4; pass++)
    for (int i = 0; i < (int)dm_linedefs.size(); i++)
      if (dm_linedefs[i]->Valid())
        TryMergeLine(dm_linedefs[i]);
}


static linedef_info_c * FindSimilarLine(linedef_info_c *L, vertex_info_c *V)
{
  linedef_info_c *best = NULL;
  int best_score = -1;

  for (int i = 0; i < 4; i++)
  {
    linedef_info_c *M = V->lines[i];

    if (! M) break;
    if (M == L) continue;

    if (! L->isFrontSimilar(M))
      continue;

    int score = 0;

    if (! L->back && ! M->back)
      score += 20;

    if (L->ColinearWith(M))
      score += 10;

    if (score > best_score)
    {
      best = M;
      best_score = score;
    }
  }

  return best;
}


static void AlignTextures(void)
{
  // Algorithm:  FIXME out of date
  //
  // 1) assign every linedef a "prev_matcher" field (forms a chain)
  //    [POSSIBILITY: similar field for back sidedefs]
  //
  // 2) give every linedef with no prev_matcher the NATURAL X offset
  //
  // 3) iterate over all linedefs, use prev_matcher chain to align X offsets

  int i;

  for (i = 0; i < (int)dm_linedefs.size(); i++)
  {
    linedef_info_c *L = dm_linedefs[i];
    if (! L->Valid())
      continue;

    L->sim_prev = FindSimilarLine(L, L->start);
    L->sim_next = FindSimilarLine(L, L->end);

    if (L->front->x_offset == IVAL_NONE && ! L->sim_prev && ! L->sim_next)
      L->front->x_offset = NaturalXOffset(L, 0);
    
    if (L->back && L->back->x_offset == IVAL_NONE)
      L->back->x_offset = NaturalXOffset(L, 1);
  }

  for (int pass = 8; pass >= 0; pass--)
  {
    int naturals = 0;
    int prev_count = 0;
    int next_count = 0;

    for (i = 0; i < (int)dm_linedefs.size(); i++)
    {
      linedef_info_c *L = dm_linedefs[i];
      if (! L->Valid())
        continue;

      if (L->front->x_offset == IVAL_NONE)
      {
        int mask = (1 << pass) - 1;

        if ((i & mask) == 0)
        {
          L->front->x_offset = NaturalXOffset(L, 0);
          naturals++;
        }
        continue;
      }

      linedef_info_c *P = L;
      linedef_info_c *N = L;

      while (P->sim_prev && P->sim_prev->front->x_offset == IVAL_NONE)
      {
        P->sim_prev->front->x_offset = P->front->x_offset - I_ROUND(P->sim_prev->length);
        P = P->sim_prev;
        prev_count++;
      }

      while (N->sim_next && N->sim_next->front->x_offset == IVAL_NONE)
      {
        N->sim_next->front->x_offset = N->front->x_offset + I_ROUND(N->length);
        N = N->sim_next;
        next_count++;
      }
    }

    DebugPrintf("AlignTextures pass %d : naturals:%d prevs:%d nexts:%d\n",
                pass, naturals, prev_count, next_count);
  }
}


void DM_WriteDoom(void)
{
  // converts the Merged list into the sectors, linedefs (etc)
  // required for a DOOM level.
  //
  // Algorithm:
  //
  // 1) reserve first sector to represent VOID space (never written)
  // 2) create a sector for each region
  // 3) coalesce neighbouring sectors with same properties
  //    - mark border segments as unused
  //    - mark vertices with all unused segs as unused
  // 4) profit!

//CSG2_Doom_TestRegions();
//return;
 
  CreateSectors();

  MakeLinedefs();
  MergeColinearLines();
  AlignTextures();

///  CreateeDummies();

  WriteLinedefs();
  WriteThings();

  // FIXME: Free everything
}


//----------------------------------------------------------------------

#define NK_FACTOR  10
#define NK_HT_FACTOR  -200

class nk_wall_c
{
public:
  linedef_info_c *line;

  nk_wall_c *right;
  nk_wall_c *back;

  int side;

  int index;

public:
  nk_wall_c(linedef_info_c *_L, int _S) :
      line(_L), right(NULL), back(NULL),
      side(_S), index(-1)
  { }

  ~nk_wall_c() {}

  int GetX() const
  {
    return (side == 0) ? line->start->x : line->end->x;
  }

  int GetY() const
  {
    return (side == 0) ? line->start->y : line->end->y;
  }

  int SectorIndex() const
  {
    return (side == 0) ? line->front->sector->index : line->back->sector->index;
  }

  void Write()
  {
    int pic;
    int flags = 0;

    if (! back)
    {
      pic = atoi(line->front->mid.c_str());
    }
    else if (line->isGreedy())
    {
      int f1_h = line->front->sector->f_h;
      int f2_h = line->back ->sector->f_h;

      bool use_upper = ((side==0) == (f1_h < f2_h));

      const sidedef_info_c *SD = (f1_h < f2_h) ? line->front : line->back;

      pic = atoi(use_upper ? SD->upper.c_str() : SD->lower.c_str());

      flags |= WALL_F_SWAP_LOWER;
    }
    else
    {
      int c1_h = line->front->sector->c_h;
      int c2_h = line->back ->sector->c_h;

      bool use_upper = (side==0) ? (c2_h < c1_h) : (c1_h < c2_h);

      const sidedef_info_c *SD = (side==0) ? line->front : line->back;

      pic = atoi(use_upper ? SD->upper.c_str() : SD->lower.c_str());
    }

    if (back)
      flags |= WALL_F_PEGGED;

    int xscale = 1 + (int)line->length / 16;
    if (xscale > 255)
      xscale = 255;

    int lo_tag = (side==0) ? line->type : 0;
    int hi_tag = (side==0) ? line->tag  : 0;


    NK_AddWall(GetX() * NK_FACTOR, -GetY() * NK_FACTOR, right->index,
               back ? back->index : -1, back ? back->SectorIndex() : -1,
               flags, pic, 0,
               xscale, 8, 0, 0,
               lo_tag, hi_tag);
  }
};

typedef std::vector<nk_wall_c *> nk_wall_list_c;


static void NK_Chain(int start, nk_wall_list_c& prelim, nk_wall_list_c *circle,
                     int *wall_id)
{
// fprintf(stderr, "starting at %d\n", start);

  int last = start;

  nk_wall_c *start_W = prelim[start];

  for (;;)
  {
    nk_wall_c *cur = prelim[last];  SYS_ASSERT(cur);
    prelim[last] = NULL;

// fprintf(stderr, "  adding %d @ wall_id:%d\n", last, *wall_id);

    cur->index = *wall_id;  (*wall_id) += 1;
    circle->push_back(cur);

    last = -1;

    for (int k = 0; k < (int)prelim.size(); k++)
    {
      nk_wall_c *W2 = prelim[k];
      if (! W2)
        continue;
       
      if ( (cur->side == 0 && cur->line->end  ->HasLine(W2->line)) ||
           (cur->side == 1 && cur->line->start->HasLine(W2->line)) )
      {
        cur->right = W2;
        last = k;
        break;
      }
    }
// fprintf(stderr, "Found right %p (%d)\n", cur->right, last);

    if (! cur->right)
    {
      SYS_ASSERT(start_W != cur);

      cur->right = start_W;
// fprintf(stderr, "End of loop, using %p\n", cur->right);
      return;
    }
  }
}

static void NK_CollectWalls(sector_info_c *S, int *wall_id, nk_wall_list_c *circle)
{
  int i;

  std::vector<nk_wall_c *> prelim;

// fprintf(stderr, "\nWall list @ sec:%d\n", S->index);
  for (i = 0; i < (int)dm_linedefs.size(); i++)
  {
    linedef_info_c *L = dm_linedefs[i];
    if (! L->Valid())
      continue;

    if (! (L->front->sector == S || (L->back && L->back->sector == S)))
      continue;

    // HMMM
    if (L->front->sector == S && L->back && L->back->sector == S)
      continue;

    nk_wall_c *W = new nk_wall_c(L, (L->front->sector == S) ? 0 : 1);

    if (W->side == 0)
      L->nk_front = W;
    else
      L->nk_back = W;

//fprintf(stderr, "  %i=%p line:%p side:%d (%d %d) --> (%d %d)\n",
//(int)prelim.size(), W, W->line, W->side,
//W->line->start->x, W->line->start->y,
//W->line->end->x, W->line->end->y);

    prelim.push_back(W);
  }

//fprintf(stderr, "\n");

  // group into wall loops

  int total = (int)prelim.size();

  SYS_ASSERT(total >= 2);

  for (i = 0; i < total; i++)
  {
    if (prelim[i])
      NK_Chain(i, prelim, circle, wall_id);
  }
}

static void NK_WriteWalls(void)
{
  int i;

  // mark all visible sectors
  for (i = 0; i < (int)dm_sectors.size(); i++)
    dm_sectors[i]->index = -1;

  for (i = 0; i < (int)dm_linedefs.size(); i++)
  {
    linedef_info_c *L = dm_linedefs[i];
    if (! L->Valid())
      continue;

    if (L->front->sector->index < 0)
    {
      L->front->sector->index = -2;
    }

    if (L->back && L->back->sector->index < 0)
    {
      L->back->sector->index = -2;
    }
  }

  int sec_id = 0;

  for (i = 0; i < (int)dm_sectors.size(); i++)
  {
    sector_info_c * S = dm_sectors[i];

    if (S->index == -2)
    {
      S->index = sec_id;  sec_id += 1;
    }
  }


  // find the walls of each sector

  std::vector<nk_wall_list_c *> sec_walls;

  for (int k = 0; k < sec_id; k++)
    sec_walls.push_back(new nk_wall_list_c);


  int wall_id = 0;

  for (i = 0; i < (int)dm_sectors.size(); i++)
  {
    sector_info_c *S = dm_sectors[i];
    if (S->index < 0)
      continue;

    NK_CollectWalls(S, &wall_id, sec_walls[S->index]);
  }


  // CONNECT FRONT AND BACK
  for (i = 0; i < (int)dm_linedefs.size(); i++)
  {
    linedef_info_c *L = dm_linedefs[i];
    if (! L->Valid())
      continue;

    if (L->nk_front && L->nk_back)
    {
      L->nk_front->back = L->nk_back;
      L->nk_back ->back = L->nk_front;
    }
  }


  // create the sectors
  for (i = 0; i < (int)dm_sectors.size(); i++)
  {
    sector_info_c *S = dm_sectors[i];
    if (S->index < 0)
      continue;

    int first =      sec_walls[S->index]->at(0)->index; 
    int count = (int)sec_walls[S->index]->size();

    int c_flags = 0;
    int visibility = 1;

    if (S->special & 0x10000)
    {
      c_flags |= SECTOR_F_PARALLAX;
    }


    NK_AddSector(first, count, visibility,
                 S->f_h * NK_HT_FACTOR, atoi(S->f_tex.c_str()),
                 S->c_h * NK_HT_FACTOR, atoi(S->c_tex.c_str()), c_flags,
                 S->special, S->tag);


    // WRITE THE WALL LOOP

    for (int k = 0; k < count; k++)
    {
      sec_walls[S->index]->at(k)->Write();
    }
  }


  // free stuff

  for (i = 0; i < (int)dm_sectors.size(); i++)
  {
    sector_info_c *S = dm_sectors[i];
    if (S->index < 0)
      continue;

    int count = (int)sec_walls[S->index]->size();

    for (int k = 0; k < count; k++)
    {
      delete sec_walls[S->index]->at(k);
    }

    delete sec_walls[S->index];
  }
}

static void NK_WriteSprites(void)
{
  for (unsigned int j = 0; j < all_entities.size(); j++)
  {
    entity_info_c *E = all_entities[j];

    int type = atoi(E->name.c_str());

    // parse entity properties
    int angle = 0;
    int lo_tag = 0;
    int hi_tag = 0;

    std::map<std::string, std::string>::iterator MI;
    for (MI = E->props.begin(); MI != E->props.end(); MI++)
    {
      const char *name  = MI->first.c_str();
      const char *value = MI->second.c_str();

      if (StringCaseCmp(name, "angle") == 0)
        angle = atoi(value);
      else if (StringCaseCmp(name, "lo_tag") == 0)
        lo_tag = atoi(value);
      else if (StringCaseCmp(name, "hi_tag") == 0)
        hi_tag = atoi(value);
    }

    // convert angle to 0-2047 range
    angle = ((405 - angle) * 256 / 45) & 2047;


    int sec = 0;

    merge_region_c *REG = CSG2_FindRegionForPoint(E->x, E->y);
    if (REG && REG->index >= 0)
    {
      sector_info_c *S = dm_sectors[REG->index];
      if (S->index >= 0)
      {
        sec = S->index;
      }
    }


    NK_AddSprite(I_ROUND( E->x * NK_FACTOR),
                 I_ROUND(-E->y * NK_FACTOR),
                 I_ROUND( E->z * NK_HT_FACTOR),
                 type, angle, sec,
                 lo_tag, hi_tag);
  }
}


void NK_WriteNukem(void)
{
  CreateSectors();

  MakeLinedefs();
  MergeColinearLines();

  NK_WriteWalls();
  NK_WriteSprites();
}


//--- editor settings ---
// vi:ts=2:sw=2:expandtab
