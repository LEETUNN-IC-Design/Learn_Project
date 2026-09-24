`default_nettype none

module top_module (
    input  [3:0] x,
    input  [3:0] y, 
    output [4:0] sum
);

    wire [3:0] cout;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : adder_gen
            if (i == 0) begin
                fadd fa_inst (
                    .a(x[0]),
                    .b(y[0]),
                    .cin(1'b0),
                    .cout(cout[0]),
                    .sum(sum[0])
                );
            end else begin
                fadd fa_inst (
                    .a(x[i]),
                    .b(y[i]),
                    .cin(cout[i-1]),
                    .cout(cout[i]),
                    .sum(sum[i])
                );
            end
        end
    endgenerate

    // Bit tràn nhớ cuối cùng chính là sum[4]
    assign sum[4] = cout[3];

endmodule

module fadd (
    input  wire a, b, cin,
    output wire cout, sum
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule