//----------------------------------------------------------------
//  Setup screen
//----------------------------------------------------------------
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
//----------------------------------------------------------------

#include "headers.h"
#include "hdr_fltk.h"
#include "hdr_lua.h"
#include "hdr_ui.h"

#include "lib_signal.h"
#include "lib_util.h"
#include "main.h"
#include "m_lua.h"


//
// Constructor
//
UI_Game::UI_Game(int X, int Y, int W, int H, const char *label) :
	Fl_Group(X, Y, W, H, label)
{
	box(FL_THIN_UP_BOX);

	if (! alternate_look)
		color(BUILD_BG, BUILD_BG);


	int y_step = kf_h(6) + KF;

	int cx = X + W * 0.36;
	int cy = Y + y_step;


	const char *heading_text = _("Game Settings");

	Fl_Box *heading = new Fl_Box(FL_NO_BOX, X + kf_w(6), cy, W - kf_w(12), kf_h(24), heading_text);
	heading->align(FL_ALIGN_LEFT | FL_ALIGN_INSIDE);
	heading->labeltype(FL_NORMAL_LABEL);
	heading->labelfont(FL_HELVETICA_BOLD);
	heading->labelsize(header_font_size);

	cy += heading->h() + y_step;


	int cw = W * 0.61;
	int ch = kf_h(24);

	game = new UI_RChoice(cx, cy, cw, ch, _("Game: "));
	game->align(FL_ALIGN_LEFT);
	game->selection_color(FL_BLUE);
	game->callback(callback_Game, this);

	cy += game->h() + y_step;


	engine = new UI_RChoice(cx, cy, cw, ch, _("Engine: "));
	engine->align(FL_ALIGN_LEFT);
	engine->selection_color(FL_BLUE);
	engine->callback(callback_Engine, this);

	cy += engine->h() + y_step * 2;


	length = new UI_RChoice(cx, cy, cw, ch, _("Length: "));
	length->align(FL_ALIGN_LEFT);
	length->selection_color(FL_BLUE);
	length->callback(callback_Length, this);

	setup_Length();

	cy += length->h() + y_step;


	mode = new UI_RChoice(cx, cy, cw, ch, _("Mode: "));
	mode->align(FL_ALIGN_LEFT);
	mode->selection_color(FL_BLUE);
	mode->callback(callback_Mode, this);

	setup_Mode();

	cy += mode->h() + y_step*2;


	theme = new UI_RChoice(cx, cy, cw, ch, _("Theme: "));
	theme->align(FL_ALIGN_LEFT);
	theme->selection_color(FL_BLUE);
	theme->callback(callback_Theme, this);

	cy += theme->h() + y_step;


	end();

	resizable(NULL);  // don't resize our children


///---	length->SetID("episode");
}


//
// Destructor
//
UI_Game::~UI_Game()
{ }


void UI_Game::callback_Game(Fl_Widget *w, void *data)
{
	UI_Game *that = (UI_Game *)data;

	ob_set_config("game", that->game->GetID());
	Signal_Raise("game");
}


void UI_Game::callback_Engine(Fl_Widget *w, void *data)
{
	UI_Game *that = (UI_Game *)data;

	ob_set_config("engine", that->engine->GetID());
	Signal_Raise("engine");
}


void UI_Game::callback_Length(Fl_Widget *w, void *data)
{
	UI_Game *that = (UI_Game *)data;

	ob_set_config("length", that->length->GetID());
}


void UI_Game::callback_Mode(Fl_Widget *w, void *data)
{
	UI_Game *that = (UI_Game *)data;

	ob_set_config("mode", that->mode->GetID());
	Signal_Raise("mode");
}


void UI_Game::callback_Theme(Fl_Widget *w, void *data)
{
	UI_Game *that = (UI_Game *) data;

	ob_set_config("theme", that->theme->GetID());
}


void UI_Game::Locked(bool value)
{
	if (value)
	{
		game  ->deactivate();
		engine->deactivate();
		length->deactivate();
		mode  ->deactivate();
		theme ->deactivate();
	}
	else
	{
		game  ->activate();
		engine->activate();
		length->activate();
		mode  ->activate();
		theme ->activate();
	}
}


void UI_Game::Defaults()
{
	// Note: game, engine, theme are handled by LUA code (ob_init)

	ParseValue("mode", "sp");
	ParseValue("length", "game");
}


bool UI_Game::ParseValue(const char *key, const char *value)
{
	// Note: game, engine, theme are handled by LUA code
	//
	if (StringCaseCmp(key, "mode") == 0)
	{
		mode->SetID(value);
		callback_Mode(NULL, this);
		return true;
	}

	if (StringCaseCmp(key, "length") == 0)
	{
		length->SetID(value);
		callback_Length(NULL, this);
	}

	return false;
}


//----------------------------------------------------------------

const char * UI_Game::mode_syms[] =
{
	"sp",   N_("Single Player"),
	"coop", N_("Co-op"),
///	"dm",   N_("Deathmatch"),
///	"ctf",  N_("Capture Flag"),

	NULL, NULL
};

const char * UI_Game::length_syms[] =
{
	"single",  N_("Single Level"),
	"few",     N_("A Few Maps"),
	"episode", N_("One Episode"),
	"game",    N_("Full Game"),

	NULL, NULL
};


void UI_Game::setup_Mode()
{
	for (int i = 0; mode_syms[i]; i += 2)
	{
		mode->AddPair(mode_syms[i], _(mode_syms[i+1]));
		mode->ShowOrHide(mode_syms[i], 1);
	}
}


void UI_Game::setup_Length()
{
	for (int i = 0; length_syms[i]; i += 2)
	{
		length->AddPair(length_syms[i], _(length_syms[i+1]));
		length->ShowOrHide(length_syms[i], 1);
	}
}


//--- editor settings ---
// vi:ts=4:sw=4:noexpandtab
