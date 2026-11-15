module uart_tx #(
    parameter CLKS_PER_BIT = 16
)(
    input wire clk,
    input wire rst,
    input wire tx_start,
    input wire [7:0] tx_data,

    output reg tx_serial,
    output reg tx_busy,
    output reg tx_done
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [12:0] baud_count;
reg [2:0] bit_count;
reg [7:0] shift_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state      <= IDLE;
        baud_count <= 0;
        bit_count  <= 0;
        shift_reg  <= 0;
        tx_serial  <= 1'b1;
        tx_busy    <= 1'b0;
        tx_done    <= 1'b0;
    end
    else begin
        tx_done <= 1'b0;

        case (state)

            IDLE: begin
                tx_serial  <= 1'b1;
                tx_busy    <= 1'b0;
                baud_count <= 0;
                bit_count  <= 0;

                if (tx_start) begin
                    shift_reg <= tx_data;
                    tx_busy   <= 1'b1;
                    state     <= START;
                end
            end

            START: begin
                tx_serial <= 1'b0;
                tx_busy   <= 1'b1;

                if (baud_count == CLKS_PER_BIT-1) begin
                    baud_count <= 0;
                    state <= DATA;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            DATA: begin
                tx_serial <= shift_reg[0];
                tx_busy   <= 1'b1;

                if (baud_count == CLKS_PER_BIT-1) begin
                    baud_count <= 0;
                    shift_reg <= shift_reg >> 1;

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
                tx_serial <= 1'b1;
                tx_busy   <= 1'b1;

                if (baud_count == CLKS_PER_BIT-1) begin
                    baud_count <= 0;
                    state <= IDLE;
                    tx_done <= 1'b1;
                    tx_busy <= 1'b0;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            default: begin
                state <= IDLE;
                tx_serial <= 1'b1;
            end

        endcase
    end
end

endmodule
