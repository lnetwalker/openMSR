
unit comedilib;
interface

const
  CS_MAX_AREFS_LENGTH = 4;
type
  TArray0toCS_MAX_AREFS_LENGTH1OfDword = array[0..(CS_MAX_AREFS_LENGTH)-1] of dword;

const
  COMEDI_MAX_NUM_POLYNOMIAL_COEFFICIENTS = 4;
type
  TArray0toCOMEDI_MAX_NUM_POLYNOMIAL_COEFFICIENTS1OfDouble = array[0..(COMEDI_MAX_NUM_POLYNOMIAL_COEFFICIENTS)-1] of double;

{
  Automatically converted by H2Pas 1.0.0 from /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib.tmp.h
  The following command line parameters were used:
    -e
    -p
    -D
    -w
    -o
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib.pas
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedilib.tmp.h
}

  const
    External_library='kernel32'; {Setup as you need}

  { Pointers to basic pascal types, inserted by h2pas conversion program.}
  






  Type

  comedi_caldac_t = record
          subdevice : dword;
          channel : dword;
          value : dword;
       end;
  Pcomedi_caldac_t  = ^comedi_caldac_t;
  comedi_polynomial_t = record
          coefficients : TArray0toCOMEDI_MAX_NUM_POLYNOMIAL_COEFFICIENTS1OfDouble;
          expansion_origin : double;
          order : dword;
       end;
  Pcomedi_polynomial_t  = ^comedi_polynomial_t;
  comedi_softcal_t = record
          to_phys : Pcomedi_polynomial_t;
          from_phys : Pcomedi_polynomial_t;
       end;
  comedi_calibration_setting_t = record
          subdevice : dword;
          channels : Pdword;
          num_channels : dword;
          ranges : Pdword;
          num_ranges : dword;
          arefs : TArray0toCS_MAX_AREFS_LENGTH1OfDword;
          num_arefs : dword;
          caldacs : Pcomedi_caldac_t;
          num_caldacs : dword;
          soft_calibration : comedi_softcal_t;
       end;
  Pcomedi_calibration_setting_t  = ^comedi_calibration_setting_t;
  comedi_calibration_t = record
          driver_name : Pchar;
          board_name : Pchar;
          settings : Pcomedi_calibration_setting_t;
          num_settings : dword;
       end;
  Pcomedi_calibration_t  = ^comedi_calibration_t;
  comedi_conversion_direction =  Longint;
  Pcomedi_conversion_direction  = ^comedi_conversion_direction;
  comedi_oor_behavior =  Longint;
  Pcomedi_oor_behavior  = ^comedi_oor_behavior;
  comedi_range = record
          min : double;
          max : double;
          comedi_unit : dword;
       end;
  Pcomedi_range  = ^comedi_range;
  Pcomedi_softcal_t  = ^comedi_softcal_t;
  Pcomedi_t  = ^comedi_t;
  comedi_sv_struct = record
          dev : Pcomedi_t;
          subdevice : dword;
          chan : dword;
          range : longint;
          aref : longint;
          n : longint;
          maxdata : lsampl_t;
       end;
  Pcomedi_sv_struct  = ^comedi_sv_struct;
  comedi_sv_t = comedi_sv_struct;
  Pcomedi_sv_t  = ^comedi_sv_t;

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  {
      include/comedilib.h
      header file for the comedi library routines
  
      COMEDI - Linux Control and Measurement Device Interface
      Copyright (C) 1998-2002 David A. Schleef <ds@schleef.org>
  
      This program is free software; you can redistribute it and/or modify
      it under the terms of the GNU Lesser General Public License as published by
      the Free Software Foundation; either version 2 of the License, or
      (at your option) any later version.
  
      This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details.
  
      You should have received a copy of the GNU General Public License
      along with this program; if not, write to the Free Software
      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  
   }
{$ifndef _COMEDILIB_H}
{$DEFINE H2PAS_FUNCTION_1}





  type
     comedi_t_struct = comedi_t;

  { range policy  }
  { number of measurements to average (for ai)  }

     Const
       COMEDI_OOR_NUMBER = 0;
       COMEDI_OOR_NAN = 1;

