/* libad.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 */

#ifndef LIBAD__H
#define LIBAD__H

#ifdef __cplusplus
extern "C" {
#endif

/* libad_types.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 *
 * basic contants and types
 */

/* libad_os.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 *
 * bit-sized integer types (unix)
 */

#ifndef CONFIG_STDINT
#define CONFIG_STDINT 1
#endif

#if CONFIG_STDINT

#include <stdint.h>

#else /* !CONFIG_STDINT */

#ifndef BIT_TYPES
#define BIT_TYPES 1
#endif /* !BIT_TYPES */

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

#include <sys/types.h>

#endif /* !CONFIG_STDINT */

#define ad_invalid_driver_version(x) 0



/* channel types
 *
 * high order byte defines channel type
 * low order 24 bits define channel id
 */

#define AD_CHA_TYPE_MASK          0xff000000

#define AD_CHA_TYPE_ANALOG_IN     0x01000000
#define AD_CHA_TYPE_ANALOG_OUT    0x02000000
#define AD_CHA_TYPE_DIGITAL_IO    0x03000000
#define AD_CHA_TYPE_ROUTE         0x06000000
#define AD_CHA_TYPE_CAN           0x07000000
#define AD_CHA_TYPE_COUNTER       0x08000000

#define ad_cha_type(x)    ((x) & 0xff000000)

/* this is AD_CHA_TYPE_DIGITAL_IO, but
 * ad_get_next_run_f returns that channel
 * as long (instead of float)
 */

#define AD_CHA_TYPE_DIGITAL_LONG  0x0b000000


/* device information structure
 */

struct ad_device_info
{
  int32_t analog_in;          /* OUT   number of analog inputs */
  int32_t analog_out;         /* OUT   number of analog outputs */
  int32_t digital_io;         /* OUT   number of digital i/o's */
  int32_t res[5];
};


/* magic analog/digital sample type
 */

union ad
{
  float a;
  int32_t d;
};

typedef union ad ad_t;


/* range information structure
 */

struct ad_range_info
{
  double min;                 /* OUT   minimum of range */
  double max;                 /* OUT   maximum of range */
  double res;                 /* OUT   resolution */
  double resv[5];
  int bps;                    /* OUT   bytes per sample */
  char unit[24];              /* OUT   unit */
};


/* libad_basic.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 *
 * defines basic operations, including discrete i/o
 */

/* macros used to parse version id
 */

#define AD_MAJOR_VERS(x)    ((unsigned char)(((x) >> 24)))
#define AD_MINOR_VERS(x)    ((unsigned char)(((x) >> 16)))
#define AD_BUILD_VERS(x)    ((unsigned short)((x)))

#define AD_VERS(mj,mn,build)  (((mj) << 24)|((mn) << 16)|(build))


/* return current LIBAD version
 */

uint32_t
ad_get_version ();


/* open driver
 *
 * common names are
 *
 *   "PCI300" - PCI-Base 300/50
 *   "P1000"  - P1000, PC20NV
 *   "PC20"   - PC20TR, PC16
 *   "PIOII"  - PIO24II, PIO48II
 *
 * returns handle of driver, or -1 on failure
 */

int32_t
ad_open (const char *name);


/* close driver
 *
 * adh is the handle returned by ad_open
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_close (int32_t adh);


/* gets device information
 *
 * adh is the handle returned by ad_open
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_get_dev_info (int32_t adh, struct ad_device_info *info);


/* get discrete sample
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   (ptr to) variable to receive sample
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_discrete_in (int32_t adh, int32_t cha, int32_t range, uint32_t *data);

int32_t
ad_discrete_in64 (int32_t adh, int32_t cha, uint64_t range, uint64_t *data);

int32_t
ad_discrete_inv (int32_t adh, int32_t chac, int32_t chav[], uint64_t rangev[], uint64_t datav[]);

/* output discrete sample
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   sample to output
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_discrete_out (int32_t adh, int32_t cha, int32_t range, uint32_t data);

int32_t
ad_discrete_out64 (int32_t adh, int32_t cha, uint64_t range, uint64_t data);

int32_t
ad_discrete_outv (int32_t adh, int32_t chac, int32_t chav[], uint64_t rangev[], uint64_t datav[]);

/* convert sample to float
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   sample
 * dbl    converted sample
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_sample_to_float (int32_t adh, int32_t cha, int32_t range, uint32_t data, float *dbl);

int32_t
ad_sample_to_float64 (int32_t adh, int32_t cha, uint64_t range, uint64_t data, double *dbl);

/* convert float to sample
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   sample
 * dbl    converted sample
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_float_to_sample (int32_t adh, int32_t cha, int32_t range, float dbl, uint32_t *sample);

int32_t
ad_float_to_sample64 (int32_t adh, int32_t cha, uint64_t range, double dbl, uint64_t *sample);

/* get direction of i/o lines
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * mask   bitmask of i/o direction (lsb defines line #1,
 *        every input is set, outputs are reset)
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_get_line_direction (int32_t adh, int32_t cha, uint32_t *mask);



/* set direction of i/o lines
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * mask   bitmask of i/o direction (lsb defines line #1,
 *        every bit set changes line direction to input)
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_set_line_direction (int32_t adh, int32_t cha, uint32_t mask);



/* get analog input (helper function, calls nothing but
 * ad_discrete_in (..., AD_CHA_TYPE_ANALOG_IN | cha, ...)
 * and ad_sample_to_float ())
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   (ptr to) variable to receive sample
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_analog_in (int32_t adh, int32_t cha, int32_t range, float *data);


/* get digital input (helper function, calls nothing but
 * ad_discrete_in (..., AD_CHA_TYPE_DIGITAL_IO | cha, ...))
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * data   (ptr to) variable to receive sample
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_digital_in (int32_t adh, int32_t cha, uint32_t *data);


/* output to analog channel (helper function, calls nothing but
 * ad_float_to_sample () and
 * ad_discrete_out (..., AD_CHA_TYPE_ANALOG_OUT | cha, ...))
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   sample to output
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_analog_out (int32_t adh, int32_t cha, int32_t range, float data);


/* output to digital channel (helper function, calls nothing but
 * ad_discrete_out (..., AD_CHA_TYPE_DIGITAL_IO | cha, ...))
 *
 * adh    handle returned by ad_open
 * cha    channel type and id
 * range  range number
 * data   sample to output
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_digital_out (int32_t adh, int32_t cha, uint32_t data);


/* digital i/o helpers - mainly for "programming"
 * languages that don't know how to 1 << line
 */

int32_t
ad_set_digital_line (int32_t adh, int32_t cha, int32_t line, uint32_t data);

int32_t
ad_get_digital_line (int32_t adh, int32_t cha, int32_t line, uint32_t *data);


/* range information
 */

int32_t
ad_get_range_count (int32_t adh, int32_t cha, int32_t *cnt);

int32_t
ad_get_range_info (int32_t adh, int32_t cha, int32_t range, struct ad_range_info *info);

int32_t
ad_get_range_info64 (int32_t adh, int32_t cha, uint64_t range, struct ad_range_info *info);

/* ioctl call (driver specific)
 *
 * adh    handle returned by ad_open
 * ioc    i/o control code
 * p      data buffer
 * size   size of data buffer (bytes)
 *
 * returns 0 on success, otherwise (WIN32) error code
 */

int32_t
ad_ioctl (int32_t adh, int32_t ioc, void *p, int32_t size);


/* return current driver version
 */

int32_t
ad_get_drv_version (int32_t adh, uint32_t *vers);

/* return product information
 */

struct ad_product_info
{
  uint32_t serial;               /* serial number */
  uint32_t fw_version;           /* firmware version */
  char model[32];                /* model name */
  uint8_t res[256];
};

int32_t
ad_get_product_info (int32_t adh, int id, struct ad_product_info *info, int32_t size);


/* libad_scan.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 *
 * defines scan operation
 */

/* what to store
 */

#define AD_STORE_DISCRETE         0x0001
#define AD_STORE_AVERAGE          0x0002
#define AD_STORE_MIN              0x0004
#define AD_STORE_MAX              0x0008
#define AD_STORE_RMS              0x0010


/* trigger mode
 */

#define AD_TRG_NONE               0x00
#define AD_TRG_POSITIVE           0x01
#define AD_TRG_NEGATIVE           0x02
#define AD_TRG_INSIDE             0x03
#define AD_TRG_OUTSIDE            0x04
#define AD_TRG_DIGITAL            0x80
#define AD_TRG_NEVER              0xff

/* alarm mode
 */

#define AD_ALARM_NONE             0x00
#define AD_ALARM_POSITIVE         0x01
#define AD_ALARM_NEGATIVE         0x02
#define AD_ALARM_INSIDE           0x03
#define AD_ALARM_OUTSIDE          0x04


/* scan descriptor
 *
 * defines scan settings of a single channel
 */

struct ad_scan_cha_desc
{
  int32_t cha;              /* IN    channel type and id */
  int32_t range;            /* IN    range number (driver specific) */
  int32_t store;            /* IN    what to sample */
  int32_t ratio;            /* IN    scan ratio */
  uint32_t zero;            /* IN    physical 0.0 */
  uint8_t trg_mode;         /* IN    trigger mode */
  uint8_t alarm_mode;       /* IN    alarm mode */
  uint8_t sc_res1[2];
  uint32_t trg_par[2];      /* IN    trigger parameters */
  int32_t samples_per_run;  /* OUT   number of samples per run */
  uint32_t alarm_par[2];    /* IN    alarm parameters */
  uint32_t sc_res2[5];
};

struct ad_scan_desc
{
  double sample_rate;       /* INOUT sampling rate (sec) */
  double clock_rate;        /* IN    ref clock rate (sec) */
  uint64_t prehist;         /* IN    number of samples prehistory */
  uint64_t posthist;        /* IN    number of samples posthistory */
  uint32_t ticks_per_run;   /* INOUT number of ticks per run */
  uint32_t bytes_per_run;   /* OUT   bytes per run */
  uint32_t samples_per_run; /* OUT   samples per run */
  uint32_t flags;           /* INOUT scan flags */
  uint32_t sd_res[12];
};

#define AD_CAN_DESC(ctrl,off,len,nbo,sgn,moff,mlen) \
  (((len) & 0x3f)                                   \
   |(((off) & 0x3f) << 6)                           \
   |(((ctrl) & 0x03) << 12)                         \
   |((nbo) ? 0x4000:0)                              \
   |((sgn) ? 0x8000:0)                              \
   |(((moff) & 0x3f) << 16)                         \
   |(((mlen) & 0x3f) << 22))

#define AD_CAN_LEN(id)         ((id) & 0x3f)
#define AD_CAN_OFF(id)         (((id) >> 6) & 0x3f)
#define AD_CAN_CTRL(id)        (((id) >> 12) & 0x03)
#define AD_CAN_NBO(id)         ((id) & 0x4000)
#define AD_CAN_SGN(id)         ((id) & 0x8000)
#define AD_CAN_MOFF(id)        (((id) >> 16) & 0x3f)
#define AD_CAN_MLEN(id)        (((id) >> 22) & 0x3f)
#define AD_CAN_MMASK           0xffff0000

/* merge can parameters into ad_scan_cha_desc
 */
#define ad_set_can_cha(cha,ctrl,off,len,nbo,sgn,id,moff,mlen) do {                                                        \
    (cha)->cha = AD_CHA_TYPE_CAN|(((ctrl) & 0x03) << 12);     \
    (cha)->range = AD_CAN_DESC(0,off,len,nbo,sgn,moff,mlen);  \
    (cha)->sc_res2[0] = (id);                                 \
  } while (0)


