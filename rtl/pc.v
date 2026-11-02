module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc_out
);

    always @(posedge clk) begin
        if (reset)
            pc_out <= 32'h00000000;
        else
            pc_out <= next_pc;
    end

endmodule
