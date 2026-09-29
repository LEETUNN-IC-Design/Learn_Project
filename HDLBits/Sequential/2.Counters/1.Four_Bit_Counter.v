`default_nettype none
module top_module (
    input clk,
    input reset,      // Synchronous active-high reset
    output reg [3:0] q);

    always @(posedge clk )begin
        if (reset) begin
            q<='0;
        end else if (q==4'b1111) q<='0;
        else q<=q+1;
    end
endmodule
