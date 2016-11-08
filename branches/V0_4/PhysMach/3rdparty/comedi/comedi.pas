
unit comedi;
interface

const
  COMEDI_NDEVCONFOPTS = 32;
type
  TArray0toCOMEDI_NDEVCONFOPTS1OfLongint = array[0..(COMEDI_NDEVCONFOPTS)-1] of longint;

const
  COMEDI_NAMELEN = 20;
type
  TArray0toCOMEDI_NAMELEN1OfChar = array[0..(COMEDI_NAMELEN)-1] of char;
type
  TArray0to8OfDword = array[0..8] of dword;
type
  TArray0to3OfDword = array[0..3] of dword;
type
  TArray0to2OfDword = array[0..2] of dword;
type
  TArray0to29OfLongint = array[0..29] of longint;

{
  Automatically converted by H2Pas 1.0.0 from /home/hartmut/src/OpenMSR/divLibs/comedi/comedi.tmp.h
  The following command line parameters were used:
    -e
    -p
    -D
    -w
    -o
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedi.pas
    /home/hartmut/src/OpenMSR/divLibs/comedi/comedi.tmp.h
}

  const
    External_library='kernel32'; {Setup as you need}

  { Pointers to basic pascal types, inserted by h2pas conversion program.}
  






  function COMEDI_BUFCONFIG : longint;

type
  comedi_bufconfig_struct = comedi_bufconfig;
  Type
  Pcomedi_bufconfig_struct  = ^comedi_bufconfig_struct;
  function COMEDI_BUFINFO : longint;

type
  comedi_bufinfo_struct = comedi_bufinfo;
  Pcomedi_bufinfo_struct  = ^comedi_bufinfo_struct;
  function COMEDI_CHANINFO : longint;

type
  comedi_chaninfo_struct = comedi_chaninfo;
  Pcomedi_chaninfo_struct  = ^comedi_chaninfo_struct;
  function COMEDI_CMD : longint;

type
  comedi_cmd_struct = comedi_cmd;
  Pcomedi_cmd_struct  = ^comedi_cmd_struct;
  comedi_counter_status_flags =  Longint;
  Pcomedi_counter_status_flags  = ^comedi_counter_status_flags;
  function COMEDI_DEVCONFIG : longint;

type
  comedi_devconfig_struct = comedi_devconfig;
  Pcomedi_devconfig_struct  = ^comedi_devconfig_struct;
  function COMEDI_DEVINFO : longint;

type
  comedi_devinfo_struct = comedi_devinfo;
  Pcomedi_devinfo_struct  = ^comedi_devinfo_struct;
  function COMEDI_INSN : longint;

type
  Pcomedi_insn  = ^comedi_insn;
  comedi_insn_struct = comedi_insn;
  Pcomedi_insn_struct  = ^comedi_insn_struct;
  function COMEDI_INSNLIST : longint;

type
  comedi_insnlist_struct = comedi_insnlist;
  Pcomedi_insnlist_struct  = ^comedi_insnlist_struct;
  comedi_io_direction =  Longint;
  Pcomedi_io_direction  = ^comedi_io_direction;
  comedi_krange_struct = comedi_krange;
  Pcomedi_krange_struct  = ^comedi_krange_struct;
  function COMEDI_RANGEINFO : longint;

type
  comedi_rangeinfo_struct = comedi_rangeinfo;
  Pcomedi_rangeinfo_struct  = ^comedi_rangeinfo_struct;
  comedi_subdevice_type =  Longint;
  Pcomedi_subdevice_type  = ^comedi_subdevice_type;
  function COMEDI_SUBDINFO : longint;

type
  comedi_subdinfo_struct = comedi_subdinfo;
  Pcomedi_subdinfo_struct  = ^comedi_subdinfo_struct;
  function COMEDI_TRIG : longint;

