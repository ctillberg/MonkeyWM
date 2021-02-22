unit Imlib2;
interface

{$PACKRECORDS C}
{$mode objfpc}

Uses X, Xlib, XUtil;//, ctypes;

const
  Imlibdll='libImlib2.so.1';
//     DATA32 = longword;
//     DATA8 = byte;
     
//    Type
//    PDATA32  = ^DATA32;
//    PDATA8  = ^DATA8;
//    PDisplay  = ^Display;
//    Pdouble  = ^double;
//    PImlib_Border  = ^Imlib_Border;
//    PImlib_Color  = ^Imlib_Color;
//    PImlib_Load_Error  = ^Imlib_Load_Error;
//    Plongint  = ^longint;
//    PPixmap  = ^Pixmap;
//    PVisual  = ^Visual;
//    PXImage  = ^XImage;
//     __IMLIB_API_H = 1;

  type
  
//     _imlib_border = record
//          left : longint;
//          right : longint;
//          top : longint;
//          bottom : longint;
//       end;

//     _imlib_color = record
//          alpha : longint;
//          red : longint;
//          green : longint;
//          blue : longint;
//       end;

     Imlib_Context = pointer;

     Imlib_Image = pointer;

     Imlib_Color_Modifier = pointer;

     Imlib_Updates = pointer;

     Imlib_Font = pointer;

     Imlib_Color_Range = pointer;

     Imlib_Filter = pointer;
//     _imlib_border = _imlib_border;
//     _imlib_color = _imlib_color;

     ImlibPolygon = pointer;
  { blending operations  }
     _imlib_operation = (IMLIB_OP_COPY,IMLIB_OP_ADD,IMLIB_OP_SUBTRACT,
       IMLIB_OP_RESHADE);

     _imlib_text_direction = (IMLIB_TEXT_TO_RIGHT := 0,IMLIB_TEXT_TO_LEFT := 1,
       IMLIB_TEXT_TO_DOWN := 2,IMLIB_TEXT_TO_UP := 3,
       IMLIB_TEXT_TO_ANGLE := 4);

     _imlib_load_error = (IMLIB_LOAD_ERROR_NONE,IMLIB_LOAD_ERROR_FILE_DOES_NOT_EXIST,
       IMLIB_LOAD_ERROR_FILE_IS_DIRECTORY,
       IMLIB_LOAD_ERROR_PERMISSION_DENIED_TO_READ,
       IMLIB_LOAD_ERROR_NO_LOADER_FOR_FILE_FORMAT,
       IMLIB_LOAD_ERROR_PATH_TOO_LONG,IMLIB_LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT,
       IMLIB_LOAD_ERROR_PATH_COMPONENT_NOT_DIRECTORY,
       IMLIB_LOAD_ERROR_PATH_POINTS_OUTSIDE_ADDRESS_SPACE,
       IMLIB_LOAD_ERROR_TOO_MANY_SYMBOLIC_LINKS,
       IMLIB_LOAD_ERROR_OUT_OF_MEMORY,IMLIB_LOAD_ERROR_OUT_OF_FILE_DESCRIPTORS,
       IMLIB_LOAD_ERROR_PERMISSION_DENIED_TO_WRITE,
       IMLIB_LOAD_ERROR_OUT_OF_DISK_SPACE,
       IMLIB_LOAD_ERROR_UNKNOWN);

  { Encodings known to Imlib2 (so far)  }
     _imlib_TTF_encoding = (IMLIB_TTF_ENCODING_ISO_8859_1,IMLIB_TTF_ENCODING_ISO_8859_2,
       IMLIB_TTF_ENCODING_ISO_8859_3,IMLIB_TTF_ENCODING_ISO_8859_4,
       IMLIB_TTF_ENCODING_ISO_8859_5);


     Imlib_Operation = _imlib_operation;

     Imlib_Load_Error = _imlib_load_error;

     ImlibLoadError = _imlib_load_error;

     Imlib_Text_Direction = _imlib_text_direction;

     Imlib_TTF_Encoding = _imlib_TTF_encoding;



    procedure imlib_context_set_display(disp:PDisplay);cdecl;external Imlibdll;

    procedure imlib_context_set_visual(visual:PVisual);cdecl;external Imlibdll;

    procedure imlib_context_set_colormap(colormap:TColormap);cdecl;external Imlibdll;

    procedure imlib_context_set_drawable(drawable:TDrawable);cdecl;external Imlibdll;
 
    procedure imlib_set_color_usage(max:longint);cdecl;external Imlibdll;

    procedure imlib_context_set_dither(dither:char);cdecl;external Imlibdll;

    procedure imlib_context_set_blend(blend:char);cdecl;external Imlibdll;

    function imlib_load_image(afile:pchar):Imlib_Image; cdecl;external Imlibdll;

    procedure imlib_context_set_image(image:Imlib_Image);cdecl;external Imlibdll;

    function imlib_image_get_height:integer; cdecl;external Imlibdll;

    function imlib_image_get_width:integer; cdecl;external Imlibdll;

    procedure imlib_image_set_has_alpha(has_alpha:char);cdecl;external Imlibdll;

    procedure imlib_image_set_irrelevant_alpha(irrelevant:char);cdecl;external Imlibdll;

    procedure imlib_render_pixmaps_for_whole_image_at_size(pixmap_return:PPixmap; mask_return:PPixmap; width:longint; height:longint);cdecl;external Imlibdll;

    procedure imlib_free_pixmap_and_mask(pixmap:TPixmap);cdecl;external Imlibdll;

    procedure imlib_context_set_mask(mask:TPixmap);cdecl;external Imlibdll;

    function imlib_create_image_from_drawable(mask:PPixmap; x:longint; y:longint; width:longint; height:longint;
               need_to_grab_x:char):Imlib_Image; cdecl;external Imlibdll;
               
    procedure imlib_save_image(filename:pchar);cdecl;external Imlibdll;
    
    procedure imlib_free_image;cdecl;external Imlibdll;

    procedure imlib_free_image_and_decache;cdecl;external Imlibdll;

