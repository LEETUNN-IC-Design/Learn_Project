`default_nettype none
module top_module (
    input  wire clk,
    input  wire w, R, E, L,
    output reg  Q
);

    always @(posedge clk) begin
        if (L) begin
            Q <= R;       
        end else if (E) begin
            Q <= w;        
        end else begin
            Q <= Q;       
        end
    end
endmodule