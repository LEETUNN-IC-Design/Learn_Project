`default_nettype none
module top_module (
    input clk,
    input reset,
    input [3:1] s,
    output fr3,
    output fr2,
    output fr1,
    output dfr
); 
    parameter U3 = 1, U23 = 2, D32 = 3, U12 = 4, D21 = 5, D1 = 6;  
    reg [2:0] state, next_state;
    always @(*) begin
        next_state = state;
        case (state) 
            D1: begin
                case (s)
                    3'b000:  next_state = D1;
                    3'b001:  next_state = U12;
                    default: next_state = D1;
                endcase
            end
            U12: begin
                case (s)
                    3'b001:  next_state = U12;
                    3'b011:  next_state = U23;
                    3'b000:  next_state = D1;   
                    default: next_state = U12;
                endcase
            end
            U23: begin
                case (s)
                    3'b011:  next_state = U23;
                    3'b111:  next_state = U3;
                    3'b001:  next_state = D21;  
                    default: next_state = U23;
                endcase
            end
            U3: begin
                case (s)
                    3'b111:  next_state = U3;
                    3'b011:  next_state = D32;
                    default: next_state = U3;
                endcase
            end
            D32: begin
                case (s)
                    3'b011:  next_state = D32;
                    3'b001:  next_state = D21;
                    3'b111:  next_state = U3;   
                    default: next_state = D32;
                endcase
            end
            D21: begin
                case (s)
                    3'b001:  next_state = D21;
                    3'b000:  next_state = D1;
                    3'b011:  next_state = U23;  
                    default: next_state = D21;
                endcase
            end
            default: next_state = D1;
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
            state <= D1;
        end else begin
            state <= next_state;
        end
    end
    always @(*) begin
        case (state) 
            D1:{fr1, fr2, fr3, dfr} = 4'b1111; 
            U12:{fr1, fr2, fr3, dfr} = 4'b1100;
            U23:{fr1, fr2, fr3, dfr} = 4'b1000;
            U3:{fr1, fr2, fr3, dfr} = 4'b0000;
            D32:{fr1, fr2, fr3, dfr} = 4'b1001;
            D21:{fr1, fr2, fr3, dfr} = 4'b1101;
            default:{fr1, fr2, fr3, dfr} = 4'b0000;
        endcase
    end

endmodule