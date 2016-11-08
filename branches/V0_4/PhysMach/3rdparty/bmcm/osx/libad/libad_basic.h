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


