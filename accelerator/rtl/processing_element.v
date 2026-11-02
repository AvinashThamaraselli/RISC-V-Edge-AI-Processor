module processing_element (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire clear,

    input wire signed [7:0] A_in,
    input wire signed [7:0] B_in,

    output reg signed [7:0] A_out,
    output reg signed [7:0] B_out,

    output wire signed [31:0] ACC
);

    // Forwarding registers
    always @(posedge clk) begin

        if (reset) begin
            A_out <= 8'sd0;
            B_out <= 8'sd0;
        end

        else if (clear) begin
            A_out <= 8'sd0;
            B_out <= 8'sd0;
        end

        else if (enable) begin
            A_out <= A_in;
            B_out <= B_in;
        end

    end

    // MAC unit
    int8_mac MAC_UNIT (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .clear(clear),
        .A(A_in),
        .B(B_in),
        .ACC(ACC)
    );

endmodule