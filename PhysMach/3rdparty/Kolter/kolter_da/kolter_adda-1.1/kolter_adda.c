/* kolter_adda.c
 * 
 * Copyright (C) 1999 by Bernhard Kuhn <bkuhn@linux-magazin.de>
 * Copying Licence: GPL
 * Last Modification: Die Aug 17 11:29:37 CEST 1999
 * Modifications after 1.0beta2: (c) Klaus Schneider <klaus_snd@web.de>
 * last modified: Wed Jan 12 18:35:43 CET 2005
 *
 * history:
 * version 1.0beta1: initial version
 * version 1.0beta2: added openb/close for "module in use"-counter
 * version 1.0beta3: included readout of status byte in A/D conversion, 
 *                   adapted to kernel version 2.4 (KS)
 * version 1.1: support kernel version 2.6,
 *              use new PCI scheme (KS)
 */



#include <linux/module.h>       /* generic module infos */
#include <linux/pci.h>          /* pci-bios functions   */
#include <linux/fs.h>           /* definitions for fops */
#include <linux/delay.h>        /* udelay()             */
#include <asm/io.h>             /* inb(), outb() etc.   */
#include <asm/uaccess.h>        /* copy_to_user()       */
#include <linux/init.h>         /* init stuff */

#include "kolter_adda.h"        /* ioctl-definitions */


#ifndef CONFIG_PCI
#error "PCI support not enabled!"
#endif

#ifdef KERNEL_VERSION

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0))
#define _KERN_2_6_
#elif (LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0))
#define _KERN_2_4_
#else /* pre 2.4.0 */
#define __init
#define __exit
#endif

#else /* !defined KERNEL_VERSION */
#define _KERN_2_6_
#endif

#ifdef _KERN_2_6_
#define _NEW_PCI_CODE_
#endif


/* Module info */
#if (defined _KERN_2_4_ || defined _KERN_2_6_)
MODULE_AUTHOR("Bernhard Kuhn <bkuhn@linux-magazin.de>, "
              "Klaus Schneider <klaus_snd@web.de>");
MODULE_DESCRIPTION("Driver for Kolter Analogue I/O board");
MODULE_LICENSE("GPL");
#endif


/* kolter adda general definitions */
#define PCI_VENDOR_ID_KOLTER 0x1001
#define PCI_DEVICE_ID_KOLTER_ADDA 0x12
#define PCI_DEVICE_ID_KOLTER_ADDA_2 0x15
#define KOLTER_ADDA_IO_EXTENT 0x40
#define KOLTER_ADDA_MAJOR 241

/* kolter adda register file */
#define KOLTER_ADC_BASE           0x00
#define KOLTER_ADC_STATUS         0x01
#define KOLTER_ADC_MUX            0x04
#define KOLTER_ADDA_OUTPUT        0x10
#define KOLTER_ADDA_INPUT         0x11
#define KOLTER_DAC_TRANSFER_DUMMY 0x1D
#define KOLTER_DAC_BASE           0x20

#define KOLTER_ADC_MUX_MASK     0x0f
#define KOLTER_ADDA_INPUT_MASK  0x02
#define KOLTER_ADDA_OUTPUT_MASK 0x01


/* the base address of the adda-card is stored here */
unsigned long kolter_adda_pci_ioaddr[KOLTER_ADDA_MAXBOARDS];
unsigned long kolter_adda_pci_iolen[KOLTER_ADDA_MAXBOARDS];

/* number of detected cards will be stored here */
int kolter_adda_pci_cards;

/* delays (in microseconds) for ad-multiplexer, ad- and da-converters */
unsigned int kolter_mux_delay[KOLTER_ADDA_MAXBOARDS];
unsigned int kolter_adc_delay[KOLTER_ADDA_MAXBOARDS];
unsigned int kolter_dac_delay[KOLTER_ADDA_MAXBOARDS];


/* transfer all latched da-registers to the four da-converters */
void kolter_dac_transfer(int card)
{

   /* read access to dummy register will transfer da-registers */
   (void) inb(kolter_adda_pci_ioaddr[card] + KOLTER_DAC_TRANSFER_DUMMY);

   /* do a delay to garanty a minimum output time */
   udelay(kolter_dac_delay[card]);

};


