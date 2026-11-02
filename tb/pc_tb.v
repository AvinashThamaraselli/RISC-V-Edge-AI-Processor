`timescale 1ns / 1ps

module pc_tb;

    reg         clk = 0;
    reg         reset;
    reg  [31:0] next_pc;
    wire [31:0] pc_out;

    pc uut (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),
        .pc_out  (pc_out)
    );

    always #5 clk = ~clk;

    initial begin
        // --- Reset test ---
        reset   = 1;
        next_pc = 32'h00000000;
        @(posedge clk);
        #1;
        if (pc_out !== 32'h00000000) $fatal(1, "FAIL: PC reset");

        // --- Sequential increments ---
        reset = 0;

        next_pc = 32'h00000004;
        @(posedge clk); #1;
        if (pc_out !== 32'h00000004) $fatal(1, "FAIL: PC = 4");

        next_pc = 32'h00000008;
        @(posedge clk); #1;
        if (pc_out !== 32'h00000008) $fatal(1, "FAIL: PC = 8");

        // --- Branch / jump target ---
        next_pc = 32'h00000020;
        @(posedge clk); #1;
        if (pc_out !== 32'h00000020) $fatal(1, "FAIL: PC target");

        // --- Synchronous reset again ---
        reset = 1;
        @(posedge clk); #1;
        if (pc_out !== 32'h00000000) $fatal(1, "FAIL: re-reset");

        $display("PASS: All PC tests passed.");
        $finish;
    end

endmodule