/* scan information structure
 */

#define AD_SF_SCANNING        0x00000001
#define AD_SF_TRIGGER         0x00000002       /* scan has triggered */
#define AD_SF_SYNCLOCK        0x00000001       /* synchronize internal clock to external clock */
#define AD_SF_INTERLEAVE      0x00000100       /* interleave every 2nd channel */
#define AD_SF_EXTCLOCK        0x00000200       /* use external clock */

struct ad_scan_state
{
  int32_t flags;                 /* OUT   scan flags */
  int32_t runs_pending;          /* OUT   number of runs ready to read */
  int64_t posthist;              /* OUT   posthistory samples remaining */
};

/* structure used to carry scan position
 */

typedef uint32_t ad_run_t;

struct ad_scan_pos
{
  ad_run_t run;             /* OUT   id of run */
  uint32_t offset;          /* OUT   run offset */
};


#define ad_scan_pos_lt(a,b) \
  ((a)->run < (b)->run      \
   || ((a)->run == (b)->run && (a)->offset < (b)->offset))

#define ad_scan_pos_ne(a,b) \
  ((a)->run != (b)->run     \
   || (a)->offset != (b)->offset)

void
ad_scan_pos_add (uint32_t run_size, struct ad_scan_pos *res, uint64_t offset);

void
ad_scan_pos_sub (uint32_t run_size, struct ad_scan_pos *res, uint64_t offset);



