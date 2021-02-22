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
unit wmeventhandler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, wmmisc, wmclientunit, wmnewclient, x,
  xlib, xutil, xatom, wmerrhandle, wmtaskbar, wmlaunchbar, wmmainmenu,
  wmdesktop;

procedure hbutton_pressed_event(event: TXButtonEvent);
procedure hbutton_pressed_event_root(event: TXButtonEvent);
procedure hbutton_release_event(event: TXButtonEvent);
procedure hmouse_motion_event(event: TXMotionEvent);
procedure henter_event(event: TXCrossingEvent);
procedure hconfigure_request(event: TXConfigureRequestEvent);
procedure hmap_request(event: TXMapRequestEvent);
procedure hunmap_event(event: TXMapRequestEvent);
procedure hclient_message(event: TXClientMessageEvent);
procedure hproperty_change(event: TXPropertyEvent);
procedure hexpose_event(event: TXExposeEvent);
procedure hreparent_event(event: TXReparentEvent);
procedure hdestroy_notify(event: TXDestroyWindowEvent);
procedure hkey_event(event: TXKeyEvent);
procedure desktopbar_buttonsclick(event: TXButtonEvent);
procedure buttonbar_buttonsclick(event: TXButtonEvent);
procedure launchbar_buttonsclick(event: TXButtonEvent);
procedure desktop_buttonsclick(event: TXButtonEvent);
procedure mainpopwin_buttonsclick(event: TXButtonEvent);

implementation

procedure hbutton_pressed_event(event: TXButtonEvent);
var
  clicked_item, zclient, tmpnum: integer;
begin
 while (XCheckTypedEvent(dsply, ButtonPress, @event)) = True do
 begin { Something? } end;

   debug_Monkey('hbutton_pressed_event event.window: ' + inttostr(event.window));
   XAllowEvents(dsply, ReplayPointer, CurrentTime);
  if (event.window = rootwin) then
  begin
    hbutton_pressed_event_root(event);
    exit;
  end
  else if (event.window = desktopbar) then
  begin
    desktopbar_buttonsclick(event);
    exit;
  end
  else if not (isalaunchbarwindow(event.window) = -1) then
  begin
    //launchbar_buttonsclick(event);
    //whiteout_launchbar_single(isalaunchbarwindow(event.window));
    exit;
  end
  else if not (isadesktopwindow(event.window) = -1) then
  begin
    case (event.button) of
    Button3:
    begin
    //desktop_buttonsclick(event);
    tmpnum := isadesktopwindow(event.window);
    //whiteout_desktop_single(tmpnum);
    motion_starting_x := event.x_root - wmdtItem[tmpnum].dtxpos;
    motion_starting_y := event.y_root - wmdtItem[tmpnum].dtypos;
    wmdtItemmove.dtismove := True;
    wmdtItemmove.dtitemmove := tmpnum;
    pointer_mode := POINTERMOVEMODE;
    XGrabPointer(dsply, wmdtItem[tmpnum].dtwindow, False, PointerMotionMask or ButtonReleaseMask, GrabModeAsync, GrabModeAsync, None, move_cursor, CurrentTime);
    debug_Monkey('set move desktop icon: ' + inttostr(tmpnum) + ' name: ' + wmdtItem[tmpnum].dtname);
    exit;
    end;
    end;
  end
  else if (mainmenuwin <> 0) and (event.window = mainmenuwin) then
  begin
