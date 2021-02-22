{

    Monkey Window Manager
    Copyright (C) 2007  Chris Tillberg

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

}
unit wmstartup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, wmmisc, wmglobals, wmerrhandle, x,
  xlib, cursorfont, wmnewclient, wmtaskbar, wmlaunchbar, wmtimer,
  imlib2, wmdesktop;
  
  
procedure start_Monkey();
procedure setup_folders_Monkey();
procedure ini_settings_Monkey();
procedure setup_atoms_Monkey();
procedure colors_Monkey();
procedure load_font_Monkey();
procedure create_cursor_Monkey();
procedure root_window_Monkey();
procedure client_init_Monkey();
procedure grab_keys_Monkey();
procedure scan_tree_Monkey();
function DoPixmapActions(thefilname: string): PixmapStruct;
procedure start_theme_Monkey();
function RunStartUpThreadApp(itemnum: pointer): longint;

implementation

procedure start_Monkey();
var
  i: integer;
  F : Text;
begin
  setup_folders_Monkey();
  ini_settings_Monkey();
  open_debug_file();
  
  debug_Monkey('setting error handler');
  XSetErrorHandler(@error_handler);
  
  debug_Monkey('opening display');
  dsply := XOpenDisplay(nil);
  if (dsply = nil) then
  begin
    debug_Monkey('Error: opening display. Quitting!');
    writeln('Error: opening display. Quitting!');
    halt;
  end;

  exitmonkey := False;
  wmClientList := TStringList.create;
  wmTaskbarList := TStringList.create;
  wmTaskbarTempList := TStringList.create;
  wmMainMenuList := TStringList.create;
  mainmenuwin := 0;
  setup_atoms_Monkey();
  load_font_Monkey();
  create_cursor_Monkey();
  client_init_Monkey();
  debug_Monkey('screen count: ' + inttostr(ScreenCount(dsply)));
  
  debug_Monkey('getting screen');
  scrn := DefaultScreen(dsply);
  //Inittiate Imlib2
  imlibvis := DefaultVisual(dsply, scrn);
  imlibcm := DefaultColormap(dsply, scrn);
  imlib_context_set_display(dsply);
  imlib_context_set_visual(imlibvis);
  imlib_context_set_colormap(imlibcm);
  imlib_set_color_usage(128);
  imlib_context_set_dither('1');
  imlib_context_set_blend('1');
  
  colors_Monkey();
  current_desktop := 1;
  focused_client := 0;
  root_window_Monkey();
    
  debug_Monkey('getting display size');
  max_width := DisplayWidth (dsply, scrn);
  max_height := DisplayHeight(dsply, scrn);
  debug_Monkey('Screen width: ' + inttostr(max_width));
  debug_Monkey('Screen height: ' + inttostr(max_height));
    
  grab_keys_Monkey();
  
  if usetheme = True then start_theme_Monkey();
    
  create_taskbar();
  
  if uselaunchbar = True then startup_launchbar();
  
  if usedesktop = True then startup_desktop();

  scan_tree_Monkey();

  TimrThrd := TimerThread.create(false);
  if numlockon = True then key_lock(1, True);
  if FileExists(wrkfoldr + '/startup') then
  begin
    tmpStartupList := TStringList.create;
    tmpStartupList.LoadFromFile(wrkfoldr + '/startup');
    if tmpStartupList.Count > 0 then
    begin
      for i := 0 to tmpStartupList.Count - 1 do
      begin
        if tmpStartupList[i] <> '' then
        begin
          try
            if Trim(tmpStartupList[i]) <> '' then BeginThread(@RunStartUpThreadApp, Pointer(i));
          except
            debug_Monkey('startup_programs: ERROR! exec: ' + tmpStartupList[i]);
          end;
        end;
      end;
    end;
  //tmpStartupList.Clear;
  //FreeAndNil(tmpStartupList);
  end;
  if (usedesktop = True) and FileExists(wrkfoldr + '/dodesktopicons') then
  begin
    Assign (F, wrkfoldr + '/dodesktopicons');
    Erase(F);
    organize_desktop();
  end;
end;

