`default_nettype none
module top_module ( 
    input  wire [15:0] a, b,
    input  wire        cin,
    output wire        cout,
    output wire [15:0] sum
);

    wire [3:0] cout_wire; // 4 đường dây truyền bit nhớ giữa 4 con BCD
    genvar i;

    generate 
        for (i = 0; i < 4; i = i + 1) begin : adder_gen
            if (i == 0) begin
                bcd_fadd u_bcd (
                    .a   (a[3:0]),
                    .b   (b[3:0]),
                    .cin (cin),
                    .cout(cout_wire[0]),
                    .sum (sum[3:0])
                );
            end
            else begin
                bcd_fadd u_bcd (
                    .a   (a[4*i + 3 : 4*i]),
                    .b   (b[4*i + 3 : 4*i]),
                    .cin (cout_wire[i-1]),
                    .cout(cout_wire[i]),
                    .sum (sum[4*i + 3 : 4*i])
                );
            end
        end
    endgenerate

    // Bit nhớ tràn cuối cùng của con thứ 3 chính là cout của module
    assign cout = cout_wire[3];

endmodule