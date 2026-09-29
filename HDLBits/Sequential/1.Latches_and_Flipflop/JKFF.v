`default_nettype none
module top_module (
    input clk,
    input j,
    input k,
    output Q); 
always @(posedge clk) begin
    if (~j) begin
        if (~k) begin
            Q<=Q;
        end else begin
            Q<=0;
        end
    end else begin
        if (~k) begin
            Q<=1;
        end else begin
            Q<=~Q;
        end

     end
end 
endmodule