`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2022 04:17:12 PM
// Design Name: 
// Module Name: system
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


module system(
    output reg [15:0] led,
    output [6:0] seg,
    output dp,
    output [3:0] an,
    input wire RsRx,
    input clk,
    input btnC
    );
    
    wire baud;
    baudrate_gen baudrate(clk,baud);
    
    wire [7:0] data_in; //1 char from receive
    wire received; //received 8 bits successfully
    reg last_rec; //check if received is new
    wire new_input;
    assign new_input = ~last_rec&received;
    uart_rx uart(baud,RsRx,received,data_in);
    
    wire reset;
    singlePulser resetPulser(reset,btnC,baud);
        
    // Param
    reg [3:0] state;
    reg [3:0] counter;
    reg [31:0] cint1,cint2;
    reg [7:0] csign1,csign2,cop;
    reg [2:0] op,op2;
    wire signed [15:0] int1,int2,result;
    wire overflow;
//    reg sign
    
    strToInt s1(cint1,csign1,state,int1); //state 4
    strToInt s2(cint2,csign2,state,int2); // state 4
    
    alu alu(int1,int2,op2,result,overflow); // everystate , op2 at state 4
//    sign = result[15];

                
    //debug
    wire [15:0] led;
//    assign led[2:0] = {state};
//    assign led[15:12] = {counter};
//    assign led[9:7] = {op};
      assign led = result;
    wire targetClk;
    wire [18:0] tclk;
    assign tclk[0]=clk;
    genvar c;
    generate for(c=0;c<18;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    
    clockDiv fdivTarget(targetClk,tclk[18]);
    
    wire [3:0] a3,a2,a1,a0,b3,b2,b1,b0,s3,s2,s1,s0;
    wire sa,sb,ss;
    intToDigit itoda(a3,a2,a1,a0,sa,result);
    intToDigit itodb(b3,b2,b1,b0,sb,result);
    intToDigit itods(s3,s2,s1,s0,ss,result);
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,s0,s1,s2,s3,targetClk);
        
    // INIT
    initial begin
        state = 0;
        counter = 0;
    end
    
    // LOOP
    always @(posedge baud) begin
        if (reset) begin
            op = 0;
            state = 4;
        end
        case(state) 
            0: begin // Wait
                counter=0;
                csign1=8'h2B;
                csign2=8'h2B;
                cint1=0;
                cint2=0;
                state=1;
            end
            1: begin // int1
                if(new_input) begin
                    case(data_in)
                        8'h2D: begin
                            if(counter==0) begin
                                csign1 = data_in;
                                counter = counter+1;
                            end
                            if(counter>1 || (counter==1 && csign1==8'h2B)) begin
                                cop = data_in;
                                op = 2;
                                counter=0;
                                state=2;
                            end
                        end
                        // operwtor csse
                        8'h2B: begin
                            if(counter>1 || (counter==1 && csign1==8'h2B)) begin
                                cop = data_in;
                                op = 1;
                                counter=0;
                                state=2;
                            end
                        end
                        8'h2A: begin
                            if(counter>1 || (counter==1 && csign1==8'h2B)) begin
                                cop = data_in;
                                op = 3;
                                counter=0;
                                state=2;
                            end
                        end
                        8'h2F: begin
                            if(counter>1 || (counter==1 && csign1==8'h2B)) begin
                                cop = data_in;
                                op = 4;
                                counter=0;
                                state=2;
                            end
                        end
                        //
                        default:
                            if(csign1==8'h2D && counter<5 && data_in>=8'h30 && data_in<=8'h39 ) begin
                                cint1[31:8] = cint1[23:0];
                                cint1[7:0] = data_in;
                                counter = counter+1;
                            end
                            else if (csign1==8'h2B && counter<4 && data_in>=8'h30 && data_in<=8'h39 ) begin
                                cint1[31:8] = cint1[23:0];
                                cint1[7:0] = data_in;
                                counter = counter+1;
                            end
                    endcase
                 end
            end
            2: begin // operater
                state = 3;
            end
            3: begin // int2
                if(new_input) begin
                    case(data_in)
                        8'h2D: begin
                            if(counter==0) begin
                                csign2 = data_in;
                                counter = counter+1;
                            end
                        end
                        8'h0D : begin // ENTER
                            counter=0;
                            state=4; 
                        end
                        //
                        default:
                            if(csign2==8'h2D && counter<5 && data_in>=8'h30 && data_in<=8'h39 ) begin
                                cint2[31:8] = cint2[23:0];
                                cint2[7:0] = data_in;
                                counter = counter+1;
                            end
                            else if (csign2==8'h2B && counter<4 && data_in>=8'h30 && data_in<=8'h39 ) begin
                                cint2[31:8] = cint2[23:0];
                                cint2[7:0] = data_in;
                                counter = counter+1;
                            end
                    endcase
                 end
            end
            4: begin // calculate
                op2 = op;
                state = 0;
            end
        endcase
        last_rec = received;
    end
    
endmodule
