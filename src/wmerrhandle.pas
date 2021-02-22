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
unit wmerrhandle;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, wmglobals, wmmisc, x, xlib;

function error_handler(display: PDisplay; event: PXErrorEvent): longint;cdecl;
function error_handler_ignore(display: PDisplay; event: PXErrorEvent): longint;cdecl;

implementation

function error_handler(display: PDisplay; event: PXErrorEvent): longint;cdecl;
var
  bufret:Array[1..255] of char;
  j: integer;
  st:string;
begin
  if (event^.error_code = BadAccess) and (event^.resourceid = rootwin) then
  begin
    debug_Monkey('Error: root window unavailible. maybe another wm is running?. Quitting!');
    writeln('Error: root window unavailible. maybe another wm is running?. Quitting!');
    halt;
  end
  else
  begin
    st := '';
    XGetErrorText(display, event^.error_code, @bufret, 255);
    for j := 1 to Length(bufret) do
    begin
      if (bufret[j] = #0) then
        break
      else
        st := st + bufret[j];
    end;
    debug_Monkey('Error : ' + st);
    debug_Monkey('Error : window id:' + inttostr(event^.resourceid));
  end;
  result := 0;
end;

function error_handler_ignore(display: PDisplay; event: PXErrorEvent): longint;cdecl;
begin
  result := 0;
end;


end.