procedure setup_folders_Monkey();
begin
  debug_Monkey('setup folders');
  wrkfoldr := Trim(GetEnvironmentVariable('HOME')) + '/.' + appdirname;
  dbugfoldr := wrkfoldr + '/debug';
  if DirectoryExists(wrkfoldr) = False then
  begin
    debug_Monkey('Home folder does not exist...creating: ' + wrkfoldr);
    CreateDir(wrkfoldr);
    if DirectoryExists('/usr/share/' + appdirname) = True then wrkfoldr := '/usr/share/' + appdirname;
  end;
  if DirectoryExists(dbugfoldr) = False then
  begin
    debug_Monkey('Debug folder does not exist...creating: ' + dbugfoldr);
    CreateDir(dbugfoldr);
  end;
  open_debug_file();
end;

procedure ini_settings_Monkey();
var
wmini, tmpstr: string;
tmplaunchsize: integer;
begin
  debug_Monkey('getting ini settings');
  if FileExists(wrkfoldr + '/monkeywm.ini') then
  begin
    wmini := wrkfoldr + '/monkeywm.ini';
  end;
  if (wmini <> '') then
  begin
  ini_monkey := TIniFile.Create(wmini);
    if ini_monkey.ReadString('Settings', 'Debug', '') = 'True' then dodebug := True;
    if ini_monkey.ReadString('Settings', 'Debug_To_File', '') = 'True' then debugtofile := True;
    if ini_monkey.ReadString('Settings', 'Num_Lock_On', '') = 'True' then numlockon := True;
    num_of_desktops := ini_monkey.ReadInteger('Settings', 'Number_Of_Desktops', 0);
    if num_of_desktops < 1 then num_of_desktops := 1;
    if num_of_desktops > 12 then num_of_desktops := 12;
    if ini_monkey.ReadString('LaunchBar', 'Use', '') = 'True' then uselaunchbar := True;
    tmplaunchsize := ini_monkey.ReadInteger('LaunchBar', 'Icons_Size', 0);
    if tmplaunchsize <> 0 then launchiconsize := tmplaunchsize;
    if ini_monkey.ReadString('LaunchBar', 'Use_Dbl_Click', '') = 'False' then lbusedoubleclick := False;
    tmplaunchsize := ini_monkey.ReadInteger('LaunchBar', 'Dbl_Click_time', 0);
    if tmplaunchsize <> 0 then lbdblclickinterval := tmplaunchsize;
    if ini_monkey.ReadString('Desktop', 'Use', '') = 'True' then usedesktop := True;
    tmplaunchsize := ini_monkey.ReadInteger('Desktop', 'Icons_Size', 0);
    if tmplaunchsize <> 0 then desktopiconsize := tmplaunchsize;
    if ini_monkey.ReadString('Desktop', 'Use_Dbl_Click', '') = 'False' then dtusedoubleclick := False;
    tmplaunchsize := ini_monkey.ReadInteger('Desktop', 'Dbl_Click_time', 0);
    if tmplaunchsize <> 0 then dtdblclickinterval := tmplaunchsize;
    if ini_monkey.ReadString('Theme', 'Use_Theme', '') = 'True' then usetheme := True;
    tmpstr := '';
    tmpstr := ini_monkey.ReadString('Theme', 'Folder', '');
    if tmpstr <> '' then themefoldr := tmpstr;
    tmpstr := '';
    tmpstr := ini_monkey.ReadString('Colors', 'Background', '');
    if tmpstr <> '' then monkey_bg := tmpstr;
    tmpstr := '';
    tmpstr := ini_monkey.ReadString('Colors', 'Foreground', '');
    if tmpstr <> '' then monkey_fg := tmpstr;
    tmpstr := '';
    tmpstr := ini_monkey.ReadString('Colors', 'Border_Color', '');
    if tmpstr <> '' then monkey_bc := tmpstr;
    ini_monkey.Free;
  end;
end;

procedure setup_atoms_Monkey();
begin
  debug_Monkey('setup atoms');
  mo_wm_state := XInternAtom(dsply, 'WM_STATE', False);
  mo_mwm_wm_hints := XInternAtom(dsply, '_MOTIF_WM_HINTS', False);
  mo_wm_change_state := XInternAtom(dsply, 'WM_CHANGE_STATE', False);
  mo_wm_protos := XInternAtom(dsply, 'WM_PROTOCOLS', False);
  mo_wm_delete := XInternAtom(dsply, 'WM_DELETE_WINDOW', False);
