`default_nettype none
module top_module (
    input clk,
    input [7:0] in,
    input reset,    
    output done
);
parameter IDLE = 0, BYTE2 = 1, BYTE3 = 2, DONE = 3 ;
reg [1:0] state, next_state;
//================================================================
always @(posedge clk) begin
    if (reset) begin
        state<=IDLE;
    end else state <= next_state;
end
//================================================================
always @(*) begin
    // next_state=state;
    case (state)
    IDLE :begin
        done = 0;
        if (in[3]) next_state = BYTE2; else next_state=IDLE; 
    end
    BYTE2 : begin 
        next_state = BYTE3;
        done = 0;
    end
    BYTE3 : next_state = DONE;
    DONE :begin
        done = 1;
         if (in[3]) next_state = BYTE2; else next_state=IDLE;
    end
    endcase
end
//================================================================    

endmodule