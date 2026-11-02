`timescale 1ns / 1ps

module systolic_array_2x2_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [7:0] A0_in;
    reg signed [7:0] A1_in;
    reg signed [7:0] B0_in;
    reg signed [7:0] B1_in;

    wire signed [31:0] C00;
    wire signed [31:0] C01;
    wire signed [31:0] C10;
    wire signed [31:0] C11;

    systolic_array_2x2 DUT (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A0_in(A0_in),
        .A1_in(A1_in),
        .B0_in(B0_in),
        .B1_in(B1_in),
        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        enable = 0;
        clear = 0;

        A0_in = 0;
        A1_in = 0;
        B0_in = 0;
        B1_in = 0;

        // Reset
        repeat (2) @(negedge clk);
        reset = 0;

        // Clear accumulators and delay registers
        clear = 1;
        @(negedge clk);
        clear = 0;

        enable = 1;

        // First matrix multiplication inputs
        A0_in = 1;
        A1_in = 3;
        B0_in = 5;
        B1_in = 6;

        @(negedge clk);

        // Second matrix multiplication inputs
        A0_in = 2;
        A1_in = 4;
        B0_in = 7;
        B1_in = 8;

        @(negedge clk);

        // Stop sending new inputs
        A0_in = 0;
        A1_in = 0;
        B0_in = 0;
        B1_in = 0;

        // Allow pipeline data to propagate
        repeat (4) @(negedge clk);

        $display("--------------------------------");
        $display("2x2 SYSTOLIC ARRAY RESULTS");
        $display("--------------------------------");

        $display("C00 = %0d (Expected: 19)", C00);
        $display("C01 = %0d (Expected: 22)", C01);
        $display("C10 = %0d (Expected: 43)", C10);
        $display("C11 = %0d (Expected: 50)", C11);

        if (C00 == 19 && C01 == 22 &&
            C10 == 43 && C11 == 50)
            $display("SYSTOLIC ARRAY TEST PASSED");
        else
            $display("SYSTOLIC ARRAY TEST FAILED");

        $finish;

    end

endmodule