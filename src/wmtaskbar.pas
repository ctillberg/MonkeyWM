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
unit wmtaskbar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, x, xlib, wmglobals, wmmisc;
  
procedure create_taskbar();
procedure redraw_taskbar();
procedure redraw_active_button(buttnwidth, buttnstart, clinum, offset: integer);
procedure redraw_inactive_button(buttnwidth, buttnstart, clinum, offset: integer);
procedure redraw_buttons();

implementation

procedure create_taskbar();
var
  setAttr: TXSetWindowAttributes;
begin
  wmTaskbarList := TStringList.create;
  setAttr.override_redirect := True;
  setAttr.background_pixel := menu_col.pixel;
  setAttr.border_pixel := border_col.pixel;
  setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  ButtonPressMask;
  taskbarwin := XCreateWindow(dsply, rootwin, 0, 0,
      max_width,  taskbarheight, 0, DefaultDepth(dsply, scrn),
	  CopyFromParent, DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);
// desktopbar
  desktopbar := XCreateWindow(dsply, taskbarwin, 1, 1,
      73,  taskbarheight - 2, 0, DefaultDepth(dsply, scrn),
	  CopyFromParent, DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);
  XMapWindow(dsply, desktopbar);
// buttonbar
  buttonbar := XCreateWindow(dsply, taskbarwin, 75, 1,
      max_width - 150,  taskbarheight - 2, 0, DefaultDepth(dsply, scrn),
	  CopyFromParent, DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);
  XMapWindow(dsply, buttonbar);
  
  debug_Monkey('create_taskbar: taskbarwin: ' + inttostr(taskbarwin));
  debug_Monkey('create_taskbar: desktopbar: ' + inttostr(desktopbar));
  debug_Monkey('create_taskbar: buttonbar: ' + inttostr(buttonbar));

  XMapWindow(dsply, taskbarwin);
  redraw_taskbar();
end;

procedure redraw_taskbar();
var
  k: integer;
begin
  XClearWindow(dsply, desktopbar);
  k := (titlebarheight - wmfontheight) DIV 2;
  XFillRectangle(dsply, desktopbar, border_gc, 0, 0, 73, taskbarheight - 2);
  XDrawString(dsply, desktopbar, text_gc, 4, wmfont^.ascent + k, PChar('Desk ' + inttostr(current_desktop)), Length(PChar('Desk ' + inttostr(current_desktop))));
  XDrawString(dsply, desktopbar, text_gc, 60, wmfont^.ascent + k, PChar('>'), Length(PChar('>')));
  XDrawString(dsply, desktopbar, text_gc, 51, wmfont^.ascent + k, PChar('<'), Length(PChar('<')));
  redraw_buttons();
end;

procedure redraw_active_button(buttnwidth, buttnstart, clinum, offset: integer);
var
  tmpname: string;
  tmppixmap: TPixmap;
  tmp_gc: TGC;
  j: integer;
begin
debug_Monkey('redraw_active_button: tmpname: ' + tmpname);
debug_Monkey('redraw_active_button: buttnwidth: ' + inttostr(buttnwidth));
debug_Monkey('redraw_active_button: buttnstart: ' + inttostr(buttnstart));
debug_Monkey('redraw_active_button: clinum: ' + inttostr(clinum));
debug_Monkey('redraw_active_button: offset: ' + inttostr(offset));
if (usetheme = True) and (buttnwidth > activebarpic.iwidth) and (activebarpic.iwidth <> 0) then
begin
  tmppixmap := XCreatePixmap(dsply, rootwin, buttnwidth, taskbarheight, DefaultDepth(dsply, scrn));
  for j := 0 to (buttnwidth DIV activebarpic.iwidth) do
  begin
    tmp_gc := XCreateGC(dsply, tmppixmap, 0, nil);
    //debug_Monkey('redraw_active_button: XCopyArea loop');
    XCopyArea(dsply, activebarpic.ipixmap, tmppixmap, tmp_gc, 0,  0, activebarpic.iwidth, activebarpic.iheight, activebarpic.iwidth * j, 0);
    XFreeGC(dsply, tmp_gc);
  end;
  if not (wmClient[clinum].name = '') then
  begin
    tmpname := SetStringLength(wmClient[clinum].name, buttnwidth - 12);
    debug_Monkey('redraw_active_button: tmpname: ' + tmpname);
    XDrawString(dsply, tmppixmap, border_gc, 6, wmfont^.ascent + offset, PChar(tmpname), Length(tmpname));
    //XDrawString(dsply, buttonbar, border_gc, button_startx + 6, wmfont^.ascent + k, wmClient[tmpnum].name, Length(wmClient[tmpnum].name));
  end;
  tmp_gc := XCreateGC(dsply, buttonbar, 0, nil);
  debug_Monkey('redraw_active_button: XCopyArea to bar');
  XCopyArea(dsply, tmppixmap, buttonbar, tmp_gc, 0,  0, buttnwidth, taskbarheight, buttnstart, 0);
  XFreeGC(dsply, tmp_gc);
  XFreePixmap(dsply, tmppixmap);
