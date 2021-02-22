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
unit wmlaunchbar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmmisc, wmglobals, x, xlib, shape, imlib2;

procedure startup_launchbar();
procedure redraw_launchbar();
procedure whiteout_launchbar_single(iconum: integer);
procedure redraw_launchbar_single(iconum: integer);
procedure ini_settings_launchbar();
function CreateNewWindow(x, y, width, height: integer): TWindow;
function isalaunchbarwindow(gavewindow: TWindow): integer;
procedure itemclick_launchbar(itemnum: integer);
function RunThreadApp(itemnum: pointer): longint;

implementation

procedure startup_launchbar();
var
  i, ileft, itop: integer;
begin
  debug_Monkey('startup_launchbar');
  ini_settings_launchbar();
  if uselaunchbar = True then
  begin
  
  launchbar_width := (launchiconsize + 2) * launchicocount;
  if (launchicocount > 0) then
  begin
    ileft := (max_width - launchbar_width) DIV 2;
    itop := max_height - launchiconsize;
    for i := 0 to launchicocount - 1 do
    begin
        if i = 0 then
          XMoveResizeWindow(dsply, wmlbItem[i].lbwindow, ileft, itop, launchiconsize, launchiconsize)
        else
          XMoveResizeWindow(dsply, wmlbItem[i].lbwindow, ileft + (i * (launchiconsize + 2)), itop, launchiconsize, launchiconsize);
        XMapWindow(dsply, wmlbItem[i].lbwindow);
    end;
    redraw_launchbar();
    end
    else
    begin
      launchbarwin := 0;
   end;
   end;
end;

procedure redraw_launchbar();
var
  i: integer;
  tmp_gc: TGC;
begin
  if (launchicocount > 0) then
  begin
    debug_Monkey('redraw_launchbar');
    for i := 0 to launchicocount - 1 do
    begin
        XRaiseWindow(dsply, wmlbItem[i].lbwindow);
        XClearWindow(dsply, wmlbItem[i].lbwindow);
        XShapeCombineMask(dsply, wmlbItem[i].lbwindow, ShapeBounding, 0, 0, wmlbItem[i].lbpicmask, ShapeSet);
        tmp_gc := XCreateGC(dsply, wmlbItem[i].lbwindow, 0, nil);
        XCopyArea(dsply, wmlbItem[i].lbpixmap, wmlbItem[i].lbwindow, tmp_gc, 0, 0, launchiconsize, launchiconsize,  0, 0);
        XFreeGC(dsply, tmp_gc);
    end;

  end;
end;

procedure whiteout_launchbar_single(iconum: integer);
var
  tmp_gc: TGC;
begin
  if (launchicocount > 0) then
  begin
    debug_Monkey('redraw_launchbar_single');
    if (wmlbItem[iconum].lbwindow <> 0) then
    begin
      XFillRectangle(dsply, wmlbItem[iconum].lbwindow, text_gc, 0, 0, launchiconsize, launchiconsize);
      XSync(dsply, false);
      Sleep(50);

        XRaiseWindow(dsply, wmlbItem[iconum].lbwindow);
        XClearWindow(dsply, wmlbItem[iconum].lbwindow);
        XShapeCombineMask(dsply, wmlbItem[iconum].lbwindow, ShapeBounding, 0, 0, wmlbItem[iconum].lbpicmask, ShapeSet);
        tmp_gc := XCreateGC(dsply, wmlbItem[iconum].lbwindow, 0, nil);
        XCopyArea(dsply, wmlbItem[iconum].lbpixmap, wmlbItem[iconum].lbwindow, tmp_gc, 0, 0, launchiconsize, launchiconsize,  0, 0);
        XFreeGC(dsply, tmp_gc);
    end;

  end;
end;

procedure redraw_launchbar_single(iconum: integer);
var
  tmp_gc: TGC;
begin
  if (launchicocount > 0) then
  begin
    debug_Monkey('redraw_launchbar_single');
    if (wmlbItem[iconum].lbwindow <> 0) then
    begin
        XRaiseWindow(dsply, wmlbItem[iconum].lbwindow);
        XClearWindow(dsply, wmlbItem[iconum].lbwindow);
        XShapeCombineMask(dsply, wmlbItem[iconum].lbwindow, ShapeBounding, 0, 0, wmlbItem[iconum].lbpicmask, ShapeSet);
        tmp_gc := XCreateGC(dsply, wmlbItem[iconum].lbwindow, 0, nil);
        XCopyArea(dsply, wmlbItem[iconum].lbpixmap, wmlbItem[iconum].lbwindow, tmp_gc, 0, 0, launchiconsize, launchiconsize,  0, 0);
        XFreeGC(dsply, tmp_gc);
    end;

  end;
