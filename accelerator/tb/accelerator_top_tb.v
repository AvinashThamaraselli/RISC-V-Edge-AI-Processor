
`timescale 1ns / 1ps

module accelerator_top_tb;

    reg clk;
    reg reset;
    reg start;
    reg clear_request;

    reg signed [7:0] A00, A01, A10, A11;
    reg signed [7:0] B00, B01, B10, B11;

    wire busy;
    wire done;

    wire signed [31:0] C00, C01, C10, C11;

    integer errors;

    accelerator_top uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .clear_request(clear_request),

        .A00(A00), .A01(A01),
        .A10(A10), .A11(A11),

        .B00(B00), .B01(B01),
        .B10(B10), .B11(B11),

        .busy(busy),
        .done(done),

        .C00(C00), .C01(C01),
        .C10(C10), .C11(C11)
    );

    always #5 clk = ~clk;

    task run_test;
        input [8*40-1:0] test_name;
        input signed [31:0] exp00, exp01, exp10, exp11;
        begin
            @(negedge clk);
            start = 1;

            @(negedge clk);
            start = 0;

            wait(done == 1);
            #1;

            $display("--------------------------------");
            $display("%0s", test_name);

            $display("C00 = %0d Expected = %0d", C00, exp00);
            $display("C01 = %0d Expected = %0d", C01, exp01);
            $display("C10 = %0d Expected = %0d", C10, exp10);
            $display("C11 = %0d Expected = %0d", C11, exp11);

            if (C00 == exp00 && C01 == exp01 &&
                C10 == exp10 && C11 == exp11) begin
                $display("TEST PASSED");
            end
            else begin
                $display("TEST FAILED");
                errors = errors + 1;
            end

            $display("--------------------------------");

            // Wait until controller returns to IDLE
            wait(busy == 0);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        clear_request = 0;
        errors = 0;

        // TEST 1: Positive operands

        A00 = 1; A01 = 2;
        A10 = 3; A11 = 4;

        B00 = 5; B01 = 6;
        B10 = 7; B11 = 8;

        #20;
        reset = 0;

        run_test("TEST 1: POSITIVE OPERANDS",
                 19, 22, 43, 50);

        // TEST 2: Mixed positive and negative

        A00 = -1; A01 = 2;
        A10 = 3;  A11 = -4;

        B00 = 5;  B01 = -6;
        B10 = -7; B11 = 8;

        run_test("TEST 2: MIXED SIGN OPERANDS",
                 -19, 22, 43, -50);

        // TEST 3: Maximum positive INT8

        A00 = 127; A01 = 127;
        A10 = 127; A11 = 127;

        B00 = 127; B01 = 127;
        B10 = 127; B11 = 127;

        run_test("TEST 3: MAXIMUM POSITIVE INT8",
                 32258, 32258, 32258, 32258);

        // TEST 4: Minimum negative INT8

        A00 = -128; A01 = -128;
        A10 = -128; A11 = -128;

        B00 = 127; B01 = 127;
        B10 = 127; B11 = 127;

        run_test("TEST 4: MINIMUM NEGATIVE INT8",
                 -32512, -32512, -32512, -32512);

        // TEST 5: Minimum negative x minimum negative

        A00 = -128; A01 = -128;
        A10 = -128; A11 = -128;

        B00 = -128; B01 = -128;
        B10 = -128; B11 = -128;

        run_test("TEST 5: NEGATIVE BOUNDARY MULTIPLICATION",
                 32768, 32768, 32768, 32768);

        // FINAL SUMMARY

        if (errors == 0)
            $display("ALL 5 TESTS PASSED SUCCESSFULLY");
        else
            $display("SIMULATION FAILED: %0d TESTS FAILED", errors);

        #20;
        $finish;
    end

    initial begin
        #1000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
