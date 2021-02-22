unit shape;
interface

uses
ctypes, x, xlib;


const
   X_ShapeQueryVersion = 0;
   X_ShapeRectangles = 1;
   X_ShapeMask = 2;
   X_ShapeCombine = 3;
   X_ShapeOffset = 4;
   X_ShapeQueryExtents = 5;
   X_ShapeSelectInput = 6;
   X_ShapeInputSelected = 7;
   X_ShapeGetRectangles = 8;
   ShapeSet = 0;
   ShapeUnion = 1;
   ShapeIntersect = 2;
   ShapeSubtract = 3;
   ShapeInvert = 4;
   ShapeBounding = 0;
   ShapeClip = 1;
   ShapeInput = 2;
   ShapeNotifyMask = 1 shl 0;
   ShapeNotify = 0;
   ShapeNumberEvents = ShapeNotify+1;

//type
//   PXShapeEvent = ^TXShapeEvent;
//   TXShapeEvent = record
//        _type : longint;
//        serial : dword;
//        send_event : boolean;
//        display : PDisplay;
//        window : TWindow;
//        kind : longint;
//        x : longint;
//        y : longint;
//        width : dword;
//        height : dword;
//        time : TTime;
//        shaped : boolean;
//     end;


function XShapeCombineMask(para1: PDisplay;
			     para2: TWindow;
			     para3: cint;
			     para4: cint;
			     para5: cint;
			     para6: TPixmap;
			     para7: cint): boolean; cdecl;external 'libXext.so.6';

function XShapeCombineShape(para1: PDisplay;
			     para2: TWindow;
			     para3: cint;
			     para4: cint;
			     para5: cint;
			     para6: TPixmap;
			     para7: cint;
			     para8: cint): boolean; cdecl;external 'libXext.so.6';


implementation


end.
