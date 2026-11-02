module riscv_cpu (
    input wire clk,
    input wire reset,

    output wire accel_busy,
    output wire accel_done,

    output wire signed [31:0] C00,
    output wire signed [31:0] C01,
    output wire signed [31:0] C10,
    output wire signed [31:0] C11
);

    // ---- PC ----
    wire [31:0] pc_out;
    wire [31:0] next_pc;
    wire [31:0] pc_plus4;

    // ---- Instruction ----
    wire [31:0] instruction;

    // ---- Decode ----
    wire [31:0] imm_out;
    wire [31:0] read_data1, read_data2;

    // ---- Control ----
    wire        reg_write, mem_read, mem_write;
    wire [1:0]  result_src;
    wire        alu_src_a, alu_src_b;
    wire        branch;
    wire [1:0]  jump;
    wire [3:0]  alu_op;

    // ---- ALU ----
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [3:0]  alu_control_out;

    // ---- Branch ----
    wire branch_taken;

    // ---- Memory ----
    wire [31:0] mem_read_data;
    wire [31:0] dmem_read_data;
    wire [31:0] accel_read_data;

    // ---- MMIO decoder ----
    wire is_mmio;
    wire dmem_read;
    wire dmem_write;
    wire accel_write;

    assign is_mmio =
        (alu_result >= 32'h00001000) &&
        (alu_result <= 32'h00001034);

    assign dmem_read  = mem_read  && !is_mmio;
    assign dmem_write = mem_write && !is_mmio;
    assign accel_write = mem_write && is_mmio;

    // ---- Accelerator register connections ----
    wire accel_start;
    wire accel_clear;

    wire signed [7:0] A00, A01, A10, A11;
    wire signed [7:0] B00, B01, B10, B11;

    // ---- Writeback ----
    wire [31:0] writeback_data;

    // ---- Next-PC targets ----
    wire [31:0] branch_target;
    wire [31:0] jalr_target;

    assign pc_plus4 = pc_out + 32'd4;
    assign branch_target = pc_out + imm_out;
    assign jalr_target = alu_result & 32'hFFFFFFFE;

    assign next_pc = (jump == 2'b10) ? jalr_target :
                     (jump == 2'b01) ? branch_target :
                     (branch && branch_taken) ? branch_target :
                     pc_plus4;

    // ---- ALU input muxes ----
    assign alu_a = alu_src_a ? pc_out : read_data1;
    assign alu_b = alu_src_b ? imm_out : read_data2;

    // ---- Memory read-data selection ----
    assign mem_read_data = is_mmio ? accel_read_data :
                                       dmem_read_data;

    // ---- Writeback mux ----
    assign writeback_data = (result_src == 2'b00) ? alu_result :
                            (result_src == 2'b01) ? mem_read_data :
                                                    pc_plus4;

    // ===================== CPU MODULES =====================

    pc PC (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    instruction_memory IMEM (
        .address(pc_out),
        .instruction(instruction)
    );

    register_file RF (
        .clk(clk),
        .reset(reset),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(writeback_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    immediate_generator IMM_GEN (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    control_unit CTRL (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .result_src(result_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op)
    );

    alu_control ALU_CTRL (
        .alu_op(alu_op),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .alu_control_out(alu_control_out)
    );

    alu ALU (
        .a(alu_a),
        .b(alu_b),
        .alu_control(alu_control_out),
        .result(alu_result),
        .zero(alu_zero)
    );

    branch_comparator BRANCH_CMP (
        .rs1_data(read_data1),
        .rs2_data(read_data2),
        .funct3(instruction[14:12]),
        .branch_taken(branch_taken)
    );

    // ===================== DATA MEMORY =====================

    // Keep the instance name DMEM unchanged.
    data_memory DMEM (
        .clk(clk),
        .mem_read(dmem_read),
        .mem_write(dmem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(dmem_read_data)
    );

    // ===================== ACCELERATOR REGISTERS =====================

    accelerator_registers ACCEL_REGS (
        .clk(clk),
        .reset(reset),

        .address(alu_result),
        .mem_write(accel_write),
        .write_data(read_data2),
        .read_data(accel_read_data),

        .start(accel_start),
        .clear(accel_clear),

        .A00(A00),
        .A01(A01),
        .A10(A10),
        .A11(A11),

        .B00(B00),
        .B01(B01),
        .B10(B10),
        .B11(B11),

        .busy(accel_busy),
        .done(accel_done),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    // ===================== ACCELERATOR TOP =====================

    accelerator_top ACCEL (
        .clk(clk),
        .reset(reset),

        .start(accel_start),
        .clear_request(accel_clear),

        .A00(A00),
        .A01(A01),
        .A10(A10),
        .A11(A11),

        .B00(B00),
        .B01(B01),
        .B10(B10),
        .B11(B11),

        .busy(accel_busy),
        .done(accel_done),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

endmodule
