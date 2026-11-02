`timescale 1ns / 1ps

module processing_element_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [7:0] A_in;
    reg signed [7:0] B_in;

    wire signed [7:0] A_out;
    wire signed [7:0] B_out;

    wire signed [31:0] ACC;

    processing_element DUT (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A_in(A_in),
        .B_in(B_in),
        .A_out(A_out),
        .B_out(B_out),
        .ACC(ACC)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        enable = 0;
        clear = 0;
        A_in = 0;
        B_in = 0;

        #10;
        reset = 0;

        // Test 1: 5 * 3 = 15
        enable = 1;
        A_in = 5;
        B_in = 3;
        #10;

        $display("Test 1: ACC = %0d, A_out = %0d, B_out = %0d",
                  ACC, A_out, B_out);

        // Test 2: 15 + (-4 * 2) = 7
        A_in = -4;
        B_in = 2;
        #10;

        $display("Test 2: ACC = %0d, A_out = %0d, B_out = %0d",
                  ACC, A_out, B_out);

        // Test 3: 7 + (-3 * -2) = 13
        A_in = -3;
        B_in = -2;
        #10;

        $display("Test 3: ACC = %0d, A_out = %0d, B_out = %0d",
                  ACC, A_out, B_out);

        // Test 4: Disable and check hold
        enable = 0;
        A_in = 10;
        B_in = 10;
        #10;

        $display("Test 4: ACC = %0d (Expected: 13)", ACC);

        // Test 5: Clear accumulator
        clear = 1;
        #10;

        $display("Test 5: ACC = %0d (Expected: 0)", ACC);

        clear = 0;

        #10;

        $display("PROCESSING ELEMENT TEST COMPLETED");

        $finish;

    end

endmodule