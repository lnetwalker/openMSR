
unit libadp;
interface



{
  Automatically converted by H2Pas 1.0.0 from libad-p.h
  The following command line parameters were used:
    -D
    libad-p.h
}

    const
      External_library='libad4'; {Setup as you need}

    Type
     uint8_t = byte;

     uint16_t = word;

       ad_timeval = record
            tv_sec : cardinal;
            tv_usec : cardinal;
         end;

       ad_scan_state = record
            flags : longint;
            runs_pending : longint;
            posthist : cardinal;
         end;

    { structure used to carry scan position
      }

       ad_run_t = cardinal;
    { OUT   id of run  }
    { OUT   run offset  }
       ad_scan_pos = record
            run : ad_run_t;
            offset : cardinal;
         end;

     ad_device_info = record
          analog_in : longint;
          analog_out : longint;
          digital_io : longint;
          res : array[0..4] of longint;
       end;

  { magic analog/digital sample type
    }
     ad = record
         case longint of
            0 : ( a : double );
            1 : ( d : longint );
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
          bps : longint;
          units : array[0..23] of char;
       end;

       ad_cha_layout = record
            start : ad_scan_pos;
            prehist_samples : cardinal;
            posthist_samples : cardinal;
            t0 : double;
         end;

     ad_product_info = record
          serial : cardinal;
          fw_version : cardinal;
          model : array[0..31] of char;
          res : array[0..255] of uint8_t;
       end;

     ad_scan_cha_desc = record
          cha : longint;
          range : longint;
          store : longint;
          ratio : longint;
          zero : cardinal;
          trg_mode : uint8_t;
          alarm_mode : uint8_t;
          sc_res1 : array[0..1] of uint8_t;
          trg_par : array[0..1] of cardinal;
          samples_per_run : longint;
          alarm_par : array[0..1] of cardinal;
          sc_res2 : array[0..4] of cardinal;
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
          prehist : cardinal;
          posthist : cardinal;
          ticks_per_run : cardinal;
          bytes_per_run : cardinal;
          samples_per_run : cardinal;
          flags : cardinal;
          sd_res : array[0..11] of cardinal;
       end;


    Pad_cha_layout  = ^ad_cha_layout;
    Pad_device_info  = ^ad_device_info;
    Pad_product_info  = ^ad_product_info;
    Pad_range_info  = ^ad_range_info;
    Pad_scan_cha_desc  = ^ad_scan_cha_desc;
    Pad_scan_desc  = ^ad_scan_desc;
    Pad_scan_pos  = ^ad_scan_pos;
    Pad_scan_state  = ^ad_scan_state;
    Pad_timeval  = ^ad_timeval;
    Pchar  = ^char;
    Pdouble  = ^double;
    Plongint  = ^longint;
    Pcardinal  = ^cardinal;