//    mainpopwin_buttonsclick(event);
//    exit;
  end
  else if (event.window = buttonbar) then
  begin
    buttonbar_buttonsclick(event);
    exit;
  end
  else
  begin
    //XAllowEvents(dsply, ReplayPointer, CurrentTime);
    zclient := get_client(event.window, any_window);
    if not (zclient = 0) then
    begin
      debug_Monkey('hbutton_pressed_event window: ' + inttostr(wmClient[zclient].window));
      if (event.subwindow = wmClient[zclient].window) then
      begin
       if not (wmClientList.IndexOf(inttostr(zclient)) = 0) then
       begin
         raise_client(zclient);
         XUngrabPointer(dsply, CurrentTime);
         XSendEvent(dsply, wmClient[zclient].window, False, SubstructureNotifyMask, @event);
       end;
     end
     else
     begin
       if (event.y > titlebarheight + 1) then
       begin
         clicked_item := window_body;
       end
       else
       begin
           if (usetheme = True) then
             clicked_item := ((wmClient[zclient].width - event.x) DIV activeclosepic.iwidth) + 1
           else
             clicked_item := ((wmClient[zclient].width - event.x) DIV titlebarheight) + 1;
           if not (clicked_item = close_box) and not (clicked_item = max_box) and
              not (clicked_item = min_box) then clicked_item := title_bar;
       end;
       motion_starting_x := event.x_root - wmClient[zclient].x;
       motion_starting_y := event.y_root - wmClient[zclient].y;

       case (event.button) of
         Button1:
         begin
           if (clicked_item = title_bar) then
           begin
	     raise_client(zclient);
	     move_client(zclient);
             exit;
           end;
           if (clicked_item = window_body) then
           begin
	     raise_client(zclient);
             exit;
           end;
        end;
        Button2:
        begin
             // nothing yet
        end;
        Button3:
        begin
	  if (clicked_item = title_bar) then
	  begin
            move_client(zclient);
            exit;
          end;
	  if (clicked_item = window_body) then
	  begin
            resize_client(zclient);
            exit;
          end;
        end;
        end;
      end;
    end;
  end;
end;

procedure hbutton_pressed_event_root(event: TXButtonEvent);
begin
   case (event.button) of
     Button1:
       begin
         if mainmenuwin <> 0 then kill_mainmenu();
         debug_Monkey('hbutton_pressed_event_root button: 1');
       end;
     Button2:
       begin
         debug_Monkey('hbutton_pressed_event_root button: 2');
       end;
     Button3:
       begin
         if mainmenuwin = 0 then
         begin
           create_mainmenu(event.x, event.y);
         end
         else
         begin
           kill_mainmenu();
           create_mainmenu(event.x, event.y);
         end;
         debug_Monkey('hbutton_pressed_event_root button: 3');
       end;
   end;
end;

procedure hbutton_release_event(event: TXButtonEvent);
var
  clicked_item, zclient: integer;
begin
   if not (wmClient[handled_client].window = 0) then
   begin
     debug_Monkey('hbutton_release_event');
     if not (pointer_mode = POINTERNORMALMODE) then
     begin
       pointer_mode := POINTERNORMALMODE;
       XUngrabPointer(dsply, CurrentTime);
       update_client(handled_client, update_size);
       handled_client := 0;
       exit;
     end;
   end
   else if not (isalaunchbarwindow(event.window) = -1) or (wmdtItemmove.dtismove = True) then
   begin
   case (event.button) of
     Button1:
     begin
       if ((event.time - lastclick) < lbdblclickinterval) or (lbusedoubleclick = False) then
       begin
         launchbar_buttonsclick(event);
       end
       else
       begin
         lastclick := event.time;
       end;
     end;
     Button3:
     begin
       if (wmdtItemmove.dtismove = True) then
       begin
         wmdtItemmove.dtismove := False;
         pointer_mode := POINTERNORMALMODE;
         XUngrabPointer(dsply, CurrentTime);
         debug_Monkey('set move desktop icon RELEASE: ' + inttostr(wmdtItemmove.dtitemmove));
         if (wmdtItemmove.dtdidmove = True) then save_desktop_setting();
       end;
     end;
     end;

     exit;
   end
   else if not (isadesktopwindow(event.window) = -1) then
   begin
     if ((event.time - lastclick) < dtdblclickinterval) or (dtusedoubleclick = False) then
     begin
       desktop_buttonsclick(event);
       end
       else
       begin
         lastclick := event.time;
       end;
     exit;
   end
   else if (mainmenuwin <> 0) and (event.window = mainmenuwin) then
   begin
     mainpopwin_buttonsclick(event);
     exit;
   end
   else
   begin
     debug_Monkey('hbutton_release_event 2 event.window: ' + inttostr(event.window));
     zclient := get_client(event.window, any_window);
     debug_Monkey('hbutton_release_event 2 zclient: ' + inttostr(zclient));
     if not (zclient = 0) then
     begin
       if (event.y > titlebarheight + 1) then
       begin
         clicked_item := window_body;
       end
       else
       begin
           if (usetheme = True) then
           begin
             if (event.x < wmClient[zclient].width) and (event.x > (wmClient[zclient].width - activeclosepic.iwidth)) then
             clicked_item := close_box
             else if (event.x < (wmClient[zclient].width - activeclosepic.iwidth - 2)) and (event.x > (wmClient[zclient].width - activeclosepic.iwidth - 2 - activemaxipic.iwidth)) then
             clicked_item := max_box
             else if (event.x < (wmClient[zclient].width - activeclosepic.iwidth - 2 - activemaxipic.iwidth - 2)) and (event.x > (wmClient[zclient].width - activeclosepic.iwidth - 2 - activemaxipic.iwidth - 2 - activeminipic.iwidth)) then
             clicked_item := min_box
             else
             clicked_item := title_bar;
           end
           else
           begin
             clicked_item := ((wmClient[zclient].width - event.x) DIV titlebarheight) + 1;
           end;
           if not (clicked_item = close_box) and not (clicked_item = max_box) and
              not (clicked_item = min_box) then clicked_item := title_bar;
       end;
       case (event.button) of
         Button1:
         begin
           if (clicked_item = max_box) then
           begin
             maximize_switch_client(zclient);
             exit;
           end;
           if (clicked_item = close_box) then
	   begin
             send_exit_client(zclient);
             exit;
	   end;
           if (clicked_item = min_box) then
	   begin
             hide_client(zclient);
	   end;
        end;
        Button2:
        begin
             // nothing yet
        end;
        Button3:
        begin
	  if (clicked_item = max_box) then
          begin
            maximize_switch_client(zclient);
            exit;
          end;
        end;
      end;
     end
   end;