end;

procedure colors_Monkey();
var
  dummy: TXColor;
begin
  debug_Monkey('alloc colors');
  XAllocNamedColor(dsply, DefaultColormap(dsply, scrn), PChar(mon_border), @border_col, @dummy);
  XAllocNamedColor(dsply, DefaultColormap(dsply, scrn), PChar(mon_text), @text_col, @dummy);
  XAllocNamedColor(dsply, DefaultColormap(dsply, scrn), PChar(mon_active), @active_col, @dummy);
  XAllocNamedColor(dsply, DefaultColormap(dsply, scrn), PChar(mon_inactive), @inactive_col, @dummy);
  XAllocNamedColor(dsply, DefaultColormap(dsply, scrn), PChar(mon_menu), @menu_col, @dummy);
end;

procedure load_font_Monkey();
begin
  debug_Monkey('getting pref_font');
  wmfont := XLoadQueryFont(dsply, pref_font);
  if wmfont = nil then
  begin
    debug_Monkey('pref_font failed! getting "fixed" font');
    wmfont := XLoadQueryFont(dsply, 'fixed');
      if wmfont = nil then
      begin
        writeln('Error: cannot load fonts. Quitting!');
        debug_Monkey('Error: cannot load fonts. Quitting!');
        halt(0);
      end;
  end;
  titlebarheight := barheight;
  wmfontheight := wmfont^.max_bounds.ascent + wmfont^.max_bounds.descent;
end;

procedure create_cursor_Monkey();
begin
  debug_Monkey('creating cursors');
  move_cursor := XCreateFontCursor(dsply, XC_fleur);
  resize_cursor := XCreateFontCursor(dsply, XC_plus);
  body_cursor := XCreateFontCursor(dsply, XC_X_cursor);
  window_cursor := XCreateFontCursor(dsply, XC_left_ptr);
end;

procedure root_window_Monkey();
var
  gv: TXGCValues;
  attr: TXSetWindowAttributes;
begin
  debug_Monkey('getting/setting root');
  rootwin := RootWindow(dsply, scrn);
  
  
  gv._function := GXcopy;
  gv.foreground := border_col.pixel;
  gv.line_width := 2;
  border_gc := XCreateGC(dsply, rootwin, GCFunction or GCForeground or GCLineWidth, @gv);

  gv.foreground := text_col.pixel;
  gv.line_width := 1;

  gv.font := wmfont^.fid;
  text_gc := XCreateGC(dsply, rootwin, GCFunction or GCForeground or GCFont, @gv);

  gv.foreground := active_col.pixel;
  active_gc := XCreateGC(dsply, rootwin, GCFunction or GCForeground, @gv);

  gv.foreground := inactive_col.pixel;
  inactive_gc := XCreateGC(dsply, rootwin, GCFunction or GCForeground, @gv);

  gv.foreground := menu_col.pixel;
  menu_gc := XCreateGC(dsply, rootwin, GCFunction or GCForeground, @gv);

  attr.event_mask := ExposureMask or childmask or buttonmask or PropertyChangeMask;
  XChangeWindowAttributes(dsply, rootwin, CWEventMask, @attr);

  XDefineCursor(dsply, rootwin, window_cursor);
end;

procedure client_init_Monkey();
begin
  debug_Monkey('initiate clients');
  client_number := 1;
  SetLength(wmClient, client_number);
  wmClient[0].window := 0;
  wmClient[0].parent := 0;
  wmClient[0].destroyed := True;
  handled_client := 0;
end;

procedure grab_keys_Monkey();
begin
  debug_Monkey('grab keys');
  XGrabKey(dsply, XKeysymToKeycode(dsply, XStringToKeysym(PChar(cycle_key))), Mod1Mask, rootwin, True, GrabModeAsync, GrabModeAsync);
  XGrabKey(dsply, XKeysymToKeycode(dsply, XStringToKeysym(PChar(close_key))), Mod1Mask, rootwin, True, GrabModeAsync, GrabModeAsync);
end;

procedure scan_tree_Monkey();
var
  i, numowindows: integer;
  dw1, dw2, winlist: PWindow;
