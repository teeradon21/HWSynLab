`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2022 02:46:03 PM
// Design Name: 
// Module Name: intToDigit
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


module intToDigit(
    output [3:0] num3,
    output [3:0] num2,
    output [3:0] num1,
    output [3:0] num0,
    output sign,
    input signed [15:0] i
    );
    
    reg signed [15:0] ttt;
    assign sign = i[15];
    
    reg signed [3:0] a,b,c,d;
    
    assign num3 = a;
    assign num2 = b;
    assign num1 = c;
    assign num0 = d;
    
    always @(i) begin
        if (sign) ttt = -i;
        else ttt = i;
        a = (ttt%10000)/1000;
        b = (ttt%1000)/100;
        c = (ttt%100)/10;
        d = ttt%10;
    end
endmodule
