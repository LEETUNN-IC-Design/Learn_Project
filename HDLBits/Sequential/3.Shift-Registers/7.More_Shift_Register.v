`default_nettype none 
module top_module(
    input [3:0] SW,
    input [3:0] KEY,
    output [3:0] LEDR
    
);
    simple_shift instance_3 (
        .clk(KEY[0]),
        .w(KEY[3]),
        .R(SW[3]),
        .E(KEY[1]),
        .L(KEY[2]),
        .Q(LEDR[3]));
    simple_shift instance_2 (
        .clk(KEY[0]),
        .w(LEDR[3]),
        .R(SW[2]),
        .E(KEY[1]),
        .L(KEY[2]),
        .Q(LEDR[2]));
    simple_shift instance_1 (
        .clk(KEY[0]),
        .w(LEDR[2]),
        .R(SW[1]),
        .E(KEY[1]),
        .L(KEY[2]),
        .Q(LEDR[1]));
    simple_shift instance_0 (
        .clk(KEY[0]),
        .w(LEDR[1]),
        .R(SW[0]),
        .E(KEY[1]),
        .L(KEY[2]),
        .Q(LEDR[0]));       

endmodule
module simple_shift (
    input  wire clk,
    input  wire w, R, E, L,
    output reg  Q
);

    always @(posedge clk) begin
        Q <= L ? R : (E ? w : Q);
    end

endmodule