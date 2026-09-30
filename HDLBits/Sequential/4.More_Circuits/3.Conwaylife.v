module top_module(
    input clk,
    input load,
    input [255:0] data,
    output reg [255:0] q
);

    reg [255:0] next_q;

    integer row, col;
    integer r_up, r_down;
    integer c_left, c_right;
    integer count;

    // Next-state logic
    always @(*) begin
        next_q = q;

        for (row = 0; row < 16; row = row + 1) begin
            for (col = 0; col < 16; col = col + 1) begin
                if (row == 0)
                    r_up = 15;
                else
                    r_up = row - 1;

                if (row == 15)
                    r_down = 0;
                else
                    r_down = row + 1;
                if (col == 0)
                    c_left = 15;
                else
                    c_left = col - 1;

                if (col == 15)
                    c_right = 0;
                else
                    c_right = col + 1;
                count =
                    q[r_up   * 16 + c_left]+
                    q[r_up   * 16 + col]+
                    q[r_up   * 16 + c_right] +
                    q[row    * 16 + c_left]  +
                    q[row    * 16 + c_right] +
                    q[r_down * 16 + c_left]  +
                    q[r_down * 16 + col]     +
                    q[r_down * 16 + c_right];
                if (count <= 1)
                    next_q[row * 16 + col] = 1'b0;
                else if (count == 2)
                    next_q[row * 16 + col] = q[row * 16 + col];
                else if (count == 3)
                    next_q[row * 16 + col] = 1'b1;
                else
                    next_q[row * 16 + col] = 1'b0;

            end
        end
    end

    // State register
    always @(posedge clk) begin
        if (load)
            q <= data;
        else
            q <= next_q;
    end

endmodule