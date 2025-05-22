`timescale 1ns/1ps
module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       send,
    input  wire       baud_tick,
    output reg        tx,
    output reg        busy
);

    // State'ler
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0] state     = IDLE;
    reg [3:0] bit_cnt   = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state     <= IDLE;
            tx        <= 1'b1;   // Line idle = high
            busy      <= 1'b0;
            bit_cnt   <= 4'd0;
            shift_reg <= 8'd0;
        end else begin
            if (state == IDLE) begin
                busy <= 1'b0;
                if (send) begin
                    // ① send geldiğinde hemen yakala
                    shift_reg <= data_in;
                    bit_cnt   <= 4'd0;
                    state     <= START;
                    busy      <= 1'b1;
                end
            end
            else if (baud_tick) begin
                case (state)
                    START: begin
                        tx    <= 1'b0;    // Start bit
                        state <= DATA;
                    end

                    DATA: begin
                        tx         <= shift_reg[0];     // LSB first
                        shift_reg  <= shift_reg >> 1;
                        bit_cnt    <= bit_cnt + 1;
                        if (bit_cnt == 4'd7)
                            state <= STOP;
                    end

                    STOP: begin
                        tx    <= 1'b1;    // Stop bit
                        state <= IDLE;
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
