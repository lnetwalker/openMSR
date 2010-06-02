# 1 "comedi.h"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "comedi.h"
# 57 "comedi.h"
typedef unsigned int lsampl_t;
typedef unsigned short sampl_t;
# 205 "comedi.h"
enum comedi_subdevice_type
{
 COMEDI_SUBD_UNUSED,
 COMEDI_SUBD_AI,
 COMEDI_SUBD_AO,
 COMEDI_SUBD_DI,
 COMEDI_SUBD_DO,
 COMEDI_SUBD_DIO,
 COMEDI_SUBD_COUNTER,
 COMEDI_SUBD_TIMER,
 COMEDI_SUBD_MEMORY,
 COMEDI_SUBD_CALIB,
 COMEDI_SUBD_PROC,
 COMEDI_SUBD_SERIAL
};



enum configuration_ids
{
 INSN_CONFIG_DIO_INPUT = 0,
 INSN_CONFIG_DIO_OUTPUT = 1,
 INSN_CONFIG_DIO_OPENDRAIN = 2,
 INSN_CONFIG_ANALOG_TRIG = 16,



 INSN_CONFIG_ALT_SOURCE = 20,
 INSN_CONFIG_DIGITAL_TRIG = 21,
 INSN_CONFIG_BLOCK_SIZE = 22,
 INSN_CONFIG_TIMER_1 = 23,
 INSN_CONFIG_FILTER = 24,
 INSN_CONFIG_CHANGE_NOTIFY = 25,


 INSN_CONFIG_SERIAL_CLOCK = 26,
 INSN_CONFIG_BIDIRECTIONAL_DATA = 27,
 INSN_CONFIG_DIO_QUERY = 28,
 INSN_CONFIG_PWM_OUTPUT = 29,
 INSN_CONFIG_GET_PWM_OUTPUT = 30,
 INSN_CONFIG_ARM = 31,
 INSN_CONFIG_DISARM = 32,
 INSN_CONFIG_GET_COUNTER_STATUS = 33,
 INSN_CONFIG_RESET = 34,
 INSN_CONFIG_GPCT_SINGLE_PULSE_GENERATOR = 1001,
 INSN_CONFIG_GPCT_PULSE_TRAIN_GENERATOR = 1002,
 INSN_CONFIG_GPCT_QUADRATURE_ENCODER = 1003,
 INSN_CONFIG_SET_GATE_SRC = 2001,
 INSN_CONFIG_GET_GATE_SRC = 2002,
 INSN_CONFIG_SET_CLOCK_SRC = 2003,
 INSN_CONFIG_GET_CLOCK_SRC = 2004,
 INSN_CONFIG_SET_OTHER_SRC = 2005,

 INSN_CONFIG_SET_COUNTER_MODE = 4097,
 INSN_CONFIG_8254_SET_MODE = INSN_CONFIG_SET_COUNTER_MODE,
 INSN_CONFIG_8254_READ_STATUS = 4098,
 INSN_CONFIG_SET_ROUTING = 4099,
 INSN_CONFIG_GET_ROUTING = 4109,
};

enum comedi_io_direction
{
 COMEDI_INPUT = 0,
 COMEDI_OUTPUT = 1,
 COMEDI_OPENDRAIN = 2
};
# 295 "comedi.h"
typedef struct comedi_trig_struct comedi_trig;
typedef struct comedi_cmd_struct comedi_cmd;
typedef struct comedi_insn_struct comedi_insn;
typedef struct comedi_insnlist_struct comedi_insnlist;
typedef struct comedi_chaninfo_struct comedi_chaninfo;
typedef struct comedi_subdinfo_struct comedi_subdinfo;
typedef struct comedi_devinfo_struct comedi_devinfo;
typedef struct comedi_devconfig_struct comedi_devconfig;
typedef struct comedi_rangeinfo_struct comedi_rangeinfo;
typedef struct comedi_krange_struct comedi_krange;
typedef struct comedi_bufconfig_struct comedi_bufconfig;
typedef struct comedi_bufinfo_struct comedi_bufinfo;

