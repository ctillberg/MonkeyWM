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
unit wmnewclient;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, wmmisc, x, xlib, xutil, wmerrhandle, wmclientunit;

procedure create_new_client(gavewin: TWindow);
function add_client_entry(givenwin: TWindow): integer;

implementation

procedure create_new_client(gavewin: TWindow);
var
  attr: TXWindowAttributes;
  mwm_hints: PropMwmHints;
  items_read, items_left, real_format, zclient: integer;
  real_type: TAtom;
begin
debug_Monkey('new_client_process: window: ' + inttostr(gavewin));
  if (gavewin > 0) then
  begin
    XGetWindowAttributes(dsply, gavewin, @attr);
    if not (attr.override_redirect = True) then
    begin
      XSetErrorHandler(@error_handler_ignore);
      XGrabServer(dsply);
      zclient := add_client_entry(gavewin);
      wmClient[zclient].clrmap := attr.colormap;
      wmClient[zclient].window := gavewin;
      wmClient[zclient].x := attr.x;
      wmClient[zclient].y := attr.y;
      wmClient[zclient].width := attr.width;
      wmClient[zclient].height := attr.height;
      wmClient[zclient].normal_x := attr.x;
      wmClient[zclient].normal_y := attr.y;
      wmClient[zclient].normal_width := attr.width;
      wmClient[zclient].normal_height := attr.height;
      if not (XGetWindowProperty(dsply, wmClient[zclient].window, mo_mwm_wm_hints, 0, 20, False,
              mo_mwm_wm_hints, @real_type, @real_format, @items_read, @items_left, @mwm_hints) = None) then
      begin
        if ((mwm_hints.flags and MWM_HINTS_DECORATIONS) = 1) and not ((mwm_hints.decorations and MWM_DECOR_ALL) = 1) then
        begin
          if (mwm_hints.decorations and MWM_DECOR_BORDER or MWM_DECOR_TITLE) = 1 then
          begin
            wmClient[zclient].frame_state := frame_shown;
          end
          else
          begin
            wmClient[zclient].frame_state := frame_none;
          end;
        end;
        freeandnil(mwm_hints);
      end;
    if (attr.map_state = IsViewable) then
    begin
      Inc(wmClient[zclient].ignore_unmap);
    end
    else
    begin
      set_salue_hint(wmClient[zclient].window, mo_wm_state, NormalState);
    end;

      XSelectInput(dsply, wmClient[zclient].window, PropertyChangeMask or FocusChangeMask);
      frame_client(zclient);
      update_client(zclient, update_size);
      if not (get_value_hint(wmClient[zclient].window, mo_wm_state) = IconicState) then
      begin
        XMapWindow(dsply, wmClient[zclient].window);
        XMapWindow(dsply, wmClient[zclient].parent);
        wmClientList.Add(inttostr(zclient));
        wmTaskbarList.Add(inttostr(zclient));
        raise_client(zclient);
        XSetInputFocus(dsply, wmClient[zclient].window, RevertToNone, CurrentTime);
      end
      else
      begin
        if (attr.map_state = IsViewable)then
        begin
          wmClientList.Add(inttostr(zclient));
          wmTaskbarList.Add(inttostr(zclient));
          hide_client(zclient);
        end;
        XDefineCursor(dsply, wmClient[zclient].parent, body_cursor);
        XDefineCursor(dsply, wmClient[zclient].window, window_cursor);
      end;
    XUngrabServer(dsply);
    XSetErrorHandler(@error_handler);
    end;
  end;
end;

function add_client_entry(givenwin: TWindow): integer;
var
  tmpclinim: integer;
begin
if not (givenWin = 0) then
begin
  tmpclinim := client_number;
  Inc(client_number);
  SetLength(wmClient, client_number);
  wmClient[tmpclinim].window := givenwin;
  wmClient[tmpclinim].parent := 0;
  XGetTransientForHint(dsply, givenwin, @wmClient[tmpclinim].trans);
  wmClient[tmpclinim].closebox := 0;
  wmClient[tmpclinim].maxbox := 0;
  wmClient[tmpclinim].minbox := 0;
  wmClient[tmpclinim].iconbox := 0;
  wmClient[tmpclinim].stickybox := 0;
  XFetchName(dsply, givenwin, @wmClient[tmpclinim].name);
  wmClient[tmpclinim].desktop := current_desktop;
  wmClient[tmpclinim].sticky := 0;
  wmClient[tmpclinim].screen := scrn;
  wmClient[tmpclinim].frame_state := 0;
  wmClient[tmpclinim].deskthidden := False;
  wmClient[tmpclinim].size := XAllocSizeHints();
  wmClient[tmpclinim].ignore_unmap := 0;
  wmClient[tmpclinim].hidden := False;
  wmClient[tmpclinim].x := 0;
  wmClient[tmpclinim].y := 0;
  wmClient[tmpclinim].width := 0;
  wmClient[tmpclinim].height := 0;
  wmClient[tmpclinim].normal_x := 0;
  wmClient[tmpclinim].normal_y := 0;
  wmClient[tmpclinim].normal_width := 0;
  wmClient[tmpclinim].normal_height := 0;
  wmClient[tmpclinim].maximized := False;
  wmClient[tmpclinim].destroyed := False;
  debug_Monkey('add_client_entry: ' + inttostr(tmpclinim) + ') name is: ' + Trim(PChar(wmClient[tmpclinim].name)) + '. window is: ' + inttostr(wmClient[tmpclinim].window));
  debug_Monkey('add_client_entry: transient: ' + inttostr(wmClient[tmpclinim].trans));
  if not (wmClient[tmpclinim].trans = 0) then
  begin
    // do something soon
  end;
  result := tmpclinim;
end;
end;

end.

