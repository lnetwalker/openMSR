/* kolter_adda.h
 * 
 * Copyright (C) 1999 by Bernhard Kuhn <bkuhn@linux-magazin.de>
 * Copying Licence: GPL
 * Last Modification: Die Aug  3 01:57:11 CEST 1999
 *
 * history:
 * version 1.0beta1: initial version
 */



#ifndef KOLTER_ADDA_H
#define KOLTER_ADDA_H



/* declare adc- and dac-resolution */
#define KOLTER_ADC_BITS 16
#define KOLTER_DAC_BITS 12

/* define the number of maximum supported boards */
#define KOLTER_ADDA_MAXBOARDS 8

/* define default timings for multiplexer,
   ad- and da-converter in microseconds */
#define KOLTER_MUX_DEFAULT_DELAY 10
#define KOLTER_ADC_DEFAULT_DELAY 25   /* f_sample_max =  40KHz */
#define KOLTER_DAC_DEFAULT_DELAY 5    /* f_sample_max = 200KHz */



/* integer ranges of ad-converters ... */
#define KOLTER_ADC_RANGE (1<<KOLTER_ADC_BITS)
#define KOLTER_ADC_HALF  (KOLTER_ADC_RANGE/2)
#define KOLTER_ADC_MIN   (-KOLTER_ADC_HALF)
#define KOLTER_ADC_MAX   (KOLTER_ADC_HALF-1)

/* ... and da-converters */
#define KOLTER_DAC_RANGE (1<<KOLTER_DAC_BITS)
#define KOLTER_DAC_HALF  (KOLTER_DAC_RANGE/2)
#define KOLTER_DAC_MIN   (-KOLTER_DAC_HALF)
#define KOLTER_DAC_MAX   (KOLTER_DAC_HALF-1)



/* generic commands */
#define KOLTER_ADDA_GENERIC_CMD 0x0000

/* select on out of 16 adc-channels (0-15) */
#define KOLTER_MUX_SELECT (KOLTER_ADDA_GENERIC_CMD | 0)

/* sample a value from the channel previsiously selected */
#define KOLTER_ADC_SAMPLE (KOLTER_ADDA_GENERIC_CMD | 1)

/* pass through all latched da-registers to the four da-converters */
#define KOLTER_DAC_TRANSFER (KOLTER_ADDA_GENERIC_CMD | 2)

/* change settling time for for ad-multiplexer, ad- and da-converters */
#define KOLTER_MUX_DELAY (KOLTER_ADDA_GENERIC_CMD | 3)
#define KOLTER_ADC_DELAY (KOLTER_ADDA_GENERIC_CMD | 4)
#define KOLTER_DAC_DELAY (KOLTER_ADDA_GENERIC_CMD | 5)

/* access digital input and output */
#define KOLTER_ADDA_IN (KOLTER_ADDA_GENERIC_CMD | 6)
#define KOLTER_ADDA_OUT (KOLTER_ADDA_GENERIC_CMD | 7)



/* sample a specific or indexed channel */
#define KOLTER_ADC_SAMPLE_INDEXED  0x10000
#define KOLTER_ADC_SAMPLE_0  (KOLTER_ADC_SAMPLE_INDEXED | 0)
#define KOLTER_ADC_SAMPLE_1  (KOLTER_ADC_SAMPLE_INDEXED | 1)
#define KOLTER_ADC_SAMPLE_2  (KOLTER_ADC_SAMPLE_INDEXED | 2)
#define KOLTER_ADC_SAMPLE_3  (KOLTER_ADC_SAMPLE_INDEXED | 3)
#define KOLTER_ADC_SAMPLE_4  (KOLTER_ADC_SAMPLE_INDEXED | 4)
#define KOLTER_ADC_SAMPLE_5  (KOLTER_ADC_SAMPLE_INDEXED | 5)
#define KOLTER_ADC_SAMPLE_6  (KOLTER_ADC_SAMPLE_INDEXED | 6)
#define KOLTER_ADC_SAMPLE_7  (KOLTER_ADC_SAMPLE_INDEXED | 7)
#define KOLTER_ADC_SAMPLE_8  (KOLTER_ADC_SAMPLE_INDEXED | 8)
#define KOLTER_ADC_SAMPLE_9  (KOLTER_ADC_SAMPLE_INDEXED | 9)
#define KOLTER_ADC_SAMPLE_10 (KOLTER_ADC_SAMPLE_INDEXED | 10)
#define KOLTER_ADC_SAMPLE_11 (KOLTER_ADC_SAMPLE_INDEXED | 11)
#define KOLTER_ADC_SAMPLE_12 (KOLTER_ADC_SAMPLE_INDEXED | 12)
#define KOLTER_ADC_SAMPLE_13 (KOLTER_ADC_SAMPLE_INDEXED | 13)
#define KOLTER_ADC_SAMPLE_14 (KOLTER_ADC_SAMPLE_INDEXED | 14)
#define KOLTER_ADC_SAMPLE_15 (KOLTER_ADC_SAMPLE_INDEXED | 15)



/* latch a specific or indexed da-register for later pass-through */
#define KOLTER_DAC_LATCH_INDEXED  0x20000
#define KOLTER_DAC_LATCH_A (KOLTER_DAC_LATCH_INDEXED | 0)
#define KOLTER_DAC_LATCH_B (KOLTER_DAC_LATCH_INDEXED | 1)     
#define KOLTER_DAC_LATCH_C (KOLTER_DAC_LATCH_INDEXED | 2)
#define KOLTER_DAC_LATCH_D (KOLTER_DAC_LATCH_INDEXED | 3)



/* pass through a specific or indexed da-register immediatly */ 
#define KOLTER_DAC_SET_INDEXED 0x30000 
#define KOLTER_DAC_SET_A (KOLTER_DAC_SET_INDEXED | 0)
#define KOLTER_DAC_SET_B (KOLTER_DAC_SET_INDEXED | 1)
#define KOLTER_DAC_SET_C (KOLTER_DAC_SET_INDEXED | 2)
#define KOLTER_DAC_SET_D (KOLTER_DAC_SET_INDEXED | 3)



#define KOLTER_ADDA_CMD_MASK 0xf0000



#endif



