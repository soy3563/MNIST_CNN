`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/13 13:01:32
// Design Name: 
// Module Name: conv
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
// ctrl 1이랑 유사동작, 근데 살짝 달라지는게 체널정리하고
//////////////////////////////////////////////////////////////////////////////////
module conv_L2#(
    parameter F = 14, // feature
    parameter B = 8, // bit size
    parameter kx = 3,
    parameter ky = 3,
    parameter ICH = 16, // ch
    parameter OCH = 32 // ch
)(
    input i_clk,
    input i_rst,
    input [ICH*kx*ky*B-1:0] i_convloed_data,
    input [ICH-1:0] i_convloed_valid,
    input [OCH*ICH*kx*ky*B-1:0] i_weight,// 32*16*9*8(och*ich*#ofWeight(kernel_size)*#bits)
    input [OCH*B-1:0] i_bias,
    output [OCH*B-1:0] o_convloed_data,
    output [OCH-1:0] o_convloed_valid
    );
    
    // weight, bias
    wire [B-1:0] convoled_data [OCH-1:0];//idx == channal
    wire [OCH-1:0] convoled_data_valid;
    reg [ICH*kx*ky*B-1:0] weight [OCH-1:0];
    integer k;
    always@(*)begin
        for(k=0;k<OCH;k=k+1)
            weight[k] = i_weight[ICH*kx*ky*B*k+:ICH*kx*ky*B];
    end

    genvar i,j;
    generate
        for(i=0;i<OCH;i=i+1)begin :Conv1
            for(j=0;j<ICH;j=j+1)begin
                conv conv(
                .i_clk(axi_clk),
                .i_pixel_data(i_convloed_data),
                .i_pixel_data_valid(i_convloed_valid[j]),
                .i_weight(weight[i][j*kx*ky*B+:kx*ky*B]),
                .i_bias(i_bias[i*B+:B]),
                .o_convloed_data(convoled_data[i]),
                .o_convloed_valid(convoled_data_valid[i])
                );
            end
        end
    endgenerate

    assign o_convloed_data = {convoled_data[31],convoled_data[30],convoled_data[29],convoled_data[28],
                              convoled_data[27],convoled_data[26],convoled_data[25],convoled_data[24],
                              convoled_data[23],convoled_data[22],convoled_data[21],convoled_data[20],
                              convoled_data[19],convoled_data[18],convoled_data[17],convoled_data[16],
                              convoled_data[15],convoled_data[14],convoled_data[13],convoled_data[12],
                              convoled_data[11],convoled_data[10],convoled_data[9],convoled_data[8],
                              convoled_data[7],convoled_data[6],convoled_data[5],convoled_data[4],
                              convoled_data[3],convoled_data[2],convoled_data[1],convoled_data[0]};

    assign o_convloed_valid = convoled_data_valid;
endmodule
