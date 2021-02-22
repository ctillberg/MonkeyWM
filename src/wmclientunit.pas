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
unit wmclientunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, x, xlib, xutil, wmmisc, wmerrhandle, wmtaskbar, wmlaunchbar;
  
procedure frame_client(xclient: integer);
procedure update_client(xclient, updatewhat: integer);
procedure set_salue_hint(gavewin: TWindow; gaveatom: TAtom; value: integer);
function get_value_hint(gavewin: TWindow; gaveatom: TAtom): integer;
procedure send_config(xclient: integer);
procedure raise_client(xclient: integer);
procedure unhide_client(xclient: integer);
procedure hide_client(xclient: integer);
function get_client(gavewin: TWindow; window_who: integer): integer;
procedure maximize_client(xclient: integer);
procedure unmaximize_client(xclient: integer);
procedure maximize_switch_client(xclient: integer);
procedure send_exit_client(xclient: integer);
function send_client_message(gavewin: TWindow; xatom: TAtom; value: integer): integer;
procedure move_client(xclient: integer);
procedure resize_client(xclient: integer);
procedure remove_parent(xclient, mapagain: integer);
procedure redraw_parent(xclient: integer; const level: integer = 0);
procedure draw_hide_pixmap(c: integer; level: integer);
procedure draw_maximize_pixmap(c: integer; level: integer);
procedure draw_close_pixmap(c: integer; level: integer);
procedure draw_hide_button(c: integer; detail_gc, background_gc: TGC);
procedure draw_maximize_button(c: integer; detail_gc, background_gc: TGC);
procedure draw_close_button(c: integer; detail_gc, background_gc: TGC);
function get_focused_client(): integer;
function client_has_trans(gavewin: TWindow): integer;
procedure raise_transients(xclient: integer);
procedure focus_clients();

implementation

procedure frame_client(xclient: integer);
var
  setAttr: TXSetWindowAttributes;
