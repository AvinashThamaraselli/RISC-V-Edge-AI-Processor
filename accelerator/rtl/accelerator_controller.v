
module accelerator_controller (
    input clk,
    input reset,

    input start,
    input clear_request,

    input signed [7:0] A00,
    input signed [7:0] A01,
    input signed [7:0] A10,
    input signed [7:0] A11,

    input signed [7:0] B00,
    input signed [7:0] B01,
    input signed [7:0] B10,
    input signed [7:0] B11,

    output reg array_enable,
    output reg array_clear,

    output reg signed [7:0] A0_in,
    output reg signed [7:0] A1_in,
    output reg signed [7:0] B0_in,
    output reg signed [7:0] B1_in,

    output busy,
    output reg done
);

    // FSM state declarations
    parameter IDLE  = 2'b00;
    parameter CLEAR = 2'b01;
    parameter FEED  = 2'b10;
    parameter DRAIN = 2'b11;

    reg [1:0] state;
    reg [1:0] cycle_count;
    reg operation_pending;

    // Busy signal
    assign busy = (state != IDLE);

    // State and counter logic
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            state <= IDLE;
            cycle_count <= 0;
            operation_pending <= 0;
            done <= 0;
        end
        else
        begin
            case (state)

                IDLE:
                begin
                    cycle_count <= 0;

                    if (start)
                    begin
                        state <= CLEAR;
                        operation_pending <= 1;
                        done <= 0;
                    end
                    else if (clear_request)
                    begin
                        state <= CLEAR;
                        operation_pending <= 0;
                        done <= 0;
                    end
                end

                CLEAR:
                begin
                    cycle_count <= 0;

                    if (operation_pending)
                        state <= FEED;
                    else
                        state <= IDLE;

                    operation_pending <= 0;
                end

                FEED:
                begin
                    if (cycle_count == 1)
                    begin
                        cycle_count <= 0;
                        state <= DRAIN;
                    end
                    else
                    begin
                        cycle_count <= cycle_count + 1;
                    end
                end

                DRAIN:
                begin
                    if (cycle_count == 1)
                    begin
                        cycle_count <= 0;
                        state <= IDLE;
                        done <= 1;
                    end
                    else
                    begin
                        cycle_count <= cycle_count + 1;
                    end
                end

                default:
                begin
                    state <= IDLE;
                    cycle_count <= 0;
                    operation_pending <= 0;
                    done <= 0;
                end

            endcase
        end
    end

    // Output logic
    always @(*)
    begin
        array_enable = 0;
        array_clear = 0;

        A0_in = 0;
        A1_in = 0;
        B0_in = 0;
        B1_in = 0;

        case (state)

            CLEAR:
            begin
                array_clear = 1;
            end

            FEED:
            begin
                array_enable = 1;

                if (cycle_count == 0)
                begin
                    A0_in = A00;
                    B0_in = B00;
                    A1_in = A10;
                    B1_in = B01;
                end
                else
                begin
                    A0_in = A01;
                    B0_in = B10;
                    A1_in = A11;
                    B1_in = B11;
                end
            end

            DRAIN:
            begin
                array_enable = 1;
            end

        endcase
    end

endmodule
