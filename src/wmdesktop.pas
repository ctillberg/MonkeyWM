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
unit wmdesktop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmmisc, wmglobals, x, xlib, shape, imlib2;

procedure startup_desktop();
procedure redraw_desktop();
procedure organize_desktop();
procedure redraw_desktop_single(iconum: integer; gavewin: TWindow);
procedure whiteout_desktop_single(iconum: integer);
procedure move_desktop_single(iconum: integer);
procedure ini_settings_desktop();
function dtCreateNewWindow(x, y, width, height: integer): TWindow;
function isadesktopwindow(gavewindow: TWindow): integer;
procedure itemclick_desktop(itemnum: integer);
function dtRunThreadApp(itemnum: pointer): longint;
procedure save_desktop_setting();

implementation

procedure startup_desktop();
var
  i, ileft, itop: integer;
begin
  debug_Monkey('startup_desktop');
  ini_settings_desktop();
  if usedesktop = True then
  begin
  wmdtItemmove.dtismove := False;
  wmdtItemmove.dtitemmove := 0;
  wmdtItemmove.dtdidmove := False;
  if (desktopicocount > 0) then
  begin
    for i := 0 to desktopicocount - 1 do
    begin
      if (wmdtItem[i].dtpicwidth > wmdtItem[i].dtcaptionwidth) then
      begin
        ileft := wmdtItem[i].dtxpos + ((wmdtItem[i].dtpicwidth - wmdtItem[i].dtcaptionwidth) DIV 2);
      end
      else
      begin
        ileft := wmdtItem[i].dtxpos - ((wmdtItem[i].dtcaptionwidth - wmdtItem[i].dtpicwidth) DIV 2);
      end;
      itop := wmdtItem[i].dtypos + wmdtItem[i].dtpicheight + 2;
      XMoveResizeWindow(dsply, wmdtItem[i].dtwindow, wmdtItem[i].dtxpos, wmdtItem[i].dtypos, wmdtItem[i].dtpicwidth, wmdtItem[i].dtpicheight);
      XMoveResizeWindow(dsply, wmdtItem[i].dtcaptionwindow, ileft, itop, wmdtItem[i].dtcaptionwidth, wmdtItem[i].dtcaptionheight);
      XMapWindow(dsply, wmdtItem[i].dtwindow);
      XMapWindow(dsply, wmdtItem[i].dtcaptionwindow);
    end;
    redraw_desktop();
   end;
   end;
end;

procedure redraw_desktop();
var
  i: integer;
  tmp_gc: TGC;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('redraw_desktop');
    for i := 0 to desktopicocount - 1 do
    begin
        XLowerWindow(dsply, wmdtItem[i].dtwindow);
        XClearWindow(dsply, wmdtItem[i].dtwindow);
        XShapeCombineMask(dsply, wmdtItem[i].dtwindow, ShapeBounding, 0, 0, wmdtItem[i].dtpicmask, ShapeSet);
        tmp_gc := XCreateGC(dsply, wmdtItem[i].dtwindow, 0, nil);
        XCopyArea(dsply, wmdtItem[i].dtpixmap, wmdtItem[i].dtwindow, tmp_gc, 0, 0, wmdtItem[i].dtpicwidth, wmdtItem[i].dtpicheight,  0, 0);
        XFreeGC(dsply, tmp_gc);
        XLowerWindow(dsply, wmdtItem[i].dtcaptionwindow);
        XClearWindow(dsply, wmdtItem[i].dtcaptionwindow);
        XFillRectangle(dsply, wmdtItem[i].dtcaptionwindow, border_gc, 0, 0, wmdtItem[i].dtcaptionwidth, wmdtItem[i].dtcaptionheight);
        XDrawString(dsply, wmdtItem[i].dtcaptionwindow, text_gc, 4, wmfont^.ascent + 2, PChar(wmdtItem[i].dtname), Length(PChar(wmdtItem[i].dtname)));
    end;

  end;
end;

