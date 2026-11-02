
`timescale 1ns / 1ps

module riscv_cpu_tb;

    reg clk   = 0;
    reg reset = 1;

    integer errors = 0;
    integer i;

    // ==========================================
    // CPU INSTANTIATION
    // ==========================================

    riscv_cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;


    // ==========================================
    // REGISTER CHECK TASK
    // ==========================================

    task check_reg;
        input [4:0] idx;
        input [31:0] expected;

        begin
            if (uut.RF.regs[idx] !== expected) begin

                $display("FAIL: x%0d = 0x%08h (Expected: 0x%08h)",
                         idx, uut.RF.regs[idx], expected);

                errors = errors + 1;

            end
            else begin

                $display("PASS: x%0d = 0x%08h",
                         idx, uut.RF.regs[idx]);

            end
        end
    endtask


    // ==========================================
    // DATA MEMORY CHECK TASK
    // ==========================================

    task check_mem;
        input [31:0] addr;
        input [31:0] expected;

        begin
            if (uut.DMEM.mem[addr[11:2]] !== expected) begin

                $display("FAIL: mem[%0d] = 0x%08h (Expected: 0x%08h)",
                         addr, uut.DMEM.mem[addr[11:2]], expected);

                errors = errors + 1;

            end
            else begin

                $display("PASS: mem[%0d] = 0x%08h",
                         addr, uut.DMEM.mem[addr[11:2]]);

            end
        end
    endtask


    // ==========================================
    // MAIN TEST
    // ==========================================

    initial begin

        // --------------------------------------
        // INITIALIZE MEMORIES
        // --------------------------------------

        for (i = 0; i < 1024; i = i + 1) begin

            uut.IMEM.mem[i] = 32'h00000000;
            uut.DMEM.mem[i] = 32'h00000000;

        end


        // ======================================
        // PART 1: ORIGINAL RV32I CPU TEST
        // ======================================

        uut.IMEM.mem[0] = 32'h00500093;  // ADDI x1,x0,5
        uut.IMEM.mem[1] = 32'h00300113;  // ADDI x2,x0,3
        uut.IMEM.mem[2] = 32'h002081B3;  // ADD  x3,x1,x2
        uut.IMEM.mem[3] = 32'h00302023;  // SW   x3,0(x0)
        uut.IMEM.mem[4] = 32'h00002203;  // LW   x4,0(x0)
        uut.IMEM.mem[5] = 32'h00418463;  // BEQ  x3,x4,+8
        uut.IMEM.mem[6] = 32'h06300293;  // ADDI x5,x0,99 (SKIPPED)
        uut.IMEM.mem[7] = 32'h008003EF;  // JAL  x7,+8
        uut.IMEM.mem[8] = 32'h04D00413;  // ADDI x8,x0,77 (SKIPPED)
        uut.IMEM.mem[9] = 32'h03700493;  // ADDI x9,x0,55


        // ======================================
        // PART 2: ACCELERATOR PROGRAM
        // ======================================

        // MMIO BASE ADDRESS = 0x1000

        uut.IMEM.mem[10] = 32'h00001537; // LUI x10,0x1


        // --------------------------------------
        // LOAD MATRIX A VALUES
        // --------------------------------------

        // Matrix A = [ 1  2 ]
        //            [ 3  4 ]

        uut.IMEM.mem[11] = 32'h00100813; // ADDI x16,x0,1
        uut.IMEM.mem[12] = 32'h00200893; // ADDI x17,x0,2
        uut.IMEM.mem[13] = 32'h00300913; // ADDI x18,x0,3
        uut.IMEM.mem[14] = 32'h00400993; // ADDI x19,x0,4


        // --------------------------------------
        // LOAD MATRIX B VALUES
        // --------------------------------------

        // Matrix B = [ 5  6 ]
        //            [ 7  8 ]

        uut.IMEM.mem[15] = 32'h00500A13; // ADDI x20,x0,5
        uut.IMEM.mem[16] = 32'h00600A93; // ADDI x21,x0,6
        uut.IMEM.mem[17] = 32'h00700B13; // ADDI x22,x0,7
        uut.IMEM.mem[18] = 32'h00800B93; // ADDI x23,x0,8


        // --------------------------------------
        // WRITE MATRIX A TO MMIO
        // --------------------------------------

        uut.IMEM.mem[19] = 32'h01052023; // SW x16,0(x10)  A00
        uut.IMEM.mem[20] = 32'h01152223; // SW x17,4(x10)  A01
        uut.IMEM.mem[21] = 32'h01252423; // SW x18,8(x10)  A10
        uut.IMEM.mem[22] = 32'h01352623; // SW x19,12(x10) A11


        // --------------------------------------
        // WRITE MATRIX B TO MMIO
        // --------------------------------------

        uut.IMEM.mem[23] = 32'h01452823; // SW x20,16(x10) B00
        uut.IMEM.mem[24] = 32'h01552A23; // SW x21,20(x10) B01
        uut.IMEM.mem[25] = 32'h01652C23; // SW x22,24(x10) B10
        uut.IMEM.mem[26] = 32'h01752E23; // SW x23,28(x10) B11


        // --------------------------------------
        // START ACCELERATOR
        // CONTROL ADDRESS = 0x1020
        // --------------------------------------

        uut.IMEM.mem[27] = 32'h00100793; // ADDI x15,x0,1
        uut.IMEM.mem[28] = 32'h02F52023; // SW x15,32(x10)


        // --------------------------------------
        // WAIT FOR ACCELERATOR
        // --------------------------------------

        uut.IMEM.mem[29] = 32'h00000013; // NOP
        uut.IMEM.mem[30] = 32'h00000013; // NOP
        uut.IMEM.mem[31] = 32'h00000013; // NOP
        uut.IMEM.mem[32] = 32'h00000013; // NOP
        uut.IMEM.mem[33] = 32'h00000013; // NOP
        uut.IMEM.mem[34] = 32'h00000013; // NOP
        uut.IMEM.mem[35] = 32'h00000013; // NOP
        uut.IMEM.mem[36] = 32'h00000013; // NOP


        // --------------------------------------
        // READ MATRIX RESULTS
        // --------------------------------------

        uut.IMEM.mem[37] = 32'h02852583; // LW x11,40(x10) C00
        uut.IMEM.mem[38] = 32'h02C52603; // LW x12,44(x10) C01
        uut.IMEM.mem[39] = 32'h03052683; // LW x13,48(x10) C10
        uut.IMEM.mem[40] = 32'h03452703; // LW x14,52(x10) C11


        // ======================================
        // PART 3: RESET CPU
        // ======================================

        reset = 1;

        repeat (2) @(posedge clk);

        #1 reset = 0;


        // ======================================
        // PART 4: RUN CPU PROGRAM
        // ======================================

        repeat (60) @(posedge clk);

        #1;


        // ======================================
        // PART 5: CHECK ORIGINAL CPU RESULTS
        // ======================================

        $display("\n");
        $display("======================================");
        $display("       RV32I CPU TEST RESULTS");
        $display("======================================");

        check_reg(5'd1,  32'd5);
        check_reg(5'd2,  32'd3);
        check_reg(5'd3,  32'd8);
        check_reg(5'd4,  32'd8);
        check_reg(5'd5,  32'd0);
        check_reg(5'd7,  32'h00000020);
        check_reg(5'd8,  32'd0);
        check_reg(5'd9,  32'd55);

        check_mem(32'd0, 32'd8);


        // ======================================
        // PART 6: CHECK ACCELERATOR RESULTS
        // ======================================

        $display("\n");
        $display("======================================");
        $display("     INT8 ACCELERATOR TEST RESULTS");
        $display("======================================");

        $display("Expected Matrix:");

        $display("[ 19  22 ]");
        $display("[ 43  50 ]");

        $display("\nActual Accelerator Results:");

        $display("C00 = %0d", $signed(uut.C00));
        $display("C01 = %0d", $signed(uut.C01));
        $display("C10 = %0d", $signed(uut.C10));
        $display("C11 = %0d", $signed(uut.C11));


        // --------------------------------------
        // CHECK CPU DESTINATION REGISTERS
        // --------------------------------------

        check_reg(5'd11, 32'd19);
        check_reg(5'd12, 32'd22);
        check_reg(5'd13, 32'd43);
        check_reg(5'd14, 32'd50);


        // --------------------------------------
        // CHECK ACCELERATOR DONE SIGNAL
        // --------------------------------------

        if (uut.accel_done !== 1'b1) begin

            $display("FAIL: Accelerator DONE signal is LOW");

            errors = errors + 1;

        end
        else begin

            $display("PASS: Accelerator DONE signal is HIGH");

        end


        // ======================================
        // FINAL RESULT
        // ======================================

        $display("\n");
        $display("======================================");

        if (errors == 0) begin

            $display("ALL TESTS PASSED SUCCESSFULLY");

        end
        else begin

            $display("TEST FAILED: %0d ERROR(S)", errors);

        end

        $display("======================================");

        $finish;

    end

endmodule
