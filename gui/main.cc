//------------------------------------------------------------------------
//  Main program
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
#include "hdr_lua.h"
#include "hdr_ui.h"

#include "lib_argv.h"
#include "lib_file.h"
#include "lib_signal.h"
#include "lib_util.h"

#include "main.h"

#include "ui_chooser.h"

#include "g_cookie.h"
#include "g_lua.h"

#include "wolf_map.h"
#include "dm_level.h"
#include "q1_main.h"


#define TICKER_TIME  40 /* ms */

#define CONFIG_FILENAME  "CONFIG.txt"
#define LOG_FILENAME     "LOGS.txt"


const char *working_path = NULL;
const char *install_path = NULL;

int screen_w;
int screen_h;

bool batch_mode = false;
bool create_backups = true;
bool hide_module_panel = false;
bool debug_messages = false;

const char *batch_output_file = NULL;


game_interface_c * game_object = NULL;


/* ----- user information ----------------------------- */

static void ShowInfo(void)
{
  printf(
    "\n"
    "** " OBLIGE_TITLE " " OBLIGE_VERSION " (C) 2006-2010 Andrew Apted **\n"
    "\n"
  );

  printf(
    "Usage: Oblige [options...]\n"
    "\n"
    "Available options:\n"
    "  -b --batch  <file>   Batch mode (no GUI)\n"
    "  -d --debug           Enable debugging\n"
    "  -t --terminal        Print log messages to stdout\n"
    "  -h --help            Show this help message\n"
    "\n"
  );

  printf(
    "This program is free software, under the terms of the GNU General\n"
    "Public License, and comes with ABSOLUTELY NO WARRANTY.  See the\n"
    "documentation for more details, or visit the following web page:\n"
    "http://www.gnu.org/licenses/gpl.html\n"
    "\n"
  );
}

void Determine_WorkingPath(const char *argv0)
{
  // firstly find the "Working directory", and set it as the
  // current directory.  That's the place where the CONFIG.txt
  // and LOGS.txt files are, as well the temp files.

#ifndef FHS_INSTALL
  working_path = GetExecutablePath(argv0);

#else
  char *path = StringNew(FL_PATH_MAX + 4);

  if (fl_filename_expand(path, "$HOME/.oblige") == 0)
    Main_FatalError("Unable to find $HOME directory!\n");

  working_path = path;

  // try to create it (doesn't matter if it already exists)
  FileMakeDir(working_path);
#endif

  if (! working_path)
    working_path = StringDup(".");
}


void Determine_InstallPath(const char *argv0)
{
  // secondly find the "Install directory", and store the
  // result in the global variable 'install_path'.  This is
  // where all the LUA scripts and other data files are.

#ifndef FHS_INSTALL
  install_path = StringDup(working_path);

#else
  static const char *prefixes[] =
  {
    "/usr/local", "/usr", "/opt", NULL
  };

  for (int i = 0; prefixes[i]; i++)
  {
#if 0  // Version specific dir
    install_path = StringPrintf("%s/share/oblige-%s", prefixes[i], OBLIGE_VERSION);
#else
    install_path = StringPrintf("%s/share/oblige", prefixes[i]);
#endif

    const char *filename = StringPrintf("%s/scripts/oblige.lua", install_path);

#if 0  // DEBUG
    fprintf(stderr, "Trying install path: [%s]\n", install_path);
    fprintf(stderr, "  using file: [%s]\n\n", filename);
#endif

    bool exists = FileExists(filename);

    StringFree(filename);

    if (exists)
      return;

    StringFree(install_path);
    install_path = NULL;
  }
#endif

  if (! install_path)
    Main_FatalError("Unable to find Oblige's install directory!\n");
}


void Setup_FLTK()
{
  bool custom_colors = true;
  bool hires_adapt = true;

  Fl::visual(FL_RGB);

  if (custom_colors)
  {
    Fl::background(236, 232, 228);
    Fl::background2(255, 255, 255);
    Fl::foreground(0, 0, 0);
  }

  Fl::scheme("plastic");

  screen_w = Fl::w();
  screen_h = Fl::h();

#if 0  // debug
  fprintf(stderr, "Screen dimensions = %dx%d\n", screen_w, screen_h);
#endif

  // determine the Kromulent factor
  KF = 0;

  if (hires_adapt)
  {
    if (screen_w > 1100 && screen_h > 720)
      KF = 2;
    else if (screen_w > 950 && screen_h > 660)
      KF = 1;
  }

  // default font size for widgets
  FL_NORMAL_SIZE = 14 + KF * 2;

  fl_message_font(FL_HELVETICA /* _BOLD */, 18);
}


