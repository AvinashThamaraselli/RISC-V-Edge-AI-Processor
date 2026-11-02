module data_memory (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    reg [31:0] mem [0:1023];

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000000;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write)
            mem[address[11:2]] <= write_data;
    end

    // Combinational read
    always @(*) begin
        if (mem_read)
            read_data = mem[address[11:2]];
        else
            read_data = 32'h00000000;
    end

endmodule
