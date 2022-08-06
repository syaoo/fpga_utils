`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.07.2022 15:32:14
// Design Name: 
// Module Name: uart_loop01
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


module uart_loop01#(
        parameter CLK_FREQ = 65_000_000,
        parameter BAUT_RATE = 115200
)(
    // global signals
    input                   CLK,
    input                   RSTn,

    // control & status signals
    output reg [1:0]           LED,

    // data
    input                   UART_RXD,
    output                  UART_TXD
);
    
    wire            sys_clk;
    wire            sys_rst_n;
    wire            cfgmclk;
    wire            eos_n;


    reg [31:0]      led_cnt;
    reg             len_ctrl;
    STARTUPE2 STARTUPE2_inst (
        .CFGMCLK(cfgmclk),     // 1-bit output: Configuration internal oscillator clock output 65MHz.
        .EOS(eos_n)            // 1-bit output: Active high output signal indicating the End Of Startup.
    );
    assign sys_clk = cfgmclk;
    assign sys_rst_n = eos_n;

    //
    // LED 控制
    //
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) begin
            led_cnt <= 32'b0;
        end else begin
            if (led_cnt<CLK_FREQ)
                led_cnt <= led_cnt+1'b1;
            else
                led_cnt <= 0;
        end
    end
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) begin
            len_ctrl <= 1'b1;
        end else begin
            if (led_cnt == CLK_FREQ)
                len_ctrl <= ~len_ctrl;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n)
            LED <= 2'b11;
        else begin
            case (RSTn)
                1'b0: begin
                    if (len_ctrl)
                        LED <= 2'b10;
                    else
                        LED <= 2'b01;
                end
                1'b1: begin
                    if (len_ctrl)
                        LED <= 2'b11;
                    else
                        LED <= 2'b00;
                end
            endcase
        end
    end

    wire                    tx_done;
    wire                    rx_valid;
    reg                     rx_valid0;
    reg                     rx_valid1;

    wire                    send;
    wire [7:0]              rx_dat;
    reg  [7:0]              tx_data;
    reg  [7:0]              data;
    reg                     tx_flag;

    // uart 回环
    transmit #(
        .CLK_FREQ           (CLK_FREQ),
        .BAUT_RATE          (BAUT_RATE)
        )u_tx(
        .clk                (sys_clk            ),
        .rst_n              (sys_rst_n           ),
        .din                (w_dat        ),
        .txd                (UART_TXD       ),
        .tx_flag            (tx_flag        ),
        .done               (tx_done        )
    );
    
    receive #(
        .CLK_FREQ           (CLK_FREQ),
        .BAUT_RATE          (BAUT_RATE)
        )u_rx(
        .clk                (sys_clk            ),
        .rst_n              (sys_rst_n           ),
        .rxd                (UART_RXD       ),
        .rx_data            (rx_dat        ),
        .valid              (rx_valid       )
    );

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) begin
            rx_valid0 <= 0;
            rx_valid1 <= 0;
        end else begin
            rx_valid0 <= rx_valid;
            rx_valid1 <= rx_valid0;
        end
    end

    assign send = rx_valid0 & ~rx_valid1;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) begin
            data <= 0;
        end else begin
            if (rx_valid) begin
                data <= rx_dat;
            end 
        end
    end
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (~sys_rst_n) begin
            tx_data <= 0;
            tx_flag <= 0;
        end else begin
            if (send && tx_done) begin
                tx_data <= data;
                tx_flag <= 1;
            end else begin
                tx_flag <= 0;
            end
        end
    end

endmodule