/* information available for each sampled channel
 * - only after the scan is done
 */

struct ad_cha_layout
{
  struct ad_scan_pos start;

  int64_t prehist_samples;
  int64_t posthist_samples;
  double t0;
};



/* start scan operation
 *
 * adh    handle returned by ad_open
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_start_scan (int32_t adh, struct ad_scan_desc *sd,
               uint32_t chac, struct ad_scan_cha_desc *chav);

int32_t
ad_start_mux_scan (int32_t adh, struct ad_scan_desc *sd,
                   uint32_t chac, struct ad_scan_cha_desc *chav);

int32_t
ad_calc_run_size (int32_t adh, struct ad_scan_desc *sd,
                  uint32_t chac, struct ad_scan_cha_desc *chav);

int32_t
ad_prep_scan (int32_t adh, struct ad_scan_desc *sd,
              uint32_t chac, struct ad_scan_cha_desc *chav);

int32_t
ad_start_prepared_scan (int32_t adh);


/* start scan helpers
 */

int32_t
ad_start_scan_v (int32_t adh, double sample_rate, uint32_t posthist,
                 uint32_t chac, int32_t *chav,
                 uint32_t rangec, int32_t *rangev);

int32_t
ad_start_mem_scan (int32_t adh, struct ad_scan_desc *sd,
                   uint32_t chac, struct ad_scan_cha_desc *chav);

