# RV32I Control-Signal Reference

## Purpose

This file is a conceptual instruction-to-control reference for the single-cycle RV32I processor. Signal names and encodings can differ between RTL implementations. **Use the actual declarations and case statements in `control_unit.v`, `alu_control.v`, and `riscv_cpu.v` as the authoritative source.** This document intentionally avoids inventing numeric encodings for project-specific control buses.

## Instruction behavior matrix

| Instruction class | Register read | ALU purpose | Data memory | Register write | Next PC |
|---|---|---|---|---|---|
| R-type ALU | rs1, rs2 | Operation selected by funct3/funct7 | No access | rd receives ALU result | PC + 4 |
| I-type ALU | rs1 | Operation selected by funct3/funct7 | No access | rd receives ALU result | PC + 4 |
| `LW` | rs1 | Effective address = rs1 + sign-extended offset | Read word | rd receives memory data | PC + 4 |
| `SW` | rs1, rs2 | Effective address = rs1 + sign-extended offset | Write word | No | PC + 4 |
| Conditional branch | rs1, rs2 | Compare operands / evaluate condition | No access | No | Branch target if condition true, otherwise PC + 4 |
| `LUI` | Not required for source arithmetic | Immediate pass/formation | No access | rd receives upper immediate result | PC + 4 |
| `AUIPC` | PC is an input to address/immediate calculation | PC + upper immediate | No access | rd receives result | PC + 4 |
| `JAL` | Not required for target calculation | PC-relative target formation | No access | rd receives return address | PC-relative target |
| `JALR` | rs1 | Register-relative target formation | No access | rd receives return address | Register-relative target |

## Branch conditions

| Instruction | Condition |
|---|---|
| `BEQ` | rs1 == rs2 |
| `BNE` | rs1 != rs2 |
| `BLT` | signed(rs1) < signed(rs2) |
| `BGE` | signed(rs1) >= signed(rs2) |
| `BLTU` | unsigned(rs1) < unsigned(rs2) |
| `BGEU` | unsigned(rs1) >= unsigned(rs2) |

## ALU operation families

The documented ALU operation set includes:
- Addition and subtraction
- Left and right logical shifts
- Arithmetic right shift
- Signed and unsigned set-less-than comparisons
- Bitwise AND, OR, XOR
- Operand-B pass-through where required by the datapath

## Verification checklist

For each instruction, verify at minimum:
1. Correct opcode and function-field decode.
2. Correct source-register selection.
3. Correct immediate format and sign extension, where applicable.
4. Correct ALU operation and operand selection.
5. Correct memory enable and address for loads/stores.
6. Correct destination register and write-back source.
7. Correct sequential or control-transfer PC behavior.
8. x0 remains zero regardless of attempted writes.

## Implementation note

This is a behavioral reference, not a replacement for the RTL. Before using it as a formal design specification, compare each row with the current control-unit truth table and update the table to match the exact signal names and values in the source.
