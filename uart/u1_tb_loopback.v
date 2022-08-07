`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.07.2022 16:35:19
// Design Name: 
// Module Name: tb_loopback
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


module tb_loopback();

initial
begin
    // [Verilog $dumpvars and $dumpfile and](http://www.referencedesigner.com/tutorials/verilog/verilog_62.php)  
    $dumpfile("u1_tb_loopback.vcd");        //生成的vcd文件名称
    $dumpvars(0, tb_loopback);    //保存tb_debounc模块及其中引用的所有子模块内的变量
end

wire sys_clk;
wire sys_rst_n;


`ifdef SIM
generate
    if (`SIM==0) begin
        wire clk0;
        wire rst_n0;
        initial $display("Simulation in Vivado");
        STARTUPE2 STARTUPE2_inst (
        .CFGMCLK(clk0),     // 1-bit output: Configuration internal oscillator clock output 65MHz.
        .EOS(rst_n0)            // 1-bit output: Active high output signal indicating the End Of Startup.
        );
        assign sys_clk = clk0;
        assign sys_rst_n =  rst_n0;
    end else begin
        initial begin
            $display("Simulation in iverilog,%m");
        end
        reg clk;
        reg rst_n;
        initial begin
            clk = 0;
            rst_n = 0;
            repeat(2) @(posedge clk);
            rst_n = 1;
        end
        always #10 clk = ~clk;
        
        assign sys_clk = clk;
        assign sys_rst_n =  rst_n;
    end

endgenerate

`endif



reg         uart_en;
reg  [7:0]  uart_din;

wire        uart_tx_busy;
wire        rxd, txd;
parameter CLK_FREQ = 16;
parameter UART_BPS = 1;
reg [8:0]       rid, interval;
reg [7:0] dat[13:0];
    initial begin
        dat[0]  = 8'h48; // H
        dat[1]  = 8'h65; // e
        dat[2]  = 8'h6c; // l
        dat[3]  = 8'h6c; // l
        dat[4]  = 8'h6f; // o
        dat[5]  = 8'h20; //  
        dat[6]  = 8'h57; // W
        dat[7]  = 8'h6f; // o
        dat[8]  = 8'h72; // r
        dat[9]  = 8'h6c; // l
        dat[10] = 8'h64; // d
        dat[11] = 8'h21; // !
        dat[12] = "\n"; //  \n
    end

uart_send #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (UART_BPS)
    ) u_send (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .uart_en        (uart_en),
    .uart_din       (uart_din),
    .uart_txd       (rxd),
    .uart_tx_busy   (uart_tx_busy)
    );

uart_loopback_top #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (UART_BPS)
    )
u_loop (
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .UART_RXD       (rxd),
    .UART_TXD       (txd)
    );

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (~sys_rst_n) begin
        uart_en <=0 ;
        rid <= 0;
        uart_din <= 0;
    end else begin
        if (~uart_tx_busy && rid<12) begin
            uart_en <= 1'b1;
            uart_din <= dat[rid];
            rid <= rid + 1'b1;
            // uart_din <= 8'hff;
        end else begin
            uart_en <= 1'b0;
        end
    end
end
always @(posedge sys_clk) begin
    if (rid==12) $finish;
end
initial begin
    # (20*1000)
    $finish;
end
endmodule
