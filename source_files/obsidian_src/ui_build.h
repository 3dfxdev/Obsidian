//------------------------------------------------------------------------
//  Build panel
//------------------------------------------------------------------------
//
//  Oblige Level Maker
//
//  Copyright (C) 2006-2016 Andrew Apted
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

#ifndef __UI_BUILD_H__
#define __UI_BUILD_H__

#include <string>
#include <vector>

#include "FL/Fl_Box.H"
#include "FL/Fl_Group.H"
#include "FL/Fl_Progress.H"
#include "ui_map.h"

class UI_Build : public Fl_Group {
   public:
    UI_MiniMap *mini_map;
    Fl_Box *seed_disp;
    Fl_Box *name_disp;
    Fl_Box *status;
    Fl_Progress *progress;
    std::string string_seed = "";

   private:
    std::string status_label;
    std::string prog_label;

    int level_index;  // starts at 1
    int level_total;

    bool node_begun;
    float node_ratio;
    float node_along;

    std::vector<std::string> step_names;

   public:
    UI_Build(int x, int y, int w, int h, const char *label = NULL);
    virtual ~UI_Build();

   public:
    void Prog_Init(int node_perc, const char *extra_steps);
    void Prog_AtLevel(int index, int total);
    void Prog_Step(const char *step_name);
    void Prog_Nodes(int pos, int limit);
    void Prog_Finish();

    void SetStatus(std::string_view msg);

   private:
    void resize(int X, int Y, int W, int H);

    void ParseSteps(const char *list);
    int FindStep(std::string name);  // -1 if not found

    void AddStatusStep(std::string name);
};

#endif /* __UI_BUILD_H__ */

//--- editor settings ---
// vi:ts=4:sw=4:noexpandtab