struct comedi_trig_struct{
 unsigned int subdev;
 unsigned int mode;
 unsigned int flags;
 unsigned int n_chan;
 unsigned int *chanlist;
 sampl_t *data;
 unsigned int n;
 unsigned int trigsrc;
 unsigned int trigvar;
 unsigned int trigvar1;
 unsigned int data_len;
 unsigned int unused[3];
};

struct comedi_insn_struct{
 unsigned int insn;
 unsigned int n;
 lsampl_t *data;
 unsigned int subdev;
 unsigned int chanspec;
 unsigned int unused[3];
};

struct comedi_insnlist_struct{
 unsigned int n_insns;
 comedi_insn *insns;
};

struct comedi_cmd_struct{
 unsigned int subdev;
 unsigned int flags;

 unsigned int start_src;
 unsigned int start_arg;

 unsigned int scan_begin_src;
 unsigned int scan_begin_arg;

 unsigned int convert_src;
 unsigned int convert_arg;

 unsigned int scan_end_src;
 unsigned int scan_end_arg;

 unsigned int stop_src;
 unsigned int stop_arg;

 unsigned int *chanlist;
 unsigned int chanlist_len;

 sampl_t *data;
 unsigned int data_len;
};

struct comedi_chaninfo_struct{
 unsigned int subdev;
 lsampl_t *maxdata_list;
 unsigned int *flaglist;
 unsigned int *rangelist;
 unsigned int unused[4];
};

struct comedi_rangeinfo_struct{
 unsigned int range_type;
 void *range_ptr;
};

struct comedi_krange_struct{
 int min;
 int max;
 unsigned int flags;
};

struct comedi_subdinfo_struct{
 unsigned int type;
 unsigned int n_chan;
 unsigned int subd_flags;
 unsigned int timer_type;
 unsigned int len_chanlist;
 lsampl_t maxdata;
 unsigned int flags;
 unsigned int range_type;
 unsigned int settling_time_0;
 unsigned int unused[9];
};

struct comedi_devinfo_struct{
 unsigned int version_code;
 unsigned int n_subdevs;
 char driver_name[20];
 char board_name[20];
 int read_subdevice;
 int write_subdevice;
 int unused[30];
};

struct comedi_devconfig_struct{
 char board_name[20];
 int options[32];
};

struct comedi_bufconfig_struct{
 unsigned int subdevice;
 unsigned int flags;

 unsigned int maximum_size;
 unsigned int size;

 unsigned int unused[4];
};

struct comedi_bufinfo_struct{
 unsigned int subdevice;
 unsigned int bytes_read;

 unsigned int buf_write_ptr;
 unsigned int buf_read_ptr;
 unsigned int buf_write_count;
 unsigned int buf_read_count;

 unsigned int bytes_written;

 unsigned int unused[4];
};
# 483 "comedi.h"
enum i8254_mode
{
 I8254_MODE0 = (0<<1),
 I8254_MODE1 = (1<<1),
 I8254_MODE2 = (2<<1),
 I8254_MODE3 = (3<<1),
 I8254_MODE4 = (4<<1),
 I8254_MODE5 = (5<<1),
 I8254_BCD = 1,
 I8254_BINARY = 0
};

// static inline unsigned NI_USUAL_PFI_SELECT(unsigned pfi_channel)
// {
// if(pfi_channel < 10)
//  return 0x1 + pfi_channel;
// else
//  return 0xb + pfi_channel;
// }
// static inline unsigned NI_USUAL_RTSI_SELECT(unsigned rtsi_channel)
// {
// if(rtsi_channel < 7)
//  return 0xb + rtsi_channel;
// else
//  return 0x1b;
// }