procedure organize_desktop();
var
  i, ileft, itop, defleft, deftop, tmpnum: integer;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('organize_desktop');
    defleft := 20;
    deftop := 50;
    for i := 0 to desktopicocount - 1 do
    begin
      wmdtItem[i].dtxpos := defleft;
      wmdtItem[i].dtypos := deftop;
      if (wmdtItem[i].dtpicwidth > wmdtItem[i].dtcaptionwidth) then
      begin
        ileft := wmdtItem[i].dtxpos + ((wmdtItem[i].dtpicwidth - wmdtItem[i].dtcaptionwidth) DIV 2);
      end
      else
      begin
        ileft := wmdtItem[i].dtxpos - ((wmdtItem[i].dtcaptionwidth - wmdtItem[i].dtpicwidth) DIV 2);
      end;
      itop := wmdtItem[i].dtypos + wmdtItem[i].dtpicheight + 2;
      XMoveResizeWindow(dsply, wmdtItem[i].dtwindow, wmdtItem[i].dtxpos, wmdtItem[i].dtypos, wmdtItem[i].dtpicwidth, wmdtItem[i].dtpicheight);
      XMoveResizeWindow(dsply, wmdtItem[i].dtcaptionwindow, ileft, itop, wmdtItem[i].dtcaptionwidth, wmdtItem[i].dtcaptionheight);
      deftop := deftop + wmdtItem[i].dtpicheight + 2 + wmdtItem[i].dtcaptionheight + 20;
      tmpnum := deftop + wmdtItem[i].dtpicheight + 2 + wmdtItem[i].dtcaptionheight + 50;
      if (tmpnum > max_height + 50) then
      begin
        defleft := defleft + 20 + wmdtItem[i].dtpicwidth;
        deftop := 50;
      end;
    end;
    save_desktop_setting();
  end;
end;

procedure move_desktop_single(iconum: integer);
var
  ileft, itop: integer;
  tmp_gc: TGC;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('move_desktop_single');
    wmdtItemmove.dtdidmove := True;
      if (wmdtItem[iconum].dtpicwidth > wmdtItem[iconum].dtcaptionwidth) then
      begin
        ileft := wmdtItem[iconum].dtxpos + ((wmdtItem[iconum].dtpicwidth - wmdtItem[iconum].dtcaptionwidth) DIV 2);
      end
      else
      begin
        ileft := wmdtItem[iconum].dtxpos - ((wmdtItem[iconum].dtcaptionwidth - wmdtItem[iconum].dtpicwidth) DIV 2);
      end;
      itop := wmdtItem[iconum].dtypos + wmdtItem[iconum].dtpicheight + 2;
      XMoveResizeWindow(dsply, wmdtItem[iconum].dtwindow, wmdtItem[iconum].dtxpos, wmdtItem[iconum].dtypos, wmdtItem[iconum].dtpicwidth, wmdtItem[iconum].dtpicheight);
      XMoveResizeWindow(dsply, wmdtItem[iconum].dtcaptionwindow, ileft, itop, wmdtItem[iconum].dtcaptionwidth, wmdtItem[iconum].dtcaptionheight);
      XLowerWindow(dsply, wmdtItem[iconum].dtwindow);
      XClearWindow(dsply, wmdtItem[iconum].dtwindow);
      XShapeCombineMask(dsply, wmdtItem[iconum].dtwindow, ShapeBounding, 0, 0, wmdtItem[iconum].dtpicmask, ShapeSet);
      tmp_gc := XCreateGC(dsply, wmdtItem[iconum].dtwindow, 0, nil);
      XCopyArea(dsply, wmdtItem[iconum].dtpixmap, wmdtItem[iconum].dtwindow, tmp_gc, 0, 0, wmdtItem[iconum].dtpicwidth, wmdtItem[iconum].dtpicheight,  0, 0);
      XFreeGC(dsply, tmp_gc);
      XLowerWindow(dsply, wmdtItem[iconum].dtcaptionwindow);
      XClearWindow(dsply, wmdtItem[iconum].dtcaptionwindow);
      XFillRectangle(dsply, wmdtItem[iconum].dtcaptionwindow, border_gc, 0, 0, wmdtItem[iconum].dtcaptionwidth, wmdtItem[iconum].dtcaptionheight);
      XDrawString(dsply, wmdtItem[iconum].dtcaptionwindow, text_gc, 4, wmfont^.ascent + 2, PChar(wmdtItem[iconum].dtname), Length(PChar(wmdtItem[iconum].dtname)));

  end;
end;

procedure whiteout_desktop_single(iconum: integer);
var
  i: integer;
  tmp_gc: TGC;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('whiteout_desktop_single');
    XFillRectangle(dsply, wmdtItem[iconum].dtwindow, text_gc, 0, 0, wmdtItem[iconum].dtpicwidth, wmdtItem[iconum].dtpicheight);
    XSync(dsply, false);
    Sleep(50);
    XClearWindow(dsply, wmdtItem[iconum].dtwindow);
    XShapeCombineMask(dsply, wmdtItem[iconum].dtwindow, ShapeBounding, 0, 0, wmdtItem[iconum].dtpicmask, ShapeSet);
    tmp_gc := XCreateGC(dsply, wmdtItem[iconum].dtwindow, 0, nil);
    XCopyArea(dsply, wmdtItem[iconum].dtpixmap, wmdtItem[iconum].dtwindow, tmp_gc, 0, 0, wmdtItem[iconum].dtpicwidth, wmdtItem[iconum].dtpicheight,  0, 0);
    XFreeGC(dsply, tmp_gc);
  end;
