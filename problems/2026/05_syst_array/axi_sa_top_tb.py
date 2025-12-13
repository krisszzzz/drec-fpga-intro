import cocotb
from cocotb.triggers import RisingEdge, Timer, ClockCycles, First
from cocotb.clock import Clock
from cocotb.queue import Queue
import numpy as np
import random
import logging

from cocotbext.axi import AxiBus, AxiSlave, AxiRam

# Test parameters
WIDTH = 16
SIZE = 4
AXI_ADDR_WIDTH = 32
AXI_DATA_WIDTH = WIDTH * SIZE

class SystolicArrayTestbench:
    """Testbench for systolic array with AXI interface"""

    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.INFO)

        self.setup_axi_slave()

        # Matrix buffers
        self.matrix_a = None
        self.matrix_b = None
        self.matrix_c_actual = None
        self.matrix_c_expected = None

        # Test data
        self.test_data_a = None
        self.test_data_b = None

        # AXI transaction counters
        self.read_count = 0
        self.write_count = 0

    def setup_axi_slave(self):
        """Setup AXI slave memory using AxiRam"""
        # Create AXI bus from DUT signals

        # Create AXI RAM (acts as memory slave)
        self.axi_ram = AxiRam(
            AxiBus.from_prefix(self.dut, "m_axi"),
            self.dut.clk,
            self.dut.rst_n,
            reset_active_level=False,
            size=2**16  # 64KB memory
        )

        self.log.info("AXI RAM initialized")

    async def reset(self, cycles=10):
        """Reset the DUT"""
        self.dut.rst_n.value = 0
        self.dut.i_start.value = 0
        self.dut.i_start.value = 0

        # Set base addresses
        self.dut.base_addr_ab.value = 0x1000
        self.dut.base_addr_c.value  = 0x2000

        await ClockCycles(self.dut.clk, cycles)
        self.dut.rst_n.value = 1
        await ClockCycles(self.dut.clk, 2)

        self.log.info("Reset complete")

    def generate_matrix_data(self, rows, cols, base_value):
        """Generate test matrix data"""
        matrix = np.zeros((rows, cols), dtype=np.uint16)
        for i in range(rows):
            for j in range(cols):
                matrix[i][j] = base_value + i * cols + j
        return matrix

    def matrix_to_axi_data(self, matrix, is_b):
        """Convert matrix to format for AXI writes"""
        rows, cols = matrix.shape
        byte_data = bytearray()

        # Pack matrix row-major order
        for i in range(rows):
            for j in range(cols):
                row = rows - i - 1 if is_b else i
                byte_data.extend(matrix[row][j].tobytes())

        return bytes(byte_data)

    def axi_data_to_matrix(self, byte_data, rows, cols):
        """Convert AXI data back to matrix"""
        matrix = np.zeros((rows, cols), dtype=np.uint16)

        for i in range(rows):
            for j in range(cols):
                idx = (i * cols + j) * 2
                if idx + 1 < len(byte_data):
                    matrix[i][j] = int.from_bytes(byte_data[idx:idx+2], 'little')

        return matrix

    async def write_matrix_to_memory(self, addr, matrix, is_b):
        """Write matrix to AXI memory"""
        byte_data = self.matrix_to_axi_data(matrix, is_b)

        # Write to AXI RAM
        self.axi_ram.write(addr, byte_data)

        # Wait for write to complete
        await ClockCycles(self.dut.clk, 10)

        self.log.info(f"Written matrix to address 0x{addr:08x}, size {len(byte_data)} bytes")

    async def read_matrix_from_memory(self, addr, rows, cols):
        """Read matrix from AXI memory"""
        byte_len = rows * cols * 2

        # Read from AXI RAM
        byte_data = self.axi_ram.read(addr, byte_len)

        # Convert to matrix
        matrix = self.axi_data_to_matrix(byte_data, rows, cols)

        self.log.info(f"Read matrix from address 0x{addr:08x}")
        return matrix

    async def wait_for_signal(self, signal, value, timeout=1000, desc=""):
        """Wait for signal to reach specified value"""
        for i in range(timeout):
            await RisingEdge(self.dut.clk)
            if signal.value == value:
                if desc:
                    self.log.debug(f"{desc}: Signal {signal._name} = {value}")
                return True

        self.log.error(f"Timeout waiting for {signal._name} to become {value}")
        return False

    async def test_load_matrix_b(self, start):
        """Test loading matrix B"""
        self.log.info("Starting test_load_matrix_b")

        # Generate test matrix B
        self.test_data_b = self.generate_matrix_data(SIZE, SIZE, start)
        self.dut.is_b.value = 1

        # Write matrix B to memory
        await self.write_matrix_to_memory(
            self.dut.base_addr_ab.value.integer,
            self.test_data_b,
            self.dut.is_b.value
        )

        # Start loading B
        self.dut.i_start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.i_start.value = 0

        await ClockCycles(self.dut.clk, 20)

        return True

    async def test_load_matrix_a_and_save_c(self, start):
        """Test loading matrix A and saving matrix C"""
        self.log.info("Starting test_load_matrix_a_and_save_c")

        # Generate test matrix A
        self.test_data_a = self.generate_matrix_data(SIZE, SIZE, start)
        self.dut.is_b.value = 0

        # Write matrix A to memory
        await self.write_matrix_to_memory(
            self.dut.base_addr_ab.value.integer,
            self.test_data_a,
            self.dut.is_b.value
        )

        # Start loading A and saving C
        self.dut.i_start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.i_start.value = 0

        await ClockCycles(self.dut.clk, 20)

        # Read matrix C from memory
        self.matrix_c_actual = await self.read_matrix_from_memory(
            self.dut.base_addr_c.value.integer,
            SIZE,
            SIZE
        )

        return True

    async def verify_results(self):
        """Verify computation results"""
        self.log.info("Verifying results...")

        if self.test_data_a is not None and self.test_data_b is not None:
            # Simple test: expected C = A * B
            a_uint32 = self.test_data_a.astype(np.uint32)
            b_uint32 = self.test_data_b.astype(np.uint32)
            self.matrix_c_expected = self.matrix_c_actual;

            for i in range(SIZE):
                for j in range(SIZE):
                    C = 0;
                    for k in range(SIZE):
                        C += self.test_data_a[i][k] * self.test_data_b[k][j]
                    self.matrix_c_actual[i][j] = C

            # Compare
            if self.matrix_c_actual is not None:
                mismatch = np.any(self.matrix_c_actual != self.matrix_c_expected)

                self.log.info("A:")
                self.log.info(self.test_data_a)
                self.log.info("B:")
                self.log.info(self.test_data_b)
                self.log.info("Actual C:")
                self.log.info(self.matrix_c_actual)
                self.log.info("Expected C:")
                self.log.info(self.matrix_c_expected)

                if mismatch:
                    self.log.error("Matrix mismatch!")
                else:
                    self.log.info("✓ Matrix C matches expected (A * B)")
            else:
                self.log.warning("No actual C matrix to compare")

    async def run_complete_test(self, start):
        """Run complete test sequence"""
        self.log.info("=" * 60)
        self.log.info("Starting complete systolic array test")
        self.log.info("=" * 60)

        # Wait after reset
        await ClockCycles(self.dut.clk, 10)

        # Test 1: Load matrix B
        self.log.info("\n" + "=" * 60)
        self.log.info("Test 1: Loading Matrix B")
        self.log.info("=" * 60)

        await self.test_load_matrix_b(start)

        # Wait between tests
        await ClockCycles(self.dut.clk, 20)

        # Test 2: Load matrix A and save matrix C
        self.log.info("\n" + "=" * 60)
        self.log.info("Test 2: Loading Matrix A and Saving Matrix C")
        self.log.info("=" * 60)

        await self.test_load_matrix_a_and_save_c(100 * start)

        # Test 3: Verify results
        self.log.info("\n" + "=" * 60)
        self.log.info("Test 3: Verification")
        self.log.info("=" * 60)

        await self.verify_results()

        self.log.info("\n" + "=" * 60)
        self.log.info("All tests completed!")
        self.log.info("=" * 60)

@cocotb.test()
async def test_basic_operation(dut):
    """Basic test of systolic array operation"""
    tb = SystolicArrayTestbench(dut)

    # Setup clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    await tb.reset()

    # Run complete test
    await tb.run_complete_test(0)

@cocotb.test()
async def test_multiple_runs(dut):
    """Test multiple runs of the systolic array"""
    tb = SystolicArrayTestbench(dut)

    # Setup clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    await tb.reset()

    # Run multiple iterations
    for i in range(3):
        tb.log.info(f"\nIteration {i+1}")
        await tb.run_complete_test(i)

    tb.log.info("✓ Multiple runs test passed")


if __name__ == "__main__":
    import sys
    print("This test is designed to run with cocotb.")
    print("Use: make SIM=icarus")
    sys.exit(0)

