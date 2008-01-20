/* main.c
 *
 * simple demo that reads some input channel
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "libad.h"


void
usage ()
{
  printf ("usage: ex1 <driver> [ -r <range> ] <cha1> .. <chan>\n"
          "  <driver>     string to pass to ad_open()\n"
          "               - will prompt for name\n"
          "  <range>      range number of analog input\n"
          "  <cha1>       number of first analog input to read\n"
          "  <chan>       number of last analog input to read\n");
  exit (1);
}


int
run_test (const char *driver, int argc, char *argv[])
{
  int32_t adh, cha, rc;
  uint32_t data, rng;
  float u;
  int i;

  adh = ad_open (driver);
  if (adh == -1)
    {
      if (ad_invalid_driver_version (errno))
        printf ("failed to open %s: invalid driver version\n", driver);
      else
        printf ("failed to open %s: err = %d\n", driver, errno);

      return 1;
    }

  rng = 0;
  for (i = 2; i < argc; i++)
    {
      if (strcmp (argv[i], "-r") == 0)
        {
          if (argv[i+1] == NULL
              || argv[i+2] == NULL)
            break;

          rng = atoi (argv[i+1]);
          i += 2;
        }
        
      cha = atoi (argv[i]);

      rc = ad_discrete_in (adh, AD_CHA_TYPE_ANALOG_IN|cha, rng, &data);
      if (rc == 0)
        rc = ad_sample_to_float (adh, AD_CHA_TYPE_ANALOG_IN|cha, rng, data, &u);

      if (rc == 0)
        printf ("cha %2d: %08x ==> %7.3f V\n", cha, data, u);
      else
        printf ("error: failed to read cha %d: err = %d\n", cha, rc);
    }

  ad_close (adh);

  return 0;
}


/* main entry
 */

int
main (int argc, char *argv[])
{
  char *driver, *p, tmp[80];
  int rc;

  if (argc <= 1)
    usage ();

  if (argv[1][0] == '-')
    {
      printf ("driver to open: ");
      fgets (tmp, sizeof(tmp), stdin);

      p = strchr (tmp, '\n');
      if (p)
        *p = '\0';

      driver = tmp;
    }
  else
    driver = argv[1];

  rc = run_test (driver, argc, argv);

  if (argv[1][0] == '-')
    {
      printf ("press return to continue...\n");
      fgets (tmp, sizeof(tmp), stdin);
    }

  return rc;
}
