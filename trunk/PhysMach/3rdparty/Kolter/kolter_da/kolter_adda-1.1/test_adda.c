/* kolter_adda.h
 * 
 * Copyright (C) 1999 by Bernhard Kuhn <bkuhn@linux-magazin.de>
 * Copying Licence: GPL
 * Last Modification: Die Aug  3 01:57:11 CEST 1999
 *
 * history:
 * version 1.0beta1: initial version
 */



/* include some stuff for file-access */
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>



/* include ioctl-commands */
#include "kolter_adda.h"



int main(int argc,char* argv[]) {

  int fd,i,j;


  if(argc!=3) {
    printf("usage: test_adda <device> <test>\n");
    printf("where <device> is on of '/dev/kolter_adda.[0-7]'\n");
    printf("and <test> is one of those:\n\n");
    printf("  -dacramp\n");
    printf("  -adcsampleall\n");
    printf("  -adcsample15\n");
    printf("  -feedback\n");
    printf("\nRTFSC for more information\n");
    exit(1);
  };


  /* get file descriptor for adda-card */
  fd = open(argv[1],O_RDWR);

  if(fd<0) {
    printf("error opening device %s\n",argv[1]);
    exit(1);
  };
  
  
  
  /* perform ramp-signal-generation on all four dac-outputs */
  if(strcmp(argv[2],"-dacramp")==0) {
    
    /* wait 2 microsec. after tranfser */
    ioctl(fd,KOLTER_DAC_DELAY,5);
    
    for(j=0;j<10;j++) {
      for(i=-KOLTER_DAC_MIN;i<KOLTER_DAC_MAX;i+=KOLTER_DAC_RANGE/100) {
	ioctl(fd,KOLTER_DAC_LATCH_A,i); /* Latch A */
	ioctl(fd,KOLTER_DAC_LATCH_B,i); /* Latch B */
	ioctl(fd,KOLTER_DAC_LATCH_C,i); /* Latch C */
	ioctl(fd,KOLTER_DAC_LATCH_D,i); /* Latch D */
	ioctl(fd,KOLTER_DAC_TRANSFER);  /* Pass A-D to DACs */
	usleep(1000); /* wait a millisecond */
      };
    };
  };
    
   
  
  
  /* sample example */
  if(strcmp(argv[2],"-adcsampleall")==0) {    

    /* wait 10 microsec. after switching to another ad-channel */
    ioctl(fd,KOLTER_MUX_DELAY,10); 
    
    /* wait 25 microsec. between samples (40KHz) */
    ioctl(fd,KOLTER_ADC_DELAY,25);
    
    /* get a sample from every ad-channel */
    for(i=0;i<15;i++) {
      int value;
      ioctl(fd,KOLTER_ADC_SAMPLE_INDEXED|i,&value);
      printf("%i %i\n",i,value);
    };
  };



  /* sample example */
  if(strcmp(argv[2],"-adcsample15")==0) {    
    
    /* select channel 15 for further adc-operations */
    ioctl(fd,KOLTER_MUX_SELECT,15);
	  
    /* get 1000 samples from the selected channel */
    for(i=0;i<1000;i++) {
      int value;
      ioctl(fd,KOLTER_ADC_SAMPLE,&value);
      printf("%i\n",value);
    };
  };



  /* feedback example: connect DAC-channel A with ADC-channel 0  */
  if(strcmp(argv[2],"-feedback")==0) {    
    
    /* set timings for mux, adc and dac */
    ioctl(fd,KOLTER_MUX_DELAY,10);
    ioctl(fd,KOLTER_ADC_DELAY,25);
    ioctl(fd,KOLTER_DAC_DELAY,5);

    /* select channel adc-channel 0 */
    ioctl(fd,KOLTER_MUX_SELECT,0);

    /* perform a ramp */
    for(i=KOLTER_DAC_MIN;i<KOLTER_DAC_MAX;i++) {
      int ival;

      /* set dac-channel */
      ioctl(fd,KOLTER_DAC_SET_A,i);
      
      /* get value adc-channel from selected channel (0) */
      ioctl(fd,KOLTER_ADC_SAMPLE,&ival);

      /* output and input should be nearly equal */
      printf("out = %3.3f V    in = %3.3f V\n",
	     (10*(float)i)/KOLTER_DAC_HALF,
	     (10*(float)ival)/KOLTER_ADC_HALF);
    };
  };
  




  
  /* input/output-test: connect digital output with digital input */
  if(strcmp(argv[2],"-iofeedback")==0) {    
    
    for(i=0;i<10;i++) {
      int ival;
      
      /* set output to high */
      ioctl(fd,KOLTER_ADDA_OUT,1);
      /* wait a second and get state of digital input */
      usleep(1000000);
      ioctl(fd,KOLTER_ADDA_IN,&ival);
      printf("1 %i\n",ival);

      /* set output to high */
      ioctl(fd,KOLTER_ADDA_OUT,0);
      /* wait a second and get state of digital input */
      usleep(1000000);
      ioctl(fd,KOLTER_ADDA_IN,&ival);
      printf("0 %i\n",ival);
    };
  };



  close(fd);
  return 0;
};