end;

procedure hmouse_motion_event(event: TXMotionEvent);
begin
  while XCheckTypedEvent (dsply, MotionNotify, @event) = True do
  begin { Something? } end;

  if not (wmClient[handled_client].window = 0) then
  begin
    debug_Monkey('hmouse_motion_event window: ' + inttostr(wmClient[handled_client].window));
    if (pointer_mode = POINTERMOVEMODE) then
    begin
      wmClient[handled_client].x := event.x_root - motion_starting_x;
      wmClient[handled_client].y := event.y_root - motion_starting_y;
      update_client(handled_client, update_position);
    end;
    if (pointer_mode = POINTERRESIZEMODE) then
    begin
      wmClient[handled_client].width := event.x_root - wmClient[handled_client].x;
      if (wmClient[handled_client].width < minwindowwidth) then wmClient[handled_client].width := minwindowwidth;
      wmClient[handled_client].height := event.y_root - wmClient[handled_client].y;
      if (wmClient[handled_client].height < minwindowheight) then wmClient[handled_client].height := minwindowheight;
      update_client(handled_client, update_size);
    end;
  end
  else if (wmdtItemmove.dtismove = True) then
  begin
    debug_Monkey('set move desktop icon SHOULD MOVE: ' + inttostr(wmdtItemmove.dtitemmove));
    wmdtItem[wmdtItemmove.dtitemmove].dtxpos := event.x_root - motion_starting_x;
    wmdtItem[wmdtItemmove.dtitemmove].dtypos := event.y_root - motion_starting_y;
    move_desktop_single(wmdtItemmove.dtitemmove);
  end;
end;

procedure henter_event(event: TXCrossingEvent);
var
  zclient: integer;
