`default_nettype none

module top_module(
    input clk,
    input in,
    input reset,    
    output done
);

    localparam IDLE  = 3'd0,
               DATA  = 3'd1,
               STOP  = 3'd2,
               DONE  = 3'd3,
               ERROR = 3'd4;

    reg [2:0] state, next_state;
    reg [2:0] cnt;
    always @(*) begin
        case (state)
            IDLE: begin
                
                next_state = (~in) ? DATA : IDLE;
            end

            DATA: begin
             
                if (cnt == 3'd7)
                    next_state = STOP;
                else
                    next_state = DATA;
            end

            STOP: begin
               
                if (in)
                    next_state = DONE;
                else
                    next_state = ERROR;
            end

            DONE: begin
             
                next_state = (~in) ? DATA : IDLE;
            end

            ERROR: begin
              
            end

            default: next_state = IDLE;
        endcase
    end

  
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            cnt   <= 3'd0;
        end else begin
            state <= next_state;

            if (state == DATA)
                cnt <= cnt + 1'b1;
            else
                cnt <= 3'd0;
        end
    end


    assign done = (state == DONE);

endmodule