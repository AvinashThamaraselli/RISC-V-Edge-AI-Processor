# Final package notes

## What changed

- Preserved the 10 uploaded RTL source files byte-for-byte.
- Preserved `pc_tb.v`.
- Fixed `riscv_cpu_tb.v` for Verilog-2001 compatibility by moving `integer i;`
  out of the `initial begin ... end` block to module scope.
- Added `setup_vivado.tcl` to create a clean Vivado project with all RTL sources
  in `sources_1` and both testbenches in `sim_1`.

## Clean Vivado setup

1. Extract this folder to a permanent path, for example `C:/VLSI PROJECTS/RISCV_Edge_AI_Final`.
2. Open Vivado 2025.2.
3. Open the Tcl Console and change directory to the extracted folder, for example:
   `cd {C:/VLSI PROJECTS/RISCV_Edge_AI_Final}`
4. Run:
   `source setup_vivado.tcl`
5. The script creates a new project folder named `vivado_project` in this package folder.
6. In Sources → Simulation Sources, right-click `riscv_cpu_tb` → Set as Top.
7. Run Simulation → Run Behavioral Simulation.
8. To test the PC independently, right-click `pc_tb` → Set as Top, then rerun simulation.

Do not run the Tcl script from inside the old project's directory. This script creates a
separate project and does not overwrite your existing project.

## Scope / honesty

This is the uploaded RV32I single-cycle CPU, not the later INT8 systolic-array accelerator.
The RTL has not been run through Vivado in this environment, so the package is corrected
for the known compiler error but simulation pass status must be confirmed on your machine.
