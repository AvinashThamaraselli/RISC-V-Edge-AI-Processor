
module accelerator_registers (
    input wire clk,
    input wire reset,

    // CPU interface
    input wire [31:0] address,
    input wire mem_write,
    input wire [31:0] write_data,
    output reg [31:0] read_data,

    // Accelerator control
    output reg start,
    output reg clear,

    // Matrix A inputs
    output reg signed [7:0] A00,
    output reg signed [7:0] A01,
    output reg signed [7:0] A10,
    output reg signed [7:0] A11,

    // Matrix B inputs
    output reg signed [7:0] B00,
    output reg signed [7:0] B01,
    output reg signed [7:0] B10,
    output reg signed [7:0] B11,

    // Accelerator status
    input wire busy,
    input wire done,

    // Matrix result inputs
    input wire signed [31:0] C00,
    input wire signed [31:0] C01,
    input wire signed [31:0] C10,
    input wire signed [31:0] C11
);

    // MMIO address map
    localparam [31:0] A00_ADDR     = 32'h00001000;
    localparam [31:0] A01_ADDR     = 32'h00001004;
    localparam [31:0] A10_ADDR     = 32'h00001008;
    localparam [31:0] A11_ADDR     = 32'h0000100C;

    localparam [31:0] B00_ADDR     = 32'h00001010;
    localparam [31:0] B01_ADDR     = 32'h00001014;
    localparam [31:0] B10_ADDR     = 32'h00001018;
    localparam [31:0] B11_ADDR     = 32'h0000101C;

    localparam [31:0] CONTROL_ADDR = 32'h00001020;
    localparam [31:0] STATUS_ADDR  = 32'h00001024;

    localparam [31:0] C00_ADDR     = 32'h00001028;
    localparam [31:0] C01_ADDR     = 32'h0000102C;
    localparam [31:0] C10_ADDR     = 32'h00001030;
    localparam [31:0] C11_ADDR     = 32'h00001034;


    // Sequential write and control logic
    always @(posedge clk) begin

        if (reset) begin

            A00 <= 8'sd0;
            A01 <= 8'sd0;
            A10 <= 8'sd0;
            A11 <= 8'sd0;

            B00 <= 8'sd0;
            B01 <= 8'sd0;
            B10 <= 8'sd0;
            B11 <= 8'sd0;

            start <= 1'b0;
            clear <= 1'b0;

        end

        else begin

            // Default control pulses
            start <= 1'b0;
            clear <= 1'b0;

            if (mem_write) begin

                case (address)

                    A00_ADDR: A00 <= write_data[7:0];
                    A01_ADDR: A01 <= write_data[7:0];
                    A10_ADDR: A10 <= write_data[7:0];
                    A11_ADDR: A11 <= write_data[7:0];

                    B00_ADDR: B00 <= write_data[7:0];
                    B01_ADDR: B01 <= write_data[7:0];
                    B10_ADDR: B10 <= write_data[7:0];
                    B11_ADDR: B11 <= write_data[7:0];

                    CONTROL_ADDR: begin
                        start <= write_data[0];
                        clear <= write_data[1];
                    end

                    default: begin
                        // No register update
                    end

                endcase

            end

        end

    end


    // Combinational read logic
    always @(*) begin

        read_data = 32'b0;

        case (address)

            A00_ADDR: read_data = {{24{A00[7]}}, A00};
            A01_ADDR: read_data = {{24{A01[7]}}, A01};
            A10_ADDR: read_data = {{24{A10[7]}}, A10};
            A11_ADDR: read_data = {{24{A11[7]}}, A11};

            B00_ADDR: read_data = {{24{B00[7]}}, B00};
            B01_ADDR: read_data = {{24{B01[7]}}, B01};
            B10_ADDR: read_data = {{24{B10[7]}}, B10};
            B11_ADDR: read_data = {{24{B11[7]}}, B11};

            STATUS_ADDR: read_data = {30'b0, done, busy};

            C00_ADDR: read_data = C00;
            C01_ADDR: read_data = C01;
            C10_ADDR: read_data = C10;
            C11_ADDR: read_data = C11;

            default: read_data = 32'b0;

        endcase

    end

endmodule
