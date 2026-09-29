`default_nettype none
module top_module (
    input clk,
    input d,
    output q
);

    always @(posedge clk) begin
        q<=d;
    end
endmodule
