/* main.c
 *
 * simple demo that samples two channels
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "libad.h"

#ifdef _WIN32
//#include <windows.h>
#include <malloc.h>
#define alloca _alloca
#endif


#define countof(x)   (sizeof(x)/sizeof((x)[0]))


void
usage ()
{
  printf ("usage: ex2 <driver> [ -r <range> ] <cha1> .. <chan>\n"
          "  <driver>     string to pass to ad_open()\n"
          "               - will prompt for name\n"
          "  <range>      range number of analog input\n"
          "  <cha1>       number of first analog input to sample\n"
          "  <chan>       number of last analog input to sample\n");
  exit (1);
}


/* helper used to dump scan results
 */

static void
dump_samples (int adh, int run_id, int chac, struct ad_scan_cha_desc *chav, int ticks_per_run, float *p)
{
  int i, j, N;
  struct ad_cha_layout layout;

  printf ("dump of run %d\n", run_id);

  for (i = 0; i < chac; i++)
    {
      ad_get_channel_layout (adh, i, &layout);

      printf ("----------------------------------------------\n");
      printf ("channel #%d\n", i);

      printf ("first sample (run/off) %d/%d\n", layout.start.run, layout.start.offset);
      printf ("%d samples prehistory, %d samples posthistory\n", (int) layout.prehist_samples, (int) layout.posthist_samples);
      printf ("time offset of first sample %1.3fms\n", layout.t0 * 1000.0);

      N = ticks_per_run / chav->ratio;
      for (j = 0; j < N; j++)
        {
          if (j % 8 == 0)
            printf ("\n");

          printf ("%8.3f ", *p++);
        }

      printf ("\n");

      chav++;
    }
}



/* simple scan
 */

int
run_test (const char *driver, int argc, char *argv[])
{
  int adh, i, chac, rng, rc, scan_result;
  struct ad_scan_cha_desc chav[16];
  struct ad_scan_desc sd;
  float *samples;

  adh = ad_open (driver);
  if (adh == -1)
    {
      if (ad_invalid_driver_version (errno))
        printf ("failed to open %s: invalid driver version\n", driver);
      else
        printf ("failed to open %s: err = %d\n", driver, errno);

      return 1;
    }


  chac = 0;
  memset (chav, 0, sizeof(chav));

  rng = 0;
  for (i = 2; i < argc; i++)
    {
      if (chac >= countof(chav))
        break;

      if (strcmp (argv[i], "-r") == 0)
        {
          if (argv[i+1] == NULL
              || argv[i+2] == NULL)
            break;

          rng = atoi (argv[i+1]);
          i += 2;
        }

      /* set up channel 
       *
       * sample analog input #1:
       *    ratio 1:1,
       *    no trigger
       */
      chav[chac].cha = AD_CHA_TYPE_ANALOG_IN | atoi (argv[i]);
      chav[chac].range = rng;
      chav[chac].store = AD_STORE_DISCRETE;
      chav[chac].ratio = 1;
      chav[chac].trg_mode = AD_TRG_NONE;

      chac++;
    }


  /* set up scan descriptor
   *     100Hz (t = 10ms)
   *     50 samples
   */

  sd.sample_rate = 0.010f;
  sd.prehist = 0;
  sd.posthist = 50;
  sd.ticks_per_run = 50;

  /* calc size of sample buffer
   * required to store all that sampled data
   */

  rc = ad_calc_run_size (adh, &sd, chac, chav);
  if (rc != 0)
    {
      printf ("failed to calc size of run\n");
      return rc;
    }

  samples = (float *) alloca (sd.samples_per_run * sizeof(float));

  /* start scan
   */

  rc = ad_start_scan (adh, &sd, chac, chav);

  if (rc == 0)
    {
      rc = ad_get_next_run_f (adh, NULL, NULL, samples);

      ad_stop_scan (adh, &scan_result);

      if (rc == 0)
        dump_samples (adh, 0, chac, chav, sd.ticks_per_run, samples);
    }

  return rc;
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