enum ni_gpct_mode_bits
{
 NI_GPCT_GATE_ON_BOTH_EDGES_BIT = 0x4,
 NI_GPCT_EDGE_GATE_MODE_MASK = 0x18,
 NI_GPCT_EDGE_GATE_STARTS_STOPS_BITS = 0x0,
 NI_GPCT_EDGE_GATE_STOPS_STARTS_BITS = 0x8,
 NI_GPCT_EDGE_GATE_STARTS_BITS = 0x10,
 NI_GPCT_EDGE_GATE_NO_STARTS_NO_STOPS_BITS = 0x18,
 NI_GPCT_STOP_MODE_MASK = 0x60,
 NI_GPCT_STOP_ON_GATE_BITS = 0x00,
 NI_GPCT_STOP_ON_GATE_OR_TC_BITS = 0x20,
 NI_GPCT_STOP_ON_GATE_OR_SECOND_TC_BITS = 0x40,
 NI_GPCT_LOAD_B_SELECT_BIT = 0x80,
 NI_GPCT_OUTPUT_MODE_MASK = 0x300,
 NI_GPCT_OUTPUT_TC_PULSE_BITS = 0x100,
 NI_GPCT_OUTPUT_TC_TOGGLE_BITS = 0x200,
 NI_GPCT_OUTPUT_TC_OR_GATE_TOGGLE_BITS = 0x300,
 NI_GPCT_HARDWARE_DISARM_MASK = 0xc00,
 NI_GPCT_NO_HARDWARE_DISARM_BITS = 0x000,
 NI_GPCT_DISARM_AT_TC_BITS = 0x400,
 NI_GPCT_DISARM_AT_GATE_BITS = 0x800,
 NI_GPCT_DISARM_AT_TC_OR_GATE_BITS = 0xc00,
 NI_GPCT_LOADING_ON_TC_BIT = 0x1000,
 NI_GPCT_LOADING_ON_GATE_BIT = 0x4000,
 NI_GPCT_COUNTING_MODE_MASK = 0x7 << 16,
 NI_GPCT_COUNTING_MODE_NORMAL_BITS = 0x0 << 16,
 NI_GPCT_COUNTING_MODE_QUADRATURE_X1_BITS = 0x1 << 16,
 NI_GPCT_COUNTING_MODE_QUADRATURE_X2_BITS = 0x2 << 16,
 NI_GPCT_COUNTING_MODE_QUADRATURE_X4_BITS = 0x3 << 16,
 NI_GPCT_COUNTING_MODE_TWO_PULSE_BITS = 0x4 << 16,
 NI_GPCT_COUNTING_MODE_SYNC_SOURCE_BITS = 0x6 << 16,
 NI_GPCT_INDEX_PHASE_MASK = 0x3 << 20,
 NI_GPCT_INDEX_PHASE_LOW_A_LOW_B_BITS = 0x0 << 20,
 NI_GPCT_INDEX_PHASE_LOW_A_HIGH_B_BITS = 0x1 << 20,
 NI_GPCT_INDEX_PHASE_HIGH_A_LOW_B_BITS = 0x2 << 20,
 NI_GPCT_INDEX_PHASE_HIGH_A_HIGH_B_BITS = 0x3 << 20,
 NI_GPCT_INDEX_ENABLE_BIT = 0x400000,
 NI_GPCT_COUNTING_DIRECTION_MASK = 0x3 << 24,
 NI_GPCT_COUNTING_DIRECTION_DOWN_BITS = 0x00 << 24,
 NI_GPCT_COUNTING_DIRECTION_UP_BITS = 0x1 << 24,
 NI_GPCT_COUNTING_DIRECTION_HW_UP_DOWN_BITS = 0x2 << 24,
 NI_GPCT_COUNTING_DIRECTION_HW_GATE_BITS = 0x3 << 24,
 NI_GPCT_RELOAD_SOURCE_MASK = 0xc000000,
 NI_GPCT_RELOAD_SOURCE_FIXED_BITS = 0x0,
 NI_GPCT_RELOAD_SOURCE_SWITCHING_BITS = 0x4000000,
 NI_GPCT_RELOAD_SOURCE_GATE_SELECT_BITS = 0x8000000,
 NI_GPCT_OR_GATE_BIT = 0x10000000,
 NI_GPCT_INVERT_OUTPUT_BIT = 0x20000000
};



