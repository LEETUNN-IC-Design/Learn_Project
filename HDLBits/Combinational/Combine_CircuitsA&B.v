`default_nettype none
module top_module (
    input x, 
    input y, 
    output z
);
assign z= (x ^ y) & x; 
endmodule