/* latch value in da-register */
void kolter_dac_latch(int card, int channel, int value)
{

   /* calculate io-address of da-channel low register */
   int addr =
       kolter_adda_pci_ioaddr[card] + KOLTER_DAC_BASE + (channel << 3);

   /* do nothing if da-channel is invalid */
   if (channel < 0 || channel > 3)
      return;

   /* boundary checks */
   if (value < KOLTER_DAC_MIN)
      value = KOLTER_DAC_MIN;
   else if (value > KOLTER_DAC_MAX)
      value = KOLTER_DAC_MAX;

   /* convert signed integer value to kolter format */
   value += KOLTER_DAC_HALF;

   /* put value into low and high bytes of latch-register */
   outb(value & 0xff, addr);
   outb(value >> 8, addr + 4);

};


/* select ad-channel for multiplexer */
void kolter_mux_select(int card, int channel)
{

   /* check channel boundary */
   channel &= KOLTER_ADC_MUX_MASK;

   /* select channel */
   outb(channel, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_MUX);

   /* do a delay to set up multiplexer */
   udelay(kolter_mux_delay[card]);

};


/* perform ad-conversion */
int kolter_adc_sample(int card)
{

   unsigned char low, high;
   unsigned int value;

   /* start conversion */
   outb(1, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);
   outb(1, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);
   outb(0, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);

   /* wait some time */
   udelay(kolter_adc_delay[card]);
   /* wait for status bit to indicate end of conversion */
   while ((inb(kolter_adda_pci_ioaddr[card] + KOLTER_ADC_STATUS) & 1) == 0);


   /* read low and high bytes of sample */
   outb(1, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);
   high = inb(kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);
   outb(3, kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);
   low = inb(kolter_adda_pci_ioaddr[card] + KOLTER_ADC_BASE);

   /* calculate sampled value */
   value = (high << 8) | low;

   /* convert sampled value from kolter format to signed integer */
   return value - KOLTER_ADC_HALF;

};


/* return zero if input is low, otherwise one */
int kolter_adda_in(int card)
{

   if ((inb(kolter_adda_pci_ioaddr[card] +
            KOLTER_ADDA_INPUT) & KOLTER_ADDA_INPUT_MASK))
      return 1;
   else
      return 0;

};


/* set digital output to low if value is zero, otherwise to high */
void kolter_adda_out(int card, int value)
{
   if (value)
      outb(KOLTER_ADDA_OUTPUT_MASK,
           kolter_adda_pci_ioaddr[card] + KOLTER_ADDA_OUTPUT);
   else
      outb(0, kolter_adda_pci_ioaddr[card] + KOLTER_ADDA_OUTPUT);
};


/* open-routine: only used to look if selected device is valid */
static int kolter_adda_open(struct inode *inode, struct file *file)
{

   /* find out accessed device: /dev/kolter_adda.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);


   /* ignore access to non-existent cards */
   if ((minor >= kolter_adda_pci_cards) ||
       (kolter_adda_pci_ioaddr[minor] == 0))
      return -EIO;

#ifndef _KERN_2_6_
   /* increase module usage counter 
      kernel 2.6 handles this automatically */
   MOD_INC_USE_COUNT;
#endif

   return 0;

};


/* close-routine: only used to look if selected device is valid */
static int kolter_adda_release(struct inode *inode, struct file *file)
{

   /* find out accessed device: /dev/kolter_adda.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);

   /* ignore access to non-existent cards */
   if ((minor >= kolter_adda_pci_cards) ||
       (kolter_adda_pci_ioaddr[minor] == 0))
      return -EIO;

#ifndef _KERN_2_6_
   /* decrease module usage counter 
      kernel 2.6 handles this automatically */
   MOD_DEC_USE_COUNT;
#endif

   return 0;

};


