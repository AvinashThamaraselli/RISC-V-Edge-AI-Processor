# RV32I smoke-test program
#
# This is a human-readable assembly reference for the instruction sequence
# exercised by the CPU integration testbench. The testbench may load equivalent
# machine-code words directly; this file is not assembled automatically by
# Vivado.
#
# Expected final state (assuming execution begins at address 0):
#   x1 = 5
#   x2 = 3
#   x3 = 8
#   memory word at address 0 = 8
#   x4 = 8
#   x5 = 0   (the instruction writing 99 is skipped)
#   x7 = 0x20 (JAL return address)
#   x8 = 0   (the instruction writing 77 is skipped)
#   x9 = 55

    .text
    .globl _start

_start:
    addi x1, x0, 5       # x1 = 5
    addi x2, x0, 3       # x2 = 3
    add  x3, x1, x2      # x3 = 8
    sw   x3, 0(x0)       # memory[0] = 8
    lw   x4, 0(x0)       # x4 = 8
    beq  x3, x4, branch_target
    addi x5, x0, 99      # skipped when branch is taken

branch_target:
    jal  x7, jump_target
    addi x8, x0, 77      # skipped by JAL

jump_target:
    addi x9, x0, 55      # x9 = 55

# Note:
# This source is supplied as a readable reference. It has not been assembled
# here, and the exact machine-code initialization used by the testbench remains
# authoritative for simulation.
