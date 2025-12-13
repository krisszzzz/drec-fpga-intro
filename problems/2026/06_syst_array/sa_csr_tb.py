import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiLiteMaster, AxiLiteBus
import random

class TB:
    def __init__(self, dut):
        self.dut = dut

        self.axil = AxiLiteMaster(
            AxiLiteBus.from_prefix(dut, "s_axil"),
            dut.clk,
            dut.rst_n,
            reset_active_level=False
        )

        self.clk = Clock(dut.clk, 1, units="ns")
        cocotb.start_soon(self.clk.start())

    async def reset(self):
        self.dut.rst_n.value = 0
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)


REG_ADDR_A = 0x00
REG_ADDR_B = 0x04
REG_ADDR_C = 0x08


@cocotb.test(timeout_time=10, timeout_unit="us")
async def test_csr_matrix_addresses(dut):
    tb = TB(dut)
    await tb.reset()

    # Write A
    addr_a_val = 0xDEADBEEF
    resp_a = await tb.axil.write(REG_ADDR_A, addr_a_val.to_bytes(4, 'little'))
    assert resp_a.resp == 0, f"Expected OKAY (0), got {resp_a.resp}"
    await RisingEdge(dut.clk)
    assert dut.o_addr_A.value == addr_a_val, f"reg_addr_A mismatch: {dut.reg_addr_A.value} != {addr_a_val}"
    dut._log.info(f"Write to A (0x{REG_ADDR_A:02x}): {addr_a_val:#x}")

    # Write B
    addr_b_val = 0x12345678
    resp_b = await tb.axil.write(REG_ADDR_B, addr_b_val.to_bytes(4, 'little'))
    assert resp_b.resp == 0, f"Expected OKAY (0), got {resp_b.resp}"
    await RisingEdge(dut.clk)
    assert dut.o_addr_B.value == addr_b_val, f"reg_addr_B mismatch: {dut.reg_addr_B.value} != {addr_b_val}"
    dut._log.info(f"Write to B (0x{REG_ADDR_B:02x}): {addr_b_val:#x}")

    # Write C
    addr_c_val = 0xF00DF00D
    resp_c = await tb.axil.write(REG_ADDR_C, addr_c_val.to_bytes(4, 'little'))
    assert resp_c.resp == 0, f"Expected OKAY (0), got {resp_c.resp}"
    await RisingEdge(dut.clk)
    assert dut.o_addr_C.value == addr_c_val, f"reg_addr_C mismatch: {dut.reg_addr_C.value} != {addr_c_val}"
    dut._log.info(f"Write to C (0x{REG_ADDR_C:02x}): {addr_c_val:#x}")

    # Incorrect address
    bad_addr = 0x10
    resp_bad = await tb.axil.write(bad_addr, (0x11111111).to_bytes(4, 'little'))
    assert resp_bad.resp == 2, f"Expected SLVERR (2), got {resp_bad.resp}"
    dut._log.info(f"Write to invalid address (0x{bad_addr:02x}) returned SLVERR")

    # Test values not changed
    assert dut.o_addr_A.value == addr_a_val
    assert dut.o_addr_B.value == addr_b_val
    assert dut.o_addr_C.value == addr_c_val
    dut._log.info("All registers retained their values")

    dut._log.info("All tests passed!")