void Main_Ticker()
{
  // This function is called very frequently.
  // To prevent a slow-down, we only call Fl::check()
  // after a certain time has elapsed.

  static u32_t last_millis = 0;

  u32_t cur_millis = TimeGetMillies();

  if ((cur_millis - last_millis) >= TICKER_TIME)
  {
    Fl::check();

    last_millis = cur_millis;
  }
}


void Main_Shutdown(bool error)
{
  if (main_win)
  {
    // on fatal error we cannot risk calling into the Lua runtime
    // (it's state may be compromised by a script error).
    if (! error)
      Cookie_Save(CONFIG_FILENAME);

    delete main_win;
    main_win = NULL;
  }

  Script_Close();
  LogClose();
  ArgvClose();
}


void Main_FatalError(const char *msg, ...)
{
  static char buffer[MSG_BUF_LEN];

  va_list arg_pt;

  va_start(arg_pt, msg);
  vsnprintf(buffer, MSG_BUF_LEN-1, msg, arg_pt);
  va_end(arg_pt);

  buffer[MSG_BUF_LEN-2] = 0;

  DLG_ShowError("%s", buffer);

  Main_Shutdown(true);

  exit(9);
}


static int escape_key_handler(int event)
{
  if (event != FL_SHORTCUT)
    return 0;

  if (Fl::event_key() != FL_Escape)
    return 0;

  // if building is in progress, cancel it, otherwise quit
  if (game_object && ! Fl::modal())
  {
    main_win->action = UI_MainWin::ABORT;
    return 1;
  }

  // let FLTK's default code kick in
  // [we cannot mimic it because we lack the 'window' ref]
  return 0;
}


static int module_key_handler(int event)
{
  if (event != FL_SHORTCUT)
    return 0;

  if (Fl::event_key() == TOGGLE_MODULES_KEY)
  {
    hide_module_panel = ! hide_module_panel;
    main_win->HideModules(hide_module_panel);
    return 1;
  }

  return 0;
}


static void Batch_Defaults(void)
{
  // inform Lua code about batch mode (the value doesn't matter)
  ob_set_config("batch", "yes");

  int seed = time(NULL) & 0x7FFFF;

  char seed_buffer[20];
  sprintf(seed_buffer, "%d", seed);

  // Game Settings
  ob_set_config("seed",   seed_buffer);
  ob_set_config("mode",   "sp");
  ob_set_config("length", "few");

  // Level Architecture
  ob_set_config("size",     "prog");
  ob_set_config("outdoors", "mixed");
  ob_set_config("secrets",  "mixed");
  ob_set_config("traps",    "mixed");

  // Playing Style
  ob_set_config("mons",    "normal");
  ob_set_config("strength","medium");
  ob_set_config("powers",  "normal");
  ob_set_config("health",  "normal");
  ob_set_config("ammo",    "normal");
}


//------------------------------------------------------------------------

void Build_Cool_Shit()
{
  // clear the map
  if (main_win)
    main_win->build_box->mini_map->EmptyMap();

  const char *format = ob_game_format();

  if (! format || strlen(format) == 0)
    Main_FatalError("ERROR: missing 'format' for game?!?\n");

  // create game object
  {
    if (StringCaseCmp(format, "doom") == 0)
      game_object = Doom_GameObject();

    else if (StringCaseCmp(format, "wolf3d") == 0)
      game_object = Wolf_GameObject();

    else if (StringCaseCmp(format, "quake") == 0)
      game_object = Quake1_GameObject();

///    else if (StringCaseCmp(format, "quake2") == 0)
///      game_object = Quake2_GameObject();

    else
      Main_FatalError("ERROR: unknown format: '%s'\n", format);
  }


  // lock most widgets of user interface
  if (main_win)
  {
    main_win->Locked(true);
    main_win->build_box->ProgSetButton(true);
    main_win->build_box->ProgStatus("Preparing...");
  }

  bool was_ok = game_object->Start();

  if (was_ok)
  {
    // run the scripts Scotty!
    was_ok = ob_build_cool_shit();

    if (! game_object->Finish(was_ok))
      was_ok = false;
  }

  if (main_win)
  {
    if (was_ok)
      main_win->build_box->ProgStatus("Success");
    else
      main_win->build_box->ProgStatus(game_object->GetError());

    main_win->build_box->ProgFinish();
    main_win->build_box->ProgSetButton(false);

    main_win->Locked(false);

    if (main_win->action == UI_MainWin::ABORT)
      main_win->action = UI_MainWin::NONE;
  }

  // don't need game object anymore
  delete game_object;
  game_object = NULL;
}


