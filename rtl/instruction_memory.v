module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] mem [0:1023];

    // Combinational read — word addressed via address[11:2]
    assign instruction = mem[address[11:2]];

endmodule
