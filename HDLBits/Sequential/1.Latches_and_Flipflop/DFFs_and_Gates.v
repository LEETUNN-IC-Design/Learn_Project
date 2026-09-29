`default_nettype none
module top_module (
    input  wire clk,
    input  wire x,
    output wire z
);

    reg  [2:0] q = '0;  
    
    always @(posedge clk) begin
        q[0] <= x ^ q[0];
        q[1] <= x & (~q[1]);
        q[2] <= x | (~q[2]);
    end

    assign z = ~(q[0] | q[1] | q[2]);

endmodule