enum ni_gpct_clock_source_bits
{
 NI_GPCT_CLOCK_SRC_SELECT_MASK = 0x3f,
 NI_GPCT_TIMEBASE_1_CLOCK_SRC_BITS = 0x0,
 NI_GPCT_TIMEBASE_2_CLOCK_SRC_BITS = 0x1,
 NI_GPCT_TIMEBASE_3_CLOCK_SRC_BITS = 0x2,
 NI_GPCT_LOGIC_LOW_CLOCK_SRC_BITS = 0x3,
 NI_GPCT_NEXT_GATE_CLOCK_SRC_BITS = 0x4,
 NI_GPCT_NEXT_TC_CLOCK_SRC_BITS = 0x5,
 NI_GPCT_SOURCE_PIN_i_CLOCK_SRC_BITS = 0x6,
 NI_GPCT_PXI10_CLOCK_SRC_BITS = 0x7,
 NI_GPCT_PXI_STAR_TRIGGER_CLOCK_SRC_BITS = 0x8,
 NI_GPCT_ANALOG_TRIGGER_OUT_CLOCK_SRC_BITS = 0x9,
 NI_GPCT_PRESCALE_MODE_CLOCK_SRC_MASK = 0x30000000,
 NI_GPCT_NO_PRESCALE_CLOCK_SRC_BITS = 0x0,
 NI_GPCT_PRESCALE_X2_CLOCK_SRC_BITS = 0x10000000,
 NI_GPCT_PRESCALE_X8_CLOCK_SRC_BITS = 0x20000000,
 NI_GPCT_INVERT_CLOCK_SRC_BIT = 0x80000000
};
// static inline unsigned NI_GPCT_SOURCE_PIN_CLOCK_SRC_BITS(unsigned n)
// {
// return 0x10 + n;
// }
// static inline unsigned NI_GPCT_RTSI_CLOCK_SRC_BITS(unsigned n)
// {
// return 0x18 + n;
// }
// static inline unsigned NI_GPCT_PFI_CLOCK_SRC_BITS(unsigned n)
// {
// return 0x20 + n;
// }




enum ni_gpct_gate_select
{

 NI_GPCT_TIMESTAMP_MUX_GATE_SELECT = 0x0,
 NI_GPCT_AI_START2_GATE_SELECT = 0x12,
 NI_GPCT_PXI_STAR_TRIGGER_GATE_SELECT = 0x13,
 NI_GPCT_NEXT_OUT_GATE_SELECT = 0x14,
 NI_GPCT_AI_START1_GATE_SELECT = 0x1c,
 NI_GPCT_NEXT_SOURCE_GATE_SELECT = 0x1d,
 NI_GPCT_ANALOG_TRIGGER_OUT_GATE_SELECT = 0x1e,
 NI_GPCT_LOGIC_LOW_GATE_SELECT = 0x1f,

 NI_GPCT_SOURCE_PIN_i_GATE_SELECT = 0x100,
 NI_GPCT_GATE_PIN_i_GATE_SELECT = 0x101,

 NI_GPCT_UP_DOWN_PIN_i_GATE_SELECT = 0x201,
 NI_GPCT_SELECTED_GATE_GATE_SELECT = 0x21e,


 NI_GPCT_DISABLED_GATE_SELECT = 0x8000,
};
// static inline unsigned NI_GPCT_GATE_PIN_GATE_SELECT(unsigned n)
// {
// return 0x102 + n;
// }
// static inline unsigned NI_GPCT_RTSI_GATE_SELECT(unsigned n)
// {
// return NI_USUAL_RTSI_SELECT(n);
// }
// static inline unsigned NI_GPCT_PFI_GATE_SELECT(unsigned n)
// {
// return NI_USUAL_PFI_SELECT(n);
// }
// static inline unsigned NI_GPCT_UP_DOWN_PIN_GATE_SELECT(unsigned n)
// {
// return 0x202 + n;
// }



