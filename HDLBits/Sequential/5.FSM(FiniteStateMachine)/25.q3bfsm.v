module top_module (
    input clk,
    input reset,
    input x,
    output z
);

    reg [2:0] y, Y;

    always @(posedge clk) begin
        if (reset)
            y <= 3'b000;
        else
            y <= Y;
    end

    always @(*) begin
        case (y)
            3'b000:  Y = x ? 3'b001 : 3'b000;
            3'b001:  Y = x ? 3'b100 : 3'b001;
            3'b010:  Y = x ? 3'b001 : 3'b010;
            3'b011:  Y = x ? 3'b010 : 3'b001;
            3'b100:  Y = x ? 3'b100 : 3'b011;
            default: Y = 3'b000;
        endcase
    end

    assign z = (y == 3'b011) || (y == 3'b100);

endmodule