begin
  while XCheckTypedEvent(dsply, EnterNotify, @event) = True do
  begin { Something? } end;
  
  zclient := get_client(event.window, any_window);
  if not (zclient = 0) then
  begin
    if (wmClient[zclient].trans = 0) and (client_has_trans(wmClient[zclient].window) = 0) then
    begin
      if (usetheme = True) then
      begin
        if (event.window = wmClient[zclient].maxbox) then XGrabButton(dsply, AnyButton, AnyModifier, wmClient[zclient].maxbox, False, ButtonMask, GrabModeSync, GrabModeSync, None, None);
        if (event.window = wmClient[zclient].minbox) then XGrabButton(dsply, AnyButton, AnyModifier, wmClient[zclient].minbox, False, ButtonMask, GrabModeSync, GrabModeSync, None, None);
        if (event.window = wmClient[zclient].closebox) then XGrabButton(dsply, AnyButton, AnyModifier, wmClient[zclient].closebox, False, ButtonMask, GrabModeSync, GrabModeSync, None, None);
      end;
      if (event.window = wmClient[zclient].parent) then XGrabButton(dsply, AnyButton, AnyModifier, wmClient[zclient].parent, False, ButtonMask, GrabModeSync, GrabModeSync, None, None);
    end;
  end
  else if not (isadesktopwindow(event.window) = -1) then
    begin
      //redraw_desktop();
      exit;
  end;
end;

procedure hconfigure_request(event: TXConfigureRequestEvent);
var
  zclient: integer;
  wc: TXWindowChanges;
  gotevent: boolean;
begin
  gotevent := False;
  zclient := get_client(event.window, child_window);
  if not (zclient = 0) then
  begin
    debug_Monkey('hconfigure_request window: ' + inttostr(wmClient[zclient].window));
    if ((event.value_mask and CWX) = 1) then
    begin
      wmClient[zclient].x := event.x;
      debug_Monkey('hconfigure_request CWX event.x: ' + inttostr(event.x));
      if (wmClient[zclient].x < 0 ) then wmClient[zclient].x := 0;
      if (wmClient[zclient].x > max_width) then wmClient[zclient].x := max_width - titlebarheight;
      gotevent := True;
    end;

    if ((event.value_mask and CWY) = 1) then
    begin
      wmClient[zclient].y := event.y;
      debug_Monkey('hconfigure_request CWY event.y: ' + inttostr(event.y));
      if (wmClient[zclient].y < 0) then wmClient[zclient].y := 0;
      if (wmClient[zclient].y > max_height) then wmClient[zclient].y := max_height - titlebarheight;
      gotevent := True;
    end;

    if ((event.value_mask and CWWidth) = 1) then
    begin
      wmClient[zclient].width := event.width;
      debug_Monkey('hconfigure_request CWWidth event.width: ' + inttostr(event.width));
      if (wmClient[zclient].width > max_width) then wmClient[zclient].width := max_width;
      gotevent := True;
    end;

    if ((event.value_mask and CWHeight) = 1) then
    begin
      wmClient[zclient].height := event.height;
      debug_Monkey('hconfigure_request CWHeight event.height: ' + inttostr(event.height));
      if (wmClient[zclient].height > max_height) then wmClient[zclient].height := max_height;
      gotevent := True;
    end;

    if (gotevent = True) then update_client(zclient, update_size);

    if (event.value_mask = CWStackMode) or ((event.value_mask and CWStackMode) = 1) then
    begin
      wc.stack_mode := event.detail;
      if (wc.sibling = 1) then
      begin
        debug_Monkey('hconfigure_request wc.sibling = 1 window: ' + inttostr(wmClient[zclient].window) + ' parent: ' + inttostr(wmClient[zclient].parent));
        XConfigureWindow(dsply, wmClient[zclient].parent, CWStackMode or CWSibling, @wc);
      end
      else
      begin
        debug_Monkey('hconfigure_request wc.sibling =  window: ' + inttostr(wmClient[zclient].window) + ' parent: ' + inttostr(wmClient[zclient].parent));
        XConfigureWindow(dsply, wmClient[zclient].parent, CWStackMode, @wc);
      end;
    end;
  end
  else
  begin
    wc.x := event.x;
    wc.y := event.y;
    wc.width := event.width;
    wc.height := event.height;
    wc.sibling := event.above;
    wc.stack_mode := event.detail;
    debug_Monkey('hconfigure_request elseelse window: ' + inttostr(event.window));
    XConfigureWindow(dsply, event.window, event.value_mask, @wc);
  end;
end;

procedure hmap_request(event: TXMapRequestEvent);
var
  zclient: integer;
