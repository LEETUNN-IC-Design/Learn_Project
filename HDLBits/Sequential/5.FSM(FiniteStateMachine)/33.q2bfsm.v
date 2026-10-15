module top_module (
    input clk,
    input resetn,
    input x,
    input y,
    output f,
    output g
);

    parameter A  = 4'd0,
              F  = 4'd1,
              S0 = 4'd2,
              S1 = 4'd3,
              S2 = 4'd4,
              G1 = 4'd5,
              G2 = 4'd6,
              P1 = 4'd7,
              P0 = 4'd8;

    reg [3:0] state, next_state;

    always @(posedge clk) begin
        if (!resetn)
            state <= A;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            A:  next_state = F;
            F:  next_state = S0;
            S0: next_state = x ? S1 : S0;
            S1: next_state = x ? S1 : S2;
            S2: next_state = x ? G1 : S0;
            G1: next_state = y ? P1 : G2;
            G2: next_state = y ? P1 : P0;
            P1: next_state = P1;
            P0: next_state = P0;
            default: next_state = A;
        endcase
    end

    assign f = (state == F);
    assign g = (state == G1) || (state == G2) || (state == P1);

endmodule
