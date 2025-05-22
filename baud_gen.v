module baud_gen(
    input wire clk,
    input wire reset,
    output reg baud_tick
);
    parameter CLK_FREQ = 100_000; // 100 MHz
    parameter BAUD_RATE = 9600;
    localparam integer BAUD_MAX = CLK_FREQ / BAUD_RATE;
    reg [31:0] cnt = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= 0;
            baud_tick <= 0;
        end else begin
            if (cnt == BAUD_MAX/2) begin
                baud_tick <= 1;
                cnt <= 0;
            end else begin
                baud_tick <= 0;
                cnt <= cnt + 1;
            end
        end
    end
endmodule
