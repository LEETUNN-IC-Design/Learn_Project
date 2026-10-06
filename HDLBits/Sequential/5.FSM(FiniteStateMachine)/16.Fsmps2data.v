`default_nettype none
module top_module (
     input clk,
    input [7:0] in,
    input reset,    // Synchronous reset
    output [23:0] out_bytes,
    output done
);
parameter IDLE = 0, BYTE2 = 1, BYTE3 = 2, DONE = 3 ;
reg [1:0] state, next_state;
reg [7:0] byte1;
reg [7:0] byte2;
reg [7:0] byte3;
//================================================================
always @(posedge clk) begin
    if (reset) begin
        state<=IDLE;
    end else state <= next_state;
end
//================================================================
always @(*) begin
    next_state = state;
    case (state)
    
    IDLE :begin
        done = 0;
        if (in[3]) next_state = BYTE2;
    end
    
    BYTE2 : begin 
        next_state = BYTE3;
        done = 0;
    end
    
    BYTE3 : begin 
        done = 0;
        next_state = DONE;
    end
    DONE :begin
        done = 1;
         if (in[3]) next_state = BYTE2;else next_state = IDLE;
    end
    endcase
end
//================================================================    
always @(posedge clk) begin
   case (state)
    
    IDLE :begin
        if (in[3]) byte1<=in; 
    end
    
    BYTE2 : begin 
         byte2<=in;
    end
    
    BYTE3 : begin
         byte3<=in;
    end
    
    DONE :begin
        if (in[3]) byte1<=in; 
    end 
    endcase
end

assign out_bytes= {byte1,byte2,byte3};
endmodule