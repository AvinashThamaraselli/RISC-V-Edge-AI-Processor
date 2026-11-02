
module accelerator_top (
    input wire clk,
    input wire reset,

    input wire start,
    input wire clear_request,

    input wire signed [7:0] A00,
    input wire signed [7:0] A01,
    input wire signed [7:0] A10,
    input wire signed [7:0] A11,

    input wire signed [7:0] B00,
    input wire signed [7:0] B01,
    input wire signed [7:0] B10,
    input wire signed [7:0] B11,

    output wire busy,
    output wire done,

    output wire signed [31:0] C00,
    output wire signed [31:0] C01,
    output wire signed [31:0] C10,
    output wire signed [31:0] C11
);

    // Controller-to-array connections
    wire array_enable;
    wire array_clear;

    wire signed [7:0] A0_in;
    wire signed [7:0] A1_in;
    wire signed [7:0] B0_in;
    wire signed [7:0] B1_in;

    // Accelerator Controller
    accelerator_controller CTRL (
        .clk(clk),
        .reset(reset),

        .start(start),
        .clear_request(clear_request),

        .A00(A00),
        .A01(A01),
        .A10(A10),
        .A11(A11),

        .B00(B00),
        .B01(B01),
        .B10(B10),
        .B11(B11),

        .array_enable(array_enable),
        .array_clear(array_clear),

        .A0_in(A0_in),
        .A1_in(A1_in),
        .B0_in(B0_in),
        .B1_in(B1_in),

        .busy(busy),
        .done(done)
    );

    // 2x2 Systolic Array
    systolic_array_2x2 ARRAY (
        .clk(clk),
        .reset(reset),
        .enable(array_enable),
        .clear(array_clear),

        .A0_in(A0_in),
        .A1_in(A1_in),
        .B0_in(B0_in),
        .B1_in(B1_in),

        .C00(C00),
        .C01(C01),
        .C10(C10),
        .C11(C11)
    );

endmodule