enum ni_gpct_other_index {
  NI_GPCT_SOURCE_ENCODER_A,
  NI_GPCT_SOURCE_ENCODER_B,
  NI_GPCT_SOURCE_ENCODER_Z
};
enum ni_gpct_other_select
{


 NI_GPCT_DISABLED_OTHER_SELECT = 0x8000,
};
// static inline unsigned NI_GPCT_PFI_OTHER_SELECT(unsigned n)
// {
// return NI_USUAL_PFI_SELECT(n);
// }




enum ni_gpct_arm_source
{
 NI_GPCT_ARM_IMMEDIATE = 0x0,
 NI_GPCT_ARM_PAIRED_IMMEDIATE = 0x1,




 NI_GPCT_ARM_UNKNOWN = 0x1000,
};


enum ni_gpct_filter_select
{
 NI_GPCT_FILTER_OFF = 0x0,
 NI_GPCT_FILTER_TIMEBASE_3_SYNC = 0x1,
 NI_GPCT_FILTER_100x_TIMEBASE_1= 0x2,
 NI_GPCT_FILTER_20x_TIMEBASE_1 = 0x3,
 NI_GPCT_FILTER_10x_TIMEBASE_1 = 0x4,
 NI_GPCT_FILTER_2x_TIMEBASE_1 = 0x5,
 NI_GPCT_FILTER_2x_TIMEBASE_3 = 0x6
};


enum ni_pfi_filter_select
{
 NI_PFI_FILTER_OFF = 0x0,
 NI_PFI_FILTER_125ns = 0x1,
 NI_PFI_FILTER_6425ns = 0x2,
 NI_PFI_FILTER_2550us = 0x3
};


enum ni_mio_clock_source
{
 NI_MIO_INTERNAL_CLOCK = 0,
 NI_MIO_RTSI_CLOCK = 1,

 NI_MIO_PLL_PXI_STAR_TRIGGER_CLOCK = 2,
 NI_MIO_PLL_PXI10_CLOCK = 3,
 NI_MIO_PLL_RTSI0_CLOCK = 4
};
// static inline unsigned NI_MIO_PLL_RTSI_CLOCK(unsigned rtsi_channel)
// {
//  return NI_MIO_PLL_RTSI0_CLOCK + rtsi_channel;
// }




enum ni_rtsi_routing
{
 NI_RTSI_OUTPUT_ADR_START1 = 0,
 NI_RTSI_OUTPUT_ADR_START2 = 1,
 NI_RTSI_OUTPUT_SCLKG = 2,
 NI_RTSI_OUTPUT_DACUPDN = 3,
 NI_RTSI_OUTPUT_DA_START1 = 4,
 NI_RTSI_OUTPUT_G_SRC0 = 5,
 NI_RTSI_OUTPUT_G_GATE0 = 6,
 NI_RTSI_OUTPUT_RGOUT0 = 7,
 NI_RTSI_OUTPUT_RTSI_BRD_0 = 8,
 NI_RTSI_OUTPUT_RTSI_OSC = 12
};
// static inline unsigned NI_RTSI_OUTPUT_RTSI_BRD(unsigned n)
// {
// return NI_RTSI_OUTPUT_RTSI_BRD_0 + n;
// }







