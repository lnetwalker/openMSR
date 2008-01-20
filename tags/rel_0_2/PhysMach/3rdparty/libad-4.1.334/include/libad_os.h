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

