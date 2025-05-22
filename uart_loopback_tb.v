`timescale 1ns/1ps

module uart_loopback_tb;
    // Clock & reset
    reg clk    = 0;
    reg reset  = 1;

    // TX side signals
    reg  [7:0] tx_data   = 0;
    reg        tx_send   = 0;
    wire       tx_busy;
    wire       tx_line;

    // Baud tick
    wire baud_tick;

    // RX side signals
    wire [7:0] rx_data;
    wire       rx_ready;

    // 100 MHz clock generator
    always #5 clk = ~clk;

    // Baudrate generator (100 MHz → 9 600 baud)
    baud_gen #(
        .CLK_FREQ(100_000),
        .BAUD_RATE(9600)
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // UART TX (transmitter)
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .data_in(tx_data),
        .send(tx_send),
        .baud_tick(baud_tick),
        .tx(tx_line),
        .busy(tx_busy)
    );

    // Loopback: RX.input <= TX.output
    wire rx_line = tx_line;

    // UART RX (receiver)
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(rx_line),
        .baud_tick(baud_tick),
        .data_out(rx_data),
        .ready(rx_ready)
    );

    // Task to send one byte
    task transmit_byte(input [7:0] b);
        begin
            // 1) TX side: veriyi yolla
            @(posedge clk);
            tx_data <= b;
            tx_send <= 1;
            @(posedge clk);
            tx_send <= 0;
        
            // 2) TX'in bitmesini bekle
            wait (!tx_busy);
        
            // 3) RX'in o byte'ı tamamlayıp ready etmesini bekle
            wait (rx_ready);
        
            // 4) Tam framing için bir stop biti kadar daha bekle
            @(posedge baud_tick);
        end
    endtask


    // Log received bytes
    always @(posedge clk) begin
        if (rx_ready) begin
            $display("[%0t] RECEIVED: %c (0x%0h)", $time, rx_data, rx_data);
        end
    end
    // Testbench'in en üstüne, initial bloğun yanına ekle
    initial begin
        $display("---- RX LOG ----");
    end
    
    // Her rx_ready kenarında aldığın karakteri bastır
    always @(posedge clk) begin
        if (rx_ready) begin
            $display("[%0t ns] RECEIVED: %c (0x%0h)", $time, rx_data, rx_data);
        end
    end

    initial begin
        // Reset pulse
        #20 reset = 0;
        #20;

        // Send "V A R T E X"
        transmit_byte("V");
        transmit_byte("A");
        transmit_byte("R");
        transmit_byte("T");
        transmit_byte("E");
        transmit_byte("X");

        // Wait last RX
        wait (rx_ready);
        // Extra stop-bit
        @(posedge baud_tick);

        $display("Loopback test complete.");
        $finish;
    end

endmodule
