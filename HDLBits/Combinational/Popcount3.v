`default_nettype none
module top_module( 
    input [2:0] in,
    output [1:0] out );
    integer i;
    always @(*) begin
    out = 2'd0; // Khởi tạo chống Latch
    for (i = 0; i < 3; i = i + 1) begin
        out = out + in[i];
    end
    end
endmodule