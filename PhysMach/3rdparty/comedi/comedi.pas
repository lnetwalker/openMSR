
unit comedi;
interface

{
  Automatically converted by H2Pas 1.0.0 from comedi.cpped.h
  The following command line parameters were used:
    -e
    -D
    -p
    -w
    -u
    comedi
    -l
    comedi
    -o
    comedi.pas
    comedi.cpped.h
}

  const
    External_library='comedi'; {Setup as you need}

  { Pointers to basic pascal types, inserted by h2pas conversion program.}
  Type
    PLongint  = ^Longint;
    PSmallInt = ^SmallInt;
    PByte     = ^Byte;
    PWord     = ^Word;
    PDWord    = ^DWord;
    PDouble   = ^Double;

  Type
  Pcomedi_bufconfig_struct  = ^comedi_bufconfig_struct;
  Pcomedi_bufinfo_struct  = ^comedi_bufinfo_struct;
  Pcomedi_chaninfo_struct  = ^comedi_chaninfo_struct;
  Pcomedi_cmd_struct  = ^comedi_cmd_struct;
  Pcomedi_counter_status_flags  = ^comedi_counter_status_flags;
  Pcomedi_devconfig_struct  = ^comedi_devconfig_struct;
  Pcomedi_devinfo_struct  = ^comedi_devinfo_struct;
  Pcomedi_insn  = ^comedi_insn;
  Pcomedi_insn_struct  = ^comedi_insn_struct;
  Pcomedi_insnlist_struct  = ^comedi_insnlist_struct;
  Pcomedi_io_direction  = ^comedi_io_direction;
  Pcomedi_krange_struct  = ^comedi_krange_struct;
  Pcomedi_rangeinfo_struct  = ^comedi_rangeinfo_struct;
  Pcomedi_subdevice_type  = ^comedi_subdevice_type;
  Pcomedi_subdinfo_struct  = ^comedi_subdinfo_struct;
  Pcomedi_trig_struct  = ^comedi_trig_struct;
  Pconfiguration_ids  = ^configuration_ids;
  Pdword  = ^dword;
  Pi8254_mode  = ^i8254_mode;
  Plsampl_t  = ^lsampl_t;
  Pni_660x_pfi_routing  = ^ni_660x_pfi_routing;
  Pni_freq_out_clock_source_bits  = ^ni_freq_out_clock_source_bits;
  Pni_gpct_arm_source  = ^ni_gpct_arm_source;
  Pni_gpct_clock_source_bits  = ^ni_gpct_clock_source_bits;
  Pni_gpct_filter_select  = ^ni_gpct_filter_select;
  Pni_gpct_gate_select  = ^ni_gpct_gate_select;
  Pni_gpct_mode_bits  = ^ni_gpct_mode_bits;
  Pni_gpct_other_index  = ^ni_gpct_other_index;
  Pni_gpct_other_select  = ^ni_gpct_other_select;
  Pni_m_series_cdio_scan_begin_src  = ^ni_m_series_cdio_scan_begin_src;
  Pni_mio_clock_source  = ^ni_mio_clock_source;
  Pni_pfi_filter_select  = ^ni_pfi_filter_select;
  Pni_pfi_routing  = ^ni_pfi_routing;
  Pni_rtsi_routing  = ^ni_rtsi_routing;
  Psampl_t  = ^sampl_t;
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}



  type

     Plsampl_t = ^lsampl_t;
     lsampl_t = dword;

     Psampl_t = ^sampl_t;
     sampl_t = word;
     comedi_subdevice_type =  Longint;
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


  type
     configuration_ids =  Longint;
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


  type
     comedi_io_direction =  Longint;
     Const
       COMEDI_INPUT = 0;
       COMEDI_OUTPUT = 1;
       COMEDI_OPENDRAIN = 2;


  type
     comedi_trig_struct = comedi_trig;
     comedi_cmd_struct = comedi_cmd;
     comedi_insn_struct = comedi_insn;
     comedi_insnlist_struct = comedi_insnlist;
     comedi_chaninfo_struct = comedi_chaninfo;
     comedi_subdinfo_struct = comedi_subdinfo;
     comedi_devinfo_struct = comedi_devinfo;
     comedi_devconfig_struct = comedi_devconfig;
     comedi_rangeinfo_struct = comedi_rangeinfo;
     comedi_krange_struct = comedi_krange;
     comedi_bufconfig_struct = comedi_bufconfig;
     comedi_bufinfo_struct = comedi_bufinfo;
     Pcomedi_trig_struct = ^comedi_trig_struct;
     comedi_trig_struct = record
          subdev : dword;
          mode : dword;
          flags : dword;
          n_chan : dword;
          chanlist : Pdword;
          data : Psampl_t;
          n : dword;
          trigsrc : dword;
          trigvar : dword;
          trigvar1 : dword;
          data_len : dword;
          unused : array[0..2] of dword;
       end;

     Pcomedi_insn_struct = ^comedi_insn_struct;
     comedi_insn_struct = record
          insn : dword;
          n : dword;
          data : Plsampl_t;
          subdev : dword;
          chanspec : dword;
          unused : array[0..2] of dword;
       end;

     Pcomedi_insnlist_struct = ^comedi_insnlist_struct;
     comedi_insnlist_struct = record
          n_insns : dword;
          insns : Pcomedi_insn;
       end;

     Pcomedi_cmd_struct = ^comedi_cmd_struct;
     comedi_cmd_struct = record
          subdev : dword;
          flags : dword;
          start_src : dword;
          start_arg : dword;
          scan_begin_src : dword;
          scan_begin_arg : dword;
          convert_src : dword;
          convert_arg : dword;
          scan_end_src : dword;
          scan_end_arg : dword;
          stop_src : dword;
          stop_arg : dword;
          chanlist : Pdword;
          chanlist_len : dword;
          data : Psampl_t;
          data_len : dword;
       end;

     Pcomedi_chaninfo_struct = ^comedi_chaninfo_struct;
     comedi_chaninfo_struct = record
          subdev : dword;
          maxdata_list : Plsampl_t;
          flaglist : Pdword;
          rangelist : Pdword;
          unused : array[0..3] of dword;
       end;

     Pcomedi_rangeinfo_struct = ^comedi_rangeinfo_struct;
     comedi_rangeinfo_struct = record
          range_type : dword;
          range_ptr : pointer;
       end;

     Pcomedi_krange_struct = ^comedi_krange_struct;
     comedi_krange_struct = record
          min : longint;
          max : longint;
          flags : dword;
       end;

     Pcomedi_subdinfo_struct = ^comedi_subdinfo_struct;
     comedi_subdinfo_struct = record
          _type : dword;
          n_chan : dword;
          subd_flags : dword;
          timer_type : dword;
          len_chanlist : dword;
          maxdata : lsampl_t;
          flags : dword;
          range_type : dword;
          settling_time_0 : dword;
          unused : array[0..8] of dword;
       end;

     Pcomedi_devinfo_struct = ^comedi_devinfo_struct;
     comedi_devinfo_struct = record
          version_code : dword;
          n_subdevs : dword;
          driver_name : array[0..19] of char;
          board_name : array[0..19] of char;
          read_subdevice : longint;
          write_subdevice : longint;
          unused : array[0..29] of longint;
       end;

     Pcomedi_devconfig_struct = ^comedi_devconfig_struct;
     comedi_devconfig_struct = record
          board_name : array[0..19] of char;
          options : array[0..31] of longint;
       end;

     Pcomedi_bufconfig_struct = ^comedi_bufconfig_struct;
     comedi_bufconfig_struct = record
          subdevice : dword;
          flags : dword;
          maximum_size : dword;
          size : dword;
          unused : array[0..3] of dword;
       end;

     Pcomedi_bufinfo_struct = ^comedi_bufinfo_struct;
     comedi_bufinfo_struct = record
          subdevice : dword;
          bytes_read : dword;
          buf_write_ptr : dword;
          buf_read_ptr : dword;
          buf_write_count : dword;
          buf_read_count : dword;
          bytes_written : dword;
          unused : array[0..3] of dword;
       end;

     i8254_mode =  Longint;
     Const
       I8254_MODE0 = 0 shl 1;
       I8254_MODE1 = 1 shl 1;
       I8254_MODE2 = 2 shl 1;
       I8254_MODE3 = 3 shl 1;
       I8254_MODE4 = 4 shl 1;
       I8254_MODE5 = 5 shl 1;
       I8254_BCD = 1;
       I8254_BINARY = 0;

  { static inline unsigned NI_USUAL_PFI_SELECT(unsigned pfi_channel) }
  {  }
  { if(pfi_channel < 10) }
  {  return 0x1 + pfi_channel; }
  { else }
  {  return 0xb + pfi_channel; }
  {  }
  { static inline unsigned NI_USUAL_RTSI_SELECT(unsigned rtsi_channel) }
  {  }
  { if(rtsi_channel < 7) }
  {  return 0xb + rtsi_channel; }
  { else }
  {  return 0x1b; }
  {  }

  type
     ni_gpct_mode_bits =  Longint;
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
       NI_GPCT_COUNTING_MODE_MASK = $7 shl 16;
       NI_GPCT_COUNTING_MODE_NORMAL_BITS = $0 shl 16;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X1_BITS = $1 shl 16;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X2_BITS = $2 shl 16;
       NI_GPCT_COUNTING_MODE_QUADRATURE_X4_BITS = $3 shl 16;
       NI_GPCT_COUNTING_MODE_TWO_PULSE_BITS = $4 shl 16;
       NI_GPCT_COUNTING_MODE_SYNC_SOURCE_BITS = $6 shl 16;
       NI_GPCT_INDEX_PHASE_MASK = $3 shl 20;
       NI_GPCT_INDEX_PHASE_LOW_A_LOW_B_BITS = $0 shl 20;
       NI_GPCT_INDEX_PHASE_LOW_A_HIGH_B_BITS = $1 shl 20;
       NI_GPCT_INDEX_PHASE_HIGH_A_LOW_B_BITS = $2 shl 20;
       NI_GPCT_INDEX_PHASE_HIGH_A_HIGH_B_BITS = $3 shl 20;
       NI_GPCT_INDEX_ENABLE_BIT = $400000;
       NI_GPCT_COUNTING_DIRECTION_MASK = $3 shl 24;
       NI_GPCT_COUNTING_DIRECTION_DOWN_BITS = $00 shl 24;
       NI_GPCT_COUNTING_DIRECTION_UP_BITS = $1 shl 24;
       NI_GPCT_COUNTING_DIRECTION_HW_UP_DOWN_BITS = $2 shl 24;
       NI_GPCT_COUNTING_DIRECTION_HW_GATE_BITS = $3 shl 24;
       NI_GPCT_RELOAD_SOURCE_MASK = $c000000;
       NI_GPCT_RELOAD_SOURCE_FIXED_BITS = $0;
       NI_GPCT_RELOAD_SOURCE_SWITCHING_BITS = $4000000;
       NI_GPCT_RELOAD_SOURCE_GATE_SELECT_BITS = $8000000;
       NI_GPCT_OR_GATE_BIT = $10000000;
       NI_GPCT_INVERT_OUTPUT_BIT = $20000000;


  type
     ni_gpct_clock_source_bits =  Longint;
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

  { static inline unsigned NI_GPCT_SOURCE_PIN_CLOCK_SRC_BITS(unsigned n) }
  {  }
  { return 0x10 + n; }
  {  }
  { static inline unsigned NI_GPCT_RTSI_CLOCK_SRC_BITS(unsigned n) }
  {  }
  { return 0x18 + n; }
  {  }
  { static inline unsigned NI_GPCT_PFI_CLOCK_SRC_BITS(unsigned n) }
  {  }
  { return 0x20 + n; }
  {  }

  type
     ni_gpct_gate_select =  Longint;
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

  { static inline unsigned NI_GPCT_GATE_PIN_GATE_SELECT(unsigned n) }
  {  }
  { return 0x102 + n; }
  {  }
  { static inline unsigned NI_GPCT_RTSI_GATE_SELECT(unsigned n) }
  {  }
  { return NI_USUAL_RTSI_SELECT(n); }
  {  }
  { static inline unsigned NI_GPCT_PFI_GATE_SELECT(unsigned n) }
  {  }
  { return NI_USUAL_PFI_SELECT(n); }
  {  }
  { static inline unsigned NI_GPCT_UP_DOWN_PIN_GATE_SELECT(unsigned n) }
  {  }
  { return 0x202 + n; }
  {  }

  type
     ni_gpct_other_index =  Longint;
     Const
       NI_GPCT_SOURCE_ENCODER_A = 0;
       NI_GPCT_SOURCE_ENCODER_B = 1;
       NI_GPCT_SOURCE_ENCODER_Z = 2;


  type
     ni_gpct_other_select =  Longint;
     Const
       NI_GPCT_DISABLED_OTHER_SELECT = $8000;

  { static inline unsigned NI_GPCT_PFI_OTHER_SELECT(unsigned n) }
  {  }
  { return NI_USUAL_PFI_SELECT(n); }
  {  }

  type
     ni_gpct_arm_source =  Longint;
     Const
       NI_GPCT_ARM_IMMEDIATE = $0;
       NI_GPCT_ARM_PAIRED_IMMEDIATE = $1;
       NI_GPCT_ARM_UNKNOWN = $1000;


  type
     ni_gpct_filter_select =  Longint;
     Const
       NI_GPCT_FILTER_OFF = $0;
       NI_GPCT_FILTER_TIMEBASE_3_SYNC = $1;
       NI_GPCT_FILTER_100x_TIMEBASE_1 = $2;
       NI_GPCT_FILTER_20x_TIMEBASE_1 = $3;
       NI_GPCT_FILTER_10x_TIMEBASE_1 = $4;
       NI_GPCT_FILTER_2x_TIMEBASE_1 = $5;
       NI_GPCT_FILTER_2x_TIMEBASE_3 = $6;


  type
     ni_pfi_filter_select =  Longint;
     Const
       NI_PFI_FILTER_OFF = $0;
       NI_PFI_FILTER_125ns = $1;
       NI_PFI_FILTER_6425ns = $2;
       NI_PFI_FILTER_2550us = $3;


  type
     ni_mio_clock_source =  Longint;
     Const
       NI_MIO_INTERNAL_CLOCK = 0;
       NI_MIO_RTSI_CLOCK = 1;
       NI_MIO_PLL_PXI_STAR_TRIGGER_CLOCK = 2;
       NI_MIO_PLL_PXI10_CLOCK = 3;
       NI_MIO_PLL_RTSI0_CLOCK = 4;

  { static inline unsigned NI_MIO_PLL_RTSI_CLOCK(unsigned rtsi_channel) }
  {  }
  {  return NI_MIO_PLL_RTSI0_CLOCK + rtsi_channel; }
  {  }

  type
     ni_rtsi_routing =  Longint;
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

  { static inline unsigned NI_RTSI_OUTPUT_RTSI_BRD(unsigned n) }
  {  }
  { return NI_RTSI_OUTPUT_RTSI_BRD_0 + n; }
  {  }

  type
     ni_pfi_routing =  Longint;
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

  { static inline unsigned NI_PFI_OUTPUT_RTSI(unsigned rtsi_channel) }
  {  }
  { return NI_PFI_OUTPUT_RTSI0 + rtsi_channel; }
  {  }

  type
     ni_660x_pfi_routing =  Longint;
     Const
       NI_660X_PFI_OUTPUT_COUNTER = 1;
       NI_660X_PFI_OUTPUT_DIO = 2;

  { static inline unsigned NI_EXT_PFI(unsigned pfi_channel) }
  {  }
  { return NI_USUAL_PFI_SELECT(pfi_channel) - 1; }
  {  }
  { static inline unsigned NI_EXT_RTSI(unsigned rtsi_channel) }
  {  }
  { return NI_USUAL_RTSI_SELECT(rtsi_channel) - 1; }
  {  }

  type
     comedi_counter_status_flags =  Longint;
     Const
       COMEDI_COUNTER_ARMED = $1;
       COMEDI_COUNTER_COUNTING = $2;
       COMEDI_COUNTER_TERMINAL_COUNT = $4;


  type
     ni_m_series_cdio_scan_begin_src =  Longint;
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

  { static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel) }
  {  }
  { return NI_USUAL_PFI_SELECT(pfi_channel); }
  {  }
  { static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel) }
  {  }
  { return NI_USUAL_RTSI_SELECT(rtsi_channel); }
  {  }
  { static inline unsigned NI_AO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel) }
  {  }
  { return NI_USUAL_PFI_SELECT(pfi_channel); }
  {  }
  { static inline unsigned NI_AO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel) }
  {  }
  { return NI_USUAL_RTSI_SELECT(rtsi_channel); }
  {  }

  type
     ni_freq_out_clock_source_bits =  Longint;
     Const
       NI_FREQ_OUT_TIMEBASE_1_DIV_2_CLOCK_SRC = 0;
       NI_FREQ_OUT_TIMEBASE_2_CLOCK_SRC = 1;


implementation


end.
