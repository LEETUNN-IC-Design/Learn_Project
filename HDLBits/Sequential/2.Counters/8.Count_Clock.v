module top_module(
    input clk,
    input reset,
    input ena,
    output reg pm,
    output reg [7:0] hh,
    output reg [7:0] mm,
    output reg [7:0] ss
);

    wire ss_roll = (ss == 8'h59);
    wire mm_roll = (mm == 8'h59) && ss_roll;
    wire hh_roll = (hh == 8'h12) && mm_roll;

    always @(posedge clk) begin
        if (reset) begin
            ss <= 8'h00;
        end else if (ena) begin
            if (ss[3:0] == 4'd9) begin
                ss[3:0] <= 4'd0;
                if (ss[7:4] == 4'd5)
                    ss[7:4] <= 4'd0;
                else
                    ss[7:4] <= ss[7:4] + 1'b1;
            end else begin
                ss[3:0] <= ss[3:0] + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            mm <= 8'h00;
        end else if (ena && ss_roll) begin
            if (mm[3:0] == 4'd9) begin
                mm[3:0] <= 4'd0;
                if (mm[7:4] == 4'd5)
                    mm[7:4] <= 4'd0;
                else
                    mm[7:4] <= mm[7:4] + 1'b1;
            end else begin
                mm[3:0] <= mm[3:0] + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            hh <= 8'h12;
        end else if (ena && mm_roll) begin
            if (hh == 8'h12) begin
                hh <= 8'h01;
            end else if (hh[3:0] == 4'd9) begin
                hh[3:0] <= 4'd0;
                hh[7:4] <= hh[7:4] + 1'b1;
            end else begin
                hh[3:0] <= hh[3:0] + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            pm <= 1'b0;
        end else if (ena && mm_roll && (hh == 8'h11)) begin
            pm <= ~pm;
        end
    end

endmodule