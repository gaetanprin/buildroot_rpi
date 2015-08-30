/*
 * Includes
 */
#include <linux/kernel.h>	/* printk() */
#include <linux/module.h>	/* modules */
#include <linux/init.h>		/* module_{init,exit}() */
#include <linux/fs.h>           /* file_operations */
#include <asm/uaccess.h>	/* copy_{from,to}_user() */
#include <asm/io.h>	/* copy_{from,to}_user() */
#include <linux/miscdevice.h>   /* misc driver interface */

#include "rpi_gpio.h"

MODULE_LICENSE("GPL");

#define BCM2708_PERI_BASE        0x20000000
#define GPIO_BASE                (BCM2708_PERI_BASE + 0x200000) /* GPIO controler */

// GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x) 
// or SET_GPIO_ALT(x,y)
#define INP_GPIO(addr,g) *((addr)+((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(addr,g) *((addr)+((g)/10)) |=  (1<<(((g)%10)*3))

#define GPIO_SET(gpio) *((gpio)+7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR(gpio) *((gpio)+10) // clears bits which are 1 ignores bits which are 0
// For GPIO# >= 32 (RPi B+)
#define GPIO_SET_EXT(gpio) *(gpio+8)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR_EXT(gpio) *(gpio+11) // clears bits which are 1 ignores bits which are 0

unsigned long *virt_addr;

static int gpio_nr = 2;

module_param(gpio_nr, int, 0644);

/*
 * Global variables
 */

static struct miscdevice mymisc; /* Misc device handler */

/*
 * File operations
 */
static int rpi_gpio_drv_open(struct inode *inode, struct file *file)
{
  printk(KERN_INFO "raspberry GPIO driver : driver is in use\n");

  return 0;
}

static int rpi_gpio_drv_release(struct inode *inode, struct file *file)
{
  printk(KERN_INFO "raspberry GPIO driver : driver released\)\n");

  return 0;
}

static long rpi_gpio_drv_ioctl(struct file *file, unsigned int cmd, unsigned long arg)

{
  if (cmd == RPI_GPIO_SET) {
    if (gpio_nr >= 32)
      GPIO_SET_EXT(virt_addr) = (1 << (gpio_nr % 32));
    else
      GPIO_SET(virt_addr) = (1 << gpio_nr);
  }
  else if (cmd == RPI_GPIO_CLEAR) {
    if (gpio_nr >= 32)
      GPIO_CLR_EXT(virt_addr) = (1 << (gpio_nr % 32));
    else
      GPIO_CLR(virt_addr) = (1 << gpio_nr);
  }

  return 0;
}

static struct file_operations rpi_gpio_drv_fops = {
  .owner   =	THIS_MODULE,
  .unlocked_ioctl   =	rpi_gpio_drv_ioctl,
  .open    =	rpi_gpio_drv_open,
  .release =	rpi_gpio_drv_release,
};

/*
 * Init and Exit
 */
static int __init rpi_gpio_drv_init(void)
{
  int ret;

  mymisc.minor = MISC_DYNAMIC_MINOR;
  mymisc.name = "rpi_gpio_drv";
  mymisc.fops = &rpi_gpio_drv_fops;

  ret = misc_register(&mymisc);

  // Map GPIO addr
  if ((virt_addr = ioremap (GPIO_BASE, PAGE_SIZE)) == NULL) {
    printk(KERN_ERR "Can't map GPIO addr !\n");
    return -1;
  }
  else
    printk(KERN_INFO "GPIO mapped to 0x%08x\n", (unsigned int)virt_addr);

  OUT_GPIO(virt_addr, gpio_nr);

  if (ret < 0) {
    printk(KERN_WARNING "rpi_gpio_drv: unable to get a dynamic minor\n");
    return ret;
  }

  return 0;
}

static void __exit rpi_gpio_drv_exit(void)
{
  misc_deregister(&mymisc);

  // Unmap addr
  iounmap (virt_addr);

  printk(KERN_INFO "rpi_gpio_drv: successfully unloaded\n");
}

/*
 * Module entry points
 */
module_init(rpi_gpio_drv_init);
module_exit(rpi_gpio_drv_exit);
