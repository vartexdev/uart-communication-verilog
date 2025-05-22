module uart_rx(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,
    input  wire       baud_tick,
    output reg [7:0]  data_out,
    output reg        ready
);
    reg [3:0]  bit_cnt   = 0;
    reg [7:0]  rx_shift  = 0;
    reg        rx_busy   = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt   <= 0;
            rx_shift  <= 0;
            rx_busy   <= 0;
            data_out  <= 0;
            ready     <= 0;
        end else if (baud_tick) begin
            ready <= 0;

            if (!rx_busy) begin
                if (rx == 0) begin    // Start bit algıla
                    rx_busy  <= 1;
                    bit_cnt  <= 0;
                end
            end else begin
                bit_cnt   <= bit_cnt + 1;
                rx_shift  <= {rx, rx_shift[7:1]};  // LSB first kaydır

                if (bit_cnt == 8) begin             // Stop bit sonunda
                    data_out <= rx_shift;
                    ready    <= 1;
                    rx_busy  <= 0;
                end
            end
        end
    end
endmodule
