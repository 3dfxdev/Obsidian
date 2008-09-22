//----------------------------------------------------------------
//  Custom Mod list
//----------------------------------------------------------------
//
//  Oblige Level Maker (C) 2006-2008 Andrew Apted
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
//----------------------------------------------------------------

#include "headers.h"
#include "hdr_fltk.h"
#include "hdr_lua.h"
#include "hdr_ui.h"

#include "lib_util.h"

#include "g_lua.h"


#define MY_PURPLE  fl_rgb_color(208,0,208)


class My_ClipGroup : public Fl_Group
{
public:
  My_ClipGroup(int X, int Y, int W, int H, const char *L = NULL) :
      Fl_Group(X, Y, W, H, L)
  {
    clip_children(1);
  }

  virtual ~My_ClipGroup()
  { }
};


//-----------------------------------------------------------------


UI_Module::UI_Module(int x, int y, int w, int h,
                     const char *id, const char *label) :
    Fl_Group(x, y, w, h),
    id_name(id),
    choice_map()
{
  end(); // cancel begin() in Fl_Group constructor
 
  resizable(NULL);

  box(FL_THIN_UP_BOX);
  color(BUILD_BG, BUILD_BG);

  mod_button = new Fl_Check_Button(x+5, y+4, w-20, 24, label);

  add(mod_button);
 
  hide();
}


UI_Module::~UI_Module()
{
}


typedef struct
{
  UI_Module *M;
  const char *opt_name;
}
opt_callback_data_t;


void UI_Module::AddOption(const char *opt, const char *label)
{
  int nw = 120;
  int nh = 28;

  int nx = x() + 192;
  int ny = y() + children() * nh;

  // FIXME: make label with ': ' suffixed

fprintf(stderr, "AddOption %s: x, y = %d,%d\n", opt, x(), y());
  UI_RChoice *rch = new UI_RChoice(nx, ny, nw, 24, label);

  choice_map[opt] = rch;

  opt_callback_data_t *cb_data = new opt_callback_data_t;
  cb_data->M = this;
  cb_data->opt_name = StringDup(opt);

  rch->align(FL_ALIGN_LEFT);
  rch->selection_color(MY_PURPLE);
  rch->callback(callback_OptChange, cb_data);

  add(rch);

  rch->hide();

  resize(x(), y(), w(), CalcHeight());
  redraw();
}


int UI_Module::CalcHeight() const
{
  int h = 4 + 24 + 6;  // check button

  if (mod_button->value())
    h += (children() - 1) * 28 + 4;

  return h;
}

void UI_Module::update_Enable()
{
  for (int j = 0; j < children(); j++)
  {
    if (child(j) == mod_button)
      continue;

    // this is awful
    UI_RChoice *M = (UI_RChoice *)child(j);

    if (mod_button->value())
      M->show();
    else
      M->hide();
  }
}


void UI_Module::OptionPair(const char *option, const char *id, const char *label)
{
  UI_RChoice *rch = FindOpt(option);
fprintf(stderr, "Looking for '%s'\n", option);
  if (! rch)
    return; // false;

fprintf(stderr, "OPTION PAIR : %s --> %s\n", id, label);
  rch->AddPair(id, label);
  rch->ShowOrHide(id, 1);
}


bool UI_Module::ParseValue(const char *option, const char *value)
{
  UI_RChoice *rch = FindOpt(option);

  if (! rch)
    return false;  // FIXME: warning

  return rch->SetID(value);
}


UI_RChoice * UI_Module::FindOpt(const char *option)
{
  if (choice_map.find(option) == choice_map.end())
    return NULL;

  return choice_map[option];
}


void UI_Module::callback_OptChange(Fl_Widget *w, void *data)
{
  UI_RChoice *rch = (UI_RChoice*) w;

  opt_callback_data_t *cb_data = (opt_callback_data_t*) data;

  SYS_ASSERT(rch);
  SYS_ASSERT(cb_data);

  UI_Module *M = cb_data->M;

  ob_set_mod_option(M->id_name.c_str(), cb_data->opt_name, rch->GetID());
}


//----------------------------------------------------------------


