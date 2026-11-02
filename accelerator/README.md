# INT8 Matrix-Multiplication Accelerator

## 1. Role in the project

This directory documents the accelerator extension associated with the RISC-V Edge-AI Processor project. The accelerator is a separate hardware block from the Step 1 RV32I CPU. Do not imply that the accelerator is already integrated into the CPU unless the top-level CPU RTL explicitly instantiates it and provides a verified interface.

The available simulation log identifies these design modules:

- `int8_mac`
- `processing_element`
- `systolic_array_2x2`
- `accelerator_registers`
- `accelerator_controller`
- `accelerator_top`

The simulation testbench is named `accelerator_top_tb`.

## 2. Functional concept

The accelerator computes a small matrix multiplication using signed 8-bit operands. For two 2×2 matrices:

\[
C = A \times B
\]

each output element is a sum of two signed 8-bit products:

\[
C_{ij} = \sum_{k=0}^{1} A_{ik} B_{kj}
\]

Each multiplication is an INT8 operation. The accumulated result requires a wider signed datapath than 8 bits; the exact accumulator width and overflow behavior must be confirmed from the RTL.

A systolic-array organization moves operand data between processing elements (PEs), allowing multiply-accumulate work to occur locally. The precise operand-stationary/weight-stationary schedule and cycle latency should be documented from the actual PE and array RTL.

## 3. Module map

| Module | Documented role inferred from module name |
|---|---|
| `int8_mac` | Signed INT8 multiply-accumulate primitive |
| `processing_element` | PE containing local arithmetic and/or data forwarding |
| `systolic_array_2x2` | 2×2 arrangement of processing elements |
| `accelerator_registers` | Operand, control, or result register bank |
| `accelerator_controller` | Sequencing/control logic for the accelerator |
| `accelerator_top` | Accelerator integration top level |
| `accelerator_top_tb` | Simulation testbench |

This table is a high-level module map. Confirm exact ports, register map, control protocol, and dataflow against the Verilog source before publishing an interface specification.

## 4. Recorded simulation evidence

A supplied Vivado 2025.2 XSim log for `accelerator_top_tb` records two test cases:

### Test 1 — Positive INT8 operands

| Output | Observed | Expected |
|---|---:|---:|
| C00 | 19 | 19 |
| C01 | 22 | 22 |
| C10 | 43 | 43 |
| C11 | 50 | 50 |

The log reports `TEST 1 PASSED`.

### Test 2 — Negative INT8 operands

| Output | Observed | Expected |
|---|---:|---:|
| C00 | -19 | -19 |
| C01 | 22 | 22 |
| C10 | 43 | 43 |
| C11 | -50 | -50 |

The log reports `TEST 2 PASSED`.

These are results copied from the supplied simulation log. Re-run the current checked-in RTL and testbench to confirm that the repository revision produces the same results.

## 5. Running the accelerator test in Vivado

1. Open the Vivado project containing the accelerator source files.
2. Ensure the accelerator RTL modules listed above are included as design sources.
3. Add `accelerator_top_tb.v` as a simulation source.
4. Set `accelerator_top_tb` as the simulation top.
5. Run **Run Behavioral Simulation**.
6. Check the Tcl Console for the positive-operand and negative-operand test results.
7. Save useful waveforms or screenshots under a project verification/evidence folder if desired.

The exact file paths may differ depending on how the project was organized in Vivado.

## 6. Current integration status

The available CPU README describes the accelerator as a later project step, not as part of the Step 1 CPU RTL. A Vivado log shows the accelerator modules compiling in a project context, but that alone does not prove that the accelerator is connected to the CPU instruction path or that a custom RISC-V instruction is implemented.

Before claiming CPU–accelerator integration, document and verify:
- CPU-to-accelerator command interface.
- Operand and result register map or streaming interface.
- Start, busy, done, and error signaling.
- Memory-mapped I/O address map, if used.
- Custom instruction encoding, if used.
- Synchronization and software-visible completion behavior.
- End-to-end CPU program that launches a matrix multiplication and checks the result.

## 7. Recommended next verification

- Add directed tests for zero, maximum positive, minimum negative, mixed-sign and overflow-boundary operands.
- Verify signed multiplication and accumulator sizing.
- Verify reset behavior and back-to-back transactions.
- Verify controller sequencing and result-valid timing.
- Run synthesis and implementation on the target FPGA and record LUT, FF, DSP, BRAM, and timing reports.
- Add an integration test only after the CPU/accelerator interface is implemented.
