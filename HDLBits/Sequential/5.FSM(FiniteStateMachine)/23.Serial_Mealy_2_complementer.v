module top_module (
    input clk,
    input areset,
    input x,
    output z
);

    parameter A = 2'b01,
              B = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= A;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state[0] = state[0] & ~x;
        next_state[1] = (state[0] & x) | state[1];
    end

    assign z = (state[0] & x) | (state[1] & ~x);

endmodule