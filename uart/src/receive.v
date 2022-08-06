`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2022 11:05:38
// Design Name: 
// Module Name: receive
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


module receive #(
    parameter CLK_FREQ = 65_000_000,
    parameter BAUT_RATE = 115200
    )(

    input           clk,
    input           rst_n,
    
    input           rxd,            // UART_RXD
    output  [7:0]   rx_data,        // 8-bit数据输出
    output          valid           // 接收完毕,数据有效标志
);

    localparam BPS = CLK_FREQ/BAUT_RATE;    // 波特率因子
    
    localparam ST_IDLE      = 0;    // 闲置状态
    localparam ST_SYNC      = 1;    // 同步,等待波特率采样脉冲
    localparam ST_START     = 2;    // 起始位
    localparam ST_DATA      = 3;    // 数据位
    localparam ST_STOP      = 4;    // 停止位

    reg [7:0]       data_shift;     // 移位寄存器
    reg [3:0]       cnt;            // 计数器
    
    reg [3:0]       state;          // 状态机
    reg [3:0]       state_next;
    
    reg [7:0]       rx_data_r;      
    reg             valid_r;

    wire            baud_en;
    wire            sample_flag;
    
    baud_gen #(
        .BPS            (BPS)
        ) u_bdg_r (
        .clk            (clk),
        .rst_n          (rst_n),
        .baud_en        (baud_en),        // 使能
        .baud_pulse     (sample_flag)      // 采样脉冲
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            state <= ST_IDLE;
        else
            state <= state_next;
    end
    
    always @(*) begin
        if(!rst_n)
            state_next = ST_IDLE;
        else begin
            case(state)
                // 闲置状态下,等待RXD电平拉低,进入同步状态
                ST_IDLE: begin
                    if(!rxd)
                        state_next = ST_SYNC;
                    else
                        state_next = state;
                end
                // 同步状态下,等待sample_flag采样标志信号,进入起始位接收状态
                ST_SYNC: begin
                    if(sample_flag)
                        state_next = ST_START;
                    else
                        state_next = state;
                end
                // 起始位接收状态下,等待sample_flag采样标志信号,进入数据位接收状态
                ST_START: begin
                    if(sample_flag)
                        state_next = ST_DATA;
                    else
                        state_next = state;
                end
                // 数据位接收状态下,等待计数器从0数到7共8-bit接收完毕,进入停止位接收状态
                ST_DATA: begin
                    if((cnt==7)&sample_flag)        
                        state_next = ST_STOP;
                    else
                        state_next = state; 
                end
                // 停止位发送状态下,等待sample_flag采样标志信号,结束本次发送,进入闲置状态
                ST_STOP:    state_next <= ST_IDLE;
                default:    state_next <= ST_IDLE;
            endcase
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 0;
        else if(state!=ST_DATA)
            cnt <= 0;
        else if(sample_flag)
            cnt <= cnt + 1;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            data_shift <= 0;
        else if(state==ST_IDLE)
            data_shift <= 0;
        else if(sample_flag)
            data_shift <= {rxd, data_shift[7:1]};
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            rx_data_r <= 0;
        else if((cnt==7)&sample_flag)
            rx_data_r <= data_shift;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            valid_r <= 0;
        else
            valid_r <= (cnt==7)&sample_flag;
    end
    
    assign baud_en = (state!=ST_IDLE);
    assign rx_data = rx_data_r;
    assign valid = valid_r;

endmodule