end
else
begin
  XFillRectangle(dsply, buttonbar, active_gc, buttnstart, 0, buttnwidth, taskbarheight - 2);
  if not (wmClient[clinum].name = '') then
  begin
  tmpname := SetStringLength(wmClient[clinum].name, buttnwidth - 12);
  debug_Monkey('redraw_active_button no theme: tmpname: ' + tmpname);
  XDrawString(dsply, buttonbar, border_gc, buttnstart + 6, wmfont^.ascent + offset, PChar(tmpname), Length(tmpname));
  //XDrawString(dsply, buttonbar, border_gc, button_startx + 6, wmfont^.ascent + k, wmClient[tmpnum].name, Length(wmClient[tmpnum].name));
  end;
end;
end;

procedure redraw_inactive_button(buttnwidth, buttnstart, clinum, offset: integer);
var
  tmpname: string;
  tmppixmap: TPixmap;
  tmp_gc: TGC;
  j: integer;
begin
if (usetheme = True) and (buttnwidth > inactivebarpic.iwidth) and (inactivebarpic.iwidth <> 0) then
begin
  tmppixmap := XCreatePixmap(dsply, rootwin, buttnwidth, taskbarheight, DefaultDepth(dsply, scrn));
  for j := 0 to (buttnwidth DIV activebarpic.iwidth) do
  begin
    tmp_gc := XCreateGC(dsply, tmppixmap, 0, nil);
    //debug_Monkey('redraw_inactive_button: XCopyArea loop');
    XCopyArea(dsply, inactivebarpic.ipixmap, tmppixmap, tmp_gc, 0,  0, inactivebarpic.iwidth, inactivebarpic.iheight, inactivebarpic.iwidth * j, 0);
    XFreeGC(dsply, tmp_gc);
  end;
  if not (wmClient[clinum].name = '') then
  begin
    tmpname := SetStringLength(wmClient[clinum].name, buttnwidth - 12);
    debug_Monkey('redraw_inactive_button: tmpname: ' + tmpname);
    XDrawString(dsply, tmppixmap, border_gc, 6, wmfont^.ascent + offset, PChar(tmpname), Length(tmpname));
    //XDrawString(dsply, buttonbar, border_gc, button_startx + 6, wmfont^.ascent + k, wmClient[tmpnum].name, Length(wmClient[tmpnum].name));
  end;
  tmp_gc := XCreateGC(dsply, buttonbar, 0, nil);
  debug_Monkey('redraw_inactive_button: XCopyArea to bar');
  XCopyArea(dsply, tmppixmap, buttonbar, tmp_gc, 0,  0, buttnwidth, taskbarheight, buttnstart, 0);
  XFreeGC(dsply, tmp_gc);
  XFreePixmap(dsply, tmppixmap);
end
else
begin
  XFillRectangle(dsply, buttonbar, inactive_gc, buttnstart, 0, buttnwidth, taskbarheight - 2);
  if not (wmClient[clinum].name = '') then
  begin
  tmpname := SetStringLength(wmClient[clinum].name, buttnwidth - 12);
  debug_Monkey('redraw_inactive_button no theme: tmpname: ' + tmpname);
  XDrawString(dsply, buttonbar, border_gc, buttnstart + 6, wmfont^.ascent + offset, PChar(tmpname), Length(tmpname));
  //XDrawString(dsply, buttonbar, border_gc, button_startx + 6, wmfont^.ascent + k, wmClient[tmpnum].name, Length(wmClient[tmpnum].name));
  end;
end;
end;

procedure redraw_buttons();
var
  c, k, button_iwidth, button_startx, tmpnum, button_width, i, j: integer;
  tmpname: string;
begin
  XClearWindow(dsply, buttonbar);
  if wmTaskbarList.Count > 0 then
  begin
    wmTaskbarTempList.Clear;
    for c := 0 to wmTaskbarList.Count - 1 do
    begin
      tmpnum := strtoint(wmTaskbarList[c]);
      if (wmClient[tmpnum].desktop = current_desktop) then wmTaskbarTempList.Add(wmTaskbarList[c]);
    end;
    if wmTaskbarTempList.Count > 0 then
    begin
    button_width := (max_width - 150) DIV wmTaskbarTempList.Count;
    k := (titlebarheight - wmfontheight) DIV 2;

    for c := 0 to wmTaskbarTempList.Count - 1 do
    begin
      button_startx := c * button_width;
      button_iwidth := ((c + 1) * button_width) - button_startx;
      tmpnum := strtoint(wmTaskbarTempList[c]);
        if not (button_startx = 0) then
        begin
          XDrawLine(dsply, buttonbar, border_gc, button_startx - 1, 0, button_startx - 1, taskbarheight);
        end;
          if (tmpnum = focused_client) then
          begin
            redraw_active_button(button_width, button_startx, tmpnum, k);
          end
          else
          begin
            redraw_inactive_button(button_width, button_startx, tmpnum, k);
          end;
        end;
      end;
    end;
end;


end.

