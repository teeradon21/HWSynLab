`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2022 11:14:15 AM
// Design Name: 
// Module Name: strToInt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module strToInt(input wire [31:0] cint, input [7:0] csign, input [2:0] state, output reg signed [15:0] i);
    wire [3:0] num3,num2,num1,num0;
    charToInt c1(cint[31:24], num3);
    charToInt c2(cint[23:16], num2);
    charToInt c3(cint[15:8], num1);
    charToInt c4(cint[7:0], num0);
    always @(state) begin
        case(state)
        4: begin
            if (csign==8'h2D) i = (num3*1000 + num2*100 + num1*10 + num0)*-1;
            else i = (num3*1000 + num2*100 + num1*10 + num0);
            $display("testtesttest");
            $display("%c",i);
            $display("%d",i);
        end
        endcase
    end
endmodule
