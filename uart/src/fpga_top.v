`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2022 11:10:21
// Design Name: 
// Module Name: fpga_top
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

/*
module fpga_top
#(
    parameter   simPresent  = 0
)(
    // global signals
    input                   CLK,
    input                   RSTn,

    // control &status signals
    input   [7:0]           SW,
    input   [0:0]           KEY,
    output  [7:0]           LED,

    // data
    input                   UART_RXD,
    output                  UART_TXD
);

    wire [7:0]  tx_data;
    wire        tx_flag;
    wire        tx_done;
    wire [7:0]  rx_data;
    
    assign tx_data = SW;
    assign tx_flag = KEY &tx_done;
    assign LED = rx_data;

    uart #( .simPresent(simPresent) ) 
    u_uart
    (
        .CLK        (CLK        ),
        .RSTn       (RSTn       ),
        
        .tx_flag    (tx_flag    ),
        .tx_data    (tx_data    ),
        .tx_done    (tx_done    ),
        
        .rx_data    (rx_data    ),
        .rx_valid   (),
    
        .UART_RXD   (UART_RXD   ),
        .UART_TXD   (UART_TXD   )
    );
endmodule
*/

// `define  AA 32

// `ifdef
// `elseif
// `else
// `endif


module fpga_top#(
        parameter CLK_FREQ = 65_000_000,
        parameter BAUT_RATE = 115200
)(
    // global signals
    input                   CLK,
    input                   RSTn,

    // control & status signals
    output  [1:0]           LED,

    // data
    input                   UART_RXD,
    output                  UART_TXD
);
 
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
    reg  [7:0]  tx_data;
    reg  [7:0]  count;
    reg         tx_en;
    wire        tx_flag;
    wire        tx_done;
    wire [7:0]  rx_data;

    reg  [31:0] led_cnt;
    reg         fled;
    reg  [31:0] hx_cnt0 = 0;
    reg         fhx = 0;
    wire        cfgmclk, eos_n, cfgmclk0;

    // assign cfgmclk = CLK;
    assign cfgmclk = cfgmclk0;

    STARTUPE2 STARTUPE2_inst (
        .CFGMCLK(cfgmclk0),     // 1-bit output: Configuration internal oscillator clock output 65MHz.
        .EOS(eos_n)            // 1-bit output: Active high output signal indicating the End Of Startup.
);

localparam FLASH_COUNT=31'd50_000_000;
reg [3:0] delay;
wire  okey, ovalid;

always @(posedge cfgmclk or negedge eos_n) begin
    if (~eos_n || okey)
        delay <= 0;
    else if(delay<4'b1111) 
        delay <= delay+1'b1;
end
    always @(posedge cfgmclk or negedge eos_n) begin
        if (!eos_n || okey) begin
            tx_data <= 0;
            count <= 0;
            tx_en <= 0;
        end else begin
            if (delay==4'b1111 && count<14 && tx_done &&~tx_en) begin
                tx_data <= dat[count];
                count <= count+1'b1;
                tx_en <= 1;
            end else begin
                tx_en = 0;
            end
        end
    end
    assign tx_flag = tx_done;
    assign LED[0] = fhx;
    assign LED[1] = fled;

    always @(*) begin
        if (~okey) begin
            fled <= 0;
        end else begin
            fled <= 1;
        end
    end

    always @(posedge cfgmclk or negedge eos_n) begin
        if (~eos_n) begin
            hx_cnt0 <= 0;
        end else begin
            if (hx_cnt0 < FLASH_COUNT)
                hx_cnt0 <= hx_cnt0 + 1'b1;
            else
                hx_cnt0 <= 0;
        end
    end
    always @(posedge cfgmclk or negedge eos_n) begin
        if (~eos_n) begin
            fhx <= 1'b0;
        end else begin
            if(hx_cnt0==FLASH_COUNT)
                fhx <= ~fhx;
        end
    end

 debounce  #(
    .CLK_FREQ   (65_000_000),
    .DELAY_TIME (20_000_000)
    )u_de(
    .clk         (cfgmclk),
    .rst_n       (eos_n),
    .ikey        (RSTn),
    .okey        (okey),
    .ovalid      (ovalid)
);

    // uart #(
    //     .CLK_FREQ           (CLK_FREQ),
    //     .BAUT_RATE          (BAUT_RATE)
    //     ) u_uart (
    //     .CLK        (cfgmclk        ),
    //     .RSTn       (eos_n       ),
        
    //     .tx_flag    (tx_en    ),
    //     .tx_data    (tx_data    ),
    //     .tx_done    (tx_done    ),
        
    //     .rx_data    (rx_data    ),
    //     .rx_valid   (),
    
    //     .UART_RXD   (UART_RXD   ),
    //     .UART_TXD   (UART_TXD   )
    // );
uart_send #(
    .CLK_FREQ   (CLK_FREQ),
    .UART_BPS   (BAUT_RATE)
    ) u_send (
    .sys_clk        (cfgmclk),
    .sys_rst_n      (eos_n),
    .uart_en        (tx_en),
    .uart_din       (tx_data),
    .uart_txd       (UART_TXD),
    .uart_tx_busy   ( )
    );
endmodule

