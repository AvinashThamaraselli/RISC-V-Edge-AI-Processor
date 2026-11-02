
module int8_mac (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire clear,

    input wire signed [7:0] A,
    input wire signed [7:0] B,

    output reg signed [31:0] ACC
);

    wire signed [15:0] product;

    assign product = A * B;

    always @(posedge clk) begin

        if (reset) begin
            ACC <= 32'sd0;
        end

        else if (clear) begin
            ACC <= 32'sd0;
        end

        else if (enable) begin
            ACC <= ACC + {{16{product[15]}}, product};
        end

    end

endmodule
