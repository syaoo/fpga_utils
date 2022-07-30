// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Debounce
// 
// Author: Step
// 
// Description: Debounce for button with FPGA/CPLD
// 
// Web: www.ecbcamp.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module debounce2 #(
    parameter  CLK_FREQ = 65_000_000,          // 时钟频率
    parameter  DELAY_TIME = 20_000_000             //延迟时间ns
    )(
    input   		clk,			//system clock
    input   		rst_n,			//system reset
    input   		ikey,			//button input
    output  		okey,		//Debounce pulse output
    output	reg		ovalid		//Debounce state output
);

localparam CNT = CLK_FREQ/DELAY_TIME;
initial begin
    $display(CNT);
end
reg  key_rst;  
//Register key_rst, lock ikey to next clk
always @(posedge clk  or  negedge rst_n)
    if (!rst_n) key_rst <= 1'b1;
    else  key_rst <=ikey;
 
//Detect the edge of ikey
wire  key_an = (key_rst==ikey)? 0:1;
 
reg[18:0]  cnt;
//Count the number of clk when a edge of ikey is occured
always @ (posedge clk  or negedge rst_n)
    if (!rst_n) cnt <= 19'd0;
    else if(key_an) cnt <=19'd0;
    else cnt <= cnt + 1'b1;
 
reg  low_sw;
//Lock the status to register low_sw when cnt count to 19'd500000
always @(posedge clk  or  negedge rst_n)
    if (!rst_n)  low_sw <= 1'b1;
	else if (cnt == 10)
        low_sw <= ikey;
 
reg   low_sw_r;
//Register low_sw_r, lock low_sw to next clk
always @ ( posedge clk  or  negedge rst_n )
    if (!rst_n) low_sw_r <= 1'b1;
    else  low_sw_r <= low_sw;
 
wire  okey;
//Detect the negedge of low_sw, generate pulse
assign okey= low_sw_r & ( ~low_sw);
 
//Detect the negedge of low_sw, generate state
always @(posedge clk or negedge rst_n)
	if (!rst_n) ovalid <= 1'b1;
    else if(okey) ovalid <= ~ovalid;
	else ovalid <= ovalid;
 
endmodule