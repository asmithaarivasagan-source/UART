UART RTL Design using Verilog

Project Description

This project implements a UART transmitter and receiver using Verilog HDL, with a TX-RX loopback connection.

Features

- UART Transmitter (TX)
- UART Receiver (RX)
- FSM-based design
- Baud rate counter
- Serial-to-parallel conversion
- Parallel-to-serial conversion
- TX-RX loopback

Project Structure

rtl/
├── uart_tx.v
├── uart_rx.v
└── uart_top.v

testbench/
└── uart_top_tb.v

Simulation

- Tool: Xilinx Vivado
- Clock Period: 10 ns
- CLKS_PER_BIT: 16
- UART Frame: 8N1

Test Data:

- "0x41"
- "0xA5"
- "0x55"

Verification Status

UART loopback simulation has been performed. Final verification of all three test cases are passed.

Tools Used

- Verilog HDL
- Xilinx Vivado
- GitHub

Learning Objectives

- Understand UART communication
- Design FSM-based RTL
- Learn module instantiation
- Connect TX and RX modules
- Verify RTL through simulation
