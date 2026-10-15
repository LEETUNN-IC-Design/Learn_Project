module top_module(
    input clk,
    input reset,
    input in,
    output disc,
    output flag,
    output err
);

    parameter IDLE  = 4'd0,
              ONE   = 4'd1,
              TWO   = 4'd2,
              THREE = 4'd3,
              FOUR  = 4'd4,
              FIVE  = 4'd5,
              SIX   = 4'd6,
              ERROR = 4'd7,
              DISC  = 4'd8,
              FLAG  = 4'd9;

    reg [3:0] state, next_state;

    always @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE:    next_state = in ? ONE   : IDLE;
            ONE:     next_state = in ? TWO   : IDLE;
            TWO:     next_state = in ? THREE : IDLE;
            THREE:   next_state = in ? FOUR  : IDLE;
            FOUR:    next_state = in ? FIVE  : IDLE;
            FIVE:    next_state = in ? SIX   : DISC;
            SIX:     next_state = in ? ERROR : FLAG;
            ERROR:   next_state = in ? ERROR : IDLE;
            DISC:    next_state = in ? ONE   : IDLE;
            FLAG:    next_state = in ? ONE   : IDLE;
            default: next_state = IDLE;
        endcase
    end

    assign disc = (state == DISC);
    assign flag = (state == FLAG);
    assign err  = (state == ERROR);

endmodule