`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/13 14:42:03
// Design Name: 
// Module Name: imageConv
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
// 14*14*16 > 7*7*32
//////////////////////////////////////////////////////////////////////////////////
module ctrlL2#(
    parameter F = 14, // feature
    parameter B = 8, // bit size
    parameter kx = 3,
    parameter ky = 3,
    parameter ICH = 16, // ch
    parameter OCH = 32 // ch
)(
    input i_clk,
    input i_rst,
    input [ICH*B-1:0] i_pixel_data,
    input [ICH-1:0]i_pixel_data_valid,
    output reg [ICH*kx*ky*B-1:0] o_pixel_data,
    output [ICH-1:0] o_pixel_data_valid,
    output reg [ICH-1:0] o_intr
);
    
    reg [kx*ky*B-1:0] L1_convoled_data [ICH-1:0];
    reg [ICH-1:0] L1_convoled_data_valid;
    reg [ICH-1:0] L1_intr;

    genvar i;
    generate// 이렇게 하면 weight 한 블록에 대한 컨트롤 신호 완성, 이제 이걸 conv_L2에서 32개의 weight 블록에서 쓰도록 가져가면 됨, ctrl 로직은 그냥 line버퍼라고 생각하면 될듯
        for(i=0;i<ICH;i=i+1)begin : ctrlICH
            ctrl#(
            .F(F)) ctrlL2 (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_pixel_data(i_pixel_data[B*i+:B]),
            .i_pixel_data_valid(i_pixel_data_valid[i]),
            .o_pixel_data(L1_convoled_data[i]),
            .o_pixel_data_valid(L1_convoled_data_valid[i]),
            .o_intr(L1_intr[i])
            );
        end// 여기까지 하면 32개의 가중치 블록 중 한군데의 16채널에 대한 4줄이 연산위해 라인 버퍼로 들어가는 컨트롤 로직 구현
    endgenerate

    assign o_pixel_data = {L1_convoled_data[15],L1_convoled_data[14],L1_convoled_data[13],L1_convoled_data[12],
                           L1_convoled_data[11],L1_convoled_data[10],L1_convoled_data[9],L1_convoled_data[8],
                           L1_convoled_data[7],L1_convoled_data[6],L1_convoled_data[5],L1_convoled_data[4],
                           L1_convoled_data[3],L1_convoled_data[2],L1_convoled_data[1],L1_convoled_data[0]};

    assign o_pixel_data_valid = L1_convoled_data_valid;
    assign o_intr = L1_intr;

endmodule
