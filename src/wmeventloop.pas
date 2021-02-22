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
unit wmeventloop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, x, xlib, wmeventhandler, wmmisc;
  
procedure event_loop_Monkey();

implementation

procedure event_loop_Monkey();
var
  event: TXEvent;
begin
  while (exitmonkey = False) do
  begin
    try
      XNextEvent(dsply, @event);
    except
      debug_Monkey('XNextEvent: Exception!');
    end;
    try
      case (event._type) of
        ButtonPress:
        begin
          debug_Monkey('XNextEvent: ButtonPress');
          hbutton_pressed_event(event.xbutton);
        end;
        ButtonRelease:
        begin
          debug_Monkey('XNextEvent: ButtonRelease');
          hbutton_release_event(event.xbutton);
        end;
        MotionNotify:
        begin
          debug_Monkey('XNextEvent: MotionNotify');
          hmouse_motion_event(event.xmotion);
        end;
        EnterNotify:
        begin
          debug_Monkey('XNextEvent: EnterNotify');
          henter_event(event.xcrossing);
        end;
        ConfigureRequest:
        begin
          debug_Monkey('XNextEvent: ConfigureRequest');
          hconfigure_request(event.xconfigurerequest);
        end;
        MapRequest:
        begin
          debug_Monkey('XNextEvent: MapRequest');
          hmap_request(event.xmaprequest);
        end;
        UnmapNotify:
        begin
          debug_Monkey('XNextEvent: UnmapNotify');
          hunmap_event(event.xmaprequest);
        end;
        ClientMessage:
        begin
          debug_Monkey('XNextEvent: ClientMessage');
          hclient_message(event.xclient);
        end;
        PropertyNotify:
        begin
          debug_Monkey('XNextEvent: PropertyNotify');
          hproperty_change(event.xproperty);
        end;
        Expose:
        begin
          debug_Monkey('XNextEvent: Expose');
          hexpose_event(event.xexpose);
        end;
        ReparentNotify:
        begin
          debug_Monkey('XNextEvent: ReparentNotify');
          hreparent_event(event.xreparent);
        end;
        DestroyNotify:
        begin
          debug_Monkey('XNextEvent: DestroyNotify');
          hdestroy_notify(event.xdestroywindow);
        end;
	KeyPress:
        begin
          debug_Monkey('XNextEvent: KeyPress');
          hkey_event(event.xkey);
        end;
        else
        begin
          try
            debug_Monkey('Case of: Else. number: ' + inttostr(event._type));
          except
            debug_Monkey('Case of: Else: Exception! number: ' + inttostr(event._type));
          end;
        end;
      end;
    except
      debug_Monkey('Case of: Exception! number: ' + inttostr(event._type));
    end;
  end;
end;

end.

