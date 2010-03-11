/* kolter_1616.h
 * 
 * Copyright (C) 1999 by Bernhard Kuhn <bkuhn@linux-magazin.de>
 * Copying Licence: GPL
 * Last Modification: Die Aug  3 01:57:11 CEST 1999
 *
 * history:
 * version 1.0beta1: initial version
 */



#ifndef KOLTER_1616_H
#define KOLTER_1616_H



/* ioctl-functions */
#define KOLTER_1616_OUTPUT   1
#define KOLTER_1616_INPUT    2

/* define the number of maximum supported boards */
#define KOLTER_1616_MAXBOARDS 8



/* include the following functions for user-space application */
#ifndef __KERNEL__

/* pass a 16 bit wide value to output-lines */
inline void kolter_1616_output(int fd,int val) {
  ioctl(fd,KOLTER_1616_OUTPUT,val);
};

/* get a 16 bit wide value from input-lines */
inline int kolter_1616_input(int fd) {
  int val;
  ioctl(fd,KOLTER_1616_INPUT,&val);
  return val;
};

#endif



#endif



