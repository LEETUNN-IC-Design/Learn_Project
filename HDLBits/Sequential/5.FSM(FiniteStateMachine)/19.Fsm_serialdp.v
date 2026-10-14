`default_nettype none

module top_module(
    input clk,
    input in,
    input reset,
    output [7:0] out_byte,
    output done
);
    localparam IDLE   = 3'd0,
               DATA   = 3'd1,
               PARITY = 3'd2,
               STOP   = 3'd3,
               DONE   = 3'd4,
               ERROR  = 3'd5;

    reg [2:0] state, next_state;
    reg [2:0] cnt;
    reg [7:0] rx_data;
    reg [7:0] out_reg;

    wire odd;
    reg reset_parity;

    parity u_parity (
        .clk(clk),
        .reset(reset_parity),
        .in(in),
        .odd(odd)
    );

    always @(*) begin
        case (state)
            IDLE: begin
                next_state = (~in) ? DATA : IDLE;
            end

            DATA: begin
                if (cnt == 3'd7)
                    next_state = PARITY;
                else
                    next_state = DATA;
            end

            PARITY: begin
                next_state = STOP;
            end

            STOP: begin
                if (in) begin
                    if (odd)
                        next_state = DONE;
                    else
                        next_state = IDLE;
                end else begin
                    next_state = ERROR;
                end
            end

            DONE: begin
                next_state = (~in) ? DATA : IDLE;
            end

            ERROR: begin
                next_state = (in) ? IDLE : ERROR;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        reset_parity = reset || (state == IDLE) || (state == DONE) || (state == ERROR) || (state == STOP);
    end

    always @(posedge clk) begin
        if (reset) begin
            state   <= IDLE;
            cnt     <= 3'd0;
            rx_data <= 8'd0;
            out_reg <= 8'd0;
        end else begin
            state <= next_state;

            if (state == DATA) begin
                rx_data <= {in, rx_data[7:1]};
                cnt     <= cnt + 1'b1;
            end else begin
                cnt <= 3'd0;
            end

            if (state == STOP && in && odd) begin
                out_reg <= rx_data;
            end
        end
    end

    assign done = (state == DONE);
    assign out_byte = out_reg;

endmodule