# RISC-V Edge-AI Processor with INT8 Systolic Array Accelerator

### Design and FPGA Implementation of a RISC-V-Based Edge-AI Processor with a Custom INT8 Matrix Multiplication Accelerator

A Verilog HDL project focused on designing a 32-bit RISC-V processor and developing a custom INT8 matrix multiplication accelerator using a 2×2 systolic array architecture.

---

## 1. Project Overview

Edge-AI applications require efficient computation with limited hardware resources, power, and memory bandwidth. Matrix multiplication is a fundamental operation in machine learning workloads, making hardware acceleration an important approach to improving computational efficiency.

This project explores the design of a RISC-V-based computing architecture with a custom INT8 matrix multiplication accelerator.

The project is organized into two major development components:

- **Step 1 – RISC-V CPU:** Design and simulation of a 32-bit single-cycle RISC-V processor using Verilog HDL.
- **Step 2 – INT8 Accelerator:** Design and simulation of a custom 2×2 systolic-array-based matrix multiplication accelerator.

The CPU and accelerator are developed as separate hardware components. Their complete integration into a unified processor system is a future development objective.

## 2. Project Objectives

- Design a 32-bit RISC-V processor using Verilog HDL.
- Implement the major datapath and control components.
- Support a useful subset of RV32I instructions.
- Develop an INT8 multiply-accumulate unit.
- Design a 2×2 systolic array for matrix multiplication.
- Develop dedicated control and register modules for the accelerator.
- Verify individual modules using Verilog testbenches.
- Simulate the designs using Xilinx Vivado.

## 3. System Architecture

The project contains two independently developed hardware blocks.

### 3.1 RISC-V Processor Architecture

The processor follows a single-cycle, non-pipelined architecture.

**Major components:**

- Program Counter (PC)
- Instruction Memory
- Register File
- Immediate Generator
- Control Unit
- ALU Control
- Arithmetic Logic Unit (ALU)
- Branch Comparator
- Data Memory

**Processor datapath:**

```text
          +----------------+
          | Program Counter|
          +-------+--------+
                  |
                  v
          +----------------+
          |Instruction     |
          |Memory          |
          +-------+--------+
                  |
                  v
          +----------------+
          | Control Unit   |
          +----------------+
                  |
       +----------+-----------+
       |                      |
       v                      v
+--------------+      +------------------+
| Register File|      |Immediate Generator|
+------+-------+      +------------------+
       |                      |
       +----------+-----------+
                  |
                  v
          +----------------+
          | ALU Control    |
          +-------+--------+
                  |
                  v
          +----------------+
          |      ALU       |
          +-------+--------+
                  |
          +-------+--------+
          |                |
          v                v
   +------------+   +--------------+
   | Data Memory|   | Branch Logic |
   +------------+   +--------------+
          |
          v
   +----------------+
   | Write Back     |
   +----------------+
```

*Conceptual architecture diagram. Refer to the RTL modules for the implemented connections and signal details.*

### 3.2 Supported Instruction Set

The processor implements the following instruction groups:

| Instruction type | Supported instructions |
|---|---|
| R-type | ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND |
| I-type ALU | ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI |
| Load | LW |
| Store | SW |
| Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Upper immediate | LUI, AUIPC |
| Jump | JAL, JALR |

**Current limitations:** LB, LH, LBU, LHU, SB, SH, FENCE, ECALL, and EBREAK are not currently implemented.

### 3.3 Processor Design Specifications

| Parameter | Description |
|---|---|
| Architecture | RISC-V |
| Instruction subset | RV32I subset |
| Datapath width | 32-bit |
| Register count | 32 |
| Register width | 32-bit |
| Register x0 | Hardwired to zero |
| Execution model | Single-cycle |
| HDL | Verilog |
| Simulation | Xilinx Vivado |

---

## 4. INT8 Matrix Multiplication Accelerator

The second component is a custom INT8 matrix multiplication accelerator based on a 2×2 systolic array.

The accelerator is designed to perform matrix multiplication using signed 8-bit input operands and multiply-accumulate processing elements.

### 4.1 Systolic Array Concept

A systolic array is a hardware architecture in which processing elements perform computations and transfer intermediate data in a coordinated manner.

Each processing element performs multiply-accumulate operations.

The accelerator uses a 2×2 arrangement of processing elements.

### 4.2 Matrix Multiplication

For two 2×2 matrices:

A =

```text
| A00  A01 |
| A10  A11 |
```

B =

```text
| B00  B01 |
| B10  B11 |
```

The resulting matrix C is:

```text
C00 = A00 × B00 + A01 × B10

C01 = A00 × B01 + A01 × B11

C10 = A10 × B00 + A11 × B10

C11 = A10 × B01 + A11 × B11
```

### 4.3 Accelerator Architecture

The accelerator contains the following modules:

| Module | Function |
|---|---|
| `int8_mac.v` | INT8 multiply-accumulate operation |
| `processing_element.v` | Individual systolic processing element |
| `systolic_array_2x2.v` | 2×2 systolic array architecture |
| `accelerator_registers.v` | Accelerator data and control registers |
| `accelerator_controller.v` | Accelerator control logic |
| `accelerator_top.v` | Top-level accelerator module |

### 4.4 Accelerator Verification