UI_CustomMods::UI_CustomMods(int x, int y, int w, int h, const char *label) :
    Fl_Group(x, y, w, h, label)
{
  end(); // cancel begin() in Fl_Group constructor
 
//  box(FL_THIN_UP_BOX);
  box(FL_FLAT_BOX);
  color(WINDOW_BG, WINDOW_BG);


  int cy = y; // + 8;

#if 0
  Fl_Box *heading = new Fl_Box(FL_NO_BOX, x+6+w/4, cy, w/2-12, 24, "Custom Mods");
  heading->align(FL_ALIGN_LEFT | FL_ALIGN_INSIDE);
  heading->labeltype(FL_NORMAL_LABEL);
  heading->labelfont(FL_HELVETICA_BOLD);
  heading->labelcolor(FL_WHITE);
//  heading->color(BUILD_BG, BUILD_BG);

  add(heading);
#endif

//  cy += 28;


  // area for module list
  mx = x+0;
  my = cy;
  mw = w-0 - Fl::scrollbar_size();
  mh = y+h-cy;

  offset_y = 0;
  total_h  = 0;

fprintf(stderr, "MLIST AREA: (%d,%d)  %dx%d\n", mx, my, mw, mh);

  sbar = new Fl_Scrollbar(mx+mw, my, Fl::scrollbar_size(), mh);
  sbar->callback(callback_Scroll, this);

  add(sbar);


  mod_pack = new My_ClipGroup(mx, my, mw, mh, "\nCustom Modules");
  mod_pack->end();

  mod_pack->align(FL_ALIGN_INSIDE);
  mod_pack->labeltype(FL_NORMAL_LABEL);
//  mod_pack->labelfont(FL_HELVETICA_BOLD);
  mod_pack->labelsize(20);
//  mod_pack->labelcolor(FL_DARK2);

  mod_pack->box(FL_FLAT_BOX);
  mod_pack->color(WINDOW_BG);  
  mod_pack->resizable(NULL);


  add(mod_pack);
}


UI_CustomMods::~UI_CustomMods()
{
}


void UI_CustomMods::AddModule(const char *id, const char *label)
{
  UI_Module *M = new UI_Module(mx, my, mw-4, 34, id, label);

  M->mod_button->callback(callback_ModEnable, M);

  mod_pack->add(M);


  PositionAll();

  sbar->value(0, mh, 0, total_h);

///???  M->redraw();
}


void UI_CustomMods::AddOption(const char *module, const char *option,
                              const char *label)
{
  UI_Module *M = FindID(module);
  if (! M)
    return; // false;

  M->AddOption(option, label);


  PositionAll();

//???  M->redraw();
}

void UI_CustomMods::OptionPair(const char *module, const char *option,
                               const char *id, const char *label)
{
  UI_Module *M = FindID(module);
fprintf(stderr, "Looking for module '%s' : %p\n", module, M);
  if (! M)
    return; // false;

  M->OptionPair(option, id, label);
}


bool UI_CustomMods::ShowOrHide(const char *id, bool new_shown)
{
  SYS_ASSERT(id);

  UI_Module *M = FindID(id);

  if (! M)
    return false;

  if ( (M->visible()?1:0) == (new_shown ? 1:0) )
    return true;

  // visibility definitely changed

  if (new_shown)
    M->show();
  else
    M->hide();

  PositionAll();

  sbar->value(0, mh, 0, total_h);

///???  M->redraw();

  return true;
}

bool UI_CustomMods::ParseOptValue(const char *module, const char *option,
                                  const char *value)
{
  ob_set_mod_option(module, option, value);

  UI_Module *M = FindID(module);

  if (! M)
    return false;

  return M->ParseValue(option, value);
}

void UI_CustomMods::ChangeValue(const char *id, bool enable)
{
  SYS_ASSERT(id);

  UI_Module *M = FindID(id);

  if (! M)
    return;

  if ( (M->mod_button->value()?1:0) == (enable ? 1:0) )
    return;

  M->mod_button->value(enable ? 1 : 0);

  callback_ModEnable(NULL, M);  // FIXME: dirty hack
}


