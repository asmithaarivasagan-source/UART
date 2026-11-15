module uart_top #(
    parameter CLKS_PER_BIT = 16
)(
    input wire clk,
    input wire rst,

    input wire tx_start,
    input wire [7:0] tx_data,

    output wire tx_serial,
    output wire tx_busy,
    output wire tx_done,

    output wire [7:0] rx_data,
    output wire rx_done
);

// Connect transmitter serial output to receiver serial input
wire serial_line;

assign serial_line = tx_serial;

// UART Transmitter
uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) transmitter (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx_serial(tx_serial),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

// UART Receiver
uart_rx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) receiver (
    .clk(clk),
    .rst(rst),
    .rx(serial_line),
    .data_out(rx_data),
    .rx_done(rx_done)
);

endmodule
