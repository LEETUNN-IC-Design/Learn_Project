`default_nettype none
module top_module(
    input clk,
    input areset,    
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging);

    parameter LEFT=0, RIGHT=1, LEFT_FALL=2, RIGHT_FALL=3, RIGHT_DIG=4 , LEFT_DIG=5, SPLAT =6  ;
    reg[4:0] cnt;
    reg [2:0] state, next_state; 
//========================================================================================
    always @(*) begin
        next_state = state;
        case (state) 
            
            LEFT:
            begin
                
                if (~ground) begin
                    next_state = LEFT_FALL; 
                end else if (dig) begin 
                    next_state=LEFT_DIG;
                end else if (bump_left) begin 
                    next_state = RIGHT; 
                end else next_state = LEFT;
            end

            RIGHT: 
            begin
                if (~ground) begin
                    next_state = RIGHT_FALL; 
                end else if (dig) begin 
                    next_state=RIGHT_DIG;
                end else if (bump_right) begin 
                    next_state = LEFT ; 
                end else next_state = RIGHT;      
            end

            RIGHT_DIG:
            begin
                if (~ground) begin
                    next_state = RIGHT_FALL;
                end else next_state = RIGHT_DIG;
            end

            LEFT_DIG:
             begin
                if (~ground) begin
                    next_state = LEFT_FALL;
                end else next_state = LEFT_DIG;
            end

            RIGHT_FALL: 
                if (ground) begin
                    if (cnt <20) begin
                    next_state = RIGHT; 
                    end else next_state= SPLAT;
                end else next_state = RIGHT_FALL;
            
            LEFT_FALL:
                if (ground) begin
                    if (cnt <20) begin
                        next_state = LEFT; 
                    end else next_state= SPLAT;
                end else next_state = LEFT_FALL;

            SPLAT: next_state =SPLAT;
            default: next_state=LEFT;
        endcase
    end
//========================================================================================
    always @(*) begin
        case (state) 
            LEFT :{walk_left,walk_right,digging ,aaah} =4'b1000; 
             
       
            RIGHT:{walk_left,walk_right,digging,aaah} =4'b0100;
                
        
            LEFT_DIG:{walk_left,walk_right,digging,aaah} =4'b0010;

            RIGHT_DIG:{walk_left,walk_right,digging,aaah} =4'b0010;
    
            RIGHT_FALL:{walk_left,walk_right,digging,aaah} =4'b0001;
             
            LEFT_FALL:{walk_left,walk_right,digging,aaah} =4'b0001;
            
            SPLAT: {walk_left,walk_right,digging,aaah} =4'b0000;

            default:{walk_left,walk_right,digging,aaah} =4'b1000;
        endcase
    end
//========================================================================================
    always @(posedge clk, posedge areset) begin
        if (areset) begin
            state<=LEFT;
            cnt<=0;
        end else begin 
        state<=next_state;  

        case (state) 
            LEFT:cnt<=0;
            RIGHT:cnt<=0;
            LEFT_DIG:cnt<=0;
            RIGHT_DIG:cnt<=0;
            RIGHT_FALL: if (cnt <= 20) cnt <= cnt + 1; else cnt <= 21;
            LEFT_FALL:if (cnt <= 20) cnt <= cnt + 1; else cnt <= 21;
        endcase
        end
    end

endmodule
