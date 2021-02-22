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
unit wmmainmenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, x, xlib, wmmisc, wmdesktop, imlib2;

procedure create_mainmenu(clickx, clicky: integer);
procedure kill_mainmenu;
procedure itemclick_mainmenu(itemnum: integer);
function MenuRunThreadApp(itemnum: pointer): longint;

implementation

procedure create_mainmenu(clickx, clicky: integer);
var
  setAttr: TXSetWindowAttributes;
  i, k, nwinx, nwiny, nwinwidth, nwinhigh, tmpwide: integer;
  tmpLaunchhList, wmTempMainMenuList, wmTempMainMenuActionList: TStringList;
  tmpimage: Imlib_Image;
  tmppix, tmpmask: TPixmap;
  gv: TXGCValues;
begin
  if FileExists(wrkfoldr + '/menu') then
  begin
  wmMainMenuList.Clear;
  wmTempMainMenuList := TStringList.create;
  wmTempMainMenuActionList := TStringList.create;
  tmpLaunchhList := TStringList.create;
  wmTempMainMenuList.LoadFromFile(wrkfoldr + '/menu');
  wmTempMainMenuList.Add('Align Icons|/usr/share/monkeywm/icons/48x48/apps/iconthemes.png|Align_Icons');
  nwinx := clickx;
  nwiny := clicky;
  //nwinwidth := 100;
  nwinwidth := 10;
  for i := 0 to wmTempMainMenuList.Count - 1 do
  begin
    if (Pos('#', Trim(wmTempMainMenuList[i])) = 1) or (Pos('|', Trim(wmTempMainMenuList[i])) = 0) then
    begin
      //Not good
    end
    else
    begin
      tmpLaunchhList.Clear;
      tmpLaunchhList := Split(Trim(wmTempMainMenuList[i]), '|', tmpLaunchhList);
      if tmpLaunchhList.Count = 3 then
      begin
        tmpwide := XTextWidth(wmfont, PChar(tmpLaunchhList[0]), Length(tmpLaunchhList[0]));
        if tmpwide + 22 > nwinwidth then nwinwidth := tmpwide + 22;
        wmMainMenuList.Add(tmpLaunchhList[2]);
        wmTempMainMenuActionList.Add(tmpLaunchhList[0] + '|' + tmpLaunchhList[1]);
      end;
    end;
  end;

  debug_Monkey('create_mainmenu: nwinwidth: ' + inttostr(nwinwidth));
  nwinhigh := wmMainMenuList.Count * 20;
  if (nwinx + nwinwidth) > max_width then nwinx := max_width - (nwinwidth + 10);
  if (nwiny + nwinhigh) > max_height then nwiny := max_height - (nwinhigh + 10);
  setAttr.override_redirect := True;
  setAttr.background_pixel := border_col.pixel;
  setAttr.border_pixel := active_col.pixel;
  setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  buttonmask;
  mainmenuwin := XCreateWindow(dsply, rootwin, nwinx, nwiny,
      nwinwidth,  nwinhigh, 1, DefaultDepth(dsply, scrn),
	  CopyFromParent, DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);

  debug_Monkey('create_mainmenu: mainmenuwin: ' + inttostr(mainmenuwin));

  XMapWindow(dsply, mainmenuwin);
  k := (20 - wmfontheight) DIV 2;
  gv.clip_x_origin := 2;
  gv.clip_y_origin := 0;
  mainmenu_gc := XCreateGC(dsply, mainmenuwin, GCClipXOrigin or GCClipYOrigin, @gv);
  for i := 0 to wmTempMainMenuActionList.Count - 1 do
  begin
    tmpLaunchhList.Clear;
    tmpLaunchhList := Split(Trim(wmTempMainMenuActionList[i]), '|', tmpLaunchhList);
    tmpimage := Imlib_load_image(PChar(tmpLaunchhList[1]));
    imlib_context_set_image(tmpimage);
    imlib_context_set_drawable(mainmenuwin);
    imlib_render_pixmaps_for_whole_image_at_size(@tmppix,
			  @tmpmask,
			  14, 14);
    gv.clip_mask := tmpmask;
    gv.clip_y_origin := (i * 20) + 2;
    XChangeGC(dsply, mainmenu_gc, GCClipMask or GCClipYOrigin, @gv);
    XCopyArea(dsply, tmppix, mainmenuwin, mainmenu_gc, 0, 0, 14, 14,  2, (i * 20) + 2);
    XDrawString(dsply, mainmenuwin, text_gc, 18, (i * 20) + wmfont^.ascent + k, Pchar(tmpLaunchhList[0]), Length(tmpLaunchhList[0]));
  end;
  end;
end;

procedure kill_mainmenu;
begin
  XMapWindow(dsply, mainmenuwin);
  XDestroyWindow(dsply, mainmenuwin);
  mainmenuwin := 0;
end;

procedure itemclick_mainmenu(itemnum: integer);
begin
  debug_Monkey('itemclick_mainmenu: exec: ' + wmMainMenuList[itemnum]);
  if mainmenuwin <> 0 then kill_mainmenu;
  if (itemnum = wmMainMenuList.Count - 1) then
  begin
    organize_desktop();
  end
  else
  begin
  if not (wmMainMenuList[itemnum] = '') then
  begin
    try
      BeginThread(@MenuRunThreadApp, Pointer(itemnum));
    except
      debug_Monkey('itemclick_mainmenu: ERROR! exec: ' + wmMainMenuList[itemnum]);
    end;
  end;
  end;
end;

function MenuRunThreadApp(itemnum: pointer): longint;
var
  ffexec:string;
  itemmnum: integer;
begin
  itemmnum := longint(itemnum);
  if fileexists(wmMainMenuList[itemmnum]) then
    ffexec := wmMainMenuList[itemmnum]
  else
    ffexec := FileSearch(wmMainMenuList[itemmnum], GetEnvironmentVariable('PATH'));
      if length(ffexec)<>0 then
      begin
        ExecuteProcess(ffexec,[]);
        exit;
      end;
end;

end.