enum ni_pfi_routing
{
 NI_PFI_OUTPUT_PFI_DEFAULT = 0,
 NI_PFI_OUTPUT_AI_START1 = 1,
 NI_PFI_OUTPUT_AI_START2 = 2,
 NI_PFI_OUTPUT_AI_CONVERT = 3,
 NI_PFI_OUTPUT_G_SRC1 = 4,
 NI_PFI_OUTPUT_G_GATE1 = 5,
 NI_PFI_OUTPUT_AO_UPDATE_N = 6,
 NI_PFI_OUTPUT_AO_START1 = 7,
 NI_PFI_OUTPUT_AI_START_PULSE = 8,
 NI_PFI_OUTPUT_G_SRC0 = 9,
 NI_PFI_OUTPUT_G_GATE0 = 10,
 NI_PFI_OUTPUT_EXT_STROBE = 11,
 NI_PFI_OUTPUT_AI_EXT_MUX_CLK = 12,
 NI_PFI_OUTPUT_GOUT0 = 13,
 NI_PFI_OUTPUT_GOUT1 = 14,
 NI_PFI_OUTPUT_FREQ_OUT = 15,
 NI_PFI_OUTPUT_PFI_DO = 16,
 NI_PFI_OUTPUT_I_ATRIG = 17,
 NI_PFI_OUTPUT_RTSI0 = 18,
 NI_PFI_OUTPUT_PXI_STAR_TRIGGER_IN = 26,
 NI_PFI_OUTPUT_SCXI_TRIG1 = 27,
 NI_PFI_OUTPUT_DIO_CHANGE_DETECT_RTSI = 28,
 NI_PFI_OUTPUT_CDI_SAMPLE = 29,
 NI_PFI_OUTPUT_CDO_UPDATE = 30
};
// static inline unsigned NI_PFI_OUTPUT_RTSI(unsigned rtsi_channel)
// {
// return NI_PFI_OUTPUT_RTSI0 + rtsi_channel;
// }







enum ni_660x_pfi_routing
{
 NI_660X_PFI_OUTPUT_COUNTER = 1,
 NI_660X_PFI_OUTPUT_DIO = 2,
};



// static inline unsigned NI_EXT_PFI(unsigned pfi_channel)
// {
// return NI_USUAL_PFI_SELECT(pfi_channel) - 1;
// }
// static inline unsigned NI_EXT_RTSI(unsigned rtsi_channel)
// {
// return NI_USUAL_RTSI_SELECT(rtsi_channel) - 1;
// }


enum comedi_counter_status_flags
{
 COMEDI_COUNTER_ARMED = 0x1,
 COMEDI_COUNTER_COUNTING = 0x2,
 COMEDI_COUNTER_TERMINAL_COUNT = 0x4,
};




enum ni_m_series_cdio_scan_begin_src
{
 NI_CDIO_SCAN_BEGIN_SRC_GROUND = 0,
 NI_CDIO_SCAN_BEGIN_SRC_AI_START = 18,
 NI_CDIO_SCAN_BEGIN_SRC_AI_CONVERT = 19,
 NI_CDIO_SCAN_BEGIN_SRC_PXI_STAR_TRIGGER = 20,
 NI_CDIO_SCAN_BEGIN_SRC_G0_OUT = 28,
 NI_CDIO_SCAN_BEGIN_SRC_G1_OUT = 29,
 NI_CDIO_SCAN_BEGIN_SRC_ANALOG_TRIGGER = 30,
 NI_CDIO_SCAN_BEGIN_SRC_AO_UPDATE = 31,
 NI_CDIO_SCAN_BEGIN_SRC_FREQ_OUT = 32,
 NI_CDIO_SCAN_BEGIN_SRC_DIO_CHANGE_DETECT_IRQ = 33
};
// static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel)
// {
// return NI_USUAL_PFI_SELECT(pfi_channel);
// }
// static inline unsigned NI_CDIO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel)
// {
// return NI_USUAL_RTSI_SELECT(rtsi_channel);
// }




// static inline unsigned NI_AO_SCAN_BEGIN_SRC_PFI(unsigned pfi_channel)
// {
// return NI_USUAL_PFI_SELECT(pfi_channel);
// }
// static inline unsigned NI_AO_SCAN_BEGIN_SRC_RTSI(unsigned rtsi_channel)
// {
// return NI_USUAL_RTSI_SELECT(rtsi_channel);
// }



enum ni_freq_out_clock_source_bits
{
 NI_FREQ_OUT_TIMEBASE_1_DIV_2_CLOCK_SRC,
 NI_FREQ_OUT_TIMEBASE_2_CLOCK_SRC
};
