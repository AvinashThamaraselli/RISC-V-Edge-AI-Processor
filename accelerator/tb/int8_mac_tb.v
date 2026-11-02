
`timescale 1ns / 1ps

module int8_mac_tb;

    reg clk;
    reg reset;
    reg enable;
    reg clear;

    reg signed [7:0] A;
    reg signed [7:0] B;

    wire signed [31:0] ACC;

    int8_mac uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A(A),
        .B(B),
        .ACC(ACC)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initial values
        reset = 1;
        enable = 0;
        clear = 0;
        A = 0;
        B = 0;

        // Apply reset
        #10;
        reset = 0;

        // Test 1: 5 * 3 = 15
        @(negedge clk);
        enable = 1;
        A = 5;
        B = 3;

        @(posedge clk);
        #1;
        $display("Test 1: ACC = %0d (Expected: 15)", ACC);

        // Test 2: 15 + (-4 * 2) = 7
        @(negedge clk);
        A = -4;
        B = 2;

        @(posedge clk);
        #1;
        $display("Test 2: ACC = %0d (Expected: 7)", ACC);

        // Test 3: 7 + (-3 * -2) = 13
        @(negedge clk);
        A = -3;
        B = -2;

        @(posedge clk);
        #1;
        $display("Test 3: ACC = %0d (Expected: 13)", ACC);

        // Test 4: Disable MAC
        @(negedge clk);
        enable = 0;
        A = 100;
        B = 100;

        @(posedge clk);
        #1;
        $display("Test 4: ACC = %0d (Expected: 13)", ACC);

        // Test 5: Clear accumulator
        @(negedge clk);
        clear = 1;

        @(posedge clk);
        #1;
        $display("Test 5: ACC = %0d (Expected: 0)", ACC);

        @(negedge clk);
        clear = 0;

        $display("INT8 MAC TEST COMPLETED");

        $finish;

    end

endmodule