end;

procedure redraw_desktop_single(iconum: integer; gavewin: TWindow);
var
  i: integer;
  tmp_gc: TGC;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('redraw_desktop_single');
    if (gavewin = wmdtItem[iconum].dtwindow) then
    begin
        //XLowerWindow(dsply, wmdtItem[i].dtwindow);
        XClearWindow(dsply, wmdtItem[iconum].dtwindow);
        XShapeCombineMask(dsply, wmdtItem[iconum].dtwindow, ShapeBounding, 0, 0, wmdtItem[iconum].dtpicmask, ShapeSet);
        tmp_gc := XCreateGC(dsply, wmdtItem[iconum].dtwindow, 0, nil);
        XCopyArea(dsply, wmdtItem[iconum].dtpixmap, wmdtItem[iconum].dtwindow, tmp_gc, 0, 0, wmdtItem[iconum].dtpicwidth, wmdtItem[iconum].dtpicheight,  0, 0);
        XFreeGC(dsply, tmp_gc);
    end;
    if (gavewin = wmdtItem[iconum].dtcaptionwindow) then
    begin
        //XLowerWindow(dsply, wmdtItem[i].dtcaptionwindow);
        XClearWindow(dsply, wmdtItem[iconum].dtcaptionwindow);
        XFillRectangle(dsply, wmdtItem[iconum].dtcaptionwindow, border_gc, 0, 0, wmdtItem[iconum].dtcaptionwidth, wmdtItem[iconum].dtcaptionheight);
        XDrawString(dsply, wmdtItem[iconum].dtcaptionwindow, text_gc, 4, wmfont^.ascent + 2, PChar(wmdtItem[iconum].dtname), Length(PChar(wmdtItem[iconum].dtname)));
    end;

  end;
end;

procedure ini_settings_desktop();
var
  wmini, tmpstr: string;
  isgood: boolean;
  i, launchicos, tmpwide, tmphigh, ileft, itop: integer;
  LaunchFile : TextFile;
  tmpLaunchList, tmpexecutelist: TStringList;
  tmp_gc: TGC;