int32_t
ad_prep_mem_scan (int32_t adh, struct ad_scan_desc *sd,
                  uint32_t chac, struct ad_scan_cha_desc *chav);


/* stop scan
 */

int32_t
ad_stop_scan (int32_t adh, int32_t *result);


/* get next available run (blocks until run is ready)
 *
 * adh    handle returned by ad_open
 * state  current state information 
 * run    id of returned run
 * p      buffer to receive data of next run
 *
 * returns 0 on success, otherwise error code
 */

int32_t
ad_get_next_run (int32_t adh, struct ad_scan_state *state,
                 uint32_t *run, void *p);

int32_t
ad_get_next_run_f (int32_t adh, struct ad_scan_state *state, uint32_t *run, float *p);


/* get buffer ptr 
 */

int32_t
ad_next_buffer (int32_t adh, const void *buf, void **next);

int32_t
ad_next_run (int32_t adh, struct ad_scan_state *state,
             uint32_t *run, void **buf);


/* get current scan state
 */

int32_t
ad_poll_scan_state (int32_t adh, struct ad_scan_state *state);


struct ad_timeval
{
  uint64_t tv_sec;
  uint32_t tv_usec;
};

int32_t
ad_get_scan_start (int32_t adh, struct ad_timeval *scan_start);


/* return trigger information
 */

int32_t
ad_get_trigger_pos (int32_t adh, struct ad_scan_pos *pos);

int32_t
ad_set_trigger_pos (int32_t adh, struct ad_scan_pos *pos);

int32_t
ad_get_channel_layout (int32_t adh, int idx, struct ad_cha_layout *layout);



#ifdef __cplusplus
}
#endif

#endif /* !LIBAD__H */