{
               
    procedure imlib_context_set_dither_mask(dither_mask:char);

    procedure imlib_context_set_anti_alias(anti_alias:char);

    procedure imlib_context_free(context:Imlib_Context);

    procedure imlib_context_push(context:Imlib_Context);

    procedure imlib_context_pop;

    function imlib_context_get:Imlib_Context;


     Imlib_Progress_Function = function (im:Imlib_Image; percent:char; update_x:longint; update_y:longint; update_w:longint; 
                  update_h:longint):longint;cdecl;

     Imlib_Data_Destructor_Function = procedure (im:Imlib_Image; data:pointer);cdecl;


    procedure imlib_context_set_operation(operation:Imlib_Operation);

    procedure imlib_context_set_font(font:Imlib_Font);

    procedure imlib_context_set_direction(direction:Imlib_Text_Direction);

    procedure imlib_context_set_angle(angle:double);

    procedure imlib_context_set_color(red:longint; green:longint; blue:longint; alpha:longint);

    procedure imlib_context_set_color_hsva(hue:double; saturation:double; value:double; alpha:longint);

    procedure imlib_context_set_color_hlsa(hue:double; lightness:double; saturation:double; alpha:longint);

    procedure imlib_context_set_color_cmya(cyan:longint; magenta:longint; yellow:longint; alpha:longint);

    procedure imlib_context_set_color_range(color_range:Imlib_Color_Range);

    procedure imlib_context_set_progress_function(progress_function:Imlib_Progress_Function);

    procedure imlib_context_set_progress_granularity(progress_granularity:char);



    procedure imlib_context_set_cliprect(x:longint; y:longint; w:longint; h:longint);

    procedure imlib_context_set_TTF_encoding(encoding:Imlib_TTF_Encoding);

    function imlib_context_get_display:^Display;

    function imlib_context_get_visual:^Visual;

    function imlib_context_get_colormap:Colormap;

    function imlib_context_get_drawable:Drawable;

    function imlib_context_get_mask:Pixmap;

    function imlib_context_get_dither_mask:char;

    function imlib_context_get_anti_alias:char;

    function imlib_context_get_dither:char;

    function imlib_context_get_blend:char;

    function imlib_context_get_color_modifier:Imlib_Color_Modifier;

    function imlib_context_get_operation:Imlib_Operation;

    function imlib_context_get_font:Imlib_Font;

    function imlib_context_get_angle:double;

    function imlib_context_get_direction:Imlib_Text_Direction;

    procedure imlib_context_get_color(red:plongint; green:plongint; blue:plongint; alpha:plongint);

    procedure imlib_context_get_color_hsva(hue:pdouble; saturation:pdouble; value:pdouble; alpha:plongint);

    procedure imlib_context_get_color_hlsa(hue:pdouble; lightness:pdouble; saturation:pdouble; alpha:plongint);

    procedure imlib_context_get_color_cmya(cyan:plongint; magenta:plongint; yellow:plongint; alpha:plongint);

    function imlib_context_get_imlib_color:^Imlib_Color;

    function imlib_context_get_color_range:Imlib_Color_Range;

    function imlib_context_get_progress_function:Imlib_Progress_Function;

    function imlib_context_get_progress_granularity:char;

    function imlib_context_get_image:Imlib_Image;

    procedure imlib_context_get_cliprect(x:plongint; y:plongint; w:plongint; h:plongint);

    function imlib_context_get_TTF_encoding:Imlib_TTF_Encoding;

    function imlib_get_cache_size:longint;

    procedure imlib_set_cache_size(bytes:longint);

    function imlib_get_color_usage:longint;

    

    procedure imlib_flush_loaders;

    function imlib_get_visual_depth(display:pDisplay; visual:pVisual):longint;

    function imlib_get_best_visual(display:pDisplay; screen:longint; depth_return:plongint):^Visual;

    function imlib_load_image_immediately(file:pchar):Imlib_Image;

    function imlib_load_image_without_cache(file:pchar):Imlib_Image;

    function imlib_load_image_immediately_without_cache(file:pchar):Imlib_Image;

    function imlib_load_image_with_error_return(file:pchar; error_return:pImlib_Load_Error):Imlib_Image;


    function imlib_image_get_filename:^char;

    function imlib_image_get_data:^DATA32;

    function imlib_image_get_data_for_reading_only:^DATA32;

    procedure imlib_image_put_back_data(data:pDATA32);

    function imlib_image_has_alpha:char;

    procedure imlib_image_set_changes_on_disk;

    procedure imlib_image_get_border(border:pImlib_Border);

    procedure imlib_image_set_border(border:pImlib_Border);

    procedure imlib_image_set_format(format:pchar);

    procedure imlib_image_set_irrelevant_format(irrelevant:char);

    procedure imlib_image_set_irrelevant_border(irrelevant:char);



    function imlib_image_format:^char;



    procedure imlib_image_query_pixel(x:longint; y:longint; color_return:pImlib_Color);

    procedure imlib_image_query_pixel_hsva(x:longint; y:longint; hue:pdouble; saturation:pdouble; value:pdouble; 
                alpha:plongint);

    procedure imlib_image_query_pixel_hlsa(x:longint; y:longint; hue:pdouble; lightness:pdouble; saturation:pdouble; 
                alpha:plongint);

    procedure imlib_image_query_pixel_cmya(x:longint; y:longint; cyan:plongint; magenta:plongint; yellow:plongint; 
                alpha:plongint);

    procedure imlib_render_pixmaps_for_whole_image(pixmap_return:pPixmap; mask_return:pPixmap);





    procedure imlib_render_image_on_drawable(x:longint; y:longint);

    procedure imlib_render_image_on_drawable_at_size(x:longint; y:longint; width:longint; height:longint);

    procedure imlib_render_image_part_on_drawable_at_size(source_x:longint; source_y:longint; source_width:longint; source_height:longint; x:longint; 
                y:longint; width:longint; height:longint);

    function imlib_render_get_pixel_color:DATA32;

    procedure imlib_blend_image_onto_image(source_image:Imlib_Image; merge_alpha:char; source_x:longint; source_y:longint; source_width:longint; 
                source_height:longint; destination_x:longint; destination_y:longint; destination_width:longint; destination_height:longint);

    function imlib_create_image(width:longint; height:longint):Imlib_Image;

    function imlib_create_image_using_data(width:longint; height:longint; data:pDATA32):Imlib_Image;

    function imlib_create_image_using_copied_data(width:longint; height:longint; data:pDATA32):Imlib_Image;

    function imlib_create_image_from_ximage(image:pXImage; mask:pXImage; x:longint; y:longint; width:longint; 
               height:longint; need_to_grab_x:char):Imlib_Image;

    function imlib_create_scaled_image_from_drawable(mask:Pixmap; source_x:longint; source_y:longint; source_width:longint; source_height:longint; 
               destination_width:longint; destination_height:longint; need_to_grab_x:char; get_mask_from_shape:char):Imlib_Image;

    function imlib_copy_drawable_to_image(mask:Pixmap; x:longint; y:longint; width:longint; height:longint; 
               destination_x:longint; destination_y:longint; need_to_grab_x:char):char;

    function imlib_clone_image:Imlib_Image;

    function imlib_create_cropped_image(x:longint; y:longint; width:longint; height:longint):Imlib_Image;

    function imlib_create_cropped_scaled_image(source_x:longint; source_y:longint; source_width:longint; source_height:longint; destination_width:longint; 
               destination_height:longint):Imlib_Image;

    { imlib updates. lists of rectangles for storing required update draws  }
    function imlib_updates_clone(updates:Imlib_Updates):Imlib_Updates;

    function imlib_update_append_rect(updates:Imlib_Updates; x:longint; y:longint; w:longint; h:longint):Imlib_Updates;

    function imlib_updates_merge(updates:Imlib_Updates; w:longint; h:longint):Imlib_Updates;

    function imlib_updates_merge_for_rendering(updates:Imlib_Updates; w:longint; h:longint):Imlib_Updates;

    procedure imlib_updates_free(updates:Imlib_Updates);

    function imlib_updates_get_next(updates:Imlib_Updates):Imlib_Updates;

    procedure imlib_updates_get_coordinates(updates:Imlib_Updates; x_return:plongint; y_return:plongint; width_return:plongint; height_return:plongint);

    procedure imlib_updates_set_coordinates(updates:Imlib_Updates; x:longint; y:longint; width:longint; height:longint);

    procedure imlib_render_image_updates_on_drawable(updates:Imlib_Updates; x:longint; y:longint);

    function imlib_updates_init:Imlib_Updates;

    function imlib_updates_append_updates(updates:Imlib_Updates; appended_updates:Imlib_Updates):Imlib_Updates;

    { image modification  }
    procedure imlib_image_flip_horizontal;

    procedure imlib_image_flip_vertical;

    procedure imlib_image_flip_diagonal;

    procedure imlib_image_orientate(orientation:longint);

    procedure imlib_image_blur(radius:longint);

    procedure imlib_image_sharpen(radius:longint);

    procedure imlib_image_tile_horizontal;

    procedure imlib_image_tile_vertical;

    procedure imlib_image_tile;

    function imlib_load_font(font_name:pchar):Imlib_Font;

    procedure imlib_free_font;

    procedure imlib_text_draw(x:longint; y:longint; text:pchar);

    procedure imlib_text_draw_with_return_metrics(x:longint; y:longint; text:pchar; width_return:plongint; height_return:plongint; 
                horizontal_advance_return:plongint; vertical_advance_return:plongint);

    procedure imlib_get_text_size(text:pchar; width_return:plongint; height_return:plongint);

    procedure imlib_get_text_advance(text:pchar; horizontal_advance_return:plongint; vertical_advance_return:plongint);

    function imlib_get_text_inset(text:pchar):longint;

    procedure imlib_add_path_to_font_path(path:pchar);

    procedure imlib_remove_path_from_font_path(path:pchar);

    function imlib_list_font_path(number_return:plongint):^^char;

    function imlib_text_get_index_and_location(text:pchar; x:longint; y:longint; char_x_return:plongint; char_y_return:plongint; 
               char_width_return:plongint; char_height_return:plongint):longint;

    procedure imlib_text_get_location_at_index(text:pchar; index:longint; char_x_return:plongint; char_y_return:plongint; char_width_return:plongint; 
                char_height_return:plongint);

    function imlib_list_fonts(number_return:plongint):^^char;

    procedure imlib_free_font_list(font_list:Ppchar; number:longint);

    function imlib_get_font_cache_size:longint;

    procedure imlib_set_font_cache_size(bytes:longint);

    procedure imlib_flush_font_cache;

    function imlib_get_font_ascent:longint;

    function imlib_get_font_descent:longint;

    function imlib_get_maximum_font_ascent:longint;

    function imlib_get_maximum_font_descent:longint;


    procedure imlib_free_color_modifier;

    procedure imlib_modify_color_modifier_gamma(gamma_value:double);

    procedure imlib_modify_color_modifier_brightness(brightness_value:double);

    procedure imlib_modify_color_modifier_contrast(contrast_value:double);

    procedure imlib_set_color_modifier_tables(red_table:pDATA8; green_table:pDATA8; blue_table:pDATA8; alpha_table:pDATA8);

    procedure imlib_get_color_modifier_tables(red_table:pDATA8; green_table:pDATA8; blue_table:pDATA8; alpha_table:pDATA8);

    procedure imlib_reset_color_modifier;

    procedure imlib_apply_color_modifier;

    procedure imlib_apply_color_modifier_to_rectangle(x:longint; y:longint; width:longint; height:longint);

    function imlib_image_draw_pixel(x:longint; y:longint; make_updates:char):Imlib_Updates;

    function imlib_image_draw_line(x1:longint; y1:longint; x2:longint; y2:longint; make_updates:char):Imlib_Updates;

    function imlib_clip_line(x0:longint; y0:longint; x1:longint; y1:longint; xmin:longint; 
               xmax:longint; ymin:longint; ymax:longint; clip_x0:plongint; clip_y0:plongint; 
               clip_x1:plongint; clip_y1:plongint):longint;

    procedure imlib_image_draw_rectangle(x:longint; y:longint; width:longint; height:longint);

    procedure imlib_image_fill_rectangle(x:longint; y:longint; width:longint; height:longint);

    procedure imlib_image_copy_alpha_to_image(image_source:Imlib_Image; x:longint; y:longint);

    procedure imlib_image_copy_alpha_rectangle_to_image(image_source:Imlib_Image; x:longint; y:longint; width:longint; height:longint; 
                destination_x:longint; destination_y:longint);

    procedure imlib_image_scroll_rect(x:longint; y:longint; width:longint; height:longint; delta_x:longint; 
                delta_y:longint);

    procedure imlib_image_copy_rect(x:longint; y:longint; width:longint; height:longint; new_x:longint; 
                new_y:longint);

    function imlib_polygon_new:ImlibPolygon;

    procedure imlib_polygon_free(poly:ImlibPolygon);

    procedure imlib_polygon_add_point(poly:ImlibPolygon; x:longint; y:longint);

    procedure imlib_image_draw_polygon(poly:ImlibPolygon; closed:byte);

    procedure imlib_image_fill_polygon(poly:ImlibPolygon);

    procedure imlib_polygon_get_bounds(poly:ImlibPolygon; px1:plongint; py1:plongint; px2:plongint; py2:plongint);

    function imlib_polygon_contains_point(poly:ImlibPolygon; x:longint; y:longint):byte;

    procedure imlib_image_draw_ellipse(xc:longint; yc:longint; a:longint; b:longint);

    procedure imlib_image_fill_ellipse(xc:longint; yc:longint; a:longint; b:longint);

    function imlib_create_color_range:Imlib_Color_Range;

    procedure imlib_free_color_range;

    procedure imlib_add_color_to_color_range(distance_away:longint);

    procedure imlib_image_fill_color_range_rectangle(x:longint; y:longint; width:longint; height:longint; angle:double);

    procedure imlib_image_fill_hsva_color_range_rectangle(x:longint; y:longint; width:longint; height:longint; angle:double);

    procedure imlib_image_attach_data_value(key:pchar; data:pointer; value:longint; destructor_function:Imlib_Data_Destructor_Function);

    function imlib_image_get_attached_data(key:pchar):pointer;

    function imlib_image_get_attached_value(key:pchar):longint;

    procedure imlib_image_remove_attached_data_value(key:pchar);

    procedure imlib_image_remove_and_free_attached_data_value(key:pchar);



    procedure imlib_save_image_with_error_return(filename:pchar; error_return:pImlib_Load_Error);

    function imlib_create_rotated_image(angle:double):Imlib_Image;

    procedure imlib_rotate_image_from_buffer(angle:double; source_image:Imlib_Image);

    procedure imlib_blend_image_onto_image_at_angle(source_image:Imlib_Image; merge_alpha:char; source_x:longint; source_y:longint; source_width:longint; 
                source_height:longint; destination_x:longint; destination_y:longint; angle_x:longint; angle_y:longint);

    procedure imlib_blend_image_onto_image_skewed(source_image:Imlib_Image; merge_alpha:char; source_x:longint; source_y:longint; source_width:longint; 
                source_height:longint; destination_x:longint; destination_y:longint; h_angle_x:longint; h_angle_y:longint; 
                v_angle_x:longint; v_angle_y:longint);

    procedure imlib_render_image_on_drawable_skewed(source_x:longint; source_y:longint; source_width:longint; source_height:longint; destination_x:longint; 
                destination_y:longint; h_angle_x:longint; h_angle_y:longint; v_angle_x:longint; v_angle_y:longint);

    procedure imlib_render_image_on_drawable_at_angle(source_x:longint; source_y:longint; source_width:longint; source_height:longint; destination_x:longint; 
                destination_y:longint; angle_x:longint; angle_y:longint);

    procedure imlib_image_filter;

    function imlib_create_filter(initsize:longint):Imlib_Filter;

    procedure imlib_context_set_filter(filter:Imlib_Filter);

    function imlib_context_get_filter:Imlib_Filter;

    procedure imlib_free_filter;

    procedure imlib_filter_set(xoff:longint; yoff:longint; a:longint; r:longint; g:longint; 
                b:longint);

    procedure imlib_filter_set_alpha(xoff:longint; yoff:longint; a:longint; r:longint; g:longint; 
                b:longint);

    procedure imlib_filter_set_red(xoff:longint; yoff:longint; a:longint; r:longint; g:longint; 
                b:longint);

    procedure imlib_filter_set_green(xoff:longint; yoff:longint; a:longint; r:longint; g:longint; 
                b:longint);

    procedure imlib_filter_set_blue(xoff:longint; yoff:longint; a:longint; r:longint; g:longint; 
                b:longint);

    procedure imlib_filter_constants(a:longint; r:longint; g:longint; b:longint);

    procedure imlib_filter_divisors(a:longint; r:longint; g:longint; b:longint);

    procedure imlib_apply_filter(script:pchar; args:array of const);

    procedure imlib_image_clear;

    procedure imlib_image_clear_color(r:longint; g:longint; b:longint; a:longint);

}

implementation


end.
