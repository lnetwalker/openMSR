/* kolter_1616.c
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
 * version 1.0beta3: adapted to kernel version 2.4 (KS)
 * version 1.1: support kernel version 2.6,
 *              use new PCI scheme (KS)
 */



#include <linux/module.h>       /* generic module infos */
#include <linux/pci.h>          /* pci-bios functions   */
#include <linux/fs.h>           /* definitions for ioctl */
#include <linux/delay.h>        /* udelay()             */
#include <asm/io.h>             /* inb(), outb() etc.   */
#include <asm/uaccess.h>        /* copy_to_user()       */
#include <linux/init.h>         /* init stuff */

#include "kolter_1616.h"        /* ioctl-definitions   */


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
MODULE_DESCRIPTION("Driver for Kolter digital I/O card");
MODULE_LICENSE("GPL");
#endif


/* kolter 1616 general definitions */
#define PCI_VENDOR_ID_KOLTER             0x1001
#define PCI_DEVICE_ID_KOLTER_1616        0x0010
#define PCI_DEVICE_ID_KOLTER_1616_RELAIS 0x0013

/* kolter 1616 uses 8 io-port bytes */
#define KOLTER_1616_IO_EXTENT 0x08

/* Major number for /dev/kolter_1616.[0-7] */
#define KOLTER_1616_MAJOR 240

/* kolter 1616 register file */
#define KOLTER_1616_OUTPUT_A_ADDR   0x00
#define KOLTER_1616_OUTPUT_B_ADDR   0x01
#define KOLTER_1616_INPUT_A_ADDR    0x04
#define KOLTER_1616_INPUT_B_ADDR    0x05

/* the base addresses of the 1616-cards will stored here */
unsigned long kolter_1616_pci_ioaddr[KOLTER_1616_MAXBOARDS];
unsigned long kolter_1616_pci_iolen[KOLTER_1616_MAXBOARDS];

/* number of detected cards will be stored here */
int kolter_1616_pci_cards;


/* open-routine: only used to look if selected device is valid */
static int kolter_1616_open(struct inode *inode, struct file *file)
{

   /* find out accessed device: /dev/kolter_1616.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);

   /* ignore access to non-existent cards */
   if ((minor >= kolter_1616_pci_cards) ||
       (kolter_1616_pci_ioaddr[minor] == 0))
      return -EIO;

#ifndef _KERN_2_6_
   /* increase module usage counter 
      kernel 2.6 handles this automatically */
   MOD_INC_USE_COUNT;
#endif

   return 0;

};


/* close-routine: only used to look if selected device is valid */
static int kolter_1616_release(struct inode *inode, struct file *file)
{

   /* find out accessed device: /dev/kolter_1616.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);

   /* ignore access to non-existent cards */
   if ((minor >= kolter_1616_pci_cards) ||
       (kolter_1616_pci_ioaddr[minor] == 0))
      return -EIO;

#ifndef _KERN_2_6_
   /* decrease module usage counter 
      kernel 2.6 handles this automatically */
   MOD_DEC_USE_COUNT;
#endif

   return 0;

};


/* ioctl-routine for input and output */
static int kolter_1616_ioctl(struct inode *inode, struct file *file,
                             unsigned int cmd, unsigned long arg)
{

   /* find out accessed device: /dev/kolter_1616.<minor> */
   unsigned int minor = MINOR(inode->i_rdev);
   unsigned long ret=0;

   /* ignore access to non-existent cards */
   if (minor >= kolter_1616_pci_cards)
      return -EIO;

   /* process ioctl-command */
   switch (cmd) {

   case KOLTER_1616_OUTPUT:
      /* pass data to output */
      outw(arg, kolter_1616_pci_ioaddr[minor] + KOLTER_1616_OUTPUT_A_ADDR);
      return 0;

   case KOLTER_1616_INPUT:
      /* get data from input */
      {
         unsigned int value = inw(kolter_1616_pci_ioaddr[minor]
                                  + KOLTER_1616_INPUT_A_ADDR);
         ret=copy_to_user((int *) arg, (int *) &value, sizeof(unsigned int));
      };
      return 0;

   };

   /* invalid ioctl-command */
   return -EIO;

};


