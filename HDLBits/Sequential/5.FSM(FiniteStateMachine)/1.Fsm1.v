`default_nettype none
module top_module(
    input clk,
    input areset,
    input in,  
    output out);
    parameter A=0, B=1; 
    reg state, next_state;
    always @(*) begin      
       if (~in) begin if (state==A) next_state=B; else next_state=A; end else next_state=state;
     end    
    always @(posedge clk, posedge areset) begin   
        if (areset) begin
            state<=B; 
        end else state<=next_state; 
     end
    assign out=state;
endmodule