(* Const before type ignored *)

  function comedi_open(fn:Pchar):Pcomedi_t;cdecl;external External_library name 'comedi_open';

  function comedi_close(var it:comedi_t):longint;cdecl;external External_library name 'comedi_close';

  { logging  }
  function comedi_loglevel(loglevel:longint):longint;cdecl;external External_library name 'comedi_loglevel';

(* Const before type ignored *)
  procedure comedi_perror(s:Pchar);cdecl;external External_library name 'comedi_perror';

  function comedi_strerror(errnum:longint):Pchar;cdecl;external External_library name 'comedi_strerror';

  function comedi_errno:longint;cdecl;external External_library name 'comedi_errno';

  function comedi_fileno(var it:comedi_t):longint;cdecl;external External_library name 'comedi_fileno';

  { global behavior  }
  {enum comedi_oor_behavior comedi_set_global_oor_behavior(enum comedi_oor_behavior behavior); }
  { device queries  }
  function comedi_get_n_subdevices(var it:comedi_t):longint;cdecl;external External_library name 'comedi_get_n_subdevices';

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function COMEDI_VERSION_CODE(a,b,c : longint) : longint;  

  function comedi_get_version_code(var it:comedi_t):longint;cdecl;external External_library name 'comedi_get_version_code';

(* Const before type ignored *)
  function comedi_get_driver_name(var it:comedi_t):Pchar;cdecl;external External_library name 'comedi_get_driver_name';