/* ----- main program ----------------------------- */


extern int TEST_Zip(int argc, char **argv);


int main(int argc, char **argv)
{
///  return TEST_Zip(argc, argv);

  // initialise argument parser (skipping program name)
  ArgvInit(argc-1, (const char **)(argv+1));

  if (ArgvFind('?', NULL) >= 0 || ArgvFind('h', "help") >= 0)
  {
    ShowInfo();
    exit(1);
  }


  int batch_arg = ArgvFind('b', "batch");
  if (batch_arg >= 0)
  {
    if (batch_arg+1 >= arg_count || arg_list[batch_arg+1][0] == '-')
    {
      fprintf(stderr, "OBLIGE ERROR: missing filename for --batch\n");
      exit(9);
    }

    batch_mode = true;
    batch_output_file = arg_list[batch_arg+1];
  }


  if (! batch_mode)
    Setup_FLTK();

  Determine_WorkingPath(argv[0]);
  Determine_InstallPath(argv[0]);

  FileChangeDir(working_path);


  LogInit(batch_mode ? NULL : LOG_FILENAME);

  if (batch_mode || ArgvFind('t', "terminal") >= 0)
    LogEnableTerminal(true);

  LogPrintf("\n");
  LogPrintf("********************************************************\n");
  LogPrintf("** " OBLIGE_TITLE " " OBLIGE_VERSION " (C) 2006-2010 Andrew Apted **\n");
  LogPrintf("********************************************************\n");
  LogPrintf("\n");

  LogPrintf("working_path: [%s]\n",   working_path);
  LogPrintf("install_path: [%s]\n\n", install_path);

  if (! batch_mode)
    Cookie_Load(CONFIG_FILENAME, true /* PRELOAD */);

  if (ArgvFind('d', "debug") >= 0)
    debug_messages = true;

  LogEnableDebug(debug_messages);

  // create directory for temporary files
  FileMakeDir("temp");

  // load icons for file chooser
#ifndef WIN32
  if (! batch_mode)
    Fl_File_Icon::load_system_icons();
#endif


  Script_Init();

  if (batch_mode)
  {
    Script_Load();

    Batch_Defaults();
    Cookie_ParseArguments();

    Build_Cool_Shit();
  }
  else
  {
    Default_Location();

    int main_w, main_h;
    UI_MainWin::CalcWindowSize(false, &main_w, &main_h);

    main_win = new UI_MainWin(main_w, main_h, OBLIGE_TITLE " " OBLIGE_VERSION);

    Script_Load();

    main_win->game_box ->Defaults();
    main_win->level_box->Defaults();
    main_win->play_box ->Defaults();

    // load config after creating window (will set widget values)
    Cookie_Load(CONFIG_FILENAME);

    Cookie_ParseArguments();

    if (hide_module_panel)
      main_win->HideModules(true);


    // show window (pass some dummy arguments)
    {
      char *argv[2];
      argv[0] = strdup("Oblige.exe");
      argv[1] = NULL;

      main_win->show(1 /* argc */, argv);
    }

    // kill the stupid bright background of the "plastic" scheme
    delete Fl::scheme_bg_;
    Fl::scheme_bg_ = NULL;

    main_win->image(NULL);

    Fl::add_handler(module_key_handler);
    Fl::add_handler(escape_key_handler);

    // draw an empty map (must be done after main window is
    // shown() because that is when FLTK finalises the colors).
    main_win->build_box->mini_map->EmptyMap();


    try
    {
      // run the GUI until the user quits
      for (;;)
      {
        Fl::wait(0.2f);

        if (main_win->action == UI_MainWin::QUIT)
          break;

        if (main_win->action == UI_MainWin::BUILD)
        {
          main_win->action = UI_MainWin::NONE;

          // save config in case everything blows up
          Cookie_Save(CONFIG_FILENAME);

          Build_Cool_Shit();
        }
      }
    }
    catch (assert_fail_c err)
    {
      Main_FatalError("Sorry, an internal error occurred:\n%s", err.GetMessage());
    }
    catch (...)
    {
      Main_FatalError("An unknown problem occurred (UI code)");
    }
  }

  Main_Shutdown(false);

  return 0;
}

//--- editor settings ---
// vi:ts=2:sw=2:expandtab
