import logging
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink
from random import getrandbits, randint

DATA_WIDTH = 32
NR_ITERS = 16
FIFO_DEPTH = 8

class TB:
    def __init__(self, dut):
        self.dut = dut

        logging.getLogger("cocotb.fifo.s_axis").setLevel(logging.INFO)
        logging.getLogger("cocotb.fifo.m_axis").setLevel(logging.INFO)

        self.source = AxiStreamSource(
            AxiStreamBus.from_prefix(dut, "s_axis"),
            dut.clk,
            dut.rst_n,
            reset_active_level=False
        )

        self.sink = AxiStreamSink(
            AxiStreamBus.from_prefix(dut, "m_axis"),
            dut.clk,
            dut.rst_n,
            reset_active_level=False
        )

        self.clock = Clock(dut.clk, 1, units="ns")
        cocotb.start_soon(self.clock.start())

    async def reset(self):
        self.dut.rst_n.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst_n.value = 1
        await RisingEdge(self.dut.clk)
        self.dut._log.info("Reset complete")


def gen_rand_bit():
    while True:
        yield getrandbits(1)


@cocotb.test()
async def test_fifo_full(dut):
    tb = TB(dut)
    await tb.reset()

    # Disable slave
    tb.sink.pause = True
    await RisingEdge(dut.clk)

    # Send data
    for i in range(FIFO_DEPTH):
        data = i
        await tb.source.send(data.to_bytes(DATA_WIDTH // 8, 'little'))
        await tb.source.wait()
        dut._log.info(f"Filling FIFO: sent data[{i}]: 0x{data:08X}")


    # FIFO should be full
    await RisingEdge(dut.clk)
    assert dut.s_axis_tready.value == 0, f"FIFO should be full (TREADY=0), but TREADY={dut.s_axis_tready.value}"
    dut._log.info("FIFO correctly indicates full state (TREADY=0)")
    dut._log.info("FIFO FULL test passed")


@cocotb.test()
async def test_fifo_empty(dut):
    tb = TB(dut)
    await tb.reset()

    # FIFO should be empty
    assert dut.m_axis_tvalid.value == 0, f"FIFO should be empty (TVALID=0), but TVALID={dut.s_axis_tready.value}"
    dut._log.info("FIFO correctly indicates empty state (TVALID=0)")
    dut._log.info("FIFO EMPTY test passed")


@cocotb.test()
async def test_fifo_stress(dut):
    tb = TB(dut)
    tb.source.set_pause_generator(gen_rand_bit())
    tb.sink.set_pause_generator(gen_rand_bit())
    await tb.reset()

    test_data = []
    for i in range(NR_ITERS):
        data = i
        test_data.append(data)
        await tb.source.send(data.to_bytes(DATA_WIDTH // 8, 'little'))
        dut._log.info(f"Filling FIFO: sent data[{i}]: 0x{data:08X}")

    for i in range(NR_ITERS):
        rx_frame = await tb.sink.recv()
        rx_data = rx_frame.tdata
        received = int.from_bytes(rx_data, 'little')
        expected = test_data[i]
        dut._log.info(f"Reading FIFO: received data[{i}]: 0x{received:08X}, expected: 0x{expected:08X}")
        assert received == expected, f"Data mismatch at position {i}: expected 0x{expected:08X}, received 0x{received:08X}"

    assert tb.source.empty()
    assert tb.sink.empty()
    dut._log.info("FIFO STRESS test passed")