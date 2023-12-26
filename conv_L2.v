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
// 
//////////////////////////////////////////////////////////////////////////////////
module conv_L2#(
    parameter F = 14, // feature
    parameter B = 8, // bit size
    parameter ICH = 16, // ch
    parameter OCH = 32 // ch
)(
    input i_clk,
    input i_rst,
    input [3*3*B-1:0] i_convloed_data,
    input i_convloed_valid,
    input [36863:0] i_weight,// 32*16*9*8(och*ich*#ofWeight*#bits)
    input [255:0] i_bias,
    output [OCH*B-1:0] o_convloed_data,
    output [31:0] o_convloed_valid
    );
    
    // weight, bias
    wire [7:0] convoled_data [31:0];//idx == channal
    wire [31:0] convoled_data_valid;
    reg [143:0] weight [31:0];
    integer a;
    always@(*)begin
        for(a=0;a<32;a=a+1)
            weight[a] = i_weight[1152*a+:1152];
    end

    genvar i,j;
    generate
        for(i=0;i<32;i=i+1)begin :Conv1
            for(j=0;j<16;j=j+1)begin
                conv conv(
                .i_clk(axi_clk),
                .i_pixel_data(i_convloed_data),
                .i_pixel_data_valid(i_convloed_valid),
                .i_weight(weight[i][j*72+:72]),
                .i_bias(i_bias[i*8+:8]),
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
