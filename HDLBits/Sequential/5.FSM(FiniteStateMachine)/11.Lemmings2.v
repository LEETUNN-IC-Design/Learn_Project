`default_nettype none
module top_module(
    input clk,
    input areset,    
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output aaah,
    output walk_right);

    parameter LEFT=0, RIGHT=1, LEFT_FALL=2, RIGHT_FALL=3;
    reg [1:0] state, next_state; 
    always @(*) begin
        next_state=state;
        case (state) 
            LEFT :begin
                if (bump_left) begin 
                    next_state=RIGHT; 
                end else next_state=LEFT;
                if (~ground) begin
                    next_state= LEFT_FALL; 
                end
            end
            RIGHT: begin
                if (bump_right) begin 
                    next_state=LEFT ; 
                end else next_state=RIGHT;
                if (~ground) begin
                    next_state= RIGHT_FALL; 
                end 
            end
            RIGHT_FALL: 
                if (ground) begin
                    next_state = RIGHT; 
                end else next_state=RIGHT_FALL;
            LEFT_FALL:
                if (ground) begin
                    next_state = LEFT; 
                end else next_state=LEFT_FALL;
        endcase
    end
    always @(*) begin
        case (state) 
            LEFT :  {walk_left,walk_right,aaah} =3'b100; 
               
            RIGHT:{walk_left,walk_right,aaah} =3'b010;
                
            RIGHT_FALL:{walk_left,walk_right,aaah} =3'b001;
                
            LEFT_FALL:{walk_left,walk_right,aaah} =3'b001;
            default:{walk_left,walk_right,aaah} =3'b100;
        endcase
    end
    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state<=LEFT;
        end else state<=next_state;  
    end

endmodule
