`default_nettype none
module top_module (
    input  wire clk,
    input  wire L,
    input  wire r_in,
    input  wire q_in,
    output reg  Q
);

    always @(posedge clk) begin
        if (L) begin
            Q <= r_in;
        end else begin
            Q <= q_in;
        end
    end

endmodule
