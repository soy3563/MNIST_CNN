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
// 28*28*1 > 14*14*16
//////////////////////////////////////////////////////////////////////////////////
module conv_L1#(
    parameter F = 28, // feature
    parameter B = 8, // bit size
    parameter kx = 3, // Kernel_size
    parameter ky = 3, // Kernel_size
    parameter ICH = 1,
    parameter OCH = 16 // ch
)(
    input i_clk,
    input i_rst,
    input [kx*ky*B-1:0] i_pixel_data,// 24bit(3pixel) for three line
    input i_pixel_data_valid,
    input [OCH*kx*ky*B-1:0] i_weight,
    input [OCH*B-1:0] i_bias, 
    output [OCH*B-1:0] o_convloed_data,
    output [OCH-1:0] o_convloed_valid
    );
    
    // weight, bias
    //reg [7:0] bias [15:0];
    wire [B-1:0] convoled_data [OCH-1:0];//idx == channal
    wire [OCH-1:0] convoled_data_valid;

    reg stride; // for stride 2
    always@(posedge i_clk)begin
        if(i_rst)
            stride <= 0;
        else if(i_pixel_data_valid)
            stride <= ~stride;
    end

    genvar i;
    generate
        for(i=0;i<OCH;i=i+1)begin : L1
            conv conv(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_pixel_data(i_pixel_data),
            .i_pixel_data_valid(i_pixel_data_valid & !stride),
            .i_weight(i_weight[i*kx*ky*B+:kx*ky*B]),
            .i_bias(i_bias[i*B+:B]),
            .o_convoled_data(convoled_data[i]),
            .o_convoled_valid(convoled_data_valid[i])
            );
        end
    endgenerate

    //send data for every channel, kx,ky,kch <=> k,k(0~15)set
    assign o_convloed_data = {convoled_data[15],convoled_data[14],convoled_data[13],convoled_data[12],
                              convoled_data[11],convoled_data[10],convoled_data[9],convoled_data[8],
                              convoled_data[7],convoled_data[6],convoled_data[5],convoled_data[4],
                              convoled_data[3],convoled_data[2],convoled_data[1],convoled_data[0]};

    assign o_convloed_valid = convoled_data_valid;

endmodule