begin
  debug_Monkey('getting desktop ini settings');
  if FileExists(wrkfoldr + '/desktop') then
  begin
    wmini := wrkfoldr + '/desktop';
  end
  else
  begin
    debug_Monkey('desktop ini file NOT FOUND!!');
  end;
  if (wmini <> '') then
  begin
    tmpLaunchList := TStringList.create;
    tmpexecutelist := TStringList.create;
    launchicos := 1;
    desktopicocount := 0;
    Assign(LaunchFile, wmini);
    Reset(LaunchFile);
    While not Eof(LaunchFile) do
    begin
      ReadLn(LaunchFile, tmpstr);
      debug_Monkey('desktop reading: ' + Trim(tmpstr));
      tmpLaunchList.Clear;
      if (Pos('#', Trim(tmpstr)) = 1) or (Pos('|', Trim(tmpstr)) = 0) then
      isgood := False
      else
      isgood := True;
      tmpLaunchList := Split(tmpstr, '|', tmpLaunchList);
      if tmpLaunchList.Count = 5 then
      begin
        for i := 0 to 4 do
        begin
          if (Trim(tmpLaunchList[i]) = '') then
          begin
            isgood := False;
            debug_Monkey('desktop setting NOT GOOD!!: ' + Trim(tmpLaunchList[i]));
          end;
        end;
        if (isgood = True) then
        begin
          SetLength(wmdtItem, launchicos);
          wmdtItem[launchicos - 1].dtpicpath := Trim(tmpLaunchList[1]);
          wmdtItem[launchicos - 1].dtimage := Imlib_load_image(PChar(wmdtItem[launchicos - 1].dtpicpath));
          wmdtItem[launchicos - 1].dtpicwidth := desktopiconsize;//tmppixstruc.iwidth;
          wmdtItem[launchicos - 1].dtpicheight := desktopiconsize;//tmppixstruc.iheight;
          wmdtItem[launchicos - 1].dtxpos := strtoint(Trim(tmpLaunchList[3]));
          wmdtItem[launchicos - 1].dtypos := strtoint(Trim(tmpLaunchList[4]));
          wmdtItem[launchicos - 1].dtname := Trim(tmpLaunchList[0]);
          debug_Monkey('launchbar execute: ' + Trim(tmpLaunchList[2]));
          debug_Monkey('launchbar execute Pos: ' + inttostr(Pos(' ', Trim(tmpLaunchList[2]))));
          if Pos(' ', Trim(tmpLaunchList[2])) = 0 then
          begin
            wmdtItem[launchicos - 1].dtexec := Trim(tmpLaunchList[2]);
            wmdtItem[launchicos - 1].dtargs := '';
          end
          else
          begin
            tmpexecutelist.Clear;
            tmpexecutelist := Split(Trim(tmpLaunchList[2]), ' ', tmpexecutelist);
            wmdtItem[launchicos - 1].dtexec := Trim(tmpexecutelist[0]);
            wmdtItem[launchicos - 1].dtargs := StringReplace(Trim(tmpLaunchList[2]), Trim(tmpexecutelist[0]) + ' ', '', [rfIgnoreCase]);
            debug_Monkey('launchbar split Arg: ' + wmdtItem[launchicos - 1].dtargs);
          end;
          if not (wmdtItem[launchicos - 1].dtpicpath = '') and not (wmdtItem[launchicos - 1].dtname = '')
          and not (wmdtItem[launchicos - 1].dtexec = '') and not (wmdtItem[launchicos - 1].dtpicwidth = 0)
           and not (wmdtItem[launchicos - 1].dtpicheight = 0) then
           begin
             Inc(desktopicocount);
             wmdtItem[launchicos - 1].dtwindow := dtCreateNewWindow(wmdtItem[launchicos - 1].dtxpos, wmdtItem[launchicos - 1].dtypos, wmdtItem[launchicos - 1].dtpicwidth, wmdtItem[launchicos - 1].dtpicheight);
             debug_Monkey('Desktop window for ' + wmdtItem[launchicos - 1].dtname + ' window: ' + inttostr(wmdtItem[launchicos - 1].dtwindow));
             imlib_context_set_image(wmdtItem[launchicos - 1].dtimage);
             imlib_context_set_drawable(wmdtItem[launchicos - 1].dtwindow);
             imlib_render_pixmaps_for_whole_image_at_size(@wmdtItem[launchicos - 1].dtpixmap,
			  @wmdtItem[launchicos - 1].dtpicmask,
			  wmdtItem[launchicos - 1].dtpicwidth, wmdtItem[launchicos - 1].dtpicheight);
             imlib_context_set_image(wmdtItem[launchicos - 1].dtimage);
             imlib_free_image;
             XShapeCombineMask(dsply, wmdtItem[launchicos - 1].dtwindow, ShapeBounding, 0, 0, wmdtItem[launchicos - 1].dtpicmask, ShapeSet);
             tmp_gc := XCreateGC(dsply, wmdtItem[launchicos - 1].dtwindow, 0, nil);
	     XCopyArea(dsply, wmdtItem[launchicos - 1].dtpixmap, wmdtItem[launchicos - 1].dtwindow, tmp_gc, 0,  0, wmdtItem[launchicos - 1].dtpicwidth, wmdtItem[launchicos - 1].dtpicheight, 0, 0);
	     XFreeGC(dsply, tmp_gc);
             wmdtItem[launchicos - 1].dtcaptionwidth := 8 + XTextWidth(wmfont, PChar(wmdtItem[launchicos - 1].dtname), Length(wmdtItem[launchicos - 1].dtname));
             wmdtItem[launchicos - 1].dtcaptionheight := wmfontheight + 4;
             if (wmdtItem[launchicos - 1].dtpicwidth > wmdtItem[launchicos - 1].dtcaptionwidth) then
             begin
               ileft := wmdtItem[launchicos - 1].dtxpos + ((wmdtItem[launchicos - 1].dtpicwidth - wmdtItem[launchicos - 1].dtcaptionwidth) DIV 2);
             end
             else
             begin
               ileft := wmdtItem[launchicos - 1].dtxpos - ((wmdtItem[launchicos - 1].dtcaptionwidth - wmdtItem[launchicos - 1].dtpicwidth) DIV 2);
             end;
             itop := wmdtItem[launchicos - 1].dtypos + wmdtItem[launchicos - 1].dtpicheight + 2;
             wmdtItem[launchicos - 1].dtcaptionwindow := dtCreateNewWindow(ileft, itop, wmdtItem[launchicos - 1].dtcaptionwidth, wmdtItem[launchicos - 1].dtcaptionheight);
             debug_Monkey('Desktop window for ' + wmdtItem[launchicos - 1].dtname + ' window: ' + inttostr(wmdtItem[launchicos - 1].dtwindow));
             XFillRectangle(dsply, wmdtItem[launchicos - 1].dtcaptionwindow, border_gc, 0, 0, wmdtItem[launchicos - 1].dtpicwidth, wmdtItem[launchicos - 1].dtpicheight);
             XDrawString(dsply, wmdtItem[launchicos - 1].dtcaptionwindow, text_gc, 4, wmfont^.ascent + 2, PChar(wmdtItem[launchicos - 1].dtname), Length(PChar(wmdtItem[launchicos - 1].dtname)));
             Inc(launchicos);
           end;
         end;
      end;

    end;
    Close(LaunchFile);
    end
    else
    begin
      usedesktop := False;
    end;
