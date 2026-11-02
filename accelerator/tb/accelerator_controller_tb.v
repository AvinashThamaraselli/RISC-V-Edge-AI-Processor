`timescale 1ns / 1ps

module accelerator_controller_tb;

    reg clk;
    reg reset;
    reg start;
    reg clear_request;

    reg signed [7:0] A00, A01, A10, A11;
    reg signed [7:0] B00, B01, B10, B11;

    wire array_enable;
    wire array_clear;

    wire signed [7:0] A0_in, A1_in;
    wire signed [7:0] B0_in, B1_in;

    wire busy;
    wire done;

    accelerator_controller uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .clear_request(clear_request),

        .A00(A00), .A01(A01),
        .A10(A10), .A11(A11),

        .B00(B00), .B01(B01),
        .B10(B10), .B11(B11),

        .array_enable(array_enable),
        .array_clear(array_clear),

        .A0_in(A0_in),
        .A1_in(A1_in),
        .B0_in(B0_in),
        .B1_in(B1_in),

        .busy(busy),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial
    begin
        // Initial values
        clk = 0;
        reset = 1;
        start = 0;
        clear_request = 0;

        // Matrix A
        A00 = 1;
        A01 = 2;
        A10 = 3;
        A11 = 4;

        // Matrix B
        B00 = 5;
        B01 = 6;
        B10 = 7;
        B11 = 8;

        // Apply reset
        #20;
        reset = 0;

        // Start accelerator
        #10;
        start = 1;

        #10;
        start = 0;

        // Wait for operation to finish
        #100;

        $finish;
    end
endmodule