/* ioctl-routine: */
static int kolter_adda_ioctl(struct inode *inode, struct file *file,
                             unsigned int cmd, unsigned long arg)
{

   /* find out accessed device: /dev/kolter_adda.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);
   unsigned long ret=0;

   /* ignore access to non-existent cards */
   if (minor >= kolter_adda_pci_cards)
      return -EIO;

   /* process ioctl-command */
   switch (cmd & KOLTER_ADDA_CMD_MASK) {

   case KOLTER_ADDA_GENERIC_CMD:

      switch (cmd) {

      case KOLTER_MUX_SELECT:
         kolter_mux_select(minor, arg);
         break;

      case KOLTER_ADC_SAMPLE:
         {
            int value = kolter_adc_sample(minor);
	    /* FIXME: ret holds the amount of bytes _NOT_ copied to user space.
	              Thus it should be checked, whether it is zero (no error)
		      or not zero (error). Leave unchecked for now */
            ret=copy_to_user((int *) arg, &value, sizeof(int));
         };
         break;

      case KOLTER_DAC_TRANSFER:
         kolter_dac_transfer(minor);
         break;

      case KOLTER_MUX_DELAY:
         kolter_mux_delay[minor] = arg;
         break;

      case KOLTER_ADC_DELAY:
         kolter_adc_delay[minor] = arg;
         break;

      case KOLTER_DAC_DELAY:
         kolter_dac_delay[minor] = arg;
         break;

      case KOLTER_ADDA_IN:
         {
            int value = kolter_adda_in(minor);
	    /* FIXME: ret holds the amount of bytes _NOT_ copied to user space.
	              Thus it should be checked, whether it is zero (no error)
		      or not zero (error). Leave unchecked for now */
            ret=copy_to_user((int *) arg, &value, sizeof(int));
         };
         break;

      case KOLTER_ADDA_OUT:
         kolter_adda_out(minor, arg);
         break;

      };
      break;

   case KOLTER_ADC_SAMPLE_INDEXED:
      {
         int value;
         int ad_channel = cmd & ~KOLTER_ADDA_CMD_MASK;
         kolter_mux_select(minor, ad_channel);
         value = kolter_adc_sample(minor);
        /* FIXME: ret holds the amount of bytes _NOT_ copied to user space.
	          Thus it should be checked, whether it is zero (no error)
	          or not zero (error). Leave unchecked for now */
         ret=copy_to_user((int *) arg, &value, sizeof(int));
      };
      break;

   case KOLTER_DAC_LATCH_INDEXED:
      {
         int da_channel = cmd & ~KOLTER_ADDA_CMD_MASK;
         kolter_dac_latch(minor, da_channel, arg);
      };
      break;

   case KOLTER_DAC_SET_INDEXED:
      {
         int da_channel = cmd & ~KOLTER_ADDA_CMD_MASK;
         kolter_dac_latch(minor, da_channel, arg);
         kolter_dac_transfer(minor);
      };
      break;

   };

   return 0;
};


/* what to do when specific file-operations occur */
static struct file_operations kolter_adda_fops = {
#if (defined _KERN_2_4_ || defined _KERN_2_6_)
   owner:THIS_MODULE,
#endif
   NULL,                        /* seek */
   NULL,                        /* read */
   NULL,                        /* write */
   NULL,                        /* readdir */
   NULL,                        /* poll */
   ioctl:kolter_adda_ioctl,     /* ioctl */
   NULL,                        /* mmap */
   open:kolter_adda_open,       /* open */
   NULL,                        /* flush */
   release:kolter_adda_release, /* release */
   NULL,                        /* fsync */
   NULL,                        /* fasync */
   NULL,                        /* check_media_change */
   NULL,                        /* revalidate */
   NULL,                        /* lock */
};


