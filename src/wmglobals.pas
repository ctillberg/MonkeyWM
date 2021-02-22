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
unit wmglobals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, x, xlib, xutil, imlib2;
  

type
   Client = record
      window : TWindow;
      parent : TWindow;
      trans : TWindow;
      closebox : TWindow;
      maxbox : TWindow;
      minbox : TWindow;
      iconbox : TWindow;
      stickybox : TWindow;
      name : PChar;
      desktop : integer;
      sticky : integer;
      screen : integer;
      frame_state : integer;
      deskthidden: boolean;
      clrmap : TColormap;
      size : PXSizeHints;
      ignore_unmap : integer;
      hidden: boolean;
      x : integer;
      y : integer;
      width : integer;
      height : integer;
      normal_x : integer;
      normal_y : integer;
      normal_width : integer;
      normal_height : integer;
      maximized : boolean;
      destroyed : boolean;
      hints: PXWMHints;
   end;
   
   PropMwmHints = record
      flags : Cardinal;
      functions : Cardinal;
      decorations : Cardinal;
      inputMode : Integer;
      status : Cardinal;
   end;
   
   PixmapStruct = record
      iimage : Imlib_Image;
      ipixmap : TPixmap;
      imask : TPixmap;
      iwidth : integer;
      iheight : integer;
   end;
   
   LaunchbarItems = record
      lbwindow : TWindow;
      lbpicpath : string;
      lbname : string;
      lbexec : string;
      lbargs : string;
      lbimage : Imlib_Image;
      lbpixmap : TPixmap;
      lbpicmask : TPixmap;
      lbpicwidth : integer;
      lbpicheight : integer;
   end;
   
   DesktopItems = record
      dtwindow : TWindow;
      dtpicpath : string;
      dtname : string;
      dtexec : string;
      dtargs : string;
      dtimage : Imlib_Image;
      dtpixmap : TPixmap;
      dtpicmask : TPixmap;
      dtxpos : integer;
      dtypos : integer;
      dtpicwidth : integer;
      dtpicheight : integer;
      dtcaptionwindow : TWindow;
      dtcaptionwidth : integer;
      dtcaptionheight : integer;
   end;
   
   DesktopItemMove = record
      dtismove : boolean;
      dtitemmove : integer;
      dtdidmove : boolean;
   end;
  
var
   dsply: PDisplay;
   scrn, font_height: integer;
   mainmenuwin: TWindow;
   exitmonkey, debugfileisopen: boolean;
   wrkfoldr, dbugfoldr: string;
   dbugfile: Text;
   wmfont: PXFontStruct;
   wmfontheight, lastclick: integer;
   rootwin, taskbarwin, buttonbar, desktopbar, timerbar, launchbarwin: TWindow;
   max_width, max_height, current_desktop, focused_client: integer;
   wmClient: Array of Client;
   wmlbItem: Array of LaunchbarItems;
   wmdtItem: Array of DesktopItems;
   string_gc, border_gc, text_gc, active_gc, depressed_gc, inactive_gc, menu_gc: TGC;
   border_col, text_col, active_col, inactive_col, menu_col: TXColor;
   client_number, launchbar_width, launchicocount, desktopicocount: integer;
   ini_monkey: TIniFile;
   numlockon: boolean;
   mo_wm_state, mo_wm_change_state, mo_wm_protos, mo_wm_delete, mo_mwm_wm_hints: TAtom;
   move_cursor, resize_cursor, body_cursor, window_cursor: TCursor;
   wmClientList, wmTaskbarList, wmTaskbarTempList, wmMainMenuList, tmpStartupList: TStringList;
   motion_starting_x, motion_starting_y, minipicleft, maxipicleft, closepicleft: integer;
   activeclosepic, activemaxipic, activeminipic, activebarpic: PixmapStruct;
   inactiveclosepic, inactivemaxipic, inactiveminipic, inactivebarpic: PixmapStruct;
   actclospic_gc, actmaxipic_gc, actminipic_gc: TGC;
   inactclospic_gc, inactmaxipic_gc, inactminipic_gc: TGC;
   launchico_gc: Array of TGC;
   mainmenu_gc: TGC;
   imlibvis: PVisual;
   imlibcm: TColormap;
   wmdtItemmove: DesktopItemMove;


   
const
   appversion: string = '0.3.0';
   appdirname: string = 'monkeywm';
   appname: string = 'MonkeyWM';
   dodebug: boolean = False;
   debugtofile: boolean = True;
   childmask = (SubstructureRedirectMask or SubstructureNotifyMask);
   buttonmask = (ButtonPressMask or ButtonReleaseMask);
   mousemask = (ButtonMask or PointerMotionMask);
   cycle_key: string = 'Tab';
   close_key: string = 'F4';
   monkey_bg: string = 'green';
   monkey_fg: string = 'white';
   monkey_bc: string = 'black';
   mon_border: string = '#000';
   mon_text: string = '#fff';
   mon_active: string = '#6cb1e7';
   mon_inactive: string = '#b6c1c9';
   mon_menu: string = '#ddd';
   mon_selected: string = '#aad';
   mon_empty: string = '#000';
   frame_shown = 0;
   frame_hidden = 1;
   frame_none = 2;
   update_size = 1;
   update_position = 2;
   MWM_HINTS_DECORATIONS = 1 shl 1;
   MWM_DECOR_ALL = 1 shl 0;
   MWM_DECOR_BORDER = 1 shl 1;
   MWM_DECOR_TITLE = 1 shl 3;
   titlebarheight: integer = 18;
   taskbarheight: integer = 20;
   minwindowwidth: integer = 30;
   minwindowheight: integer = 30;
   pref_font = '-b&h-lucida-medium-r-*-*-11-*-*-*-*-*-*-*';
   child_window = 0;
   parent_window = 1;
   any_window = 2;
   title_bar = 0;
   close_box = 1;
   max_box = 2;
   min_box = 3;
   window_body = 4;
   POINTERNORMALMODE = 0;
   POINTERMOVEMODE = 1;
   POINTERRESIZEMODE = 2;
   pointer_mode: integer = POINTERNORMALMODE;
   handled_client: integer = 0;
   num_of_desktops: integer = 4;
   usetheme: boolean = False;
   themefoldr: string = 'default';
   uselaunchbar: boolean = False;
   launchiconsize: integer = 48;
   usedesktop: boolean = False;
   desktopiconsize: integer = 48;
   lbusedoubleclick: boolean = True;
   lbdblclickinterval: integer = 200;
   dtusedoubleclick: boolean = True;
   dtdblclickinterval: integer = 200;

   

implementation

end.

