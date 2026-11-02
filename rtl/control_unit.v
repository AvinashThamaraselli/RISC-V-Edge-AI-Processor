module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg  [1:0]  result_src,   // 00=ALU  01=MEM  10=PC+4
    output reg         alu_src_a,    // 0=rs1   1=PC
    output reg         alu_src_b,    // 0=rs2   1=imm
    output reg         branch,
    output reg  [1:0]  jump,         // 00=none 01=JAL 10=JALR
    output reg  [3:0]  alu_op
);

    // opcode encodings
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_OPIMM  = 7'b0010011;
    localparam OP_OP     = 7'b0110011;

    // ALU op encodings (must match alu.v / alu_control.v)
    localparam ALU_ADD   = 4'b0000;
    localparam ALU_SUB   = 4'b0001;
    localparam ALU_AND   = 4'b0010;
    localparam ALU_OR    = 4'b0011;
    localparam ALU_XOR   = 4'b0100;
    localparam ALU_SLL   = 4'b0101;
    localparam ALU_SRL   = 4'b0110;
    localparam ALU_SRA   = 4'b0111;
    localparam ALU_SLT   = 4'b1000;
    localparam ALU_SLTU  = 4'b1001;
    localparam ALU_B     = 4'b1010;
    localparam ALU_RTYPE = 4'b1011;

    always @(*) begin
        // Defaults — safe / NOP
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        result_src = 2'b00;
        alu_src_a  = 1'b0;
        alu_src_b  = 1'b0;
        branch     = 1'b0;
        jump       = 2'b00;
        alu_op     = ALU_ADD;

        case (opcode)

            OP_LUI: begin
                reg_write  = 1'b1;
                alu_src_b  = 1'b1;
                alu_op     = ALU_B;        // pass immediate through
            end

            OP_AUIPC: begin
                reg_write  = 1'b1;
                alu_src_a  = 1'b1;         // PC
                alu_src_b  = 1'b1;         // imm
                alu_op     = ALU_ADD;      // PC + imm
            end

            OP_JAL: begin
                reg_write  = 1'b1;
                result_src = 2'b10;        // write PC+4
                alu_src_a  = 1'b1;
                alu_src_b  = 1'b1;
                jump       = 2'b01;
                alu_op     = ALU_ADD;      // PC + imm = target
            end

            OP_JALR: begin
                reg_write  = 1'b1;
                result_src = 2'b10;        // write PC+4
                alu_src_b  = 1'b1;         // rs1 + imm
                jump       = 2'b10;
                alu_op     = ALU_ADD;
            end

            OP_BRANCH: begin
                branch     = 1'b1;
                alu_op     = ALU_SUB;      // not used for compare, but safe
            end

            OP_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                result_src = 2'b01;        // write memory data
                alu_src_b  = 1'b1;         // rs1 + imm
                alu_op     = ALU_ADD;
            end

            OP_STORE: begin
                mem_write  = 1'b1;
                alu_src_b  = 1'b1;         // rs1 + imm
                alu_op     = ALU_ADD;
            end

            OP_OPIMM: begin
                reg_write  = 1'b1;
                alu_src_b  = 1'b1;         // immediate
                case (funct3)
                    3'b000: alu_op = ALU_ADD;                                    // ADDI
                    3'b001: alu_op = ALU_SLL;                                    // SLLI
                    3'b010: alu_op = ALU_SLT;                                    // SLTI
                    3'b011: alu_op = ALU_SLTU;                                   // SLTIU
                    3'b100: alu_op = ALU_XOR;                                    // XORI
                    3'b101: alu_op = funct7[5] ? ALU_SRA : ALU_SRL;             // SRAI / SRLI
                    3'b110: alu_op = ALU_OR;                                     // ORI
                    3'b111: alu_op = ALU_AND;                                    // ANDI
                    default: alu_op = ALU_ADD;
                endcase
            end

            OP_OP: begin
                reg_write  = 1'b1;
                alu_op     = ALU_RTYPE;   // alu_control decodes funct3/funct7
            end

            default: begin
                // unrecognised — keep defaults (acts as NOP)
            end

        endcase
    end

endmodule