begin
  zclient := get_client(event.window, child_window);
  if (zclient = 0) then
  begin
    debug_Monkey('hmap_request new window: ' + inttostr(event.window));
    create_new_client(event.window);
  end
  else
  begin
    debug_Monkey('hmap_request unhide window: ' + inttostr(wmClient[zclient].window));
    unhide_client(zclient);
  end;
end;

procedure hunmap_event(event: TXMapRequestEvent);
var
  zclient: integer;
begin
  zclient := get_client(event.window, child_window);
  if not (zclient = 0) then
  begin
    if not (wmClient[zclient].ignore_unmap = 0) then
    begin
      debug_Monkey('hunmap_event Dec() window: ' + inttostr(wmClient[zclient].window));
      Dec(wmClient[zclient].ignore_unmap);
    end
    else
    begin
      debug_Monkey('hunmap_event remove_parent window: ' + inttostr(wmClient[zclient].window));
      remove_parent(zclient, 0);
    end;
  end;
end;

procedure hclient_message(event: TXClientMessageEvent);
var
  zclient: integer;
begin
  zclient := get_client(event.window, child_window);
  if not (zclient = 0) then
  begin
    debug_Monkey('hclient_message window: ' + inttostr(wmClient[zclient].window));
    if (event.message_type = mo_wm_change_state) and (event.format = 32) and (event.data.l[0] = IconicState) then
    begin
      hide_client(zclient);
    end;
  end;
end;

procedure hproperty_change(event: TXPropertyEvent);
var
  zclient: integer;
begin
  zclient := get_client(event.window, child_window);
  if not (zclient = 0) then
  begin
      if (event.atom = XA_WM_NAME) then
      begin
        debug_Monkey('hproperty_change WM_NAME window: ' + inttostr(wmClient[zclient].window) + ' atom: ' + inttostr(event.atom));
        XSetErrorHandler(@error_handler_ignore);
	XFetchName(dsply, wmClient[zclient].window, @wmClient[zclient].name);
        XSetErrorHandler(@error_handler);
	redraw_parent(zclient);
        redraw_taskbar();
      end
      else if (event.atom = XA_WM_NORMAL_HINTS) then
      begin
        debug_Monkey('hproperty_change WM_NORMAL_HINTS window: ' + inttostr(wmClient[zclient].window) + ' atom: ' + inttostr(event.atom));
        update_client(zclient, update_size);
      end
      else
      begin
        debug_Monkey('*******************************************************************');
        debug_Monkey('hproperty_change OTHER window: ' + inttostr(wmClient[zclient].window));
        debug_Monkey('hproperty_change OTHER atom: ' + inttostr(event.atom));
        debug_Monkey('hproperty_change OTHER state: ' + inttostr(event.state));
        debug_Monkey('*******************************************************************');
      end;
  end;
end;

procedure hexpose_event(event: TXExposeEvent);
var
  zclient: integer;
begin
  if (event.count = 0) and not (event.window = rootwin) then
  begin
    if not (isalaunchbarwindow(event.window) = -1) then
    begin
      //redraw_launchbar();
      redraw_launchbar_single(isalaunchbarwindow(event.window));
      exit;
    end
    else if not (isadesktopwindow(event.window) = -1) then
    begin
      //redraw_desktop();
       redraw_desktop_single(isadesktopwindow(event.window), event.window);
      exit;
    end
    else
    begin
      zclient := get_client(event.window, parent_window);
      if not (zclient = 0) then
      begin
        debug_Monkey('hexpose_event window: ' + inttostr(wmClient[zclient].window));
        redraw_parent(zclient);
      end;
    end;
  end;
end;

procedure hreparent_event(event: TXReparentEvent);
begin
  // nothing in here
end;

procedure hdestroy_notify(event: TXDestroyWindowEvent);
var
  zclient: integer;
begin
  zclient := get_client(event.window, child_window);
  if not (zclient = 0) then
  begin
    debug_Monkey('hdestroy_notify window: ' + inttostr(wmClient[zclient].window));
    remove_parent(zclient, 0);
  end;
end;

procedure hkey_event(event: TXKeyEvent);
var
  zclient: integer;
