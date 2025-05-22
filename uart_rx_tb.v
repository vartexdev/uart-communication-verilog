`timescale 1ns/1ps

module uart_rx_tb;

    reg clk = 0;
    reg reset = 1;
    reg rx = 1;
    wire [7:0] data_out;
    wire ready;
    wire baud_tick;

    // 100 kHz clock (10 us period)
    always #5 clk = ~clk;

    // Baudrate generator
    baud_gen #(
        .CLK_FREQ(100_000),  // 100 kHz
        .BAUD_RATE(9600)
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // UART RX
    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .baud_tick(baud_tick),
        .data_out(data_out),
        .ready(ready)
    );

    // UART gönderici taskı - artık BAUD_TICK ile senkron!
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            @(posedge clk);
            rx = 0; // Start bit
            @(posedge baud_tick);
            for (i=0; i<8; i=i+1) begin
                rx = data[i]; // LSB first
                @(posedge baud_tick);
            end
            rx = 1; // Stop bit
            @(posedge baud_tick);
        end
    endtask

    initial begin
        // RESET
        #100; reset = 0;
        #100;
        repeat(10) @(posedge baud_tick); // Burayı arttırabilirsin!
        send_uart_byte("V"); 
        repeat(4) @(posedge baud_tick);
        send_uart_byte("A"); 
        repeat(4) @(posedge baud_tick);
        send_uart_byte("R"); 
        repeat(4) @(posedge baud_tick);
        send_uart_byte("T"); 
        repeat(4) @(posedge baud_tick);
        send_uart_byte("E"); 
        repeat(4) @(posedge baud_tick);
        send_uart_byte("X"); 
        #1000;
        $stop;
    end

endmodule