void UI_CustomMods::PositionAll(UI_Module *focus)
{
fprintf(stderr, "PositionAll:\n");
  
  // determine focus [closest to top without going past it]
  if (! focus)
  {
    int best_dist = 9999;

    for (int j = 0; j < mod_pack->children(); j++)
    {
      UI_Module *M = (UI_Module *) mod_pack->child(j);
      SYS_ASSERT(M);

      if (!M->visible() || M->y() < my || M->y() >= my+mh)
        continue;

      int dist = M->y() - my;

      if (dist < best_dist)
      {
        focus = M;
        best_dist = dist;
      }
    }
  }


  // calculate new total height
  int new_height = 0;
  int spacing = 4;

  for (int k = 0; k < mod_pack->children(); k++)
  {
    UI_Module *M = (UI_Module *) mod_pack->child(k);
    SYS_ASSERT(M);

    if (M->visible())
      new_height += M->CalcHeight() + spacing;
  }


  // determine new offset_y
  if (new_height <= mh)
  {
    offset_y = 0;
  }
  else if (focus)
  {
    int focus_oy = focus->y() - my;
    SYS_ASSERT(focus_oy >= 0);

    int above_h = 0;
    for (int k = 0; k < mod_pack->children(); k++)
    {
      UI_Module *M = (UI_Module *) mod_pack->child(k);
      if (M->visible() && M->y() < focus->y())
      {
        above_h += M->CalcHeight() + spacing;
      }
    }

    offset_y = above_h - focus_oy;

    offset_y = MAX(offset_y, 0);
    offset_y = MIN(offset_y, new_height - mh);
  }
  else
  {
    // when not shrinking, offset_y will remain valid
    if (new_height < total_h)
      offset_y = 0;
  }

  total_h = new_height;

  SYS_ASSERT(offset_y >= 0);
  SYS_ASSERT(offset_y <= total_h);


  // reposition all the modules
  int ny = my - offset_y;

  for (int j = 0; j < mod_pack->children(); j++)
  {
    UI_Module *M = (UI_Module *) mod_pack->child(j);
    SYS_ASSERT(M);

    int nh = M->visible() ? M->CalcHeight() : 1;
  
    if (ny != M->y() || nh != M->h())
    {
      M->resize(M->x(), ny, M->w(), nh);
    }

    if (M->visible())
      ny += M->CalcHeight() + spacing;
  }


  // p = position, first line displayed
  // w = window, number of lines displayed
  // t = top, number of first line
  // l = length, total number of lines
  sbar->value(offset_y, mh, 0, total_h);

  mod_pack->redraw();
}


void UI_CustomMods::callback_Scroll(Fl_Widget *w, void *data)
{
  Fl_Scrollbar *sbar = (Fl_Scrollbar *)w;
  UI_CustomMods *that = main_win->mod_box;

  int previous_y = that->offset_y;

  that->offset_y = sbar->value();

  int dy = that->offset_y - previous_y;

  // simply reposition all the UI_Module widgets
  for (int j = 0; j < that->mod_pack->children(); j++)
  {
    Fl_Widget *F = that->mod_pack->child(j);
    SYS_ASSERT(F);

    F->resize(F->x(), F->y() - dy, F->w(), F->h());
  }

  that->mod_pack->redraw();
}


void UI_CustomMods::callback_ModEnable(Fl_Widget *w, void *data)
{
  UI_Module *M = (UI_Module *)data;

  M->update_Enable();

  UI_CustomMods *that = main_win->mod_box;

  // no height change if no options
  if (M->choice_map.size() > 0)
  {
    that->offset_y=0;

    int old_total_h = that->total_h;

    that->PositionAll(M);

    that->sbar->value(0, that->mh, 0, that->total_h);

    fprintf(stderr, "HEIGHT CHANGE: %d --> %d\n", old_total_h, that->total_h);
  }

  if (w)
    ob_set_mod_option(M->id_name.c_str(), "self", M->mod_button->value() ? "true" : "false");
}


UI_Module * UI_CustomMods::FindID(const char *id) const
{
  // this is awful
  for (int j = 0; j < mod_pack->children(); j++)
  {
    UI_Module *M = (UI_Module *) mod_pack->child(j);
    SYS_ASSERT(M);

    if (strcmp(M->id_name.c_str(), id) == 0)
      return M;
  }

  return NULL;
}


void UI_CustomMods::Locked(bool value)
{
  if (value)
  {
    mod_pack->deactivate();
  }
  else
  {
    mod_pack->activate();
  }
}


//--- editor settings ---
// vi:ts=2:sw=2:expandtab
