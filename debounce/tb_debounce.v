`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.07.2022 10:28:49
// Design Name: 
// Module Name: tb_debounce
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


module tb_debounce();
 // Inputs
 reg        pb_1;
 reg        clk;
 // Outputs
 wire       pb_out;
 wire       okey, ovalid, okey1;
 wire       okey2, ovalid2;
 reg rst_n;
 // Instantiate the debouncing Verilog code
  debounce2  #(
    .CLK_FREQ   (20),
    .DELAY_TIME (2)
    )u_db2(
    .clk         (clk),
    .rst_n       (rst_n),
    .ikey        (~pb_1),
    .okey        (okey2),
    .ovalid      (ovalid2)
    );

debounce1 #(
    .CLK_FREQ   (20),
    .DELAY_TIME (2)
)u_db1(
    .clk    (clk),
    .rst_n  (rst_n),
    .ikey   (pb_1),
    .okey   (okey1)
);

debounce0 #(10)
 u_db0 (
    .rst_n (rst_n),
    .pb_1(~pb_1), 
    .clk(clk), 
    .pb_out(pb_out)
 );
 debounce  #(
    .CLK_FREQ   (20),
    .DELAY_TIME (2)
    )u_db(
    .clk         (clk),
    .rst_n       (rst_n),
    .ikey        (pb_1),
    .okey        (okey),
    .ovalid      (ovalid)
    );
 initial begin
  clk = 0;
  forever #10 clk = ~clk;
 end
 initial begin
    rst_n = 0;
    #10 
    rst_n = 1;
 end
 initial
begin
    // [Verilog $dumpvars and $dumpfile and](http://www.referencedesigner.com/tutorials/verilog/verilog_62.php)  
    $dumpfile("db.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_debounce);    //保存tb_debounc模块及其中引用的所有子模块内的变量
end
 initial begin
 pb_1 = 0;
  #50
  pb_1 = 0;
  #10;
  pb_1=1;
  #20;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #40;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1; 
  #1000; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #20;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #40;
  pb_1 = 0; 
  #200;
 pb_1 = 0;
  #50
  pb_1 = 0;
  #10;
  pb_1=1;
  #20;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #40;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1; 
  #1000; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #20;
  pb_1 = 0;
  #10;
  pb_1=1;
  #30; 
  pb_1 = 0;
  #10;
  pb_1=1;
  #40;
  pb_1 = 0; 
  #500;
  $finish;
 end 
      
endmodule
