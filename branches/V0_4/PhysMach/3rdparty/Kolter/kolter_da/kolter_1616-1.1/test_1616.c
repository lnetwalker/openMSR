/* test_1616.c - kolter 1616 test program
 * 
 * Copyright (C) 1999 by Bernhard Kuhn <bkuhn@linux-magazin.de>
 * Copying Licence: GPL
 * Last Modification: Die Aug  3 01:57:11 CEST 1999
 *
 * history:
 * version 1.0beta1: initial version
 */



#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>



#include "kolter_1616.h"  /* ioctl-commands and some inline functions */



int main(int argc,char* argv[]) {

  int fd,output_value,input_value;


  if(argc!=2) {
    printf("usage: test_1616 <device>\n");
    printf("where <device> is on of '/dev/kolter_1616.[0-7]'\n");
    printf("\nRTFSC for more information\n");
    exit(1);
  };



  /* get file descriptor for adda-card */
  fd = open(argv[1],O_RDWR);

  if(fd<0) {
    printf("error opening device %s\n",argv[1]);
    exit(1);
  };


  for(;;) {

    /* count forever */
    for(output_value=0;output_value<65536;output_value++) {

      /* pass counter to output-lines */
      kolter_1616_output(fd,output_value);

      /* get value from input lines */
      input_value=kolter_1616_input(fd);

      printf("%x\n",input_value);
      sleep(1);

    };
  };

  /* will never reach that point (press CTRL+C) */
  close(fd);
  return 0;
};