begin
  debug_Monkey('querying xwindow tree');
  XGrabServer(dsply);

  XQueryTree(dsply, rootwin, @dw1, @dw2, @winlist, @numowindows);
  
  if not (numowindows = 0) then
  begin
    for i := 0 to numowindows - 1 do
    begin
      if (winlist[i] > 0) then
      begin
        create_new_client(winlist[i]);
      end;
    end;
  end;

  try
    XFree(winlist);
  except
  end;

  XUngrabServer(dsply);
end;

function DoPixmapActions(thefilname: string): PixmapStruct;
var
  tmpPixmapStruct: PixmapStruct;
begin
  imlib_context_set_drawable(rootwin);
  tmpPixmapStruct.iimage := Imlib_load_image(PChar(thefilname));
  imlib_context_set_image(tmpPixmapStruct.iimage);
  tmpPixmapStruct.iwidth := imlib_image_get_width;
  tmpPixmapStruct.iheight := imlib_image_get_height;
  if (tmpPixmapStruct.iwidth = 0) or (tmpPixmapStruct.iheight = 0) then
  begin
  usetheme := False;
  end
  else
  begin
  imlib_render_pixmaps_for_whole_image_at_size(@tmpPixmapStruct.ipixmap,
			  @tmpPixmapStruct.imask,
			  tmpPixmapStruct.iwidth, tmpPixmapStruct.iheight);
  imlib_context_set_image(tmpPixmapStruct.iimage);
  imlib_free_image;
  end;
  result := tmpPixmapStruct;
end;

procedure start_theme_Monkey();
var
  gv: TXGCValues;
begin
  debug_Monkey('start_theme_Monkey');
  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/titlebar-active.xpm') and (usetheme = True) then
  activebarpic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/titlebar-active.xpm');

  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/titlebar-inactive.xpm') and (usetheme = True) then
  inactivebarpic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/titlebar-inactive.xpm');

  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/close-active.xpm') and (usetheme = True) then
  activeclosepic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/close-active.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := activeclosepic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    actclospic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;

  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/close-inactive.xpm') and (usetheme = True) then
  inactiveclosepic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/close-inactive.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := inactiveclosepic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    inactclospic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;
  
  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/maximize-active.xpm') and (usetheme = True) then
  activemaxipic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/maximize-active.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := activemaxipic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    actmaxipic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;
  
  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/maximize-inactive.xpm') and (usetheme = True) then
  inactivemaxipic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/maximize-inactive.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := inactivemaxipic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    inactmaxipic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;
  
  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/hide-active.xpm') and (usetheme = True) then
  activeminipic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/hide-active.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := activeminipic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    actminipic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;
  
  if FileExists(wrkfoldr + '/themes/' + themefoldr + '/hide-inactive.xpm') and (usetheme = True) then
  inactiveminipic := DoPixmapActions(wrkfoldr + '/themes/' + themefoldr + '/hide-inactive.xpm');
  if (usetheme = True) then
  begin
    gv.clip_mask := inactiveminipic.imask;
    gv.clip_x_origin := 0;
    gv.clip_y_origin := 0;
    inactminipic_gc := XCreateGC(dsply, rootwin, GCClipMask or GCClipXOrigin or GCClipYOrigin, @gv);
  end;
  if (usetheme = True) then
  begin
    closepicleft := activeclosepic.iwidth;
    maxipicleft := activemaxipic.iwidth + 2 + closepicleft;
    minipicleft := activeminipic.iwidth + 2 + maxipicleft;
  end;
end;

function RunStartUpThreadApp(itemnum: pointer): longint;
var
  ffexec:string;
  itemmnum: integer;
begin
  itemmnum := longint(itemnum);
  if fileexists(tmpStartupList[itemmnum]) then
    ffexec := tmpStartupList[itemmnum]
  else
    ffexec := FileSearch(tmpStartupList[itemmnum], GetEnvironmentVariable('PATH'));
  if length(ffexec)<>0 then
  begin
    debug_Monkey('trying to autostartup: ' + ffexec);
    try
    ExecuteProcess(ffexec,[]);
    except
    end;
    exit;
  end;
end;


end.

