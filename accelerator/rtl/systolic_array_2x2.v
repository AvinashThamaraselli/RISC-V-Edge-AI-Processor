module systolic_array_2x2 (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire clear,

    input wire signed [7:0] A0_in,
    input wire signed [7:0] A1_in,

    input wire signed [7:0] B0_in,
    input wire signed [7:0] B1_in,

    output wire signed [31:0] C00,
    output wire signed [31:0] C01,
    output wire signed [31:0] C10,
    output wire signed [31:0] C11
);

    // Internal connections
    wire signed [7:0] A00_out;
    wire signed [7:0] B00_out;

    wire signed [7:0] A01_out;
    wire signed [7:0] B01_out;

    wire signed [7:0] A10_out;
    wire signed [7:0] B10_out;

    wire signed [7:0] A11_out;
    wire signed [7:0] B11_out;

    // Input delay registers
    reg signed [7:0] A1_delay;
    reg signed [7:0] B1_delay;

    always @(posedge clk) begin
        if (reset) begin
            A1_delay <= 8'sd0;
            B1_delay <= 8'sd0;
        end
        else if (clear) begin
            A1_delay <= 8'sd0;
            B1_delay <= 8'sd0;
        end
        else if (enable) begin
            A1_delay <= A1_in;
            B1_delay <= B1_in;
        end
    end

    // PE00
    processing_element PE00 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A_in(A0_in),
        .B_in(B0_in),
        .A_out(A00_out),
        .B_out(B00_out),
        .ACC(C00)
    );

    // PE01
    processing_element PE01 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A_in(A00_out),
        .B_in(B1_delay),
        .A_out(A01_out),
        .B_out(B01_out),
        .ACC(C01)
    );

    // PE10
    processing_element PE10 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A_in(A1_delay),
        .B_in(B00_out),
        .A_out(A10_out),
        .B_out(B10_out),
        .ACC(C10)
    );

    // PE11
    processing_element PE11 (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A_in(A10_out),
        .B_in(B01_out),
        .A_out(A11_out),
        .B_out(B11_out),
        .ACC(C11)
    );

endmodule