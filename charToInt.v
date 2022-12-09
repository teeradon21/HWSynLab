`timescale 1ns / 1ps

module charToInt(input wire [7:0] c, output reg [3:0] i);
    always @(c)
        case(c)
            8'h30: i=0;
            8'h31: i=1;
            8'h32: i=2;
            8'h33: i=3;
            8'h34: i=4;
            8'h35: i=5;
            8'h36: i=6;
            8'h37: i=7;
            8'h38: i=8;
            8'h39: i=9;
        endcase
endmodule