
`timescale 1ns / 1ps

module accelerator_registers_tb;

    reg clk;
    reg reset;

    // CPU interface
    reg [31:0] address;
    reg mem_write;
    reg [31:0] write_data;
    wire [31:0] read_data;

    // Accelerator control
    wire start;
    wire clear;

    // Matrix operands
    wire signed [7:0] A00;
    wire signed [7:0] A01;
    wire signed [7:0] A10;
    wire signed [7:0] A11;

    wire signed [7:0] B00;
    wire signed [7:0] B01;
    wire signed [7:0] B10;
    wire signed [7:0] B11;

    // Status inputs
    reg busy;
    reg done;

    // Result inputs
    reg signed [31:0] C00;
    reg signed [31:0] C01;
    reg signed [31:0] C10;
    reg signed [31:0] C11;

    integer errors;


    // DUT
    accelerator_registers DUT (

        .clk(clk),
        .reset(reset),

        .address(address),
        .mem_write(mem_write),
        .write_data(write_data),
        .read_data(read_data),

        .start(start),
        .clear(clear),

        .A00(A00),
        .A01(A01),
        .A10(A10),
        .A11(A11),

        .B00(B00),
        .B01(B01),
        .B10(B10),
        .B11(B11),

        .busy(busy),
        .done(done),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );


    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // CPU write task
    task write_register;
        input [31:0] addr;
        input [31:0] data;

        begin
            @(negedge clk);

            address = addr;
            write_data = data;
            mem_write = 1'b1;

            @(posedge clk);
            #1;

            mem_write = 1'b0;
        end
    endtask


    // CPU read task
    task read_register;
        input [31:0] addr;

        begin
            address = addr;
            #1;
        end
    endtask


    // Main test sequence
    initial begin

        errors = 0;

        reset = 1'b1;
        address = 32'b0;
        mem_write = 1'b0;
        write_data = 32'b0;

        busy = 1'b0;
        done = 1'b0;

        C00 = 32'sd19;
        C01 = 32'sd22;
        C10 = 32'sd43;
        C11 = 32'sd50;

        #12;
        reset = 1'b0;

        // --------------------------------
        // TEST 1: WRITE MATRIX A
        // --------------------------------

        write_register(32'h1000, 32'hFFFFFFFB); // -5
        write_register(32'h1004, 32'd2);
        write_register(32'h1008, 32'd3);
        write_register(32'h100C, 32'hFFFFFFFC); // -4

        // --------------------------------
        // TEST 2: WRITE MATRIX B
        // --------------------------------

        write_register(32'h1010, 32'd6);
        write_register(32'h1014, 32'hFFFFFFF9); // -7
        write_register(32'h1018, 32'd8);
        write_register(32'h101C, 32'd9);

        // --------------------------------
        // TEST 3: VERIFY OPERANDS
        // --------------------------------

        $display("--------------------------------");
        $display("TEST 3: OPERAND REGISTER CHECK");
        $display("--------------------------------");

        if (A00 !== -8'sd5 ||
            A01 !==  8'sd2 ||
            A10 !==  8'sd3 ||
            A11 !== -8'sd4) begin

            $display("FAIL: Matrix A operands incorrect");
            errors = errors + 1;

        end
        else begin
            $display("PASS: Matrix A operands stored correctly");
        end

        if (B00 !==  8'sd6 ||
            B01 !== -8'sd7 ||
            B10 !==  8'sd8 ||
            B11 !==  8'sd9) begin

            $display("FAIL: Matrix B operands incorrect");
            errors = errors + 1;

        end
        else begin
            $display("PASS: Matrix B operands stored correctly");
        end


        // --------------------------------
        // TEST 4: SIGN EXTENSION READ
        // --------------------------------

        read_register(32'h1000);

        if (read_data !== 32'hFFFFFFFB) begin
            $display("FAIL: A00 signed read incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: A00 signed read = %0d", $signed(read_data));
        end


        // --------------------------------
        // TEST 5: START CONTROL
        // --------------------------------

        write_register(32'h1020, 32'd1);

        if (start !== 1'b1) begin
            $display("FAIL: START pulse not generated");
            errors = errors + 1;
        end
        else begin
            $display("PASS: START pulse generated");
        end

        @(posedge clk);
        #1;

        if (start !== 1'b0) begin
            $display("FAIL: START pulse did not return low");
            errors = errors + 1;
        end
        else begin
            $display("PASS: START pulse returned low");
        end


        // --------------------------------
        // TEST 6: CLEAR CONTROL
        // --------------------------------

        write_register(32'h1020, 32'd2);

        if (clear !== 1'b1) begin
            $display("FAIL: CLEAR pulse not generated");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CLEAR pulse generated");
        end

        @(posedge clk);
        #1;

        if (clear !== 1'b0) begin
            $display("FAIL: CLEAR pulse did not return low");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CLEAR pulse returned low");
        end


        // --------------------------------
        // TEST 7: STATUS REGISTER
        // --------------------------------

        busy = 1'b1;
        done = 1'b0;

        read_register(32'h1024);

        if (read_data !== 32'h00000001) begin
            $display("FAIL: BUSY status incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: BUSY status correct");
        end

        busy = 1'b0;
        done = 1'b1;

        read_register(32'h1024);

        if (read_data !== 32'h00000002) begin
            $display("FAIL: DONE status incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: DONE status correct");
        end


        // --------------------------------
        // TEST 8: RESULT REGISTER READ
        // --------------------------------

        $display("--------------------------------");
        $display("TEST 8: RESULT REGISTER CHECK");
        $display("--------------------------------");

        read_register(32'h1028);

        if (read_data !== 32'd19) begin
            $display("FAIL: C00 incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: C00 = %0d", read_data);
        end


        read_register(32'h102C);

        if (read_data !== 32'd22) begin
            $display("FAIL: C01 incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: C01 = %0d", read_data);
        end


        read_register(32'h1030);

        if (read_data !== 32'd43) begin
            $display("FAIL: C10 incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: C10 = %0d", read_data);
        end


        read_register(32'h1034);

        if (read_data !== 32'd50) begin
            $display("FAIL: C11 incorrect");
            errors = errors + 1;
        end
        else begin
            $display("PASS: C11 = %0d", read_data);
        end


        // --------------------------------
        // FINAL RESULT
        // --------------------------------

        $display("--------------------------------");

        if (errors == 0) begin
            $display("ALL ACCELERATOR REGISTER TESTS PASSED");
        end
        else begin
            $display("TEST FAILED: %0d ERRORS", errors);
        end

        $display("--------------------------------");

        #10;
        $finish;

    end

endmodule