#ifdef _NEW_PCI_CODE_
/* init one device */
static int __devinit kolter_adda_init_one(struct pci_dev *dev,
                                          const struct pci_device_id *ent)
{
   unsigned long ioaddr, iolen;

   /* If we have too many devices, go away */
   if (kolter_adda_pci_cards >= KOLTER_ADDA_MAXBOARDS) {
      return -EIO;
   }

   /* enable device */
   if (pci_enable_device(dev)) {
      printk(KERN_ERR "Error enabling PCI device %p\n", dev);
      return -EIO;
   }

   /* read base io-address */
   ioaddr = pci_resource_start(dev, 0);
   iolen = pci_resource_len(dev, 0);
   if (request_region(ioaddr, iolen, pci_name(dev)) == NULL) {
      printk(KERN_ERR "I/O address conflict for device \"%s\"\n",
             pci_name(dev));
      return -EIO;
   }

   /* inform user */
   printk(KERN_INFO "kolter_adda: pci-card %i found at address 0x%lx\n",
          kolter_adda_pci_cards, ioaddr);
   //printk("bus=%i, device=%i\n",pci_bus,pci_device_fn>>3);

   /* store io-address of found pci-card */
   kolter_adda_pci_ioaddr[kolter_adda_pci_cards] = ioaddr;
   kolter_adda_pci_iolen[kolter_adda_pci_cards] = iolen;
   kolter_mux_delay[kolter_adda_pci_cards] = KOLTER_MUX_DEFAULT_DELAY;
   kolter_adc_delay[kolter_adda_pci_cards] = KOLTER_ADC_DEFAULT_DELAY;
   kolter_dac_delay[kolter_adda_pci_cards] = KOLTER_DAC_DEFAULT_DELAY;

   /* increment card counter */
   kolter_adda_pci_cards++;

   return 0;
}


/* remove one device */
static void __devexit kolter_adda_remove_one(struct pci_dev *dev)
{
   unsigned long ioaddr;
   int ind;

   /* look for this device */
   ioaddr = pci_resource_start(dev, 0);
   for (ind = 0; ind < kolter_adda_pci_cards; ind++) {
      if (ioaddr == kolter_adda_pci_ioaddr[ind]) {
         /* release */
         release_region(ioaddr, kolter_adda_pci_iolen[ind]);
         kolter_adda_pci_ioaddr[ind] = 0;
         if (ind == kolter_adda_pci_cards - 1)
            /* last card removed */
            kolter_adda_pci_cards--;
      }
   }

   return;
}


/* PCI device table */
static struct pci_device_id kolter_adda_pci_tbl[] __devinitdata = {
   {PCI_VENDOR_ID_KOLTER, PCI_DEVICE_ID_KOLTER_ADDA, PCI_ANY_ID,
    PCI_ANY_ID, 0, 0, 0},
   {PCI_VENDOR_ID_KOLTER, PCI_DEVICE_ID_KOLTER_ADDA_2, PCI_ANY_ID,
    PCI_ANY_ID, 0, 0, 0},
   {0,},                        /* terminate list */
};
MODULE_DEVICE_TABLE(pci, kolter_adda_pci_tbl);

static struct pci_driver kolter_adda_pci_driver = {
   name:"kolter_adda",
   id_table:kolter_adda_pci_tbl,
   probe:kolter_adda_init_one,
   remove:kolter_adda_remove_one,
};
#endif /* _NEW_PCI_CODE_ */


#ifndef _KERN_2_6_
/* use old initialisation scheme */
#define kolter_adda_init_module init_module
#define kolter_adda_cleanup_module cleanup_module
#endif

/* prototype */
static void __exit kolter_adda_cleanup_module(void);


