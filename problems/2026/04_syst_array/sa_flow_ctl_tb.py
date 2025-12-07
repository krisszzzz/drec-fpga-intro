import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray, Range

async def reset_dut(dut):
    dut.rst_n.value = 0
    await Timer(10, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

def pack_words(words, width):
    value = 0
    for word in words:
        value = (value << width) | (word & ((1 << width) - 1))
    return value


@cocotb.test()
async def test_sa_flow_ctl(dut):
    WIDTH = 16
    SIZE = 4

    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    await reset_dut(dut)

    def drive_input(vld, is_b, data, rdy):
        dut.i_vld.value = int(vld)
        dut.is_b.value = int(is_b)
        dut.i_ab.value = pack_words(data, WIDTH)
        dut.i_ready.value = int(rdy)

    # -------------------------------------------
    # Idle (valid = 0, ready = 1)
    # -------------------------------------------
    drive_input(vld=0, is_b=0, data=[0], rdy=1)
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)
    assert dut.o_vld.value == 0, "o_vld should be low during idle"
    cocotb.log.info("Idle test passed")

    # -------------------------------------------
    # Backpressure (valid = 1, ready = 0)
    # -------------------------------------------
    test_data = [(i + 1) for i in range(SIZE)]
    drive_input(vld=1, is_b=0, data=test_data, rdy=0)
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)
    assert dut.o_vld.value == 1, "o_vld should be asserted under backpressure (after some clocks)"
    cocotb.log.info("Backpressure test passed")

    # -------------------------------------------
    # Normal transfer (watch waves)
    # -------------------------------------------

    # wait to flush the values
    drive_input(vld=0, is_b=0, data=[0], rdy=1)
    for _ in range(10 * SIZE):
        await RisingEdge(dut.clk)

    # start the transfer B matrix
    drive_input(vld=1, is_b=1, data=test_data, rdy=0)
    for _ in range(SIZE):
        await RisingEdge(dut.clk)

    drive_input(vld=1, is_b=0, data=test_data, rdy=1)
    while (dut.o_vld.value != 1):
        await RisingEdge(dut.clk)

    for _ in range(SIZE):
        await RisingEdge(dut.clk)

    cocotb.log.info("Normal transfer test passed")