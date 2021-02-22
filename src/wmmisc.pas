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
unit wmmisc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, x, xlib, xutil, wmglobals, xkb, xkblib;

procedure open_debug_file();
procedure debug_Monkey(writstr: string);
procedure key_lock(key: integer; have_on: boolean);
function xkbgk_mask(oname: string): integer;
function xkbgk_mask_modifier(xkbgk: PXkbDescPtr; oname: string): integer;
function barheight: integer;
function Split(source, deli: string; astringlist: TStringList): TStringList;
function SetStringLength(sourcestr: PChar; maxlength: integer): string;

function XkbVirtualModsToRealMonkey(xkb: PXkbDescPtr; virtual_mask: Word; mask_rtrn: PWord) : Boolean;
        cdecl; external libX11 name 'XkbVirtualModsToReal';

implementation

procedure open_debug_file();
begin
  if (dodebug = True) and (debugtofile = True) then
  begin
    try
      Assign(dbugfile, dbugfoldr + '/Debug-' + appname + '.txt');
      ReWrite(dbugfile);
      debugfileisopen := True;
    except
      Writeln('Exception: Open debug file error!');
      debugfileisopen := False;
    end;
  end;
end;

procedure debug_Monkey(writstr: string);
begin
  if (dodebug = True) then
  begin
    if (debugfileisopen = True) then
    begin
      Writeln(dbugfile, writstr);
      Flush(dbugfile);
    end
    else
    begin
      Writeln(writstr);
    end;
  end;
end;

procedure key_lock(key: integer; have_on: boolean);
var
  lname: string;
  mask: integer;
begin
lname := '';
if (key = 1) then lname := 'NumLock';
if (key = 3) then lname := 'ScrollLock';
if not (lname = '') then
begin
  mask := xkbgk_mask(lname);
  if (have_on = True) and not (mask = -1) then
  begin
    debug_Monkey('turn ' + lname + ' on');
    XkbLockModifiers(dsply, XkbUseCoreKbd, mask, mask);
  end
  else if (have_on = False) and not (mask = -1) then
  begin
    debug_Monkey('turn ' + lname + ' off');
    XkbLockModifiers(dsply, XkbUseCoreKbd, mask, 0);
  end;
end;
end;
    
function xkbgk_mask(oname: string): integer;
var
  emask: integer;
  xkbgk: PXkbDescPtr;
begin
  xkbgk := XkbGetKeyboard(dsply, XkbAllComponentsMask, XkbUseCoreKbd);
  if not (xkbgk = nil) then
  begin
    emask := xkbgk_mask_modifier(xkbgk, oname);
    XkbFreeKeyBoard(xkbgk, 1, True);
    result := emask;
    exit;
  end;
result := -1;
end;

function xkbgk_mask_modifier(xkbgk: PXkbDescPtr; oname: string): integer;
var
  i, mask: integer;
  modstrng: PChar;
begin
  if not (xkbgk = nil) and not (xkbgk^.names = nil) then
  begin
    for i:= 0 to 15 do
    begin
      modstrng := XGetAtomName(dsply, xkbgk^.names^.vmods[i]);
      if not (modstrng = nil) and (oname = modstrng) then
      begin
        XkbVirtualModsToRealMonkey(xkbgk, 1 shl i, @mask);
        result := mask;
        exit;
      end;
    end;
  end;
result := -1;
end;

function barheight: integer;
begin
  result := wmfont^.max_bounds.ascent + wmfont^.max_bounds.descent + 8;
end;

function Split(source, deli: string; astringlist: TStringList): TStringList;
var
  endofcurrstring: byte;
begin
  repeat
  endofcurrstring := Pos(deli, source);
  if endofcurrstring = 0 then
    astringlist.add(source)
  else
    astringlist.add(Copy(source, 1, endofcurrstring - 1));
  source := Copy(source, endofcurrstring + length(deli), length(source) - endofcurrstring);
  until endofcurrstring = 0;
  result := astringlist;
end;

function SetStringLength(sourcestr: PChar; maxlength: integer): string;
var
  tmpstring: string;
  tmpnum: integer;
begin
  tmpstring := sourcestr;
  debug_Monkey('SetStringLength maxlength: ' + inttostr(maxlength) + ' string length: ' + inttostr(XTextWidth(wmfont, PChar(tmpstring), Length(tmpstring))));
  if (XTextWidth(wmfont, PChar(tmpstring), Length(tmpstring)) > maxlength) then
  begin
    while (XTextWidth(wmfont, PChar(tmpstring + ' ...'), Length(tmpstring + ' ...')) > maxlength) do
    begin
      tmpstring := Copy(tmpstring, 1, Length(tmpstring) - 1);
      debug_Monkey('SetStringLength cutting string length: ' + inttostr(XTextWidth(wmfont, PChar(tmpstring), Length(tmpstring))) + ' - ' + tmpstring);
    end;
    result := tmpstring + ' ...';
  end
  else
  begin
    result := tmpstring;
  end;
end;

end.