begin
  debug_Monkey('hkey_event key: start of it');
  if (event.window = rootwin) then
  begin
    debug_Monkey('hkey_event key: it is a root win');
    event.state := event.state and (Mod1Mask); // or ControlMask or ShiftMask);
    zclient := get_client(event.subwindow, any_window);
    if (zclient = 0) then zclient := get_focused_client();
    if (event.keycode = XKeysymToKeycode(dsply, XStringToKeysym(PChar(cycle_key)))) and (event.state = Mod1Mask) then
    begin
      debug_Monkey('hkey_event key: ' + cycle_key);
      XCirculateSubwindowsUp(dsply, rootwin);
    end;
    if (event.keycode = XKeysymToKeycode(dsply, XStringToKeysym(PChar(close_key)))) and (event.state = Mod1Mask) then
    begin
      debug_Monkey('hkey_event key: ' + close_key);
      if not (zclient = 0) then send_exit_client(zclient);
    end;
  end;
end;

procedure desktopbar_buttonsclick(event: TXButtonEvent);
begin
  case (event.button) of
  Button1:
  begin
    if (event.x > 47) and (event.x < 58) then
    begin
      debug_Monkey('desktopbar_buttonsclick: down desktop clicked: ' + inttostr(event.x));
      if (num_of_desktops > 1) then
      begin
        Dec(current_desktop);
        if (current_desktop < 1) then current_desktop := num_of_desktops;
        focus_clients();
      end;
    end
    else if (event.x > 58) and (event.x < 69) then
    begin
      debug_Monkey('desktopbar_buttonsclick: up desktop clicked: ' + inttostr(event.x));
      if (num_of_desktops > 1) then
      begin
        Inc(current_desktop);
        if (current_desktop > num_of_desktops) then current_desktop := 1;
        focus_clients();
      end;
    end;
  end;
  end;
end;

procedure buttonbar_buttonsclick(event: TXButtonEvent);
var
  button_width, clicked_item, tmpnum: integer;
begin
  case (event.button) of
  Button1:
  begin
    if wmTaskbarTempList.Count > 0 then
    begin
      button_width := (max_width - 150) DIV wmTaskbarTempList.Count;
      clicked_item := event.x DIV button_width;
      tmpnum := strtoint(wmTaskbarTempList[clicked_item]);
      if (wmClient[tmpnum].hidden = True) then
      begin
        unhide_client(tmpnum);
      end
      else if (tmpnum = focused_client) then
      begin
        hide_client(tmpnum);
      end
      else
      begin
        raise_client(tmpnum);
      end;
    end;
  end;
  end;
end;

procedure launchbar_buttonsclick(event: TXButtonEvent);
var
  clicked_item: integer;
begin
  case (event.button) of
  Button1:
  begin
    if (launchicocount > 0) then
    begin
      clicked_item := isalaunchbarwindow(event.window);
      if not (clicked_item = -1) then
      begin
        debug_Monkey('launchbar_buttonsclick: clicked: ' + inttostr(clicked_item));
        whiteout_launchbar_single(clicked_item);
        itemclick_launchbar(clicked_item);
      end;
    end;
  end;
  end;
end;

procedure desktop_buttonsclick(event: TXButtonEvent);
var
  clicked_item: integer;
begin
  case (event.button) of
  Button1:
  begin
    if (desktopicocount > 0) then
    begin
      clicked_item := isadesktopwindow(event.window);
      if not (clicked_item = -1) then
      begin
        debug_Monkey('desktop_buttonsclick: clicked: ' + inttostr(clicked_item));
        whiteout_desktop_single(clicked_item);
        itemclick_desktop(clicked_item);
      end;
    end;
  end;
  end;
end;

procedure mainpopwin_buttonsclick(event: TXButtonEvent);
var
  clicked_item: integer;
begin
  case (event.button) of
  Button1:
  begin
    if (wmMainMenuList.Count > 0) then
    begin
      clicked_item := event.y DIV 20;
      debug_Monkey('mainpopwin_buttonsclick: clicked: ' + inttostr(clicked_item));
      itemclick_mainmenu(clicked_item);
    end;
  end;
  end;
end;

end.

