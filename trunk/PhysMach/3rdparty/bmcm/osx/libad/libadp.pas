
unit libadp;
interface

uses
  ctypes;

{
  Automatically converted by H2Pas 1.0.0 from libado.h
  The following command line parameters were used:
    -d
    -e
    -C
    -w
    -l
    libad4
    -o
    libadp.pas
    libado.h
}

  const
    External_library='libad4'; {Setup as you need}

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  { libad.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
    }
{$ifndef LIBAD__H}
{$define LIBAD__H}  
{ C++ extern C conditionnal removed }
  {#include "libad_types.h" }
  { libad_types.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * basic contants and types
    }
  {#include "libad_os.h" }
  { libad_os.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * bit-sized integer types (unix)
    }
{$ifndef CONFIG_STDINT}

  const
     CONFIG_STDINT = 1;     
{$endif}
{$ifdef CONFIG_STDINT}
  {#include <stdint.h> }
{$else}
  { !CONFIG_STDINT  }
{$ifndef BIT_TYPES}

  const
     BIT_TYPES = 1;     
{$endif}
  { !BIT_TYPES  }

  type

     uint8_t = cuchar;

     uint16_t = cushort;

     uint32_t = ^cardinal;

     uint64_t = culonglong;
	 
	 int32_t = longint;
	 
	 int64_t = cardinal;
	 
	 pchar = ^char;
	 
 {was $include <sys/types.h>}
{$endif}
  { !CONFIG_STDINT  }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function ad_invalid_driver_version(x : longint) : longint;  

  { channel types
   *
   * high order byte defines channel type
   * low order 24 bits define channel id
    }

  const
     AD_CHA_TYPE_MASK = $ff000000;     
     AD_CHA_TYPE_ANALOG_IN = $01000000;     
     AD_CHA_TYPE_ANALOG_OUT = $02000000;     
     AD_CHA_TYPE_DIGITAL_IO = $03000000;     
     AD_CHA_TYPE_ROUTE = $06000000;     
     AD_CHA_TYPE_CAN = $07000000;     
     AD_CHA_TYPE_COUNTER = $08000000;     
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function ad_cha_type(x : longint) : longint;  

  { this is AD_CHA_TYPE_DIGITAL_IO, but
   * ad_get_next_run_f returns that channel
   * as long (instead of float)
    }

  const
     AD_CHA_TYPE_DIGITAL_LONG = $0b000000;     
  { device information structure
    }
  { OUT   number of analog inputs  }
  { OUT   number of analog outputs  }
  { OUT   number of digital i/o's  }

  type
     ad_device_info = record
          analog_in : int32_t;
          analog_out : int32_t;
          digital_io : int32_t;
          res : array[0..4] of int32_t;
       end;

  { magic analog/digital sample type
    }
     ad = record
         case longint of
            0 : ( a : cfloat );
            1 : ( d : int32_t );
         end;


     ad_t = ad;
  { range information structure
    }
  { OUT   minimum of range  }
  { OUT   maximum of range  }
  { OUT   resolution  }
  { OUT   bytes per sample  }
  { OUT   unit  }
     ad_range_info = record
          min : double;
          max : double;
          res : double;
          resv : array[0..4] of double;
          bps : cint;
          units : array[0..23] of cchar;
       end;

  {#include "libad_basic.h" }
  { libad_basic.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * defines basic operations, including discrete i/o
    }
  { macros used to parse version id
    }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MAJOR_VERS(x : longint) : cuchar;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MINOR_VERS(x : longint) : cuchar;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_BUILD_VERS(x : longint) : cushort;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_VERS(mj,mn,build : longint) : longint;  

  { return current LIBAD version
    }
  function ad_get_version:uint32_t;cdecl;external External_library name 'ad_get_version';

  { open driver
   *
   * common names are
   *
   *   "PCI300" - PCI-Base 300/50
   *   "P1000"  - P1000, PC20NV
   *   "PC20"   - PC20TR, PC16
   *   "PIOII"  - PIO24II, PIO48II
   *
   * returns handle of driver, or -1 on failure
    }
(* Const before type ignored *)
  function ad_open(name:pchar):int32_t;cdecl;external External_library name 'ad_open';

  { close driver
   *
   * adh is the handle returned by ad_open
   *
   * returns 0 on success, otherwise error code
    }
  function ad_close(adh:int32_t):int32_t;cdecl;external External_library name 'ad_close';

  { gets device information
   *
   * adh is the handle returned by ad_open
   *
   * returns 0 on success, otherwise error code
    }
  function ad_get_dev_info(adh:int32_t; var info:ad_device_info):int32_t;cdecl;external External_library name 'ad_get_dev_info';

  { get discrete sample
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   (ptr to) variable to receive sample
   *
   * returns 0 on success, otherwise error code
    }
  function ad_discrete_in(adh:int32_t; cha:int32_t; range:int32_t; var data:uint32_t):int32_t;cdecl;external External_library name 'ad_discrete_in';

  function ad_discrete_in64(adh:int32_t; cha:int32_t; range:uint64_t; var data:uint64_t):int32_t;cdecl;external External_library name 'ad_discrete_in64';

  function ad_discrete_inv(adh:int32_t; chac:int32_t; chav:array of int32_t; rangev:array of uint64_t; datav:array of uint64_t):int32_t;cdecl;external External_library name 'ad_discrete_inv';

  { output discrete sample
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample to output
   *
   * returns 0 on success, otherwise error code
    }
  function ad_discrete_out(adh:int32_t; cha:int32_t; range:int32_t; data:uint32_t):int32_t;cdecl;external External_library name 'ad_discrete_out';

  function ad_discrete_out64(adh:int32_t; cha:int32_t; range:uint64_t; data:uint64_t):int32_t;cdecl;external External_library name 'ad_discrete_out64';

  function ad_discrete_outv(adh:int32_t; chac:int32_t; chav:array of int32_t; rangev:array of uint64_t; datav:array of uint64_t):int32_t;cdecl;external External_library name 'ad_discrete_outv';

  { convert sample to float
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample
   * dbl    converted sample
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_sample_to_float(adh:int32_t; cha:int32_t; range:int32_t; data:uint32_t; var dbl:cfloat):int32_t;cdecl;external External_library name 'ad_sample_to_float';

  function ad_sample_to_float64(adh:int32_t; cha:int32_t; range:uint64_t; data:uint64_t; var dbl:double):int32_t;cdecl;external External_library name 'ad_sample_to_float64';

  { convert float to sample
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample
   * dbl    converted sample
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_float_to_sample(adh:int32_t; cha:int32_t; range:int32_t; dbl:cfloat; var sample:uint32_t):int32_t;cdecl;external External_library name 'ad_float_to_sample';

  function ad_float_to_sample64(adh:int32_t; cha:int32_t; range:uint64_t; dbl:double; var sample:uint64_t):int32_t;cdecl;external External_library name 'ad_float_to_sample64';

  { get direction of i/o lines
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * mask   bitmask of i/o direction (lsb defines line #1,
   *        every input is set, outputs are reset)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_get_line_direction(adh:int32_t; cha:int32_t; var mask:uint32_t):int32_t;cdecl;external External_library name 'ad_get_line_direction';

  { set direction of i/o lines
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * mask   bitmask of i/o direction (lsb defines line #1,
   *        every bit set changes line direction to input)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_set_line_direction(adh:int32_t; cha:int32_t; mask:int64_t):int32_t;cdecl;external External_library name 'ad_set_line_direction';

  { get analog input (helper function, calls nothing but
   * ad_discrete_in (..., AD_CHA_TYPE_ANALOG_IN | cha, ...)
   * and ad_sample_to_float ())
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   (ptr to) variable to receive sample
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_analog_in(adh:int32_t; cha:int32_t; range:int32_t; var data:cfloat):int32_t;cdecl;external External_library name 'ad_analog_in';

  { get digital input (helper function, calls nothing but
   * ad_discrete_in (..., AD_CHA_TYPE_DIGITAL_IO | cha, ...))
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * data   (ptr to) variable to receive sample
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_digital_in(adh:int32_t; cha:int32_t; var data:uint32_t):int32_t;cdecl;external External_library name 'ad_digital_in';

  { output to analog channel (helper function, calls nothing but
   * ad_float_to_sample () and
   * ad_discrete_out (..., AD_CHA_TYPE_ANALOG_OUT | cha, ...))
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample to output
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_analog_out(adh:int32_t; cha:int32_t; range:int32_t; data:cfloat):int32_t;cdecl;external External_library name 'ad_analog_out';

  { output to digital channel (helper function, calls nothing but
   * ad_discrete_out (..., AD_CHA_TYPE_DIGITAL_IO | cha, ...))
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample to output
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_digital_out(adh:int32_t; cha:int32_t; data:int64_t):int32_t;cdecl;external External_library name 'ad_digital_out';

  { digital i/o helpers - mainly for "programming"
   * languages that don't know how to 1 << line
    }
  function ad_set_digital_line(adh:int32_t; cha:int32_t; line:int32_t; data:uint32_t):int32_t;cdecl;external External_library name 'ad_set_digital_line';

  function ad_get_digital_line(adh:int32_t; cha:int32_t; line:int32_t; var data:uint32_t):int32_t;cdecl;external External_library name 'ad_get_digital_line';

  { range information
    }
  function ad_get_range_count(adh:int32_t; cha:int32_t; var cnt:int32_t):int32_t;cdecl;external External_library name 'ad_get_range_count';

  function ad_get_range_info(adh:int32_t; cha:int32_t; range:int32_t; var info:ad_range_info):int32_t;cdecl;external External_library name 'ad_get_range_info';

  function ad_get_range_info64(adh:int32_t; cha:int32_t; range:uint64_t; var info:ad_range_info):int32_t;cdecl;external External_library name 'ad_get_range_info64';

  { ioctl call (driver specific)
   *
   * adh    handle returned by ad_open
   * ioc    i/o control code
   * p      data buffer
   * size   size of data buffer (bytes)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_ioctl(adh:int32_t; ioc:int32_t; var p:pointer; size:int32_t):int32_t;cdecl;external External_library name 'ad_ioctl';

  { return current driver version
    }
  function ad_get_drv_version(adh:int32_t; var vers:uint32_t):int32_t;cdecl;external External_library name 'ad_get_drv_version';

  { return product information
    }
  { serial number  }
  { firmware version  }
  { model name  }

  type
     ad_product_info = record
          serial : uint32_t;
          fw_version : uint32_t;
          model : array[0..31] of cchar;
          res : array[0..255] of uint8_t;
       end;


  function ad_get_product_info(adh:int32_t; id:cint; var info:ad_product_info; size:int32_t):int32_t;cdecl;external External_library name 'ad_get_product_info';

  {#include "libad_scan.h" }
  { libad_scan.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * defines scan operation
    }
  { what to store
    }

  const
     AD_STORE_DISCRETE = $0001;     
     AD_STORE_AVERAGE = $0002;     
     AD_STORE_MIN = $0004;     
     AD_STORE_MAX = $0008;     
     AD_STORE_RMS = $0010;     
  { trigger mode
    }
     AD_TRG_NONE = $00;     
     AD_TRG_POSITIVE = $01;     
     AD_TRG_NEGATIVE = $02;     
     AD_TRG_INSIDE = $03;     
     AD_TRG_OUTSIDE = $04;     
     AD_TRG_DIGITAL = $80;     
     AD_TRG_NEVER = $ff;     
  { alarm mode
    }
     AD_ALARM_NONE = $00;     
     AD_ALARM_POSITIVE = $01;     
     AD_ALARM_NEGATIVE = $02;     
     AD_ALARM_INSIDE = $03;     
     AD_ALARM_OUTSIDE = $04;     
  { scan descriptor
   *
   * defines scan settings of a single channel
    }
  { IN    channel type and id  }
  { IN    range number (driver specific)  }
  { IN    what to sample  }
  { IN    scan ratio  }
  { IN    physical 0.0  }
  { IN    trigger mode  }
  { IN    alarm mode  }
  { IN    trigger parameters  }
  { OUT   number of samples per run  }
  { IN    alarm parameters  }

  type
     ad_scan_cha_desc = record
          cha : int32_t;
          range : int32_t;
          store : int32_t;
          ratio : int32_t;
          zero : uint32_t;
          trg_mode : uint8_t;
          alarm_mode : uint8_t;
          sc_res1 : array[0..1] of uint8_t;
          trg_par : array[0..1] of uint32_t;
          samples_per_run : int32_t;
          alarm_par : array[0..1] of uint32_t;
          sc_res2 : array[0..4] of uint32_t;
       end;

  { INOUT sampling rate (sec)  }
  { IN    ref clock rate (sec)  }
  { IN    number of samples prehistory  }
  { IN    number of samples posthistory  }
  { INOUT number of ticks per run  }
  { OUT   bytes per run  }
  { OUT   samples per run  }
  { INOUT scan flags  }
     ad_scan_desc = record
          sample_rate : double;
          clock_rate : double;
          prehist : uint64_t;
          posthist : uint64_t;
          ticks_per_run : uint32_t;
          bytes_per_run : uint32_t;
          samples_per_run : uint32_t;
          flags : uint32_t;
          sd_res : array[0..11] of uint32_t;
       end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_DESC(ctrl,off,len : longint; nbo,sgn : boolean; moff,mlen : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_LEN(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_OFF(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_CTRL(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_NBO(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_SGN(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_MOFF(id : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_MLEN(id : longint) : longint;  


  const
     AD_CAN_MMASK = $ffff0000;     
  { merge can parameters into ad_scan_cha_desc
    }
  {#define ad_set_can_cha(cha,ctrl,off,len,nbo,sgn,id,moff,mlen) \
  	(cha)->cha = AD_CHA_TYPE_CAN|(((ctrl) & 0x03) << 12) \
  	(cha)->range = AD_CAN_DESC(0,off,len,nbo,sgn,moff,mlen)\
  	(cha)->sc_res2[0] = (id)
  
  
  /* scan information structure
    }
     AD_SF_SCANNING = $00000001;     
  { scan has triggered  }
     AD_SF_TRIGGER = $00000002;     
  { synchronize internal clock to external clock  }
     AD_SF_SYNCLOCK = $00000001;     
  { interleave every 2nd channel  }
     AD_SF_INTERLEAVE = $00000100;     
  { use external clock  }
     AD_SF_EXTCLOCK = $00000200;     
  { OUT   scan flags  }
  { OUT   number of runs ready to read  }
  { OUT   posthistory samples remaining  }

  type
     ad_scan_state = record
          flags : int32_t;
          runs_pending : int32_t;
          posthist : int64_t;
       end;

  { structure used to carry scan position
    }

     ad_run_t = uint32_t;
  { OUT   id of run  }
  { OUT   run offset  }
     ad_scan_pos = record
          run : ad_run_t;
          offset : uint32_t;
       end;

  {
  #define ad_scan_pos_lt(a,b) \
    ((a)->run < (b)->run      \
     || ((a)->run == (b)->run && (a)->offset < (b)->offset))
  
  #define ad_scan_pos_ne(a,b) \
    ((a)->run != (b)->run     \
     || (a)->offset != (b)->offset)
   }

  procedure ad_scan_pos_add(run_size:uint32_t; var res:ad_scan_pos; offset:uint64_t);cdecl;external External_library name 'ad_scan_pos_add';

  procedure ad_scan_pos_sub(run_size:uint32_t; var res:ad_scan_pos; offset:uint64_t);cdecl;external External_library name 'ad_scan_pos_sub';

  { information available for each sampled channel
   * - only after the scan is done
    }

  type
     ad_cha_layout = record
          start : ad_scan_pos;
          prehist_samples : int64_t;
          posthist_samples : int64_t;
          t0 : double;
       end;

  { start scan operation
   *
   * adh    handle returned by ad_open
   *
   * returns 0 on success, otherwise error code
    }

  function ad_start_scan(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_start_scan';

  function ad_start_mux_scan(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_start_mux_scan';

  function ad_calc_run_size(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_calc_run_size';

  function ad_prep_scan(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_prep_scan';

  function ad_start_prepared_scan(adh:int32_t):int32_t;cdecl;external External_library name 'ad_start_prepared_scan';

  { start scan helpers
    }
  function ad_start_scan_v(adh:int32_t; sample_rate:double; posthist:uint32_t; chac:uint32_t; var chav:int32_t; 
             rangec:uint32_t; var rangev:int32_t):int32_t;cdecl;external External_library name 'ad_start_scan_v';

  function ad_start_mem_scan(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_start_mem_scan';

  function ad_prep_mem_scan(adh:int32_t; var sd:ad_scan_desc; chac:uint32_t; var chav:ad_scan_cha_desc):int32_t;cdecl;external External_library name 'ad_prep_mem_scan';

  { stop scan
    }
  function ad_stop_scan(adh:int32_t; var result:int32_t):int32_t;cdecl;external External_library name 'ad_stop_scan';

  { get next available run (blocks until run is ready)
   *
   * adh    handle returned by ad_open
   * state  current state information 
   * run    id of returned run
   * p      buffer to receive data of next run
   *
   * returns 0 on success, otherwise error code
    }
  function ad_get_next_run(adh:int32_t; var state:ad_scan_state; var run:uint32_t; var p:pointer):int32_t;cdecl;external External_library name 'ad_get_next_run';

  function ad_get_next_run_f(adh:int32_t; var state:ad_scan_state; var run:uint32_t; var p:cfloat):int32_t;cdecl;external External_library name 'ad_get_next_run_f';

  { get buffer ptr 
    }
(* Const before type ignored *)
  function ad_next_buffer(adh:int32_t; var buf:pointer; var next:pointer):int32_t;cdecl;external External_library name 'ad_next_buffer';

  function ad_next_run(adh:int32_t; var state:ad_scan_state; var run:uint32_t; var buf:pointer):int32_t;cdecl;external External_library name 'ad_next_run';

  { get current scan state
    }
  function ad_poll_scan_state(adh:int32_t; var state:ad_scan_state):int32_t;cdecl;external External_library name 'ad_poll_scan_state';


  type
     ad_timeval = record
          tv_sec : uint64_t;
          tv_usec : uint32_t;
       end;


  function ad_get_scan_start(adh:int32_t; var scan_start:ad_timeval):int32_t;cdecl;external External_library name 'ad_get_scan_start';

  { return trigger information
    }
  function ad_get_trigger_pos(adh:int32_t; var pos:ad_scan_pos):int32_t;cdecl;external External_library name 'ad_get_trigger_pos';

  function ad_set_trigger_pos(adh:int32_t; var pos:ad_scan_pos):int32_t;cdecl;external External_library name 'ad_set_trigger_pos';

  function ad_get_channel_layout(adh:int32_t; idx:cint; var layout:ad_cha_layout):int32_t;cdecl;external External_library name 'ad_get_channel_layout';

{ C++ end of extern C conditionnal removed }
{$endif}
  { !LIBAD__H  }

implementation

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function ad_invalid_driver_version(x : longint) : longint;
    begin
       ad_invalid_driver_version:=0;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function ad_cha_type(x : longint) : longint;
    begin
       ad_cha_type:= x and $ff000000;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MAJOR_VERS(x : longint) : cuchar;
    begin
       AD_MAJOR_VERS:=cuchar(x shr 24);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MINOR_VERS(x : longint) : cuchar;
    begin
       AD_MINOR_VERS:=cuchar(x shr 16);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_BUILD_VERS(x : longint) : cushort;
    begin
       AD_BUILD_VERS:=cushort(x);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_VERS(mj,mn,build : longint) : longint;
    begin
       AD_VERS:=((mj shl 24) or (mn shl 16)) or build;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_DESC(ctrl,off,len:longint; nbo,sgn: boolean ;moff,mlen : longint) : longint;
    var
       if_local1, if_local2 : longint;
    (* result types are not known *)
    begin
       if nbo then
         if_local1:=$4000
       else
         if_local1:=0;
       if sgn then
         if_local2:=$8000
       else
         if_local2:=0;
       AD_CAN_DESC:=((((((len and $3f) or ((off and $3f) shl 6)) or ((ctrl and $03) shl 12)) or (if_local1)) or (if_local2)) or ((moff and $3f) shl 16)) or ((mlen and $3f) shl 22);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_LEN(id : longint) : longint;
    begin
       AD_CAN_LEN:=id and $3f;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_OFF(id : longint) : longint;
    begin
       AD_CAN_OFF:=(id shr 6) and $3f;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_CTRL(id : longint) : longint;
    begin
       AD_CAN_CTRL:=(id shr 12) and $03;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_NBO(id : longint) : longint;
    begin
       AD_CAN_NBO:=id and $4000;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_SGN(id : longint) : longint;
    begin
       AD_CAN_SGN:=id and $8000;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_MOFF(id : longint) : longint;
    begin
       AD_CAN_MOFF:=(id shr 16) and $3f;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_MLEN(id : longint) : longint;
    begin
       AD_CAN_MLEN:=(id shr 22) and $3f;
    end;


end.
