`timescale 1ns/1ps

module uart_tx_tb;
    reg        clk    = 0;
    reg        reset  = 1;
    reg  [7:0] data   = 0;
    reg        send   = 0;
    wire       tx;
    wire       busy;
    wire       baud_tick;

    // 100 kHz clock
    always #5 clk = ~clk;

    // Baudrate generator (same as RX tb)
    baud_gen #(
        .CLK_FREQ(100_000),
        .BAUD_RATE(9600)
    ) baud_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // UART TX under test
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .data_in(data),
        .send(send),
        .baud_tick(baud_tick),
        .tx(tx),
        .busy(busy)
    );

    // Send a byte task
    task transmit(input [7:0] b);
        begin
          @(posedge clk);
          data  <= b;
          send  <= 1;
          @(posedge clk);
          send  <= 0;
          wait (!busy);
          @(posedge baud_tick);
         end
    endtask


    initial begin
        // 1) Reset
        reset = 1;
        #20;
        reset = 0;
        #20;
    
        // 2) Mesajı sırayla gönder
        transmit("S");
        transmit("E");
        transmit("N");
        transmit("D");
        wait(!busy);
        @(posedge baud_tick);
        $finish;

    end

endmodule