{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  { libad.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
    }
{ C++ extern C conditionnal removed }
  { libad_types.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * basic contants and types
    }
  { libad_os.h
   *
   * libad is a simple interface to BMC Messsysteme Drivers
   *
   * bit-sized integer types (unix)
    }


  const
     CONFIG_STDINT = 1;     
     BIT_TYPES = 1;     
  { !BIT_TYPES  }


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
  function AD_MAJOR_VERS(x : longint) : byte;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MINOR_VERS(x : longint) : byte;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_BUILD_VERS(x : longint) : word;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_VERS(mj,mn,build : longint) : longint;  

  { return current LIBAD version
    }
  function ad_get_version:cardinal;cdecl;external External_library name 'ad_get_version';

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
  function ad_open(name:Pchar):longint;cdecl;external External_library name 'ad_open';

  { close driver
   *
   * adh is the handle returned by ad_open
   *
   * returns 0 on success, otherwise error code
    }
  function ad_close(adh:longint):longint;cdecl;external External_library name 'ad_close';

  { gets device information
   *
   * adh is the handle returned by ad_open
   *
   * returns 0 on success, otherwise error code
    }
  function ad_get_dev_info(adh:longint; info:Pad_device_info):longint;cdecl;external External_library name 'ad_get_dev_info';

  { get discrete sample
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   (ptr to) variable to receive sample
   *
   * returns 0 on success, otherwise error code
    }
  function ad_discrete_in(adh:longint; cha:longint; range:longint; data:Pcardinal):longint;cdecl;external External_library name 'ad_discrete_in';

  function ad_discrete_in64(adh:longint; cha:longint; range:cardinal; data:Pcardinal):longint;cdecl;external External_library name 'ad_discrete_in64';

  function ad_discrete_inv(adh:longint; chac:longint; chav:array of longint; rangev:array of cardinal; datav:array of cardinal):longint;cdecl;external External_library name 'ad_discrete_inv';

  { output discrete sample
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * range  range number
   * data   sample to output
   *
   * returns 0 on success, otherwise error code
    }
  function ad_discrete_out(adh:longint; cha:longint; range:longint; data:cardinal):longint;cdecl;external External_library name 'ad_discrete_out';

  function ad_discrete_out64(adh:longint; cha:longint; range:cardinal; data:cardinal):longint;cdecl;external External_library name 'ad_discrete_out64';

  function ad_discrete_outv(adh:longint; chac:longint; chav:array of longint; rangev:array of cardinal; datav:array of cardinal):longint;cdecl;external External_library name 'ad_discrete_outv';

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
  function ad_sample_to_float(adh:longint; cha:longint; range:longint; data:cardinal; dbl:Pdouble):longint;cdecl;external External_library name 'ad_sample_to_float';

  function ad_sample_to_float64(adh:longint; cha:longint; range:cardinal; data:cardinal; dbl:Pdouble):longint;cdecl;external External_library name 'ad_sample_to_float64';

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
  function ad_float_to_sample(adh:longint; cha:longint; range:longint; dbl:double; sample:Pcardinal):longint;cdecl;external External_library name 'ad_float_to_sample';

  function ad_float_to_sample64(adh:longint; cha:longint; range:cardinal; dbl:double; sample:Pcardinal):longint;cdecl;external External_library name 'ad_float_to_sample64';

  { get direction of i/o lines
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * mask   bitmask of i/o direction (lsb defines line #1,
   *        every input is set, outputs are reset)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_get_line_direction(adh:longint; cha:longint; mask:Pcardinal):longint;cdecl;external External_library name 'ad_get_line_direction';

  { set direction of i/o lines
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * mask   bitmask of i/o direction (lsb defines line #1,
   *        every bit set changes line direction to input)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_set_line_direction(adh:longint; cha:longint; mask:cardinal):longint;cdecl;external External_library name 'ad_set_line_direction';

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
  function ad_analog_in(adh:longint; cha:longint; range:longint; data:Pdouble):longint;cdecl;external External_library name 'ad_analog_in';

  { get digital input (helper function, calls nothing but
   * ad_discrete_in (..., AD_CHA_TYPE_DIGITAL_IO | cha, ...))
   *
   * adh    handle returned by ad_open
   * cha    channel type and id
   * data   (ptr to) variable to receive sample
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_digital_in(adh:longint; cha:longint; data:Pcardinal):longint;cdecl;external External_library name 'ad_digital_in';

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
  function ad_analog_out(adh:longint; cha:longint; range:longint; data:double):longint;cdecl;external External_library name 'ad_analog_out';

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
  function ad_digital_out(adh:longint; cha:longint; data:cardinal):longint;cdecl;external External_library name 'ad_digital_out';

  { digital i/o helpers - mainly for "programming"
   * languages that don't know how to 1 << line
    }
  function ad_set_digital_line(adh:longint; cha:longint; line:longint; data:cardinal):longint;cdecl;external External_library name 'ad_set_digital_line';

  function ad_get_digital_line(adh:longint; cha:longint; line:longint; data:Pcardinal):longint;cdecl;external External_library name 'ad_get_digital_line';

  { range information
    }
  function ad_get_range_count(adh:longint; cha:longint; cnt:Plongint):longint;cdecl;external External_library name 'ad_get_range_count';

  function ad_get_range_info(adh:longint; cha:longint; range:longint; info:Pad_range_info):longint;cdecl;external External_library name 'ad_get_range_info';

  function ad_get_range_info64(adh:longint; cha:longint; range:cardinal; info:Pad_range_info):longint;cdecl;external External_library name 'ad_get_range_info64';

  { ioctl call (driver specific)
   *
   * adh    handle returned by ad_open
   * ioc    i/o control code
   * p      data buffer
   * size   size of data buffer (bytes)
   *
   * returns 0 on success, otherwise (WIN32) error code
    }
  function ad_ioctl(adh:longint; ioc:longint; p:pointer; size:longint):longint;cdecl;external External_library name 'ad_ioctl';

  { return current driver version
    }
  function ad_get_drv_version(adh:longint; vers:Pcardinal):longint;cdecl;external External_library name 'ad_get_drv_version';

  { return product information
    }
  { serial number  }
  { firmware version  }
  { model name  }



  function ad_get_product_info(adh:longint; id:longint; info:Pad_product_info; size:longint):longint;cdecl;external External_library name 'ad_get_product_info';

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

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function AD_CAN_DESC(ctrl,off,len,nbo,sgn,moff,mlen : longint) : longint;  

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
(* error 
#define ad_set_can_cha(cha,ctrl,off,len,nbo,sgn,id,moff,mlen) do {                                                        \
in declaration at line 493 *)
(* error 
    (cha)->cha = AD_CHA_TYPE_CAN|(((ctrl) & 0x03) << 12);     \*)
(* error 
    (cha)->range = AD_CAN_DESC(0,off,len,nbo,sgn,moff,mlen);  \
in declaration at line 494 *)
(* error 
    (cha)->range = AD_CAN_DESC(0,off,len,nbo,sgn,moff,mlen);  \*)
(* error 
    (cha)->sc_res2[0] = (id);                                 \
in declaration at line 495 *)
(* error 
    (cha)->sc_res2[0] = (id);                                 \*)
(* error 
  } while (0)
    { scan information structure
      }
in define line 502 *)
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


(* error 
   || ((a)->run == (b)->run && (a)->offset < (b)->offset))
in define line 529 *)
(* error 
   || (a)->offset != (b)->offset)
in define line 533 *)

    procedure ad_scan_pos_add(run_size:cardinal; res:Pad_scan_pos; offset:cardinal);cdecl;external External_library name 'ad_scan_pos_add';

    procedure ad_scan_pos_sub(run_size:cardinal; res:Pad_scan_pos; offset:cardinal);cdecl;external External_library name 'ad_scan_pos_sub';

    { information available for each sampled channel
     * - only after the scan is done
      }

    { start scan operation
     *
     * adh    handle returned by ad_open
     *
     * returns 0 on success, otherwise error code
      }

    function ad_start_scan(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_start_scan';

    function ad_start_mux_scan(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_start_mux_scan';

    function ad_calc_run_size(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_calc_run_size';

    function ad_prep_scan(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_prep_scan';

    function ad_start_prepared_scan(adh:longint):longint;cdecl;external External_library name 'ad_start_prepared_scan';

    { start scan helpers
      }
    function ad_start_scan_v(adh:longint; sample_rate:double; posthist:cardinal; chac:cardinal; chav:Plongint; 
               rangec:cardinal; rangev:Plongint):longint;cdecl;external External_library name 'ad_start_scan_v';

    function ad_start_mem_scan(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_start_mem_scan';

    function ad_prep_mem_scan(adh:longint; sd:Pad_scan_desc; chac:cardinal; chav:Pad_scan_cha_desc):longint;cdecl;external External_library name 'ad_prep_mem_scan';

    { stop scan
      }
    function ad_stop_scan(adh:longint; result:Plongint):longint;cdecl;external External_library name 'ad_stop_scan';

    { get next available run (blocks until run is ready)
     *
     * adh    handle returned by ad_open
     * state  current state information 
     * run    id of returned run
     * p      buffer to receive data of next run
     *
     * returns 0 on success, otherwise error code
      }
    function ad_get_next_run(adh:longint; state:Pad_scan_state; run:Pcardinal; p:pointer):longint;cdecl;external External_library name 'ad_get_next_run';

    function ad_get_next_run_f(adh:longint; state:Pad_scan_state; run:Pcardinal; p:Pdouble):longint;cdecl;external External_library name 'ad_get_next_run_f';

    { get buffer ptr 
      }
(* Const before type ignored *)
    function ad_next_buffer(adh:longint; buf:pointer; next:Ppointer):longint;cdecl;external External_library name 'ad_next_buffer';

    function ad_next_run(adh:longint; state:Pad_scan_state; run:Pcardinal; buf:Ppointer):longint;cdecl;external External_library name 'ad_next_run';

    { get current scan state
      }
    function ad_poll_scan_state(adh:longint; state:Pad_scan_state):longint;cdecl;external External_library name 'ad_poll_scan_state';



    function ad_get_scan_start(adh:longint; scan_start:Pad_timeval):longint;cdecl;external External_library name 'ad_get_scan_start';

    { return trigger information
      }
    function ad_get_trigger_pos(adh:longint; pos:Pad_scan_pos):longint;cdecl;external External_library name 'ad_get_trigger_pos';

    function ad_set_trigger_pos(adh:longint; pos:Pad_scan_pos):longint;cdecl;external External_library name 'ad_set_trigger_pos';

    function ad_get_channel_layout(adh:longint; idx:longint; layout:Pad_cha_layout):longint;cdecl;external External_library name 'ad_get_channel_layout';


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
       ad_cha_type:=x or($ff000000);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MAJOR_VERS(x : longint) : byte;
    begin
       AD_MAJOR_VERS:=byte(x shr 24);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_MINOR_VERS(x : longint) : byte;
    begin
       AD_MINOR_VERS:=byte(x shr 16);
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_BUILD_VERS(x : longint) : word;
    begin
       AD_BUILD_VERS:=word(x);
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
  function AD_CAN_DESC(ctrl,off,len,nbo,sgn,moff,mlen : longint) : longint;
    var
       if_local1, if_local2 : longint;
    (* result types are not known *)
    begin
{       if nbo then
         if_local1:=$4000
       else
         if_local1:=0;
       if sgn then
         if_local2:=$8000
       else
         if_local2:=0;
       AD_CAN_DESC:=((((((len(@($3f))) or ((off(@($3f))) shl 6)) or ((ctrl(@($03))) shl 12)) or (if_local1)) or (if_local2)) or ((moff(@($3f))) shl 16)) or ((mlen(@($3f))) shl 22);}
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_LEN(id : longint) : longint;
    begin
       AD_CAN_LEN:=id or $3f;
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
       AD_CAN_NBO:=id or $4000;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function AD_CAN_SGN(id : longint) : longint;
    begin
       AD_CAN_SGN:=id or $8000;
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