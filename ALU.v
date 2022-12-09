`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2022 03:36:54 PM
// Design Name: 
// Module Name: ALU
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


module alu(
    input signed [15:0] a,
    input signed [15:0] b,
    input [2:0] opcode,
    output reg signed  [15:0] out,
    output reg overflow
    );
    
    reg signed [20:0] s;
    always @ (a or b or opcode)
        case(opcode)
            0: begin
                s=0;
                out=s;
                overflow=0;
                end
            1: begin
                s=a+b;
                overflow =(s>9999 | s<-9999);
                out = s;
                end
            2: begin
                s=a-b;
                overflow =(s>9999 | s<-9999);
                out = s;
                end
            3: begin
                s=a*b;
                overflow =(s>9999 | s<-9999);
                out = s;
                end
            4: begin
                s=a/b;
                overflow =(b==0 | s>9999 | s<-9999);
                out = s;
                end
        endcase
endmodule