begin
  if not (wmClient[xclient].window = 0) then
  begin
    setAttr.override_redirect := True;
    setAttr.background_pixel := menu_col.pixel;
    setAttr.border_pixel := border_col.pixel;
    setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  buttonmask;

    wmClient[xclient].parent := XCreateWindow(dsply, rootwin, wmClient[xclient].x, wmClient[xclient].y,
      wmClient[xclient].width + 2,  wmClient[xclient].height + titlebarheight + 3, 0, DefaultDepth(dsply, scrn),
	  CopyFromParent, DefaultVisual(dsply, scrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);
    debug_Monkey('frame_client: window: ' + inttostr(wmClient[xclient].window) + ' parent: ' + inttostr(wmClient[xclient].parent));
    
    XAddToSaveSet(dsply, wmClient[xclient].window);
    XSetWindowBorderWidth(dsply, wmClient[xclient].window, 0);
    if (wmClient[xclient].frame_state = frame_hidden) then
    begin
      XReparentWindow(dsply, wmClient[xclient].window, wmClient[xclient].parent, 1, 1);
    end
    else
    begin
      XReparentWindow(dsply, wmClient[xclient].window, wmClient[xclient].parent, 1, titlebarheight);
    end;
  end;
end;

procedure update_client(xclient, updatewhat: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('update_client: window: ' + inttostr(wmClient[xclient].window) + ' updatewhat: ' + inttostr(updatewhat));
    if (updatewhat = update_size) or (updatewhat = update_position) then
    begin
      if (wmClient[xclient].frame_state = frame_shown) then
      begin
        if (wmClient[xclient].x < taskbarheight) then wmClient[xclient].x := 1;
        if (wmClient[xclient].y < (taskbarheight + titlebarheight + 1)) then
          wmClient[xclient].y := titlebarheight + taskbarheight + 1;
        if (wmClient[xclient].x > max_width) then wmClient[xclient].x := max_width - titlebarheight;
        if (wmClient[xclient].y > max_height) then wmClient[xclient].y := max_height - titlebarheight;
        XMoveResizeWindow(dsply, wmClient[xclient].parent, wmClient[xclient].x - 1, wmClient[xclient].y - titlebarheight - 1, wmClient[xclient].width + 2, wmClient[xclient].height + titlebarheight + 2);
        if not (updatewhat = update_position) then
        begin
        XMoveResizeWindow(dsply, wmClient[xclient].window, 1, titlebarheight, wmClient[xclient].width, wmClient[xclient].height);
        end;
      end
      else
      begin
        if (wmClient[xclient].x < taskbarheight) then wmClient[xclient].x := 1;
        if (wmClient[xclient].y < taskbarheight + 1) then wmClient[xclient].y := taskbarheight + 1;
        if (wmClient[xclient].x > max_width) then wmClient[xclient].x := max_width - titlebarheight;
        if (wmClient[xclient].y > max_height) then wmClient[xclient].y := max_height - titlebarheight;
          XMoveResizeWindow(dsply, wmClient[xclient].parent, wmClient[xclient].x - 1, wmClient[xclient].y - 1, wmClient[xclient].width + 2, wmClient[xclient].height + 2);
        if not (updatewhat = update_position) then
          XMoveResizeWindow(dsply, wmClient[xclient].window, 1, 1, wmClient[xclient].width, wmClient[xclient].height);
      end;
    end;
    send_config(xclient);
    XSync(dsply, false);
  end;
end;

procedure set_salue_hint(gavewin: TWindow; gaveatom: TAtom; value: integer);
var
  data: array[0..2] of integer;
begin
  if not (gavewin = 0) then
  begin
    debug_Monkey('set_salue_hint: window: ' + inttostr(gavewin) + ' value: ' + inttostr(value));
    data[0] := value;
    data[1] := None;
    XChangeProperty(dsply, gavewin, gaveatom, gaveatom, 32, PropModeReplace, @data, 2);
  end;
end;

function get_value_hint(gavewin: TWindow; gaveatom: TAtom): integer;
var
  real_type: TAtom;
  real_format, read_items, items_left, value: integer;
  data: array [0..255] of integer;
begin
value := 0;
  if not (gavewin = 0) then
  begin
    debug_Monkey('get_value_hint: window: ' + inttostr(gavewin));
    if (XGetWindowProperty(dsply, gavewin, gaveatom, 0, 2, False, gaveatom, @real_type,
                        @real_format, @read_items, @items_left, @data) = Success) then
    begin
      if (read_items = 1) and (real_format = 32) then
      begin
      debug_Monkey('get_value_hint: window: ' + inttostr(gavewin) + ' value: ' + inttostr(data[0]));
      value := data[0];
      end;
    end;
  end;
result := value;
end;

procedure send_config(xclient: integer);
var
  xcevent: TXConfigureEvent;
begin
  debug_Monkey('send_config: window: ' + inttostr(wmClient[xclient].window));
  xcevent._type := ConfigureNotify;
  xcevent.event := wmClient[xclient].window;
  xcevent.window := wmClient[xclient].window;
  xcevent.x := wmClient[xclient].x;
  xcevent.y := wmClient[xclient].y;
  xcevent.width := wmClient[xclient].width;
  xcevent.height := wmClient[xclient].height;
  xcevent.border_width := 0;
  xcevent.above := None;
  xcevent.override_redirect := False;
  XSendEvent(dsply, wmClient[xclient].window, False, StructureNotifyMask, @xcevent);
end;

procedure raise_client(xclient: integer);
var
  tmpindx: integer;
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('raise_client: window: ' + inttostr(wmClient[xclient].window));
    unhide_client(xclient);
    tmpindx := wmClientList.IndexOf(inttostr(xclient));
    if (wmClientList.Count > 1) and (tmpindx > 0) then
      wmClientList.Move(tmpindx, 0);
      raise_transients(xclient);
    focus_clients();
  end;
end;

procedure unhide_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('unhide_client: window: ' + inttostr(wmClient[xclient].window));
    set_salue_hint(wmClient[xclient].window, mo_wm_state, NormalState);
    wmClient[xclient].hidden := False;
    XMapWindow(dsply, wmClient[xclient].window);
    XMapWindow(dsply, wmClient[xclient].parent);
    focus_clients();
  end;
end;

procedure hide_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('hide_client: window: ' + inttostr(wmClient[xclient].window));
    Inc(wmClient[xclient].ignore_unmap);
    wmClient[xclient].hidden := True;
    XUnmapWindow(dsply, wmClient[xclient].parent);
    XUnmapWindow(dsply, wmClient[xclient].window);
    set_salue_hint(wmClient[xclient].window, mo_wm_state, IconicState);
    focus_clients();
  end;
end;

function get_client(gavewin: TWindow; window_who: integer): integer;
var
  i, found, tmpnum: integer;
  whut: string;
begin
  found := 0;
  if (gavewin > 0) then
  begin
    if (window_who = parent_window) then whut := 'parent_window';
    if (window_who = any_window) then whut := 'any_window';
    if (window_who = child_window) then whut := 'child_window';
    debug_Monkey('get_client window: ' + inttostr(gavewin) + ' searching: ' + whut);
    for i := 0 to wmClientList.Count - 1 do
    begin
      tmpnum := strtoint(wmClientList[i]);
      if (window_who = any_window) or (window_who = child_window) then
      begin
        if (gavewin = wmClient[tmpnum].window) then
        begin
          debug_Monkey('get_client window: ' + inttostr(gavewin) + ' searching: ' + whut + ' FOUND! window');
          found := 1;
          result := tmpnum;
          break;
        end;
      end;
      if (window_who = any_window) or (window_who = parent_window) then
      begin
        if (gavewin = wmClient[tmpnum].parent) then
        begin
          debug_Monkey('get_client window: ' + inttostr(gavewin) + ' searching: ' + whut + ' FOUND! parent');
          found := 1;
          result := tmpnum;
          break;
        end;
      end;
    end;
  end;
  if (found = 0) then
  begin
    debug_Monkey('get_client window: ' + inttostr(gavewin) + ' searching: ' + whut + ' NOT FOUND!');
    for i := 0 to wmClientList.Count - 1 do
    begin
      tmpnum := strtoint(wmClientList[i]);
      if (gavewin = wmClient[tmpnum].parent) then
      begin
        debug_Monkey('get_client window: ' + inttostr(gavewin) + ' searching: ' + whut + ' FOUND! in loop');
        if (wmClient[tmpnum].window = 0) then XDestroyWindow(dsply, wmClient[tmpnum].parent);
      end;
    end;
  end;
if found = 0 then result := 0;
end;

procedure maximize_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('maximize_client window: ' + inttostr(wmClient[xclient].window));
    if (wmClient[xclient].maximized = False) then
    begin
      wmClient[xclient].normal_x := wmClient[xclient].x;
      wmClient[xclient].normal_y := wmClient[xclient].y;
      wmClient[xclient].normal_width := wmClient[xclient].width;
      wmClient[xclient].normal_height := wmClient[xclient].height;
      wmClient[xclient].maximized := True;
    end;

    wmClient[xclient].x := 1;
    wmClient[xclient].width := max_width - 2;

    if not (wmClient[xclient].frame_state = frame_shown) then
    begin
      wmClient[xclient].y := 1;
      wmClient[xclient].height := max_height;
    end
    else
    begin
      wmClient[xclient].y := titlebarheight;
      if uselaunchbar = True then
      wmClient[xclient].height := max_height - titlebarheight - taskbarheight - launchiconsize - 2
      else
      wmClient[xclient].height := max_height - titlebarheight - taskbarheight - 2;
    end;

    if (wmClient[xclient].size^.flags and PMaxSize) = 1 then
    begin
      if (wmClient[xclient].width > wmClient[xclient].size^.max_width) then
        wmClient[xclient].width := wmClient[xclient].size^.max_width;
      if (wmClient[xclient].height > wmClient[xclient].size^.max_height) then
        wmClient[xclient].height := wmClient[xclient].size^.max_height;
    end;

    update_client(xclient, update_size);
  end;
end;

procedure unmaximize_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('unmaximize_client window: ' + inttostr(wmClient[xclient].window));
    if (wmClient[xclient].maximized = True) then
    begin
      wmClient[xclient].x := wmClient[xclient].normal_x;
      wmClient[xclient].y := wmClient[xclient].normal_y;
      wmClient[xclient].width := wmClient[xclient].normal_width;
      wmClient[xclient].height := wmClient[xclient].normal_height;
      wmClient[xclient].maximized := False;
      update_client(xclient, update_size);
    end;
  end;
end;

procedure maximize_switch_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('maximize_switch_client window: ' + inttostr(wmClient[xclient].window));
    if (wmClient[xclient].maximized = True) then
    begin
      unmaximize_client(xclient);
    end
    else if (wmClient[xclient].maximized = False) then
    begin
      maximize_client(xclient);
    end;
  end;
end;

procedure send_exit_client(xclient: integer);
var
  count, maxcount, found, tmpnum, tmppnum: integer;
  protocols: PAtom;
begin
  found := 0;
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('send_exit_client window: ' + inttostr(wmClient[xclient].window));
    if not (XGetWMProtocols(dsply, wmClient[xclient].window, @protocols, @maxcount) = 0) then
    begin
     for count := 0 to maxcount - 1 do
     begin
       if (protocols[count] = mo_wm_delete) then
       begin
         found := 1;
         break;
       end;
     end;
    try
      XFree(protocols);
    except
    end;
  end;
    if (found = 1) then
    begin
      send_client_message(wmClient[xclient].window, mo_wm_protos, mo_wm_delete);
      exit;
    end
    else
    begin
      XSync(dsply, false);
      XDestroyWindow(dsply, wmClient[xclient].window);
      wmClient[xclient].destroyed := True;
      wmClient[xclient].window := 0;
      tmpnum := wmClientList.IndexOf(inttostr(xclient));
      wmClientList.Delete(tmpnum);
      tmppnum := wmTaskbarList.IndexOf(inttostr(xclient));
      wmTaskbarList.Delete(tmppnum);
      focus_clients();
    end;
  end;
end;

function send_client_message(gavewin: TWindow; xatom: TAtom; value: integer): integer;
var
  event: TXEvent;
begin
  debug_Monkey('send_client_message window: ' + inttostr(gavewin));
  event._type := ClientMessage;
  event.xclient.window := gavewin;
  event.xclient.message_type := xatom;
  event.xclient.format := 32;
  event.xclient.data.l[0] := value;
  event.xclient.data.l[1] := CurrentTime;
  result := XSendEvent(dsply, gavewin, False, NoEventMask, @event);
end;

procedure move_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('move_client window: ' + inttostr(wmClient[xclient].window));
    pointer_mode := POINTERMOVEMODE;
    XGrabPointer(dsply, wmClient[xclient].parent, False, PointerMotionMask or ButtonReleaseMask, GrabModeAsync, GrabModeAsync, None, move_cursor, CurrentTime);
    handled_client := xclient;
  end;
end;

procedure resize_client(xclient: integer);
begin
  if not (wmClient[xclient].window = 0) then
  begin
    debug_Monkey('resize_client window: ' + inttostr(wmClient[xclient].window));
    pointer_mode := POINTERRESIZEMODE;
    XGrabPointer(dsply, wmClient[xclient].parent, False, PointerMotionMask or ButtonReleaseMask, GrabModeAsync, GrabModeAsync, None, resize_cursor, CurrentTime);
    handled_client := xclient;
  end;
end;

procedure remove_parent(xclient, mapagain: integer);
var
  tmpnum, tmppnum: integer;
begin
  if not (xclient = 0) then
  begin
    debug_Monkey('remove_parent window: ' + inttostr(wmClient[xclient].window));
    XSync(dsply,false);
    XSetErrorHandler(@error_handler_ignore);
    XGrabServer(dsply);
    XRemoveFromSaveSet(dsply, wmClient[xclient].window);
    if (wmClient[xclient].frame_state = frame_shown) then
    begin
      XReparentWindow(dsply, wmClient[xclient].window, rootwin, wmClient[xclient].x, wmClient[xclient].y);
      wmClient[xclient].destroyed := True;
      wmClient[xclient].window := 0;
    end;
    if (mapAgain = 1) then
    begin
      XMapWindow(dsply, wmClient[xclient].window);
    end
    else
    begin
      set_salue_hint(wmClient[xclient].window, mo_wm_state, WithdrawnState);
    end;
    XDestroyWindow(dsply, wmClient[xclient].parent);
    XUngrabServer(dsply);
    XSync(dsply, false);
    tmpnum := wmClientList.IndexOf(inttostr(xclient));
    wmClientList.Delete(tmpnum);
    tmppnum := wmTaskbarList.IndexOf(inttostr(xclient));
    wmTaskbarList.Delete(tmppnum);
    focus_clients();
    XSetErrorHandler(@error_handler);
  end;
end;

procedure redraw_parent(xclient: integer; const level: integer = 0);
var
  k: integer;
begin
  XClearWindow(dsply, wmClient[xclient].parent);
  if (wmClient[xclient].frame_state = frame_shown) and not (wmClient[xclient].window = 0) then
  begin
    k := (titlebarheight - wmfontheight) DIV 2;
    XDrawLine(dsply, wmClient[xclient].parent, border_gc, 1, titlebarheight - 1, wmClient[xclient].width + 1, titlebarheight - 1);
    if (wmClientList.IndexOf(inttostr(xclient)) = 0) or (level = 1) then
    begin
      if (usetheme = True) then
      begin
        XSetWindowBackgroundPixmap(dsply, wmClient[xclient].parent, activebarpic.ipixmap);
      end
      else
      begin
        XFillRectangle(dsply, wmClient[xclient].parent, active_gc, 1, 1, wmClient[xclient].width, titlebarheight - 2);
      end;
      if (wmClient[xclient].name <> '') then
      begin
        XDrawString(dsply, wmClient[xclient].parent, border_gc, 4, wmfont^.ascent + k, wmClient[xclient].name, Length(wmClient[xclient].name));
      end;
      if (usetheme = True) then
      begin
        draw_close_pixmap(xclient, 1);
        draw_maximize_pixmap(xclient, 1);
        draw_hide_pixmap(xclient, 1);
      end
      else
      begin
        draw_hide_button(xclient, border_gc, active_gc);
        draw_maximize_button(xclient, border_gc, active_gc);
        draw_close_button(xclient, border_gc, active_gc);
      end;
    end
    else
    begin
      if (usetheme = True) then
      begin
        XSetWindowBackgroundPixmap(dsply, wmClient[xclient].parent, inactivebarpic.ipixmap);
      end
      else
      begin
        XFillRectangle(dsply, wmClient[xclient].parent, inactive_gc, 1, 1, wmClient[xclient].width, titlebarheight - 2);
      end;
      if (wmClient[xclient].name <> '') then
      begin
        XDrawString(dsply, wmClient[xclient].parent, border_gc, 4, wmfont^.ascent + k, wmClient[xclient].name, Length(wmClient[xclient].name));
      end;
      if (usetheme = True) then
      begin
        draw_close_pixmap(xclient, 0);
        draw_maximize_pixmap(xclient, 0);
        draw_hide_pixmap(xclient, 0);
      end
      else
      begin
        draw_hide_button(xclient, border_gc, inactive_gc);
        draw_maximize_button(xclient, border_gc, inactive_gc);
        draw_close_button(xclient, border_gc, inactive_gc);
      end;
    end;
  XSync(dsply, false);
  end;
end;

procedure draw_hide_pixmap(c: integer; level: integer);
var
  gv: TXGCValues;
  jx, jy: integer;
begin
  jx := wmClient[c].width - minipicleft;
  jy := (titlebarheight - activeminipic.iheight) DIV 2;
  gv.clip_x_origin := jx;
  gv.clip_y_origin := jy;
  if (level = 1) then
  begin
    XChangeGC(dsply, actminipic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, activeminipic.ipixmap, wmClient[c].parent, actminipic_gc, 0, 0, activeminipic.iwidth, activeminipic.iheight,  jx, jy);
  end
  else
  begin
    XChangeGC(dsply, inactminipic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, inactiveminipic.ipixmap, wmClient[c].parent, inactminipic_gc, 0, 0, inactiveminipic.iwidth, inactiveminipic.iheight,  jx, jy);
  end;
end;

procedure draw_maximize_pixmap(c: integer; level: integer);
var
  gv: TXGCValues;
  jx, jy: integer;
begin
  jx := wmClient[c].width - maxipicleft;
  jy := (titlebarheight - activemaxipic.iheight) DIV 2;
  gv.clip_x_origin := jx;
  gv.clip_y_origin := jy;
  if (level = 1) then
  begin
    XChangeGC(dsply, actmaxipic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, activemaxipic.ipixmap, wmClient[c].parent, actmaxipic_gc, 0, 0, activemaxipic.iwidth, activemaxipic.iheight,  jx, jy);
  end
  else
  begin
    XChangeGC(dsply, inactmaxipic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, inactivemaxipic.ipixmap, wmClient[c].parent, inactmaxipic_gc, 0, 0, inactivemaxipic.iwidth, inactivemaxipic.iheight,  jx, jy);
  end;
end;

procedure draw_close_pixmap(c: integer; level: integer);
var
  gv: TXGCValues;
  jx, jy: integer;
begin
  jx := wmClient[c].width - closepicleft;
  jy := (titlebarheight - activeclosepic.iheight) DIV 2;
  gv.clip_x_origin := jx;
  gv.clip_y_origin := jy;
  if (level = 1) then
  begin
    XChangeGC(dsply, actclospic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, activeclosepic.ipixmap, wmClient[c].parent, actclospic_gc, 0, 0, activeclosepic.iwidth, activeclosepic.iheight,  jx, jy);
  end
  else
  begin
    XChangeGC(dsply, inactclospic_gc, GCClipXOrigin or GCClipYOrigin, @gv);
    XCopyArea(dsply, inactiveclosepic.ipixmap, wmClient[c].parent, inactclospic_gc, 0, 0, inactiveclosepic.iwidth, inactiveclosepic.iheight,  jx, jy);
  end;
end;

procedure draw_hide_button(c: integer; detail_gc, background_gc: TGC);
var
  x: integer;
begin
  x := wmClient[c].width - ((titlebarheight - 2) * 3);
  XFillRectangle(dsply, wmClient[c].parent, background_gc, x + 2, 2, titlebarheight - 4, titlebarheight - 4);

  XDrawRectangle(dsply, wmClient[c].parent, detail_gc, x + 4, titlebarheight - 8, titlebarheight - 9, 2);
end;

procedure draw_maximize_button(c: integer; detail_gc, background_gc: TGC);
var
  x: integer;
begin
  x := wmClient[c].width - ((titlebarheight - 2) * 2);
  XFillRectangle(dsply, wmClient[c].parent, background_gc, x + 2, 2, titlebarheight - 4, titlebarheight - 4);

  XDrawRectangle(dsply, wmClient[c].parent, detail_gc, x + 4, 4, titlebarheight - 9, titlebarheight - 9);
  XDrawRectangle(dsply, wmClient[c].parent, detail_gc, x + 5, titlebarheight - 10, 4, 4);
end;

procedure draw_close_button(c: integer; detail_gc, background_gc: TGC);
var
  x: integer;
begin
  x := wmClient[c].width - (titlebarheight - 2);
  XFillRectangle(dsply, wmClient[c].parent, background_gc, x + 2, 2, titlebarheight - 4, titlebarheight - 4);

  XDrawLine(dsply, wmClient[c].parent, detail_gc, x + 4, 4, x + titlebarheight - 4, titlebarheight - 4);
  XDrawLine(dsply, wmClient[c].parent, detail_gc, x + 4, titlebarheight - 4, x + titlebarheight - 4, 4);
end;

function get_focused_client(): integer;
var
  focused_window: TWindow;
  dummy_int, found, zclient: integer;
begin
  found := 0;
  XGetInputFocus(dsply, @focused_window, @dummy_int);

  if not (focused_window = 0) then
  begin
    if not (focused_window = rootwin) then
    begin
      zclient := get_client(focused_window, any_window);
      if (wmClient[zclient].window > 0) then
      begin
        if not (focused_window = wmClient[zclient].window) then
        begin
          XSetInputFocus(dsply, wmClient[zclient].window, RevertToNone, CurrentTime);
        end;
        found := 1;
        result := zclient;
      end;
    end;
  end;
if found = 0 then result := 0;
end;

function client_has_trans(gavewin: TWindow): integer;
var
  i, found, tmpnum: integer;
begin
  found := 0;
  if (gavewin > 0) then
  begin
    debug_Monkey('client_has_trans window: ' + inttostr(gavewin));
    for i := 0 to wmClientList.Count - 1 do
    begin
      tmpnum := strtoint(wmClientList[i]);
      if (gavewin = wmClient[tmpnum].trans) then
      begin
        debug_Monkey('client_has_trans found!');
        found := 1;
        result := tmpnum;
        break;
      end;
    end;
  end;
if found = 0 then result := 0;
end;

procedure raise_transients(xclient: integer);
var
  i, tmpnum: integer;
begin
  debug_Monkey('raise_transients');
  if wmClientList.Count >= 1 then
  begin
    for i := 0 to wmClientList.Count - 1 do
    begin
      tmpnum := strtoint(wmClientList[i]);
      if (wmClient[tmpnum].trans = wmClient[xclient].window) then
      begin
        wmClientList.Move(i, 0);
      end;
    end;
  end;
end;

procedure focus_clients();
var
  i, tmpnum, found: integer;
begin
  debug_Monkey('focus_clients');
  found := 0;
  if wmClientList.Count >= 1 then
  begin
    for i := 0 to wmClientList.Count - 1 do
    begin
      tmpnum := strtoint(wmClientList[i]);
      if (wmClient[tmpnum].hidden = False) then
      begin
        if (wmClient[tmpnum].desktop = current_desktop) then
        begin
        if wmClient[tmpnum].deskthidden = True then XMapWindow(dsply, wmClient[tmpnum].parent);
          if (found = 0) then
          begin
            found := 1;
            XRaiseWindow(dsply, wmClient[tmpnum].parent);
            XSetInputFocus(dsply, wmClient[tmpnum].window, RevertToNone, CurrentTime);
            focused_client := tmpnum;
            redraw_parent(tmpnum, 1);
          end
          else
          begin
            redraw_parent(tmpnum);
          end;
        end
        else
        begin
          wmClient[tmpnum].deskthidden := True;
          XUnmapWindow(dsply, wmClient[tmpnum].parent);
        end;
      end;
    end;
  end;
  redraw_taskbar();
  redraw_launchbar();
end;


end.

