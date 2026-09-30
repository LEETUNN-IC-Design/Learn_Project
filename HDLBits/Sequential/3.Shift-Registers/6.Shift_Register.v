`default_nettype none
module top_module (
    input clk,
    input resetn,   // synchronous reset
    input in,
    output reg out);
    reg [3:1] state;
always @(posedge clk ) begin
    if (~resetn) begin 
        out <=0;  
        state <= '0;
    end else begin

        state[1]<=in; 
        state[2]<=state[1];
        state[3]<=state[2];
        out <= state[3]; 
    end
end
endmodule

