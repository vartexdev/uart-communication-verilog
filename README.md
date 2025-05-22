# UART Communication Modules

## Description
This project contains Verilog implementations of UART Receiver and Transmitter modules, including testbenches and a loopback simulation for verification. A baud rate generator is also provided for clock control.

## Files

| File                  | Description |
|-----------------------|-------------|
| `uart_rx.v`           | UART Receiver module (8-bit data, asynchronous) |
| `uart_rx_tb.v`        | Testbench for UART Receiver |
| `uart_tx.v`           | UART Transmitter module (8-bit data) |
| `uart_tx_tb.v`        | Testbench for UART Transmitter |
| `uart_loopback_tb.v`  | Loopback test combining RX and TX |
| `baud_gen.v`          | Baud rate clock generator |

## Features
- 9600 baud rate support (customizable)
- Loopback test simulates bidirectional data transmission
- Ready/valid handshaking
- Asynchronous reset support

## How to Simulate
Run `uart_loopback_tb.v` to verify full-duplex communication.
Make sure the clock and baud parameters are correctly set in `baud_gen.v`.

## Author
Sinan A. – Verilog / FPGA Enthusiast  
Uludağ University, Electrical & Electronics Engineering