(* Const before type ignored *)
  function comedi_get_board_name(var it:comedi_t):Pchar;cdecl;external External_library name 'comedi_get_board_name';

  function comedi_get_read_subdevice(var dev:comedi_t):longint;cdecl;external External_library name 'comedi_get_read_subdevice';

  function comedi_get_write_subdevice(var dev:comedi_t):longint;cdecl;external External_library name 'comedi_get_write_subdevice';

  { subdevice queries  }
  function comedi_get_subdevice_type(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_get_subdevice_type';

  function comedi_find_subdevice_by_type(var it:comedi_t; _type:longint; subd:dword):longint;cdecl;external External_library name 'comedi_find_subdevice_by_type';

  function comedi_get_subdevice_flags(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_get_subdevice_flags';

  function comedi_get_n_channels(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_get_n_channels';

  function comedi_range_is_chan_specific(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_range_is_chan_specific';

  function comedi_maxdata_is_chan_specific(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_maxdata_is_chan_specific';

  { channel queries  }
  function comedi_get_maxdata(var it:comedi_t; subdevice:dword; chan:dword):lsampl_t;cdecl;external External_library name 'comedi_get_maxdata';

  function comedi_get_n_ranges(var it:comedi_t; subdevice:dword; chan:dword):longint;cdecl;external External_library name 'comedi_get_n_ranges';

  function comedi_get_range(var it:comedi_t; subdevice:dword; chan:dword; range:dword):Pcomedi_range;cdecl;external External_library name 'comedi_get_range';

  function comedi_find_range(var it:comedi_t; subd:dword; chan:dword; comedi_unit:dword; min:double; 
             max:double):longint;cdecl;external External_library name 'comedi_find_range';

  { buffer queries  }
  function comedi_get_buffer_size(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_get_buffer_size';

  function comedi_get_max_buffer_size(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_get_max_buffer_size';

  function comedi_set_buffer_size(var it:comedi_t; subdevice:dword; len:dword):longint;cdecl;external External_library name 'comedi_set_buffer_size';

  { low-level stuff  }
{$ifdef _COMEDILIB_DEPRECATED}
  function comedi_trigger(var it:comedi_t; var trig:comedi_trig):longint;cdecl;external External_library name 'comedi_trigger';

  { deprecated  }
{$endif}

  function comedi_do_insnlist(var it:comedi_t; var il:comedi_insnlist):longint;cdecl;external External_library name 'comedi_do_insnlist';

  function comedi_do_insn(var it:comedi_t; var insn:comedi_insn):longint;cdecl;external External_library name 'comedi_do_insn';

  function comedi_lock(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_lock';

  function comedi_unlock(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_unlock';

  { physical units  }
  function comedi_to_phys(data:lsampl_t; var rng:comedi_range; maxdata:lsampl_t):double;cdecl;external External_library name 'comedi_to_phys';

  function comedi_from_phys(data:double; var rng:comedi_range; maxdata:lsampl_t):lsampl_t;cdecl;external External_library name 'comedi_from_phys';

  function comedi_sampl_to_phys(var dest:double; dst_stride:longint; var src:sampl_t; src_stride:longint; var rng:comedi_range; 
             maxdata:lsampl_t; n:longint):longint;cdecl;external External_library name 'comedi_sampl_to_phys';

  function comedi_sampl_from_phys(var dest:sampl_t; dst_stride:longint; var src:double; src_stride:longint; var rng:comedi_range; 
             maxdata:lsampl_t; n:longint):longint;cdecl;external External_library name 'comedi_sampl_from_phys';

  { syncronous stuff  }
  function comedi_data_read(var it:comedi_t; subd:dword; chan:dword; range:dword; aref:dword; 
             var data:lsampl_t):longint;cdecl;external External_library name 'comedi_data_read';

  function comedi_data_read_n(var it:comedi_t; subd:dword; chan:dword; range:dword; aref:dword; 
             var data:lsampl_t; n:dword):longint;cdecl;external External_library name 'comedi_data_read_n';

  function comedi_data_read_hint(var it:comedi_t; subd:dword; chan:dword; range:dword; aref:dword):longint;cdecl;external External_library name 'comedi_data_read_hint';

  function comedi_data_read_delayed(var it:comedi_t; subd:dword; chan:dword; range:dword; aref:dword; 
             var data:lsampl_t; nano_sec:dword):longint;cdecl;external External_library name 'comedi_data_read_delayed';

  function comedi_data_write(var it:comedi_t; subd:dword; chan:dword; range:dword; aref:dword; 
             data:lsampl_t):longint;cdecl;external External_library name 'comedi_data_write';

  function comedi_dio_config(var it:comedi_t; subd:dword; chan:dword; dir:dword):longint;cdecl;external External_library name 'comedi_dio_config';

  function comedi_dio_get_config(var it:comedi_t; subd:dword; chan:dword; var dir:dword):longint;cdecl;external External_library name 'comedi_dio_get_config';

  function comedi_dio_read(var it:comedi_t; subd:dword; chan:dword; var bit:dword):longint;cdecl;external External_library name 'comedi_dio_read';

  function comedi_dio_write(var it:comedi_t; subd:dword; chan:dword; bit:dword):longint;cdecl;external External_library name 'comedi_dio_write';

  function comedi_dio_bitfield2(var it:comedi_t; subd:dword; write_mask:dword; var bits:dword; base_channel:dword):longint;cdecl;external External_library name 'comedi_dio_bitfield2';

  { Should be moved to _COMEDILIB_DEPRECATED once bindings for other languages are updated
   * to use comedi_dio_bitfield2() instead. }
  function comedi_dio_bitfield(var it:comedi_t; subd:dword; write_mask:dword; var bits:dword):longint;cdecl;external External_library name 'comedi_dio_bitfield';

  { slowly varying stuff  }
  function comedi_sv_init(var it:comedi_sv_t; var dev:comedi_t; subd:dword; chan:dword):longint;cdecl;external External_library name 'comedi_sv_init';

  function comedi_sv_update(var it:comedi_sv_t):longint;cdecl;external External_library name 'comedi_sv_update';

  function comedi_sv_measure(var it:comedi_sv_t; var data:double):longint;cdecl;external External_library name 'comedi_sv_measure';

  { streaming I/O (commands)  }
  function comedi_get_cmd_src_mask(var dev:comedi_t; subdevice:dword; var cmd:comedi_cmd):longint;cdecl;external External_library name 'comedi_get_cmd_src_mask';

  function comedi_get_cmd_generic_timed(var dev:comedi_t; subdevice:dword; var cmd:comedi_cmd; chanlist_len:dword; scan_period_ns:dword):longint;cdecl;external External_library name 'comedi_get_cmd_generic_timed';

  function comedi_cancel(var it:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_cancel';

  function comedi_command(var it:comedi_t; var cmd:comedi_cmd):longint;cdecl;external External_library name 'comedi_command';

  function comedi_command_test(var it:comedi_t; var cmd:comedi_cmd):longint;cdecl;external External_library name 'comedi_command_test';

  function comedi_poll(var dev:comedi_t; subdevice:dword):longint;cdecl;external External_library name 'comedi_poll';

  { buffer control  }
  function comedi_set_max_buffer_size(var it:comedi_t; subdev:dword; max_size:dword):longint;cdecl;external External_library name 'comedi_set_max_buffer_size';

  function comedi_get_buffer_contents(var it:comedi_t; subdev:dword):longint;cdecl;external External_library name 'comedi_get_buffer_contents';

  function comedi_mark_buffer_read(var it:comedi_t; subdev:dword; bytes:dword):longint;cdecl;external External_library name 'comedi_mark_buffer_read';

  function comedi_mark_buffer_written(var it:comedi_t; subdev:dword; bytes:dword):longint;cdecl;external External_library name 'comedi_mark_buffer_written';

  function comedi_get_buffer_offset(var it:comedi_t; subdev:dword):longint;cdecl;external External_library name 'comedi_get_buffer_offset';

{$ifdef _COMEDILIB_DEPRECATED}
  {
   * The following functions are deprecated and should not be used.
    }
  function comedi_get_timer(var it:comedi_t; subdev:dword; freq:double; var trigvar:dword; var actual_freq:double):longint;cdecl;external External_library name 'comedi_get_timer';

  function comedi_timed_1chan(var it:comedi_t; subdev:dword; chan:dword; range:dword; aref:dword; 
             freq:double; n_samples:dword; var data:double):longint;cdecl;external External_library name 'comedi_timed_1chan';

  function comedi_get_rangetype(var it:comedi_t; subdevice:dword; chan:dword):longint;cdecl;external External_library name 'comedi_get_rangetype';

{$endif}
{$ifndef _COMEDILIB_STRICT_ABI}
  {
     The following prototypes are _NOT_ part of the Comedilib ABI, and
     may change in future versions without regard to source or binary
     compatibility.  In practice, this is a holding place for the next
     library ABI version change.
    }
  { structs and functions used for parsing calibration files  }

(* Const before type ignored *)

  function comedi_parse_calibration_file(cal_file_path:Pchar):Pcomedi_calibration_t;cdecl;external External_library name 'comedi_parse_calibration_file';

(* Const before type ignored *)
  function comedi_apply_parsed_calibration(var dev:comedi_t; subdev:dword; channel:dword; range:dword; aref:dword; 
             var calibration:comedi_calibration_t):longint;cdecl;external External_library name 'comedi_apply_parsed_calibration';

  function comedi_get_default_calibration_path(var dev:comedi_t):Pchar;cdecl;external External_library name 'comedi_get_default_calibration_path';

  procedure comedi_cleanup_calibration(var calibration:comedi_calibration_t);cdecl;external External_library name 'comedi_cleanup_calibration';

(* Const before type ignored *)
  function comedi_apply_calibration(var dev:comedi_t; subdev:dword; channel:dword; range:dword; aref:dword; 
             cal_file_path:Pchar):longint;cdecl;external External_library name 'comedi_apply_calibration';

  { New stuff to provide conversion between integers and physical values that
  * can support software calibrations.  }

     Const
       COMEDI_TO_PHYSICAL = 0;
       COMEDI_FROM_PHYSICAL = 1;

(* Const before type ignored *)

  function comedi_get_softcal_converter(subdevice:dword; channel:dword; range:dword; direction:comedi_conversion_direction; var calibration:comedi_calibration_t; 
             var polynomial:comedi_polynomial_t):longint;cdecl;external External_library name 'comedi_get_softcal_converter';

  function comedi_get_hardcal_converter(var dev:comedi_t; subdevice:dword; channel:dword; range:dword; direction:comedi_conversion_direction; 
             var polynomial:comedi_polynomial_t):longint;cdecl;external External_library name 'comedi_get_hardcal_converter';

(* Const before type ignored *)
  function comedi_to_physical(data:lsampl_t; var conversion_polynomial:comedi_polynomial_t):double;cdecl;external External_library name 'comedi_to_physical';

(* Const before type ignored *)
  function comedi_from_physical(data:double; var conversion_polynomial:comedi_polynomial_t):lsampl_t;cdecl;external External_library name 'comedi_from_physical';

{$endif}
{$endif}

implementation

{$IFDEF H2PAS_FUNCTION_1}
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function COMEDI_VERSION_CODE(a,b,c : longint) : longint;
    begin
       COMEDI_VERSION_CODE:=((a shl 16) or (b shl 8)) or c;
    end;
{$ENDIF H2PAS_FUNCTION_1}


end.
