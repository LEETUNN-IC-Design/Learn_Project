module top_module (
    input clk,
    input reset,
    input s,
    input w,
    output z
);

    parameter A  = 4'd0,
              B  = 4'd1,
              B1 = 4'd2,
              B2 = 4'd3,
              B3 = 4'd4;

    reg [3:0] state, next_state;
    reg [1:0] w_reg;

    always @(posedge clk) begin
        if (reset)
            state <= A;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            A:  next_state = s ? B : A;
            B:  next_state = B1;
            B1: next_state = B2;
            B2: next_state = B3;
            B3: next_state = B1;
            default: next_state = A;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            w_reg <= 2'b00;
        end else begin
            case (state)
                B:  w_reg <= {1'b0, w};
                B1: w_reg <= w_reg + {1'b0, w};
                B2: w_reg <= w_reg + {1'b0, w};
                B3: w_reg <= {1'b0, w};
            endcase
        end
    end

    assign z = (state == B3) && (w_reg == 2'd2);

endmodule