Simulation results from the supplied Vivado log include:

| Test case | C00 | C01 | C10 | C11 | Status |
|---|---:|---:|---:|---:|---|
| Positive operands | 19 | 22 | 43 | 50 | PASS |
| Negative INT8 operands | -19 | 22 | 43 | -50 | PASS |

These results document the two test cases shown in the available simulation log. They do not, by themselves, establish exhaustive verification or FPGA hardware validation.

---

## 5. Repository Structure

```text
RISC-V-Edge-AI-Processor/
│
├── README.md
├── FIXES.md
│
├── rtl/
│   ├── alu.v
│   ├── alu_control.v
│   ├── branch_comparator.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── immediate_generator.v
│   ├── instruction_memory.v
│   ├── pc.v
│   ├── register_file.v
│   └── riscv_cpu.v
│
├── tb/
│   ├── pc_tb.v
│   └── riscv_cpu_tb.v
│
├── docs/
│   ├── architecture.md
│   └── control_signals.md
│
├── programs/
│   └── test_program.S
│
└── accelerator/
    ├── README.md
    │
    ├── rtl/
    │   ├── accelerator_controller.v
    │   ├── accelerator_registers.v
    │   ├── accelerator_top.v
    │   ├── int8_mac.v
    │   ├── processing_element.v
    │   └── systolic_array_2x2.v
    │
    └── tb/
        ├── accelerator_controller_tb.v
        ├── accelerator_registers_tb.v
        ├── accelerator_top_tb.v
        ├── int8_mac_tb.v
        ├── processing_element_tb.v
        └── systolic_array_2x2_tb.v
```

---

## 6. Tools and Technologies

| Tool / Technology | Purpose |
|---|---|
| Verilog HDL | Hardware description and RTL design |
| Xilinx Vivado | RTL simulation and FPGA design environment |
| Artix-7 FPGA | Intended FPGA target |
| Git | Version control |
| GitHub | Source code management and collaboration |

---

## 7. Simulation and Verification

The project uses Verilog testbenches to verify the processor and accelerator modules.

### 7.1 RISC-V Processor Simulation

1. Open Xilinx Vivado.
2. Create or open a Vivado project.
3. Add the Verilog files from the `rtl/` directory as design sources.
4. Add the testbenches from the `tb/` directory as simulation sources.
5. Set `riscv_cpu_tb` as the simulation top module.
6. Run Behavioral Simulation.
7. Examine the waveform and simulation output.

### 7.2 Accelerator Simulation

1. Add all Verilog files from `accelerator/rtl/` as design sources.
2. Add the testbenches from `accelerator/tb/` as simulation sources.
3. Select the desired testbench as the simulation top module.
4. Run Behavioral Simulation.
5. Inspect the waveforms and compare the outputs with expected matrix multiplication results.

**Note:** The assembly reference program in `programs/test_program.S` is documentation for a test sequence. It is not automatically assembled or loaded by Vivado. The actual instruction initialization and testbench setup determine what the CPU executes.

---

## 8. Documentation

Additional project documentation is available in the `docs/` directory.

- `architecture.md` – Processor architecture, datapath, and module descriptions.
- `control_signals.md` – Instruction control-signal reference.
- `programs/test_program.S` – Example assembly-style instruction sequence.
- `accelerator/README.md` – Accelerator architecture and verification details.
- `FIXES.md` – Development fixes and implementation notes.

---

## 9. Current Development Status

| Component | Status |
|---|---|
| RISC-V processor RTL | Developed |
| Processor module testbenches | Available |
| INT8 MAC unit | Developed |
| Processing element | Developed |
| 2×2 systolic array | Developed |
| Accelerator controller and registers | Developed |
| Accelerator top module | Developed |
| Accelerator simulation test cases | Positive and negative operand cases reported passing |
| Complete CPU–accelerator integration | Future work |
| FPGA synthesis and implementation results | To be documented after validation |

---

## 10. Future Enhancements

- Integrate the INT8 accelerator with the RISC-V processor.
- Implement memory-mapped I/O (MMIO) for accelerator control.
- Add custom RISC-V instructions for accelerator operations.
- Expand the systolic array to larger matrix dimensions.
- Develop a more comprehensive verification environment.
- Perform FPGA synthesis and implementation on an Artix-7 device.
- Analyze LUT, FF, DSP, BRAM utilization, timing, and power.
- Explore optimized hardware architectures for Edge-AI workloads.

---

## 11. Learning Outcomes

This project provides practical experience in:

- RISC-V processor architecture.
- RTL design using Verilog HDL.
- Datapath and control-unit design.
- Arithmetic and logic unit implementation.
- Hardware verification and simulation.
- INT8 fixed-point arithmetic.
- Multiply-accumulate architectures.
- Systolic array design.
- FPGA development workflows.

---

## 12. Acknowledgements

This project builds on concepts from RISC-V processor architecture, digital system design, RTL development, and hardware acceleration.

We acknowledge the guidance and technical support received during the development of this project.

---

## 13. License

This project is intended for educational and research purposes.

Add a license file to this repository if you intend to distribute the project under a specific open-source license.

---

**Project Focus:** RISC-V Architecture | Verilog HDL | RTL Design | INT8 Computing | Systolic Array | FPGA | Edge AI
