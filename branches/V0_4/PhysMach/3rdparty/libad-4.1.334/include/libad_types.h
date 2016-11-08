/* libad_types.h
 *
 * libad is a simple interface to BMC Messsysteme Drivers
 *
 * basic contants and types
 */

#include "libad_os.h"

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