end;


function dtCreateNewWindow(x, y, width, height: integer): TWindow;
var
  setAttr: TXSetWindowAttributes;
begin
  debug_Monkey('Desktop CreateNewWindow');
  setAttr.override_redirect := True;
  setAttr.background_pixel := WhitePixel(dsply, scrn);
  setAttr.border_pixel := WhitePixel(dsply, scrn);
  setAttr.colormap := DefaultColormap(dsply, scrn);
  setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  buttonmask;
  result := XCreateWindow(dsply, rootwin, x, y, width,
            height, 0, CopyFromParent, InputOutput,
            DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWColormap or CWEventMask, @setAttr);
end;

function isadesktopwindow(gavewindow: TWindow): integer;
var
  i, tmpret: integer;
  found: boolean;
begin
  debug_Monkey('Desktop isalaunchbarwindow');
  found := False;
  for i := 0 to desktopicocount - 1 do
  begin
    if wmdtItem[i].dtwindow = gavewindow then
    begin
      tmpret := i;
      found := True;
      debug_Monkey('Launchbar isalaunchbarwindow FOUND: ' + inttostr(i));
      break;
    end;
    if wmdtItem[i].dtcaptionwindow = gavewindow then
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

procedure itemclick_desktop(itemnum: integer);
begin
  debug_Monkey('itemclick_desktop: name: ' + wmdtItem[itemnum].dtname);
  debug_Monkey('itemclick_desktop: exec: ' + wmdtItem[itemnum].dtexec);
  if not (wmdtItem[itemnum].dtexec = '') then
  begin
    try
      BeginThread(@dtRunThreadApp, Pointer(itemnum));
    except
      debug_Monkey('itemclick_desktop: ERROR! exec: ' + wmdtItem[itemnum].dtexec);
    end;
  end;
end;


function dtRunThreadApp(itemnum: pointer): longint;
var
  ffexec, tmmpargline:string;
  itemmnum, i: integer;
  tmparguementlist: TStringList;
begin
  itemmnum := longint(itemnum);
  if fileexists(wmdtItem[itemmnum].dtexec) then
    ffexec := wmdtItem[itemmnum].dtexec
  else
    ffexec := FileSearch(wmdtItem[itemmnum].dtexec, GetEnvironmentVariable('PATH'));
      if length(ffexec)<>0 then
      begin
        if (wmdtItem[itemmnum].dtargs = '') then
        begin
          ExecuteProcess(ffexec,[]);
        end
        else
        begin
          if Pos(' ', wmdtItem[itemmnum].dtargs) = 0 then
          begin
          try
            ExecuteProcess(ffexec,[wmdtItem[itemmnum].dtargs]);
          except
          end;
          end
          else
          begin
            tmparguementlist := TStringList.create;
            tmparguementlist := Split(wmdtItem[itemmnum].dtargs, ' ', tmparguementlist);
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

procedure save_desktop_setting();
var
  i: integer;
  tmpsavedesktop: TStringList;
  tmpsvaeline: string;
begin
  if (desktopicocount > 0) then
  begin
    debug_Monkey('save_desktop_setting');
    wmdtItemmove.dtdidmove := False;
    tmpsavedesktop := TStringList.create;
    for i := 0 to desktopicocount - 1 do
    begin
      tmpsvaeline := '';
      tmpsvaeline := wmdtItem[i].dtname + '|' + wmdtItem[i].dtpicpath + '|' + wmdtItem[i].dtexec;
      if not (wmdtItem[i].dtargs = '') then tmpsvaeline := tmpsvaeline + ' ' + wmdtItem[i].dtargs;
      tmpsvaeline := tmpsvaeline + '|' + inttostr(wmdtItem[i].dtxpos) + '|' + inttostr(wmdtItem[i].dtypos);
      
      tmpsavedesktop.Add(tmpsvaeline);
    end;
   tmpsavedesktop.SaveToFile(wrkfoldr + '/desktop');
  end;
end;

end.