end;

procedure ini_settings_launchbar();
var
  wmini, tmpstr: string;
  isgood: boolean;
  i, launchicos: integer;
  LaunchFile : TextFile;
  tmpLaunchList, tmpexecutelist: TStringList;
  tmp_gc: TGC;
begin
  debug_Monkey('getting launchbar ini settings');
  if FileExists(wrkfoldr + '/launchbar') then
  begin
    wmini := wrkfoldr + '/launchbar';
  end
  else
  begin
    debug_Monkey('launchbar ini file NOT FOUND!!');
  end;
  if (wmini <> '') then
  begin
    tmpLaunchList := TStringList.create;
    tmpexecutelist := TStringList.create;
    launchicos := 1;
    launchicocount := 0;
    Assign(LaunchFile, wmini);
    Reset(LaunchFile);
    While not Eof(LaunchFile) do
    begin
      ReadLn(LaunchFile, tmpstr);
      debug_Monkey('launchbar reading: ' + Trim(tmpstr));
      tmpLaunchList.Clear;
      if (Pos('#', Trim(tmpstr)) = 1) or (Pos('|', Trim(tmpstr)) = 0) then
      isgood := False
      else
      isgood := True;
      tmpLaunchList := Split(tmpstr, '|', tmpLaunchList);
      if tmpLaunchList.Count = 3 then
      begin
        for i := 0 to 2 do
        begin
          if (Trim(tmpLaunchList[i]) = '') then
          begin
            isgood := False;
            debug_Monkey('launchbar setting NOT GOOD!!: ' + Trim(tmpLaunchList[i]));
          end;
        end;
        if (isgood = True) then
        begin
          SetLength(wmlbItem, launchicos);
          wmlbItem[launchicos - 1].lbpicpath := Trim(tmpLaunchList[1]);
          wmlbItem[launchicos - 1].lbimage := Imlib_load_image(PChar(wmlbItem[launchicos - 1].lbpicpath));
          wmlbItem[launchicos - 1].lbpicwidth := launchiconsize;//tmppixstruc.iwidth;
          wmlbItem[launchicos - 1].lbpicheight := launchiconsize;//tmppixstruc.iheight;
          wmlbItem[launchicos - 1].lbname := Trim(tmpLaunchList[0]);
          debug_Monkey('launchbar execute: ' + Trim(tmpLaunchList[2]));
          debug_Monkey('launchbar execute Pos: ' + inttostr(Pos(' ', Trim(tmpLaunchList[2]))));
          if Pos(' ', Trim(tmpLaunchList[2])) = 0 then
          begin
            wmlbItem[launchicos - 1].lbexec := Trim(tmpLaunchList[2]);
            wmlbItem[launchicos - 1].lbargs := '';
          end
          else
          begin
            tmpexecutelist.Clear;
            tmpexecutelist := Split(Trim(tmpLaunchList[2]), ' ', tmpexecutelist);
            wmlbItem[launchicos - 1].lbexec := Trim(tmpexecutelist[0]);
            wmlbItem[launchicos - 1].lbargs := StringReplace(Trim(tmpLaunchList[2]), Trim(tmpexecutelist[0]) + ' ', '', [rfIgnoreCase]);
            debug_Monkey('launchbar split Arg: ' + wmlbItem[launchicos - 1].lbargs);
          end;
          if not (wmlbItem[launchicos - 1].lbpicpath = '') and not (wmlbItem[launchicos - 1].lbname = '')
          and not (wmlbItem[launchicos - 1].lbexec = '') and not (wmlbItem[launchicos - 1].lbpicwidth = 0)
           and not (wmlbItem[launchicos - 1].lbpicheight = 0) then
           begin
             Inc(launchicocount);
             wmlbItem[launchicos - 1].lbwindow := CreateNewWindow(max_width DIV 2, max_height - launchiconsize, launchiconsize, launchiconsize);
             debug_Monkey('Launchbar window for ' + wmlbItem[launchicos - 1].lbname + ' window: ' + inttostr(wmlbItem[launchicos - 1].lbwindow));
             imlib_context_set_image(wmlbItem[launchicos - 1].lbimage);
             imlib_context_set_drawable(wmlbItem[launchicos - 1].lbwindow);
             imlib_render_pixmaps_for_whole_image_at_size(@wmlbItem[launchicos - 1].lbpixmap,
			  @wmlbItem[launchicos - 1].lbpicmask,
			  wmlbItem[launchicos - 1].lbpicwidth, wmlbItem[launchicos - 1].lbpicheight);
             imlib_context_set_image(wmlbItem[launchicos - 1].lbimage);
             imlib_free_image;
             XShapeCombineMask(dsply, wmlbItem[launchicos - 1].lbwindow, ShapeBounding, 0, 0, wmlbItem[launchicos - 1].lbpicmask, ShapeSet);
             tmp_gc := XCreateGC(dsply, wmlbItem[launchicos - 1].lbwindow, 0, nil);
	     XCopyArea(dsply, wmlbItem[launchicos - 1].lbpixmap, wmlbItem[launchicos - 1].lbwindow, tmp_gc, 0,  0, wmlbItem[launchicos - 1].lbpicwidth, wmlbItem[launchicos - 1].lbpicheight, 0, 0);
	     XFreeGC(dsply, tmp_gc);
             Inc(launchicos);
           end;
         end;
      end;
    
    end;
    Close(LaunchFile);
    end
    else
    begin
      uselaunchbar := False;
    end;