type
  comedi_trig_struct = comedi_trig;
  Pcomedi_trig_struct  = ^comedi_trig_struct;
  configuration_ids =  Longint;
  Pconfiguration_ids  = ^configuration_ids;

  i8254_mode =  Longint;
  Pi8254_mode  = ^i8254_mode;
  lsampl_t = dword;
  Plsampl_t  = ^lsampl_t;
  ni_660x_pfi_routing =  Longint;
  Pni_660x_pfi_routing  = ^ni_660x_pfi_routing;
  ni_freq_out_clock_source_bits =  Longint;
  Pni_freq_out_clock_source_bits  = ^ni_freq_out_clock_source_bits;
  ni_gpct_arm_source =  Longint;
  Pni_gpct_arm_source  = ^ni_gpct_arm_source;
  ni_gpct_clock_source_bits =  Longint;
  Pni_gpct_clock_source_bits  = ^ni_gpct_clock_source_bits;
  ni_gpct_filter_select =  Longint;
  Pni_gpct_filter_select  = ^ni_gpct_filter_select;
  ni_gpct_gate_select =  Longint;
  Pni_gpct_gate_select  = ^ni_gpct_gate_select;
  ni_gpct_mode_bits =  Longint;
  Pni_gpct_mode_bits  = ^ni_gpct_mode_bits;
  ni_gpct_other_index =  Longint;
  Pni_gpct_other_index  = ^ni_gpct_other_index;
  ni_gpct_other_select =  Longint;
  Pni_gpct_other_select  = ^ni_gpct_other_select;
  ni_m_series_cdio_scan_begin_src =  Longint;
  Pni_m_series_cdio_scan_begin_src  = ^ni_m_series_cdio_scan_begin_src;
  ni_mio_clock_source =  Longint;
  Pni_mio_clock_source  = ^ni_mio_clock_source;
  ni_pfi_filter_select =  Longint;
  Pni_pfi_filter_select  = ^ni_pfi_filter_select;
  ni_pfi_routing =  Longint;
  Pni_pfi_routing  = ^ni_pfi_routing;
  ni_rtsi_routing =  Longint;
  Pni_rtsi_routing  = ^ni_rtsi_routing;
  sampl_t = word;
  Psampl_t  = ^sampl_t;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


  {
      include/comedi.h (installed as /usr/include/comedi.h)
      header file for comedi
  
      COMEDI - Linux Control and Measurement Device Interface
      Copyright (C) 1998-2001 David A. Schleef <ds@schleef.org>
  
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
{$ifndef _COMEDI_H}
{$DEFINE H2PAS_FUNCTION_1}
  { comedi's major device number  }

  const
     COMEDI_MAJOR = 98;     
  {
     maximum number of minor devices.  This can be increased, although
     kernel structures are currently statically allocated, thus you
     don't want this to be much more than you actually use.
    }
     COMEDI_NDEVICES = 16;     
  {length of nth chunk of firmware data }
     COMEDI_DEVCONF_AUX_DATA3_LENGTH = 25;     
     COMEDI_DEVCONF_AUX_DATA2_LENGTH = 26;     
     COMEDI_DEVCONF_AUX_DATA1_LENGTH = 27;     
     COMEDI_DEVCONF_AUX_DATA0_LENGTH = 28;     
  {most significant 32 bits of pointer address (if needed) }
     COMEDI_DEVCONF_AUX_DATA_HI = 29;     
  {least significant 32 bits of pointer address }
     COMEDI_DEVCONF_AUX_DATA_LO = 30;     
  { total data length  }
     COMEDI_DEVCONF_AUX_DATA_LENGTH = 31;     

  { packs and unpacks a channel/range number  }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_PACK(chan,rng,aref : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_PACK_FLAGS(chan,range,aref,flags : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function CR_CHAN(a : longint) : a;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_RANGE(a : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_AREF(a : longint) : longint;  


  const
     CR_FLAGS_MASK = $fc000000;     
     CR_ALT_FILTER = 1 shl 26;     
     CR_DITHER = CR_ALT_FILTER;     
     CR_DEGLITCH = CR_ALT_FILTER;     
     CR_ALT_SOURCE = 1 shl 27;     
     CR_EDGE = 1 shl 30;     
     CR_INVERT = 1 shl 31;     
  { analog ref = analog ground  }
     AREF_GROUND = $00;     
  { analog ref = analog common  }
     AREF_COMMON = $01;     
  { analog ref = differential  }
     AREF_DIFF = $02;     
  { analog ref = other (undefined)  }
     AREF_OTHER = $03;     
  { counters -- these are arbitrary values  }
     GPCT_RESET = $0001;     
     GPCT_SET_SOURCE = $0002;     
     GPCT_SET_GATE = $0004;     
     GPCT_SET_DIRECTION = $0008;     
     GPCT_SET_OPERATION = $0010;     
     GPCT_ARM = $0020;     
     GPCT_DISARM = $0040;     
     GPCT_GET_INT_CLK_FRQ = $0080;     
     GPCT_INT_CLOCK = $0001;     
     GPCT_EXT_PIN = $0002;     
     GPCT_NO_GATE = $0004;     
     GPCT_UP = $0008;     
     GPCT_DOWN = $0010;     
     GPCT_HWUD = $0020;     
     GPCT_SIMPLE_EVENT = $0040;     
     GPCT_SINGLE_PERIOD = $0080;     
     GPCT_SINGLE_PW = $0100;     
     GPCT_CONT_PULSE_OUT = $0200;     
     GPCT_SINGLE_PULSE_OUT = $0400;     
  { instructions  }
     INSN_MASK_WRITE = $8000000;     
     INSN_MASK_READ = $4000000;     
     INSN_MASK_SPECIAL = $2000000;     
     INSN_READ = 0 or INSN_MASK_READ;     
     INSN_WRITE = 1 or INSN_MASK_WRITE;     
     INSN_BITS = (2 or INSN_MASK_READ) or INSN_MASK_WRITE;     
     INSN_CONFIG = (3 or INSN_MASK_READ) or INSN_MASK_WRITE;     
     INSN_GTOD = (4 or INSN_MASK_READ) or INSN_MASK_SPECIAL;     
     INSN_WAIT = (5 or INSN_MASK_WRITE) or INSN_MASK_SPECIAL;     
     INSN_INTTRIG = (6 or INSN_MASK_WRITE) or INSN_MASK_SPECIAL;     
  { trigger flags  }
  { These flags are used in comedi_trig structures  }
     TRIG_BOGUS = $0001;     
     TRIG_DITHER = $0002;     
     TRIG_DEGLITCH = $0004;     
  {#define TRIG_RT	0x0008 }
     TRIG_CONFIG = $0010;     
     TRIG_WAKE_EOS = $0020;     
  {#define TRIG_WRITE	0x0040 }
  { command flags  }
  { These flags are used in comedi_cmd structures  }
     CMDF_PRIORITY = $00000008;     
     TRIG_RT = CMDF_PRIORITY;     
     CMDF_WRITE = $00000040;     
     TRIG_WRITE = CMDF_WRITE;     
     CMDF_RAWDATA = $00000080;     
     COMEDI_EV_START = $00040000;     
     COMEDI_EV_SCAN_BEGIN = $00080000;     
     COMEDI_EV_CONVERT = $00100000;     
     COMEDI_EV_SCAN_END = $00200000;     
     COMEDI_EV_STOP = $00400000;     
     TRIG_ROUND_MASK = $00030000;     
     TRIG_ROUND_NEAREST = $00000000;     
     TRIG_ROUND_DOWN = $00010000;     
     TRIG_ROUND_UP = $00020000;     
     TRIG_ROUND_UP_NEXT = $00030000;     
  { trigger sources  }
     TRIG_ANY = $ffffffff;     
     TRIG_INVALID = $00000000;     
     TRIG_NONE = $00000001;     
     TRIG_NOW = $00000002;     
     TRIG_FOLLOW = $00000004;     
     TRIG_TIME = $00000008;     
     TRIG_TIMER = $00000010;     
     TRIG_COUNT = $00000020;     
     TRIG_EXT = $00000040;     
     TRIG_INT = $00000080;     
     TRIG_OTHER = $00000100;     
  { subdevice flags  }
     SDF_BUSY = $0001;     
     SDF_BUSY_OWNER = $0002;     
     SDF_LOCKED = $0004;     
     SDF_LOCK_OWNER = $0008;     
     SDF_MAXDATA = $0010;     
     SDF_FLAGS = $0020;     
     SDF_RANGETYPE = $0040;     
     SDF_MODE0 = $0080;     
     SDF_MODE1 = $0100;     
     SDF_MODE2 = $0200;     
     SDF_MODE3 = $0400;     
     SDF_MODE4 = $0800;     
     SDF_CMD = $1000;     
     SDF_SOFT_CALIBRATED = $2000;     
     SDF_CMD_WRITE = $4000;     
     SDF_CMD_READ = $8000;     
     SDF_READABLE = $00010000;     
     SDF_WRITABLE = $00020000;     
     SDF_WRITEABLE = SDF_WRITABLE;     
     SDF_INTERNAL = $00040000;     
     SDF_RT = $00080000;     
     SDF_GROUND = $00100000;     
     SDF_COMMON = $00200000;     
     SDF_DIFF = $00400000;     
     SDF_OTHER = $00800000;     
     SDF_DITHER = $01000000;     
     SDF_DEGLITCH = $02000000;     
     SDF_MMAP = $04000000;     
     SDF_RUNNING = $08000000;     
     SDF_LSAMPL = $10000000;     
     SDF_PACKED = $20000000;     
  { subdevice types  }
  { unused by driver  }
  { analog input  }
  { analog output  }
  { digital input  }
  { digital output  }
  { digital input/output  }
  { counter  }
  { timer  }
  { memory, EEPROM, DPRAM  }
  { calibration DACs  }
  { processor, DSP  }
  { serial IO  }

     Const
       COMEDI_SUBD_UNUSED = 0;
       COMEDI_SUBD_AI = 1;
       COMEDI_SUBD_AO = 2;
       COMEDI_SUBD_DI = 3;
       COMEDI_SUBD_DO = 4;
       COMEDI_SUBD_DIO = 5;
       COMEDI_SUBD_COUNTER = 6;
       COMEDI_SUBD_TIMER = 7;
       COMEDI_SUBD_MEMORY = 8;
       COMEDI_SUBD_CALIB = 9;
       COMEDI_SUBD_PROC = 10;
       COMEDI_SUBD_SERIAL = 11;

  { configuration instructions  }
  {	INSN_CONFIG_WAVEFORM = 17, }
  {	INSN_CONFIG_TRIG = 18, }
  {	INSN_CONFIG_COUNTER = 19, }
  {ALPHA }
  { Use CTR as single pulsegenerator }
  { Use CTR as pulsetraingenerator }
  { Use the counter as encoder }
  { Set gate source }
  { Get gate source }
  { Set master clock source }
  { Get master clock source }
  { Set other source }
  {	INSN_CONFIG_GET_OTHER_SRC = 2006,	// Get other source }
  { deprecated  }

     Const
       INSN_CONFIG_DIO_INPUT = 0;
       INSN_CONFIG_DIO_OUTPUT = 1;
       INSN_CONFIG_DIO_OPENDRAIN = 2;
       INSN_CONFIG_ANALOG_TRIG = 16;
       INSN_CONFIG_ALT_SOURCE = 20;
       INSN_CONFIG_DIGITAL_TRIG = 21;
       INSN_CONFIG_BLOCK_SIZE = 22;
       INSN_CONFIG_TIMER_1 = 23;
       INSN_CONFIG_FILTER = 24;
       INSN_CONFIG_CHANGE_NOTIFY = 25;
       INSN_CONFIG_SERIAL_CLOCK = 26;
       INSN_CONFIG_BIDIRECTIONAL_DATA = 27;
       INSN_CONFIG_DIO_QUERY = 28;
       INSN_CONFIG_PWM_OUTPUT = 29;
       INSN_CONFIG_GET_PWM_OUTPUT = 30;
       INSN_CONFIG_ARM = 31;
       INSN_CONFIG_DISARM = 32;
       INSN_CONFIG_GET_COUNTER_STATUS = 33;
       INSN_CONFIG_RESET = 34;
       INSN_CONFIG_GPCT_SINGLE_PULSE_GENERATOR = 1001;
       INSN_CONFIG_GPCT_PULSE_TRAIN_GENERATOR = 1002;
       INSN_CONFIG_GPCT_QUADRATURE_ENCODER = 1003;
       INSN_CONFIG_SET_GATE_SRC = 2001;
       INSN_CONFIG_GET_GATE_SRC = 2002;
       INSN_CONFIG_SET_CLOCK_SRC = 2003;
       INSN_CONFIG_GET_CLOCK_SRC = 2004;
       INSN_CONFIG_SET_OTHER_SRC = 2005;
       INSN_CONFIG_SET_COUNTER_MODE = 4097;
       INSN_CONFIG_8254_SET_MODE = INSN_CONFIG_SET_COUNTER_MODE;
       INSN_CONFIG_8254_READ_STATUS = 4098;
       INSN_CONFIG_SET_ROUTING = 4099;
       INSN_CONFIG_GET_ROUTING = 4109;


     Const
       COMEDI_INPUT = 0;
       COMEDI_OUTPUT = 1;
       COMEDI_OPENDRAIN = 2;

  { ioctls  }
     CIO = 'd';     
      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

  { was #define dname def_expr }
  function COMEDI_LOCK : longint;
      { return type might be wrong }

  { was #define dname def_expr }
  function COMEDI_UNLOCK : longint;
      { return type might be wrong }

  { was #define dname def_expr }
  function COMEDI_CANCEL : longint;
      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

  { was #define dname def_expr }
  function COMEDI_CMDTEST : longint;
      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

      { return type might be wrong }

  { was #define dname def_expr }
  function COMEDI_POLL : longint;
      { return type might be wrong }

  { structures  }

  { range stuff  }
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function __RANGE(a,b : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function RANGE_OFFSET(a : longint) : longint;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function RANGE_LENGTH(b : longint) : b;  

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function RF_UNIT(flags : longint) : flags;  


  const
     RF_EXTERNAL = 1 shl 8;     
     UNIT_volt = 0;     
     UNIT_mA = 1;     
     UNIT_none = 2;     
  { was #define dname def_expr }
  function COMEDI_MIN_SPEED : dword;    

  { callback stuff  }
  { only relevant to kernel modules.  }

  const
     COMEDI_CB_EOS = 1;     
     COMEDI_CB_EOA = 2;     
     COMEDI_CB_BLOCK = 4;     
     COMEDI_CB_EOBUF = 8;     
     COMEDI_CB_ERROR = 16;     
     COMEDI_CB_OVERFLOW = 32;     
  {******************************************************** }
  { everything after this line is ALPHA  }
  {******************************************************** }
  {
    8254 specific configuration.
  
    It supports two config commands:
  
    0 ID: INSN_CONFIG_SET_COUNTER_MODE
    1 8254 Mode
      I8254_MODE0, I8254_MODE1, ..., I8254_MODE5
      OR'ed with:
      I8254_BCD, I8254_BINARY
  
    0 ID: INSN_CONFIG_8254_READ_STATUS
    1 <-- Status byte returned here.
      B7=Output
      B6=nil Count
      B5-B0 Current mode.
  
   }
  { Interrupt on terminal count  }
  { Hardware retriggerable one-shot  }
  { Rate generator  }
  { Square wave mode  }
  { Software triggered strobe  }
  { Hardware triggered strobe (retriggerable)  }
  { use binary-coded decimal instead of binary (pretty useless)  }

     Const
       I8254_MODE0 = 0 shl 1;
       I8254_MODE1 = 1 shl 1;
       I8254_MODE2 = 2 shl 1;
       I8254_MODE3 = 3 shl 1;
       I8254_MODE4 = 4 shl 1;
       I8254_MODE5 = 5 shl 1;
       I8254_BCD = 1;
       I8254_BINARY = 0;

  {unsigned NI_USUAL_PFI_SELECT(unsigned pfi_channel) 
  	if(pfi_channel < 10)
  		return (0x1 + pfi_channel);
  	else
  		return 0xb + pfi_channel;
  
  static inline unsigned NI_USUAL_RTSI_SELECT(unsigned rtsi_channel)
  
  	if(rtsi_channel < 7)
  		return 0xb + rtsi_channel;
  	else
  		return 0x1b;
  
  /* mode bits for NI general-purpose counters, set with INSN_CONFIG_SET_COUNTER_MODE  }
     NI_GPCT_COUNTING_MODE_SHIFT = 16;     
     NI_GPCT_INDEX_PHASE_BITSHIFT = 20;     
     NI_GPCT_COUNTING_DIRECTION_SHIFT = 24;     

     Const
       NI_GPCT_GATE_ON_BOTH_EDGES_BIT = $4;
       NI_GPCT_EDGE_GATE_MODE_MASK = $18;
       NI_GPCT_EDGE_GATE_STARTS_STOPS_BITS = $0;
       NI_GPCT_EDGE_GATE_STOPS_STARTS_BITS = $8;
       NI_GPCT_EDGE_GATE_STARTS_BITS = $10;
       NI_GPCT_EDGE_GATE_NO_STARTS_NO_STOPS_BITS = $18;
       NI_GPCT_STOP_MODE_MASK = $60;
       NI_GPCT_STOP_ON_GATE_BITS = $00;
       NI_GPCT_STOP_ON_GATE_OR_TC_BITS = $20;
       NI_GPCT_STOP_ON_GATE_OR_SECOND_TC_BITS = $40;
       NI_GPCT_LOAD_B_SELECT_BIT = $80;
       NI_GPCT_OUTPUT_MODE_MASK = $300;
       NI_GPCT_OUTPUT_TC_PULSE_BITS = $100;
       NI_GPCT_OUTPUT_TC_TOGGLE_BITS = $200;
       NI_GPCT_OUTPUT_TC_OR_GATE_TOGGLE_BITS = $300;
       NI_GPCT_HARDWARE_DISARM_MASK = $c00;
       NI_GPCT_NO_HARDWARE_DISARM_BITS = $000;
       NI_GPCT_DISARM_AT_TC_BITS = $400;
       NI_GPCT_DISARM_AT_GATE_BITS = $800;
       NI_GPCT_DISARM_AT_TC_OR_GATE_BITS = $c00;
       NI_GPCT_LOADING_ON_TC_BIT = $1000;
       NI_GPCT_LOADING_ON_GATE_BIT = $4000;
       NI_GPCT_COUNTING_MODE_MASK = $7 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_NORMAL_BITS = $0 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X1_BITS = $1 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X2_BITS = $2 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X4_BITS = $3 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_TWO_PULSE_BITS = $4 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_COUNTING_MODE_SYNC_SOURCE_BITS = $6 shl NI_GPCT_COUNTING_MODE_SHIFT;
       NI_GPCT_INDEX_PHASE_MASK = $3 shl NI_GPCT_INDEX_PHASE_BITSHIFT;
       NI_GPCT_INDEX_PHASE_LOW_A_LOW_B_BITS = $0 shl NI_GPCT_INDEX_PHASE_BITSHIFT;
       NI_GPCT_INDEX_PHASE_LOW_A_HIGH_B_BITS = $1 shl NI_GPCT_INDEX_PHASE_BITSHIFT;
       NI_GPCT_INDEX_PHASE_HIGH_A_LOW_B_BITS = $2 shl NI_GPCT_INDEX_PHASE_BITSHIFT;
       NI_GPCT_INDEX_PHASE_HIGH_A_HIGH_B_BITS = $3 shl NI_GPCT_INDEX_PHASE_BITSHIFT;
       NI_GPCT_INDEX_ENABLE_BIT = $400000;
       NI_GPCT_COUNTING_DIRECTION_MASK = $3 shl NI_GPCT_COUNTING_DIRECTION_SHIFT;
       NI_GPCT_COUNTING_DIRECTION_DOWN_BITS = $00 shl NI_GPCT_COUNTING_DIRECTION_SHIFT;
       NI_GPCT_COUNTING_DIRECTION_UP_BITS = $1 shl NI_GPCT_COUNTING_DIRECTION_SHIFT;
       NI_GPCT_COUNTING_DIRECTION_HW_UP_DOWN_BITS = $2 shl NI_GPCT_COUNTING_DIRECTION_SHIFT;
       NI_GPCT_COUNTING_DIRECTION_HW_GATE_BITS = $3 shl NI_GPCT_COUNTING_DIRECTION_SHIFT;
       NI_GPCT_RELOAD_SOURCE_MASK = $c000000;
       NI_GPCT_RELOAD_SOURCE_FIXED_BITS = $0;
       NI_GPCT_RELOAD_SOURCE_SWITCHING_BITS = $4000000;
       NI_GPCT_RELOAD_SOURCE_GATE_SELECT_BITS = $8000000;
       NI_GPCT_OR_GATE_BIT = $10000000;
       NI_GPCT_INVERT_OUTPUT_BIT = $20000000;

  { Bits for setting a clock source with
   * INSN_CONFIG_SET_CLOCK_SRC when using NI general-purpose counters.  }
  { NI 660x-specific  }
  { divide source by 2  }
  { divide source by 8  }

     Const
       NI_GPCT_CLOCK_SRC_SELECT_MASK = $3f;
       NI_GPCT_TIMEBASE_1_CLOCK_SRC_BITS = $0;
       NI_GPCT_TIMEBASE_2_CLOCK_SRC_BITS = $1;
       NI_GPCT_TIMEBASE_3_CLOCK_SRC_BITS = $2;
       NI_GPCT_LOGIC_LOW_CLOCK_SRC_BITS = $3;
       NI_GPCT_NEXT_GATE_CLOCK_SRC_BITS = $4;
       NI_GPCT_NEXT_TC_CLOCK_SRC_BITS = $5;
       NI_GPCT_SOURCE_PIN_i_CLOCK_SRC_BITS = $6;
       NI_GPCT_PXI10_CLOCK_SRC_BITS = $7;
       NI_GPCT_PXI_STAR_TRIGGER_CLOCK_SRC_BITS = $8;
       NI_GPCT_ANALOG_TRIGGER_OUT_CLOCK_SRC_BITS = $9;
       NI_GPCT_PRESCALE_MODE_CLOCK_SRC_MASK = $30000000;
       NI_GPCT_NO_PRESCALE_CLOCK_SRC_BITS = $0;
       NI_GPCT_PRESCALE_X2_CLOCK_SRC_BITS = $10000000;
       NI_GPCT_PRESCALE_X8_CLOCK_SRC_BITS = $20000000;
       NI_GPCT_INVERT_CLOCK_SRC_BIT = $80000000;

  {static inline unsigned NI_GPCT_SOURCE_PIN_CLOCK_SRC_BITS(unsigned n) /* NI 660x-specific  }
  {
  	return 0x10 + n;
  
  static inline unsigned NI_GPCT_RTSI_CLOCK_SRC_BITS(unsigned n)
  
  	return 0x18 + n;
  
  static inline unsigned NI_GPCT_PFI_CLOCK_SRC_BITS(unsigned n) /* no pfi on NI 660x  }
  {
  	return 0x20 + n;
  
   }
  { Possibilities for setting a gate source with
  INSN_CONFIG_SET_GATE_SRC when using NI general-purpose counters.
  May be bitwise-or'd with CR_EDGE or CR_INVERT.  }
  { m-series gates  }
  { more gates for 660x  }
  { more gates for 660x "second gate"  }
  { m-series "second gate" sources are unknown,
  	we should add them here with an offset of 0x300 when known.  }

     Const
       NI_GPCT_TIMESTAMP_MUX_GATE_SELECT = $0;
       NI_GPCT_AI_START2_GATE_SELECT = $12;
       NI_GPCT_PXI_STAR_TRIGGER_GATE_SELECT = $13;
       NI_GPCT_NEXT_OUT_GATE_SELECT = $14;
       NI_GPCT_AI_START1_GATE_SELECT = $1c;
       NI_GPCT_NEXT_SOURCE_GATE_SELECT = $1d;
       NI_GPCT_ANALOG_TRIGGER_OUT_GATE_SELECT = $1e;
       NI_GPCT_LOGIC_LOW_GATE_SELECT = $1f;
       NI_GPCT_SOURCE_PIN_i_GATE_SELECT = $100;
       NI_GPCT_GATE_PIN_i_GATE_SELECT = $101;
       NI_GPCT_UP_DOWN_PIN_i_GATE_SELECT = $201;
       NI_GPCT_SELECTED_GATE_GATE_SELECT = $21e;
       NI_GPCT_DISABLED_GATE_SELECT = $8000;

  {static inline unsigned NI_GPCT_GATE_PIN_GATE_SELECT(unsigned n)
  
  	return 0x102 + n;
  
  static inline unsigned NI_GPCT_RTSI_GATE_SELECT(unsigned n)
  
  	return NI_USUAL_RTSI_SELECT(n);
  
  static inline unsigned NI_GPCT_PFI_GATE_SELECT(unsigned n)
  
  	return NI_USUAL_PFI_SELECT(n);
  
  static inline unsigned NI_GPCT_UP_DOWN_PIN_GATE_SELECT(unsigned n)
  
  	return 0x202 + n;
  
   }
  { Possibilities for setting a source with
  INSN_CONFIG_SET_OTHER_SRC when using NI general-purpose counters.  }

     Const
       NI_GPCT_SOURCE_ENCODER_A = 0;
       NI_GPCT_SOURCE_ENCODER_B = 1;
       NI_GPCT_SOURCE_ENCODER_Z = 2;

  { m-series gates  }
  { Still unknown, probably only need NI_GPCT_PFI_OTHER_SELECT }

     Const
       NI_GPCT_DISABLED_OTHER_SELECT = $8000;

  {static inline unsigned NI_GPCT_PFI_OTHER_SELECT(unsigned n)
  
  	return NI_USUAL_PFI_SELECT(n);
  
   }
  { start sources for ni general-purpose counters for use with
  INSN_CONFIG_ARM  }
  { Start both the counter and the adjacent paired counter simultaneously  }
  { NI doesn't document bits for selecting hardware arm triggers.  If
  	the NI_GPCT_ARM_UNKNOWN bit is set, we will pass the least significant
  	bits (3 bits for 660x or 5 bits for m-series) through to the hardware.
  	This will at least allow someone to figure out what the bits do later. }

     Const
       NI_GPCT_ARM_IMMEDIATE = $0;
       NI_GPCT_ARM_PAIRED_IMMEDIATE = $1;
       NI_GPCT_ARM_UNKNOWN = $1000;

  { digital filtering options for ni 660x for use with INSN_CONFIG_FILTER.  }

     Const
       NI_GPCT_FILTER_OFF = $0;
       NI_GPCT_FILTER_TIMEBASE_3_SYNC = $1;
       NI_GPCT_FILTER_100x_TIMEBASE_1 = $2;
       NI_GPCT_FILTER_20x_TIMEBASE_1 = $3;
       NI_GPCT_FILTER_10x_TIMEBASE_1 = $4;
       NI_GPCT_FILTER_2x_TIMEBASE_1 = $5;
       NI_GPCT_FILTER_2x_TIMEBASE_3 = $6;

  { PFI digital filtering options for ni m-series for use with INSN_CONFIG_FILTER.  }

     Const
       NI_PFI_FILTER_OFF = $0;
       NI_PFI_FILTER_125ns = $1;
       NI_PFI_FILTER_6425ns = $2;
       NI_PFI_FILTER_2550us = $3;

  { master clock sources for ni mio boards and INSN_CONFIG_SET_CLOCK_SRC  }
  { doesn't work for m-series, use NI_MIO_PLL_RTSI_CLOCK()  }
  { the NI_MIO_PLL_* sources are m-series only  }

     Const
       NI_MIO_INTERNAL_CLOCK = 0;
       NI_MIO_RTSI_CLOCK = 1;
       NI_MIO_PLL_PXI_STAR_TRIGGER_CLOCK = 2;
       NI_MIO_PLL_PXI10_CLOCK = 3;
       NI_MIO_PLL_RTSI0_CLOCK = 4;

  {static inline unsigned NI_MIO_PLL_RTSI_CLOCK(unsigned rtsi_channel)
  
  	return NI_MIO_PLL_RTSI0_CLOCK + rtsi_channel;
  
   }
  { Signals which can be routed to an NI RTSI pin with INSN_CONFIG_SET_ROUTING.
   The numbers assigned are not arbitrary, they correspond to the bits required
   to program the board.  }
  { pre-m-series always have RTSI clock on line 7  }

     Const
       NI_RTSI_OUTPUT_ADR_START1 = 0;
       NI_RTSI_OUTPUT_ADR_START2 = 1;
       NI_RTSI_OUTPUT_SCLKG = 2;
       NI_RTSI_OUTPUT_DACUPDN = 3;
       NI_RTSI_OUTPUT_DA_START1 = 4;
       NI_RTSI_OUTPUT_G_SRC0 = 5;
       NI_RTSI_OUTPUT_G_GATE0 = 6;
       NI_RTSI_OUTPUT_RGOUT0 = 7;
       NI_RTSI_OUTPUT_RTSI_BRD_0 = 8;
       NI_RTSI_OUTPUT_RTSI_OSC = 12;

  {static inline unsigned NI_RTSI_OUTPUT_RTSI_BRD(unsigned n)
  
  	return NI_RTSI_OUTPUT_RTSI_BRD_0 + n;
    }
  { Signals which can be routed to an NI PFI pin on an m-series board
   with INSN_CONFIG_SET_ROUTING.  These numbers are also returned
   by INSN_CONFIG_GET_ROUTING on pre-m-series boards, even though
   their routing cannot be changed.  The numbers assigned are
   not arbitrary, they correspond to the bits required
   to program the board.  }

     Const
       NI_PFI_OUTPUT_PFI_DEFAULT = 0;
       NI_PFI_OUTPUT_AI_START1 = 1;
       NI_PFI_OUTPUT_AI_START2 = 2;
       NI_PFI_OUTPUT_AI_CONVERT = 3;
       NI_PFI_OUTPUT_G_SRC1 = 4;
       NI_PFI_OUTPUT_G_GATE1 = 5;
       NI_PFI_OUTPUT_AO_UPDATE_N = 6;
       NI_PFI_OUTPUT_AO_START1 = 7;
       NI_PFI_OUTPUT_AI_START_PULSE = 8;
       NI_PFI_OUTPUT_G_SRC0 = 9;
       NI_PFI_OUTPUT_G_GATE0 = 10;
       NI_PFI_OUTPUT_EXT_STROBE = 11;
       NI_PFI_OUTPUT_AI_EXT_MUX_CLK = 12;
       NI_PFI_OUTPUT_GOUT0 = 13;
       NI_PFI_OUTPUT_GOUT1 = 14;
       NI_PFI_OUTPUT_FREQ_OUT = 15;
       NI_PFI_OUTPUT_PFI_DO = 16;
       NI_PFI_OUTPUT_I_ATRIG = 17;
       NI_PFI_OUTPUT_RTSI0 = 18;
       NI_PFI_OUTPUT_PXI_STAR_TRIGGER_IN = 26;
       NI_PFI_OUTPUT_SCXI_TRIG1 = 27;
       NI_PFI_OUTPUT_DIO_CHANGE_DETECT_RTSI = 28;
       NI_PFI_OUTPUT_CDI_SAMPLE = 29;
       NI_PFI_OUTPUT_CDO_UPDATE = 30;

  {static inline unsigned NI_PFI_OUTPUT_RTSI(unsigned rtsi_channel)
  
  	return NI_PFI_OUTPUT_RTSI0 + rtsi_channel;
  
   }
  { Signals which can be routed to output on a NI PFI pin on a 660x board
   with INSN_CONFIG_SET_ROUTING.  The numbers assigned are
   not arbitrary, they correspond to the bits required
   to program the board.  Lines 0 to 7 can only be set to
   NI_660X_PFI_OUTPUT_DIO.  Lines 32 to 39 can only be set to
   NI_660X_PFI_OUTPUT_COUNTER.  }
  { counter }
  { static digital output }

     Const
       NI_660X_PFI_OUTPUT_COUNTER = 1;
       NI_660X_PFI_OUTPUT_DIO = 2;

  { NI External Trigger lines.  These values are not arbitrary, but are related to
  	the bits required to program the board (offset by 1 for historical reasons).  }
  {static inline unsigned NI_EXT_PFI(unsigned pfi_channel)
  
  	return NI_USUAL_PFI_SELECT(pfi_channel) - 1;
  
  static inline unsigned NI_EXT_RTSI(unsigned rtsi_channel)
  
  	return NI_USUAL_RTSI_SELECT(rtsi_channel) - 1;
  
   }
  { status bits for INSN_CONFIG_GET_COUNTER_STATUS  }

     Const
       COMEDI_COUNTER_ARMED = $1;
       COMEDI_COUNTER_COUNTING = $2;
       COMEDI_COUNTER_TERMINAL_COUNT = $4;

  { Clock sources for CDIO subdevice on NI m-series boards.
  Used as the scan_begin_arg for a comedi_command. These
  sources may also be bitwise-or'd with CR_INVERT to change polarity.  }

     Const
       NI_CDIO_SCAN_BEGIN_SRC_GROUND = 0;
       NI_CDIO_SCAN_BEGIN_SRC_AI_START = 18;
       NI_CDIO_SCAN_BEGIN_SRC_AI_CONVERT = 19;
       NI_CDIO_SCAN_BEGIN_SRC_PXI_STAR_TRIGGER = 20;
       NI_CDIO_SCAN_BEGIN_SRC_G0_OUT = 28;
       NI_CDIO_SCAN_BEGIN_SRC_G1_OUT = 29;
       NI_CDIO_SCAN_BEGIN_SRC_ANALOG_TRIGGER = 30;
       NI_CDIO_SCAN_BEGIN_SRC_AO_UPDATE = 31;
       NI_CDIO_SCAN_BEGIN_SRC_FREQ_OUT = 32;
       NI_CDIO_SCAN_BEGIN_SRC_DIO_CHANGE_DETECT_IRQ = 33;

  {static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel)
  
  	return NI_USUAL_PFI_SELECT(pfi_channel);
  
  static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel)
  
  	return NI_USUAL_RTSI_SELECT(rtsi_channel);
  
  
  /* scan_begin_src for scan_begin_arg==TRIG_EXT with analog output command
  on NI boards.  These scan begin sources can also be bitwise-or'd with
  CR_INVERT to change polarity.  }
  {static inline unsigned NI_AO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel)
  
  	return NI_USUAL_PFI_SELECT(pfi_channel);
  
  static inline unsigned NI_AO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel)
  
  	return NI_USUAL_RTSI_SELECT(rtsi_channel);
  
  
  /* Bits for setting a clock source with
   * INSN_CONFIG_SET_CLOCK_SRC when using NI frequency output subdevice.  }
  { 10 MHz }
  { 100 KHz }

     Const
       NI_FREQ_OUT_TIMEBASE_1_DIV_2_CLOCK_SRC = 0;
       NI_FREQ_OUT_TIMEBASE_2_CLOCK_SRC = 1;

{$endif}
  { _COMEDI_H  }

implementation

{$IFDEF H2PAS_FUNCTION_1}
  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_PACK(chan,rng,aref : longint) : longint;
    begin
       CR_PACK:=(((aref(@($3))) shl 24) or ((rng(@($ff))) shl 16)) or chan;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_PACK_FLAGS(chan,range,aref,flags : longint) : longint;
    begin
       CR_PACK_FLAGS:=(CR_PACK(chan,range,aref)) or (flags(@(CR_FLAGS_MASK)));
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function CR_CHAN(a : longint) : a;
    begin
       CR_CHAN:=a(@($ffff));
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_RANGE(a : longint) : longint;
    begin
       CR_RANGE:=(a shr 16) and $ff;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function CR_AREF(a : longint) : longint;
    begin
       CR_AREF:=(a shr 24) and $03;
    end;

  { was #define dname def_expr }
  function COMEDI_DEVCONFIG : longint;
      { return type might be wrong }
      begin
         COMEDI_DEVCONFIG:=_IOW(CIO,0,comedi_devconfig);
      end;

  { was #define dname def_expr }
  function COMEDI_DEVINFO : longint;
      { return type might be wrong }
      begin
         COMEDI_DEVINFO:=_IOR(CIO,1,comedi_devinfo);
      end;

  { was #define dname def_expr }
  function COMEDI_SUBDINFO : longint;
      { return type might be wrong }
      begin
         COMEDI_SUBDINFO:=_IOR(CIO,2,comedi_subdinfo);
      end;

  { was #define dname def_expr }
  function COMEDI_CHANINFO : longint;
      { return type might be wrong }
      begin
         COMEDI_CHANINFO:=_IOR(CIO,3,comedi_chaninfo);
      end;

  { was #define dname def_expr }
  function COMEDI_TRIG : longint;
      { return type might be wrong }
      begin
         COMEDI_TRIG:=_IOWR(CIO,4,comedi_trig);
      end;

  { was #define dname def_expr }
  function COMEDI_LOCK : longint;
      { return type might be wrong }
      begin
         COMEDI_LOCK:=_IO(CIO,5);
      end;

  { was #define dname def_expr }
  function COMEDI_UNLOCK : longint;
      { return type might be wrong }
      begin
         COMEDI_UNLOCK:=_IO(CIO,6);
      end;

  { was #define dname def_expr }
  function COMEDI_CANCEL : longint;
      { return type might be wrong }
      begin
         COMEDI_CANCEL:=_IO(CIO,7);
      end;

  { was #define dname def_expr }
  function COMEDI_RANGEINFO : longint;
      { return type might be wrong }
      begin
         COMEDI_RANGEINFO:=_IOR(CIO,8,comedi_rangeinfo);
      end;

  { was #define dname def_expr }
  function COMEDI_CMD : longint;
      { return type might be wrong }
      begin
         COMEDI_CMD:=_IOR(CIO,9,comedi_cmd);
      end;

  { was #define dname def_expr }
  function COMEDI_CMDTEST : longint;
      { return type might be wrong }
      begin
         COMEDI_CMDTEST:=_IOR(CIO,10,comedi_cmd);
      end;

  { was #define dname def_expr }
  function COMEDI_INSNLIST : longint;
      { return type might be wrong }
      begin
         COMEDI_INSNLIST:=_IOR(CIO,11,comedi_insnlist);
      end;

  { was #define dname def_expr }
  function COMEDI_INSN : longint;
      { return type might be wrong }
      begin
         COMEDI_INSN:=_IOR(CIO,12,comedi_insn);
      end;

  { was #define dname def_expr }
  function COMEDI_BUFCONFIG : longint;
      { return type might be wrong }
      begin
         COMEDI_BUFCONFIG:=_IOR(CIO,13,comedi_bufconfig);
      end;

  { was #define dname def_expr }
  function COMEDI_BUFINFO : longint;
      { return type might be wrong }
      begin
         COMEDI_BUFINFO:=_IOWR(CIO,14,comedi_bufinfo);
      end;

  { was #define dname def_expr }
  function COMEDI_POLL : longint;
      { return type might be wrong }
      begin
         COMEDI_POLL:=_IO(CIO,15);
      end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function __RANGE(a,b : longint) : longint;
    begin
       __RANGE:=((a(@($ffff))) shl 16) or (b(@($ffff)));
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  { return type might be wrong }   
  function RANGE_OFFSET(a : longint) : longint;
    begin
       RANGE_OFFSET:=(a shr 16) and $ffff;
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function RANGE_LENGTH(b : longint) : b;
    begin
       RANGE_LENGTH:=b(@($ffff));
    end;

  { was #define dname(params) para_def_expr }
  { argument types are unknown }
  function RF_UNIT(flags : longint) : flags;
    begin
       RF_UNIT:=flags(@($ff));
    end;

  { was #define dname def_expr }
  function COMEDI_MIN_SPEED : dword;
      begin
         COMEDI_MIN_SPEED:=dword($ffffffff);
      end;
{$ENDIF H2PAS_FUNCTION_1}


end.
