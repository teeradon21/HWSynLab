`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2022 05:37:11 PM
// Design Name: 
// Module Name: vga_sync
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


module vga_sync(
    input wire clk, reset,
    output wire hsync, vsync, video_on, p_tick,
    output wire [9:0] x, y
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  10; // vertical top border
	localparam V_B_BORDER      =  33; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
    localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	
	// mod-4 counter to generate 25 MHz pixel tick
	reg [1:0] pixel_reg;
	wire [1:0] pixel_next;
	wire pixel_tick;
	
	always @(posedge clk, posedge reset)
		if(reset) pixel_reg <= 0;
		else pixel_reg <= pixel_next;
	
	assign pixel_next = pixel_reg + 1; // increment pixel_reg 
	
	assign pixel_tick = (pixel_reg == 0); // assert tick 1/4 of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
 
	// infer registers
	always @(posedge clk, posedge reset)
		if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            vsync_reg   <= 0;
            hsync_reg   <= 0;
		end
		else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            vsync_reg   <= vsync_next;
            hsync_reg   <= hsync_next;
		end
			
	// next-state logic of horizontal vertical sync counters
	always @* begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			         : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			         : v_count_reg;
    end
    
    // hsync and vsync are active low signals
    // hsync signal asserted during horizontal retrace
    assign hsync_next = (h_count_reg >= START_H_RETRACE) && (h_count_reg <= END_H_RETRACE);

    // vsync signal asserted during vertical retrace
    assign vsync_next = (v_count_reg >= START_V_RETRACE) && (v_count_reg <= END_V_RETRACE);

    // video only on when pixels are in both horizontal and vertical display region
    assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);

    // output signals
    assign hsync  = hsync_reg;
    assign vsync  = vsync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = pixel_tick;
endmodule


////////////////////////////////////////////////
module vga(
    input wire [2:0] ops,
    input wire [3:0] a3,a2,a1,a0,b3,b2,b1,b0,s3,s2,s1,s0,
    input wire sa,sb,ss,overflow,
    input wire clk,
    input wire [11:0] sw,
    input wire [1:0] push,
    output wire hsync, vsync,
    output wire [11:0] rgb
	);
	
	parameter WIDTH = 640;
	parameter HEIGHT = 480;
	
	// register for Basys 2 8-bit RGB DAC 
	reg [11:0] rgb_reg;
	reg reset = 0;
	wire [9:0] x, y;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;
	wire p_tick;

    // instantiate vga_sync
    vga_sync vga_sync_unit (
        .clk(clk), .reset(reset), 
        .hsync(hsync), .vsync(vsync), .video_on(video_on), .p_tick(p_tick), 
        .x(x), .y(y)
        );
        
    // ???
    reg [79:0] zero [119:0];
    reg [79:0] one [119:0];
    reg [79:0] two [119:0];
    reg [79:0] three [119:0];
    reg [79:0] four [119:0];
    reg [79:0] five [119:0];
    reg [79:0] six [119:0];
    reg [79:0] seven [119:0];
    reg [79:0] eight [119:0];
    reg [79:0] nine [119:0];
    reg [79:0] n [119:0];
    reg [79:0] a [119:0];
    reg [79:0] plus [119:0];
    reg [79:0] minus [119:0];
    reg [79:0] multi [119:0];
    reg [79:0] div [119:0];
    reg [79:0] blank [119:0];
    
    initial begin
        $readmemb("0.data", zero);
        $readmemb("1.data", one);
        $readmemb("2.data", two);
        $readmemb("3.data", three);
        $readmemb("4.data", four);
        $readmemb("5.data", five);
        $readmemb("6.data", six);
        $readmemb("7.data", seven);
        $readmemb("8.data", eight);
        $readmemb("9.data", nine);
        $readmemb("plus.data", plus);
        $readmemb("minus.data", minus);
        $readmemb("multi.data", multi);
        $readmemb("div.data", div);
        $readmemb("n.data", n);
        $readmemb("a.data", a);
        $readmemb("blank.data", blank);
    end

	always @(posedge p_tick) // merge 2 colors with weighted average
	// check x y
        if (y>=40 & y<160) begin
            if (x>=80 & x<160) begin

            end
            else if (x>=160 & x<240) begin
                if (a3==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a3==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a3==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a3==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=240 & x<320) begin
                if (a2==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a2==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a2==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a2==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=320 & x<400) begin
                if (a1==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a1==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a1==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a1==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=400 & x<480) begin
                if (a0==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a0==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a0==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a0==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=480 & x<560) begin
            
            end
            else begin
               rgb_reg[3:0] <= 4'd0;
               rgb_reg[7:4] <= 4'd0;
               rgb_reg[11:8] <= 4'd0; 
            end
        end
        else if (y>=160 & y <320) begin
            if (x>=80 & x<160) begin

            end
            else if (x>=160 & x<240) begin
                if (a3==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a3==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a3==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a3==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=240 & x<320) begin
                if (a2==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a2==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a2==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a2==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=320 & x<400) begin
                if (a1==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a1==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a1==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a1==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=400 & x<480) begin
                if (a0==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a0==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a0==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a0==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=480 & x<560) begin
            
            end
            else begin
               rgb_reg[3:0] <= 4'd0;
               rgb_reg[7:4] <= 4'd0;
               rgb_reg[11:8] <= 4'd0; 
            end        
        end
        else if (y>=360 & y <440) begin
            if (x>=80 & x<160) begin

            end
            else if (x>=160 & x<240) begin
                if (a3==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a3==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a3==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a3==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a3==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a3==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=240 & x<320) begin
                if (a2==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a2==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a2==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a2==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a2==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a2==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=320 & x<400) begin
                if (a1==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a1==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a1==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a1==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a1==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a1==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=400 & x<480) begin
                if (a0==0) begin
                   rgb_reg[3:0] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (zero[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==1) begin
                   rgb_reg[3:0] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (one[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==2) begin
                   rgb_reg[3:0] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (two[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==3) begin
                   rgb_reg[3:0] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (three[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (three[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==4) begin
                   rgb_reg[3:0] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (four[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (four[y][x]>0) ? 4'd1 : 4'd0;                  
                end
                else if (a0==5) begin
                   rgb_reg[3:0] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (five[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (five[y][x]>0) ? 4'd1 : 4'd0;       
                end
                else if (a0==6) begin
                   rgb_reg[3:0] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (six[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (six[y][x]>0) ? 4'd1 : 4'd0;              
                end
                else if (a0==7) begin
                   rgb_reg[3:0] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (seven[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (seven[y][x]>0) ? 4'd1 : 4'd0;  
                end
                else if (a0==8) begin
                   rgb_reg[3:0] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (eight[y][x]>0) ? 4'd1 : 4'd0;
                end
                else if (a0==9) begin
                   rgb_reg[3:0] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[7:4] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                   rgb_reg[11:8] <= (nine[y][x]>0) ? 4'd1 : 4'd0;
                end
            end
            else if (x>=480 & x<560) begin
            
            end
            else begin
               rgb_reg[3:0] <= 4'd0;
               rgb_reg[7:4] <= 4'd0;
               rgb_reg[11:8] <= 4'd0; 
            end        
        end
        else begin
            rgb_reg[3:0] <= 4'd0;
            rgb_reg[7:4] <= 4'd0;
            rgb_reg[11:8] <= 4'd0;
        end
    // output
    assign rgb = (video_on) ? rgb_reg : 12'b0;
endmodule
