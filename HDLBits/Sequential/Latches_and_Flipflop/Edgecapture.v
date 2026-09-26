`default_nettype none
module top_module (
    input clk,
    input reset,
    input [31:0] in,
    output [31:0] out
);
reg [31:0] in_dly ;
always @(posedge clk)
begin
    in_dly <= in ;
    if (reset) begin
        out<='0;
    end else begin
        out <= out |(~in & in_dly);
    end 
end

endmodule