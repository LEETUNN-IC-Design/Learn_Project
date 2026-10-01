`default_nettype none
module top_module(
    input clk,
    input in,
    input areset,
    output out); 

parameter A=0, B=1, C=2, D=3;
reg [1:0] state, next_state;
always @(*) begin
    case (state)
        A:if (in) next_state=B ;else next_state=A;
        B:if (in) next_state=B ;else next_state=C;
        C:if (in) next_state=D ;else next_state=A;
        D:if (in) next_state=B ;else next_state=C;
        default: next_state=A;
    endcase 
end

always @(posedge clk or posedge areset ) begin
    if (areset) begin
        state <= A ;
    end else state <= next_state ;
end
assign out = (state == D);

endmodule