end;


function CreateNewWindow(x, y, width, height: integer): TWindow;
var
  setAttr: TXSetWindowAttributes;
begin
  debug_Monkey('Launchbar CreateNewWindow');
  setAttr.override_redirect := True;
  setAttr.background_pixel := WhitePixel(dsply, scrn);
  setAttr.border_pixel := WhitePixel(dsply, scrn);
  setAttr.colormap := DefaultColormap(dsply, scrn);
  setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  buttonmask;
  result := XCreateWindow(dsply, rootwin, x, y, width,
            height, 0, CopyFromParent, InputOutput,
            DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWColormap or CWEventMask, @setAttr);
end;

function isalaunchbarwindow(gavewindow: TWindow): integer;
var
  i, tmpret: integer;
  found: boolean;
begin
  debug_Monkey('Launchbar isalaunchbarwindow');
  found := False;
  for i := 0 to launchicocount - 1 do
  begin
    if wmlbItem[i].lbwindow = gavewindow then
    begin
      tmpret := i;
      found := True;
      debug_Monkey('Launchbar isalaunchbarwindow FOUND: ' + inttostr(i));
      break;
    end;
  end;
  if found = False then
    result := (-1)
  else
    result := tmpret;
end;

procedure itemclick_launchbar(itemnum: integer);
begin
  debug_Monkey('itemclick_launchbar: name: ' + wmlbItem[itemnum].lbname);
  debug_Monkey('itemclick_launchbar: exec: ' + wmlbItem[itemnum].lbexec);
  if not (wmlbItem[itemnum].lbexec = '') then
  begin
    try
      BeginThread(@RunThreadApp, Pointer(itemnum));
    except
      debug_Monkey('itemclick_launchbar: ERROR! exec: ' + wmlbItem[itemnum].lbexec);
    end;
  end;
end;


function RunThreadApp(itemnum: pointer): longint;
var
  ffexec: string;
  itemmnum: integer;
  tmparguementlist: TStringList;
begin
  itemmnum := longint(itemnum);
  if fileexists(wmlbItem[itemmnum].lbexec) then
    ffexec := wmlbItem[itemmnum].lbexec
  else
    ffexec := FileSearch(wmlbItem[itemmnum].lbexec, GetEnvironmentVariable('PATH'));
      if length(ffexec)<>0 then
      begin
        if (wmlbItem[itemmnum].lbargs = '') then
        begin
          ExecuteProcess(ffexec,[]);
        end
        else
        begin
          if Pos(' ', wmlbItem[itemmnum].lbargs) = 0 then
          begin
          try
            ExecuteProcess(ffexec,[wmlbItem[itemmnum].lbargs]);
          except
          end;
          end
          else
          begin
            tmparguementlist := TStringList.create;
            tmparguementlist := Split(wmlbItem[itemmnum].lbargs, ' ', tmparguementlist);
            case (tmparguementlist.Count) of
            2:
            begin
            try
            ExecuteProcess(ffexec,[tmparguementlist[0],tmparguementlist[1]]);
            except
            end;
            end;
            3:
            begin
            try
            ExecuteProcess(ffexec,[tmparguementlist[0],tmparguementlist[1],tmparguementlist[2]]);
            except
            end;
            end;
            4:
            begin
            try
            ExecuteProcess(ffexec,[tmparguementlist[0],tmparguementlist[1],tmparguementlist[2],tmparguementlist[3]]);
            except
            end;
            end;
            5:
            begin
            try
            ExecuteProcess(ffexec,[tmparguementlist[0],tmparguementlist[1],tmparguementlist[2],tmparguementlist[3],tmparguementlist[4]]);
            except
            end;
            end;
            6:
            begin
            try
            ExecuteProcess(ffexec,[tmparguementlist[0],tmparguementlist[1],tmparguementlist[2],tmparguementlist[3],tmparguementlist[4],tmparguementlist[5]]);
            except
            end;
            end;
            end;
        end;
      end;
    end;
end;

end.

