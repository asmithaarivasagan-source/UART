module uart_rx #(
    parameter CLKS_PER_BIT = 16
)(
    input wire clk,
    input wire rst,
    input wire rx,

    output reg [7:0] data_out,
    output reg rx_done
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [12:0] baud_count;
reg [2:0] bit_count;
reg [7:0] shift_reg;

reg rx_sync1;
reg rx_sync2;

// Synchronize asynchronous RX signal
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end
    else begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
end

// Receiver FSM
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state      <= IDLE;
        baud_count <= 0;
        bit_count  <= 0;
        shift_reg  <= 0;
        data_out   <= 0;
        rx_done    <= 0;
    end
    else begin
        rx_done <= 1'b0;

        case (state)

            IDLE: begin
                baud_count <= 0;
                bit_count  <= 0;

                if (rx_sync2 == 1'b0)
                    state <= START;
            end

            START: begin
                if (baud_count == (CLKS_PER_BIT/2)-1) begin
                    baud_count <= 0;

                    if (rx_sync2 == 1'b0)
                        state <= DATA;
                    else
                        state <= IDLE;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            DATA: begin
                if (baud_count == CLKS_PER_BIT-1) begin
                    baud_count <= 0;

                    shift_reg <= {rx_sync2, shift_reg[7:1]};

                    if (bit_count == 7)
                        state <= STOP;
                    else
                        bit_count <= bit_count + 1;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            STOP: begin
                if (baud_count == CLKS_PER_BIT-1) begin
                    baud_count <= 0;

                    if (rx_sync2 == 1'b1) begin
                        data_out <= shift_reg;
                        rx_done <= 1'b1;
                    end

                    state <= IDLE;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            default: begin
                state <= IDLE;
                baud_count <= 0;
            end

        endcase
    end
end

endmodule