/* initialisize module, called at 'insmod' */
static int __init kolter_adda_init_module(void)
{
#ifdef _NEW_PCI_CODE_
   int ret;
#endif

   /* reset number of found cards */
   kolter_adda_pci_cards = 0;
   memset(kolter_adda_pci_ioaddr, 0, sizeof(kolter_adda_pci_ioaddr));

   /* try to register major number for device access */
   if (register_chrdev(KOLTER_ADDA_MAJOR, "kolter_adda",
                       &kolter_adda_fops) != 0) {
      printk("kolter_adda: unable to get major %d\n", KOLTER_ADDA_MAJOR);
      return -EIO;
   }
#ifdef _NEW_PCI_CODE_
   if ((ret = pci_register_driver(&kolter_adda_pci_driver)) < 0) {
      printk(KERN_ERR "kolter_adda: can't register PCI driver (%d)\n",
             ret);
      unregister_chrdev(KOLTER_ADDA_MAJOR, "kolter_adda");
      return -EIO;
   }
#else /* !_NEW_PCI_CODE_ */
   /* pci bios present ? */
   if (pcibios_present()) {

      unsigned char pci_bus, pci_device_fn;
      unsigned int pci_ioaddr;

      /* at least one Kolter ADDA present? */
      while ((pcibios_find_device(PCI_VENDOR_ID_KOLTER,
                                  PCI_DEVICE_ID_KOLTER_ADDA,
                                  kolter_adda_pci_cards,
                                  &pci_bus, &pci_device_fn) == 0) ||
             (pcibios_find_device(PCI_VENDOR_ID_KOLTER,
                                  PCI_DEVICE_ID_KOLTER_ADDA_2,
                                  kolter_adda_pci_cards,
                                  &pci_bus, &pci_device_fn) == 0)) {

         /* more cards installed than supported? */
         if (kolter_adda_pci_cards == KOLTER_ADDA_MAXBOARDS) {
            printk("kolter_adda: too many pci-cards present\n");
            kolter_adda_pci_cards--;
            cleanup_module();
            return -EIO;
         }

         /* read base io-address */
         pcibios_read_config_dword(pci_bus, pci_device_fn,
                                   PCI_BASE_ADDRESS_0, &pci_ioaddr);

         /* mask out io/mem-info since we know it is an io-address */
         pci_ioaddr &= PCI_BASE_ADDRESS_IO_MASK;

         /* normaly, regions should not yet be occupied by other cards,
            so we can omit checking if regions are already reserved */
         request_region(pci_ioaddr, KOLTER_ADDA_IO_EXTENT, "kolter_adda");

         /* inform user */
         printk("kolter_adda: pci-card %i found at address 0x%x, ",
                kolter_adda_pci_cards, pci_ioaddr);
         printk("bus=%i, device=%i\n", pci_bus, pci_device_fn >> 3);

         /* store io-address of found pci-card */
         kolter_adda_pci_ioaddr[kolter_adda_pci_cards] = pci_ioaddr;
         kolter_mux_delay[kolter_adda_pci_cards] =
             KOLTER_MUX_DEFAULT_DELAY;
         kolter_adc_delay[kolter_adda_pci_cards] =
             KOLTER_ADC_DEFAULT_DELAY;
         kolter_dac_delay[kolter_adda_pci_cards] =
             KOLTER_DAC_DEFAULT_DELAY;

         /* try to find another Kolter ADDA */
         kolter_adda_pci_cards++;

      }

      /* any Kolter ADDA cards present? */
      if (kolter_adda_pci_cards) {
         printk("kolter_adda: %i pci-cards found\n",
                kolter_adda_pci_cards);
         return 0;
      }

      printk("kolter_adda: no pci-cards found\n");
      return -EIO;

   }

   printk("kolter_adda: no pci-bios present\n");
   return -EIO;
#endif /* !_NEW_PCI_CODE_ */

   return 0;
}


/* deinitialisize module, called at 'rmmod' */
static void __exit kolter_adda_cleanup_module(void)
{
#ifndef _NEW_PCI_CODE_
   int index;
#endif

   /* unregister character device from defined major number */
   unregister_chrdev(KOLTER_ADDA_MAJOR, "kolter_adda");

#ifdef _NEW_PCI_CODE_
   /* unregister PCI driver */
   pci_unregister_driver(&kolter_adda_pci_driver);
#else /* !_NEW_PCI_CODE_ */
   /* unregister io-regions from the kernel */
   for (index = 0; index < kolter_adda_pci_cards; index++) {
      release_region(kolter_adda_pci_ioaddr[index], KOLTER_ADDA_IO_EXTENT);
   }
#endif /* !_NEW_PCI_CODE_ */

   return;
}

#ifdef _KERN_2_6_
module_init(kolter_adda_init_module);
module_exit(kolter_adda_cleanup_module);
#endif
