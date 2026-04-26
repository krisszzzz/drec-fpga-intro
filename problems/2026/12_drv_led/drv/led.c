#include <linux/fs.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/vmalloc.h>

#include <asm/pgtable.h>
#include <linux/io.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>

static void __iomem *base;

static ssize_t led_write(struct file *filp, const char __user *buf,
                         size_t count, loff_t *pos) {
  char value;

  if (count == 0) {
    return -EINVAL;
  }

  if (copy_from_user(&value, buf, sizeof(char))) {
    return -EFAULT;
  }

  iowrite32(value, base);

  pr_info("Led: Wrote 0x%x to address %p\n", value, base);

  return 1;
}

static const struct file_operations fops = {
    .owner = THIS_MODULE,
    .write = led_write,
};

static struct miscdevice led_miscdev = {
    .minor = MISC_DYNAMIC_MINOR, // Use free number
    .name = "led",               // Device name
    .fops = &fops,               // File operations
    .mode = 0666,                // Read only
};

// static const struct of_device_id gpio_dt_match[] =

static int led_probe(struct platform_device *pdev) {
  struct device *dev = &pdev->dev;
  base = devm_platform_ioremap_resource(pdev, 0);

  if (IS_ERR(base)) {
    return PTR_ERR(base);
  }

  pr_info("Led: Driver probed, base address: %p\n", base);

  led_miscdev.parent = dev;

  int ret = misc_register(&led_miscdev);

  if (ret != 0) {
    pr_err("Error: misc_register failed: %d\n", ret);
  } else {
    pr_info("misc_register passed!\n");
  }

  return ret;
}

static const struct of_device_id led_dt_match[] = {
    {
        .compatible = "drec-fpga-intro,led-mmio",
    },
    {},
};
MODULE_DEVICE_TABLE(of, led_dt_match);

static struct platform_driver led_drv = {
    .probe = led_probe,
    .driver =
        {
            .name = "led",
            .of_match_table = led_dt_match,
        },
};

module_platform_driver(led_drv);

MODULE_LICENSE("GPL");
