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
unit wmtimer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, wmtaskbar, x, xlib;

type
   TimerThread = class(TThread)
     procedure execute;override;
     procedure write_time;
     procedure load_font_Timer();
     procedure root_window_Timer();
     procedure create_window_Timer();
   end;
   

var
   TimrThrd: TimerThread;
   timedsply: PDisplay;
   timescrn, timewmfontheight: integer;
   timeborder_col, timetext_col, timemenu_col: TXColor;
   timewmfont: PXFontStruct;
   timerootwin, timtimerbar: TWindow;
   timeborder_gc, timetext_gc, timemenu_gc: TGC;

implementation

procedure TimerThread.write_time;
var
  k: integer;
  timenow: string;
begin
  k := (titlebarheight - timewmfontheight) DIV 2;
  timenow := FormatDateTime('HH:NN AMPM',Now);
  XClearWindow(timedsply, timtimerbar);
  XFillRectangle(timedsply, timtimerbar, timeborder_gc, 0, 0, 73, taskbarheight - 2);
  XDrawString(timedsply, timtimerbar, timetext_gc, 12, timewmfont^.ascent + k, PChar(timenow), Length(PChar(timenow)));
  XSync(timedsply, false);
end;

procedure TimerThread.execute;
var
  dummy: TXColor;
begin
  timedsply := XOpenDisplay(nil);
  timescrn := DefaultScreen(timedsply);
  XAllocNamedColor(timedsply, DefaultColormap(timedsply, timescrn), PChar(mon_border), @timeborder_col, @dummy);
  XAllocNamedColor(timedsply, DefaultColormap(timedsply, timescrn), PChar(mon_text), @timetext_col, @dummy);
  XAllocNamedColor(timedsply, DefaultColormap(timedsply, timescrn), PChar(mon_menu), @timemenu_col, @dummy);
  load_font_Timer();
  root_window_Timer();
  create_window_Timer();
   while (exitmonkey = False) do
   begin
     write_time;
     sleep(100);
   end;
end;

procedure TimerThread.load_font_Timer();
begin
  timewmfont := XLoadQueryFont(timedsply, pref_font);
  if timewmfont = nil then
  begin
    timewmfont := XLoadQueryFont(timedsply, 'fixed');
  end;
  timewmfontheight := timewmfont^.max_bounds.ascent + timewmfont^.max_bounds.descent;
end;

procedure TimerThread.root_window_Timer();
var
  tgv: TXGCValues;
begin
  timerootwin := RootWindow(timedsply, timescrn);


  tgv._function := GXcopy;
  tgv.foreground := timeborder_col.pixel;
  tgv.line_width := 2;
  timeborder_gc := XCreateGC(timedsply, timerootwin, GCFunction or GCForeground or GCLineWidth, @tgv);

  tgv.foreground := timetext_col.pixel;
  tgv.line_width := 1;

  tgv.font := timewmfont^.fid;
  timetext_gc := XCreateGC(timedsply, timerootwin, GCFunction or GCForeground or GCFont, @tgv);
  
  tgv.foreground := timemenu_col.pixel;
  timemenu_gc := XCreateGC(timedsply, timerootwin, GCFunction or GCForeground, @tgv);
end;

procedure TimerThread.create_window_Timer();
var
  setAttr: TXSetWindowAttributes;
begin
  setAttr.override_redirect := True;
  setAttr.background_pixel := timemenu_col.pixel;
  setAttr.border_pixel := timeborder_col.pixel;
  setAttr.event_mask := childmask or ExposureMask or EnterWindowMask or  ButtonPressMask;
  timtimerbar := XCreateWindow(timedsply, taskbarwin, max_width - 74, 1,
      73,  taskbarheight - 2, 0, DefaultDepth(timedsply, timescrn),
	  CopyFromParent, DefaultVisual(timedsply, timescrn), CWOverrideRedirect or CWBackPixel or CWBorderPixel or CWEventMask, @setAttr);
  XMapWindow(timedsply, timtimerbar);
end;

end.

