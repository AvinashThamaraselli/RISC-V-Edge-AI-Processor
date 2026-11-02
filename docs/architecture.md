# RV32I CPU Architecture

## 1. Scope

This document describes the Step 1 processor implementation in this repository: a 32-bit, single-cycle RV32I-style CPU written in Verilog-2001. The INT8 matrix-multiplication accelerator is a separate project extension and is documented in `accelerator/README.md`.

The processor is intended for functional simulation in Xilinx Vivado. The stated FPGA target is Xilinx Artix-7; actual hardware implementation and resource/timing results should be added only after synthesis and implementation on the target device.

## 2. Design parameters

| Parameter | Design choice |
|---|---|
| ISA subset | RV32I base integer instructions listed in the root README |
| Datapath width | 32 bits |
| Instruction width | 32 bits |
| Register file | 32 × 32-bit registers; x0 reads as zero |
| Organization | Single-cycle, non-pipelined |
| PC reset | Synchronous, active-high; reset address 0x00000000 |
| HDL | Verilog-2001 |
| Simulation tool | Xilinx Vivado / XSim |
| Intended FPGA family | Artix-7 |

## 3. Datapath overview

At a functional level, each instruction passes through these operations within one clock cycle:

1. The program counter (PC) supplies the current instruction address.
2. Instruction memory returns the 32-bit instruction.
3. The control unit decodes the opcode and generates control signals.
4. The register file supplies source operands `rs1` and `rs2`.
5. The immediate generator constructs and sign-extends the immediate for I-, S-, B-, U-, or J-type instructions.
6. The ALU performs arithmetic, logical, shift, comparison, or address-generation operations.
7. For loads, data memory supplies the value to write back. For stores, the data memory accepts the store data.
8. The write-back path selects the result written to `rd`.
9. The next-PC logic selects sequential execution, a branch target, or a jump target.

This is a conceptual datapath description. Consult the RTL port declarations and signal assignments for the exact implementation-level connectivity and mux coding.

## 4. RTL module responsibilities

| Module | Responsibility |
|---|---|
| `pc.v` | Holds the current instruction address and updates it on the active clock edge; supports synchronous reset |
| `instruction_memory.v` | Supplies instructions from the instruction memory array |
| `register_file.v` | Implements 32 general-purpose 32-bit registers and the architectural x0-zero behavior |
| `immediate_generator.v` | Extracts and sign-extends I/S/B/U/J immediates |
| `alu.v` | Performs 32-bit arithmetic, logical, shift, comparison, and pass-through operations |
| `alu_control.v` | Decodes instruction function fields for ALU operation selection |
| `branch_comparator.v` | Evaluates equality and signed/unsigned branch conditions |
| `control_unit.v` | Decodes instruction opcode and produces datapath control information |
| `data_memory.v` | Implements data-memory read and write behavior |
| `riscv_cpu.v` | Integrates the processor datapath and control path |

## 5. Instruction formats and supported operations

The implementation's documented supported operations are:

- R-type: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
- I-type ALU: `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`
- Loads/stores: `LW`, `SW`
- Conditional branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- Upper immediate: `LUI`, `AUIPC`
- Jumps: `JAL`, `JALR`

The root README identifies `FENCE`, `ECALL`, `EBREAK`, and byte/halfword loads and stores (`LB`, `LH`, `LBU`, `LHU`, `SB`, `SH`) as outside the current implemented subset. Do not describe the core as a fully compliant implementation of every RV32I instruction until those operations and the remaining architectural requirements are implemented and verified.

## 6. Control-flow behavior

- Sequential instruction flow advances to the next 4-byte instruction address.
- Conditional branches compare register operands and select a branch target when the decoded condition is true.
- `JAL` transfers control to a PC-relative target and writes a return address to the destination register.
- `JALR` transfers control using a register-based target as specified by the implementation.

The exact target calculation and alignment behavior should be checked against `riscv_cpu.v` and the immediate/branch logic.

## 7. Memory model

The documented design uses a combinational-read, synchronous-write data memory. The current instruction subset includes word load (`LW`) and word store (`SW`). Byte and halfword access support is listed as future work.

## 8. Verification approach

The repository includes:
- `tb/pc_tb.v` for independent PC testing.
- `tb/riscv_cpu_tb.v` for processor-level integration testing.

The integration program exercises arithmetic, a word store, a word load, a conditional branch, and a jump. The root README records expected register and memory values. Re-run the testbenches in the current repository revision before treating the results as a release sign-off.

## 9. Vivado simulation

1. Create or open a Vivado RTL project.
2. Add all processor RTL files from `rtl/` as design sources.
3. Add `tb/riscv_cpu_tb.v` as a simulation source.
4. Set `riscv_cpu_tb` as the simulation top.
5. Run **Run Behavioral Simulation**.
6. Inspect the Tcl Console and waveform for the self-checking test result.

For an independent PC test, set `pc_tb` as the simulation top and rerun behavioral simulation.

## 10. Future work

- Add and verify byte/halfword load-store operations.
- Expand directed and randomized instruction-level regression tests.
- Add exception/illegal-instruction behavior if required by the project specification.
- Run synthesis and implementation for the target Artix-7 part.
- Record LUT, FF, BRAM, DSP, clock-frequency, and timing results from actual Vivado reports.
- Integrate the INT8 accelerator with a defined CPU interface (for example, a memory-mapped register interface) only after the interface contract is finalized.
