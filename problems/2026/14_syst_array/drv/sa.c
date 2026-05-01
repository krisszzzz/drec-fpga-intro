
#include <linux/delay.h>
#include <linux/dma-mapping.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/of_irq.h>
#include <linux/platform_device.h>

static struct sa_dev_state {
  void __iomem *reg_base;
  struct completion op_done;
} g_sa;

// Обработчик прерывания
static irqreturn_t sa_irq_handler(int irq, void *dev_id) {
  complete(&g_sa.op_done);

  return IRQ_HANDLED;
}

static int sa_dev_probe(struct platform_device *pdev) {
  struct device *dev = &pdev->dev;
  int ret;
  int irq;

  g_sa.reg_base = devm_platform_ioremap_resource(pdev, 0);
  if (IS_ERR(g_sa.reg_base)) {
    return PTR_ERR(g_sa.reg_base);
  }

  dev_info(dev, "MMIO at %px\n", g_sa.reg_base);

  init_completion(&g_sa.op_done);

  irq = platform_get_irq(pdev, 0);

  if (irq < 0)
    return irq;

  ret = devm_request_irq(dev, irq, sa_irq_handler, 0, dev_name(dev), NULL);
  if (ret)
    return dev_err_probe(dev, ret, "failed to request IRQ\n");

  ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
  if (ret)
    dev_err_probe(dev, ret, "failed to set DMA mask\n");

  dma_addr_t src_phys, dst_phys;
  uint16_t *src_base =
      dmam_alloc_coherent(dev, PAGE_SIZE, &src_phys, GFP_KERNEL);
  uint16_t *dst_base =
      dmam_alloc_coherent(dev, PAGE_SIZE, &dst_phys, GFP_KERNEL);

  dev_info(dev, "Src. buf at %px (%x)\n", src_base, src_phys);
  dev_info(dev, "Dst. buf at %px (%x)\n", dst_base, dst_phys);

  if (!src_base || !dst_base)
    return -ENOMEM;

  for (int i = 0; i < (PAGE_SIZE / sizeof(uint16_t)); i++)
    writew_relaxed(9, &dst_base[i]);
  wmb();

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      uint16_t num = readw_relaxed(&dst_base[i]);
      dev_info(dev, "%u\t", num);
    }
    dev_info(dev, "\n");
  }

  for (int i = 0; i < (PAGE_SIZE / sizeof(uint16_t)); i++)
    writew_relaxed(9, &src_base[i]);
  wmb();

  const int start_offset = 0x0;
  const int is_b_offset = 0x4;
  const int ab_addr_offset = 0x8;
  const int c_addr_offset = 0xC;

  // Load B
  dev_info(dev, "Starting Load B...\n");
  reinit_completion(&g_sa.op_done);
  iowrite32(src_phys, g_sa.reg_base + ab_addr_offset);
  iowrite32(dst_phys, g_sa.reg_base + c_addr_offset);

  iowrite32(0x1, g_sa.reg_base + is_b_offset);
  // initiate sa after setting all adresses
  // start is write-to-trigger register (self-cleaning)
  iowrite32(0x1, g_sa.reg_base + start_offset);

  // wait for load complete
  if (!wait_for_completion_timeout(&g_sa.op_done, HZ)) {
    dev_err(dev, "Load B timeout!\n");
    return -ETIMEDOUT;
  }

  // Load A + compute C
  dev_info(dev, "Starting Computation...\n");
  iowrite32(0x0, g_sa.reg_base + is_b_offset);
  iowrite32(0x1, g_sa.reg_base + start_offset);

  if (!wait_for_completion_timeout(&g_sa.op_done, HZ)) {
    dev_err(dev, "Computation timeout!\n");
    return -ETIMEDOUT;
  }

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      uint16_t num = readw_relaxed(&dst_base[i]);
      dev_info(dev, "%u\t", num);
    }
    dev_info(dev, "\n");
  }

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      uint16_t num = readw_relaxed(&src_base[i]);
      dev_info(dev, "%u\t", num);
    }
    dev_info(dev, "\n");
  }

  return 0;
}

static const struct of_device_id sa_dev_dt_match[] = {
    {
        .compatible = "drec-fpga-intro,sa-dev",
    },
    {},
};
MODULE_DEVICE_TABLE(of, sa_dev_dt_match);

static struct platform_driver sa_dev_drv = {
    .probe = sa_dev_probe,
    .driver =
        {
            .name = KBUILD_MODNAME,
            .of_match_table = sa_dev_dt_match,
        },
};

module_platform_driver(sa_dev_drv);

MODULE_LICENSE("GPL");
