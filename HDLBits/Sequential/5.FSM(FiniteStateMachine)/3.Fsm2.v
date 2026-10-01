`default_nettype none
module top_module(
    input clk,
    input areset,    // Asynchronous reset to OFF
    input j,
    input k,
    output out); //  

    parameter OFF=0, ON=1; 
    reg state, next_state;

    always @(*) begin
        if (state) begin 
            if (k==1) next_state = OFF;else next_state = state;
        end else if (j==1) next_state = ON;else next_state = state;
    end

    always @(posedge clk, posedge areset) begin
        if(areset) begin
            state <= 0;
        end else state <= next_state;
    end
assign out = state;

endmodule