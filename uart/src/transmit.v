`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2022 10:59:54
// Design Name: 
// Module Name: transmit
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


module transmit #(
    parameter CLK_FREQ = 65_000_000,
    parameter BAUT_RATE = 115200
    )(

    input           clk,
    input           rst_n,
    
    input   [7:0]   din,            // 8-bit数据输入
    input           tx_flag,        // 发送标志
    output          txd,            // UART_TXD
    output          done            // 发送完毕
);
    localparam BPS = CLK_FREQ/BAUT_RATE;    // 波特率因子

    localparam ST_IDLE      = 0;    // 闲置状态
    localparam ST_SYNC      = 1;    // 同步, 等待波特率采样脉冲
    localparam ST_START     = 2;    // 起始位
    localparam ST_DATA      = 3;    // 数据位
    localparam ST_STOP      = 4;    // 停止位

    reg [8:0]       data_shift;     // 移位寄存器
    reg [3:0]       cnt;            // 计数器
    
    reg [3:0]       state;          // 状态机
    reg [3:0]       state_next;
    wire            baud_en;        // 波特率发生器使能
    wire            sample_flag;    // 采样信号
    
    baud_gen #(
        .BPS            (BPS)
        ) u_bdg_t (
        .clk            (clk),
        .rst_n          (rst_n),
        .baud_en        (baud_en),        // 使能
        .baud_pulse     (sample_flag)      // 采样脉冲
    );

    always @(posedge clk, negedge rst_n) begin
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
                // 闲置状态下, 等待tx_flag发送标志信号, 进入同步状态
                ST_IDLE: begin
                    if(tx_flag)
                        state_next = ST_SYNC;
                    else
                        state_next = state;
                end
                // 同步状态下, 等待sample_flag采样标志信号, 进入起始位发送状态
                ST_SYNC: begin
                    if(sample_flag)
                        state_next = ST_START;
                    else
                        state_next = state;
                end
                // 起始位发送状态下, 等待sample_flag采样标志信号, 进入数据位发送状态
                ST_START: begin
                    if(sample_flag)
                        state_next = ST_DATA;
                    else
                        state_next = state;
                end
                // 数据位发送状态下, 等待计数器从0数到7共8-bit发送完毕, 进入停止位发送状态
                ST_DATA: begin
                    if((cnt==7)&sample_flag)
                        state_next = ST_STOP;
                    else
                        state_next = state; 
                end
                // 停止位发送状态下, 等待sample_flag采样标志信号, 结束本次发送, 进入闲置状态
                ST_STOP: begin
                    if(sample_flag)
                        state_next = ST_IDLE;
                    else
                        state_next = state;
                end
                default:            state_next <= ST_IDLE;
            endcase
        end
    end
    
    // 计数器, 在ST_DATA状态下数采样脉冲sample_flag
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            cnt <= 0;
        else if(state!=ST_DATA)
            cnt <= 0;
        else if(sample_flag)
            cnt <= cnt + 1;
    end
    
    // 移位寄存器, 实现并串转换
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            data_shift <= 9'b1_1111_1111;
        else if(state==ST_IDLE)     
            data_shift <= 9'b1_1111_1111;
        else if((state==ST_SYNC)&sample_flag)
            data_shift <= {din, 1'b0};
        else if(sample_flag)        
            data_shift <= {1'b1, data_shift[8:1]};

    end

    assign txd = data_shift[0];
    assign baud_en = (state!=ST_IDLE);  // 只要不在闲置状态, 就令波特率发生器开始工作
    assign done = (state==ST_IDLE);     // 如果处于闲置状态, 表明发送完毕

endmodule