/* what to do when specific file-operations occur */
static struct file_operations kolter_1616_fops = {
#if (defined _KERN_2_4_ || defined _KERN_2_6_)
   owner:THIS_MODULE,
#endif
   NULL,                        /* seek */
   NULL,                        /* read */
   NULL,                        /* write */
   NULL,                        /* readdir */
   NULL,                        /* poll */
   ioctl:kolter_1616_ioctl,     /* ioctl */
   NULL,                        /* mmap */
   open:kolter_1616_open,       /* open */
   NULL,                        /* flush */
   release:kolter_1616_release, /* release */
   NULL,                        /* fsync */
   NULL,                        /* fasync */
   NULL,                        /* check_media_change */
   NULL,                        /* revalidate */
   NULL,                        /* lock */
};


#ifdef _NEW_PCI_CODE_
/* init one device */
static int __devinit kolter_1616_init_one(struct pci_dev *dev,
                                          const struct pci_device_id *ent)
{
   unsigned long ioaddr, iolen;

   /* If we have too many devices, go away */
   if (kolter_1616_pci_cards >= KOLTER_1616_MAXBOARDS) {
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
   printk(KERN_INFO "kolter_1616: pci-card %i found at address 0x%lx\n",
          kolter_1616_pci_cards, ioaddr);
   //printk("bus=%i, device=%i\n",pci_bus,pci_device_fn>>3);

   /* store io-address of found pci-card */
   kolter_1616_pci_ioaddr[kolter_1616_pci_cards] = ioaddr;
   kolter_1616_pci_iolen[kolter_1616_pci_cards] = iolen;

   /* increment card counter */
   kolter_1616_pci_cards++;

   return 0;
}


/* remove one device */
static void __devexit kolter_1616_remove_one(struct pci_dev *dev)
{
   unsigned long ioaddr;
   int ind;

   /* look for this device */
   ioaddr = pci_resource_start(dev, 0);
   for (ind = 0; ind < kolter_1616_pci_cards; ind++) {
      if (ioaddr == kolter_1616_pci_ioaddr[ind]) {
         /* release */
         release_region(ioaddr, kolter_1616_pci_iolen[ind]);
         kolter_1616_pci_ioaddr[ind] = 0;
         if (ind == kolter_1616_pci_cards - 1)
            /* last card removed */
            kolter_1616_pci_cards--;
      }
   }

   return;
}


/* PCI device table */
static struct pci_device_id kolter_1616_pci_tbl[] __devinitdata = {
   {PCI_VENDOR_ID_KOLTER, PCI_DEVICE_ID_KOLTER_1616, PCI_ANY_ID,
    PCI_ANY_ID, 0, 0, 0},
   {PCI_VENDOR_ID_KOLTER, PCI_DEVICE_ID_KOLTER_1616_RELAIS, PCI_ANY_ID,
    PCI_ANY_ID, 0, 0, 0},
   {0,},                        /* terminate list */
};
MODULE_DEVICE_TABLE(pci, kolter_1616_pci_tbl);

static struct pci_driver kolter_1616_pci_driver = {
   name:"kolter_1616",
   id_table:kolter_1616_pci_tbl,
   probe:kolter_1616_init_one,
   remove:kolter_1616_remove_one,
};
#endif /* _NEW_PCI_CODE_ */


#ifndef _KERN_2_6_
/* use old initialisation scheme */
#define kolter_1616_init_module init_module
#define kolter_1616_cleanup_module cleanup_module
#endif

/* prototype */
static void __exit kolter_1616_cleanup_module(void);


/* initialisize module, called at 'insmod' */
static int __init kolter_1616_init_module(void)
{
#ifdef _NEW_PCI_CODE_
   int ret;
#endif

   /* reset number of found cards */
   kolter_1616_pci_cards = 0;
   memset(kolter_1616_pci_ioaddr, 0, sizeof(kolter_1616_pci_ioaddr));

   /* try to register major number for device access */
   if (register_chrdev(KOLTER_1616_MAJOR, "kolter_1616",
                       &kolter_1616_fops) != 0) {
      printk("kolter_1616: unable to get major %d\n", KOLTER_1616_MAJOR);
      return -EIO;
   }
#ifdef _NEW_PCI_CODE_
   if ((ret = pci_register_driver(&kolter_1616_pci_driver)) < 0) {
      printk(KERN_ERR "kolter_1616: can't register PCI driver (%d)\n",
             ret);
      unregister_chrdev(KOLTER_1616_MAJOR, "kolter_1616");
      return -EIO;
   }
#else /* !_NEW_PCI_CODE_ */
   /* pci bios present ? */
   if (pcibios_present()) {

      unsigned char pci_bus, pci_device_fn;
      unsigned int pci_ioaddr;

      /* at least one Kolter 1616 present? */
      while (pcibios_find_device(PCI_VENDOR_ID_KOLTER,
                                 PCI_DEVICE_ID_KOLTER_1616,
                                 kolter_1616_pci_cards,
                                 &pci_bus, &pci_device_fn) == 0) {

         /* more cards installed than supported? */
         if (kolter_1616_pci_cards == KOLTER_1616_MAXBOARDS) {
            printk("kolter_1616: too many pci-cards present\n");
            kolter_1616_pci_cards--;
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
         request_region(pci_ioaddr, KOLTER_1616_IO_EXTENT, "kolter_1616");

         /* inform user */
         printk("kolter_1616: pci-card %i found at address 0x%x, ",
                kolter_1616_pci_cards, pci_ioaddr);
         printk("bus=%i, device=%i\n", pci_bus, pci_device_fn >> 3);

         /* store io-address of found pci-card */
         kolter_1616_pci_ioaddr[kolter_1616_pci_cards] = pci_ioaddr;

         /* try to find another kolter 1616 */
         kolter_1616_pci_cards++;

      };

      /* at least one Kolter 1616 with Relais present? */
      while (pcibios_find_device(PCI_VENDOR_ID_KOLTER,
                                 PCI_DEVICE_ID_KOLTER_1616_RELAIS,
                                 kolter_1616_pci_cards,
                                 &pci_bus, &pci_device_fn) == 0) {

         /* more cards installed than supported? */
         if (kolter_1616_pci_cards == KOLTER_1616_MAXBOARDS) {
            printk("kolter_1616: too many pci-cards present\n");
            kolter_1616_pci_cards--;
            cleanup_module();
            return -EIO;
         };

         /* read base io-address */
         pcibios_read_config_dword(pci_bus, pci_device_fn,
                                   PCI_BASE_ADDRESS_0, &pci_ioaddr);

         /* mask out io/mem-info since we know it is an io-address */
         pci_ioaddr &= PCI_BASE_ADDRESS_IO_MASK;

         /* normaly, regions should not yet be occupied by other cards,
            so we can omit checking if regions are already reserved */
         request_region(pci_ioaddr, KOLTER_1616_IO_EXTENT,
                        "kolter_1616_relais");

         /* inform user */
         printk("kolter_1616_relais: pci-card %i found at address 0x%x, ",
                kolter_1616_pci_cards, pci_ioaddr);
         printk("bus=%i, device=%i\n", pci_bus, pci_device_fn >> 3);

         /* store io-address of found pci-card */
         kolter_1616_pci_ioaddr[kolter_1616_pci_cards] = pci_ioaddr;

         /* try to find another kolter 1616 */
         kolter_1616_pci_cards++;

      };

      /* any kolter 1616 cards present? */
      if (kolter_1616_pci_cards) {

         printk("kolter_1616: %i pci-cards found\n",
                kolter_1616_pci_cards);
         return 0;

      };

      printk("kolter_1616: no pci-cards found\n");
      return -EIO;

   }

   printk("kolter_1616: no pci-bios present\n");
   return -EIO;
#endif /* !_NEW_PCI_CODE_ */

   return 0;
}


/* deinitialisize module, called at 'rmmod' */
static void __exit kolter_1616_cleanup_module(void)
{

#ifndef _NEW_PCI_CODE_
   int index;
#endif

   /* unregister character device from defined major number */
   unregister_chrdev(KOLTER_1616_MAJOR, "kolter_1616");

#ifdef _NEW_PCI_CODE_
   /* unregister PCI driver */
   pci_unregister_driver(&kolter_1616_pci_driver);
#else /* !_NEW_PCI_CODE_ */
   /* unregister io-regions from the kernel */
   for (index = 0; index < kolter_1616_pci_cards; index++) {
      release_region(kolter_1616_pci_ioaddr[index], KOLTER_1616_IO_EXTENT);
   };
#endif /* !_NEW_PCI_CODE_ */

   return;
}


#ifdef _KERN_2_6_
module_init(kolter_1616_init_module);
module_exit(kolter_1616_cleanup_module);
#endif
