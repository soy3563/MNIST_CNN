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
module conv_L1#(
    parameter F = 28, // feature
    parameter B = 8, // bit size
    parameter ICH = 16, // ch
    parameter OCH = 16 // ch
)(
    input i_clk,
    input i_rst,
    input [3*3*B-1:0] i_pixel_data,// 24bit(3pixel) for three line
    input i_pixel_data_valid,
    input [1151:0] i_weight,
    input [127:0] i_bias, 
    output [OCH*B-1:0] o_convloed_data,
    output [OCH-1:0] o_convloed_valid
    );
    
    // weight, bias
    //reg [7:0] bias [15:0];
    wire [7:0] convoled_data [15:0];//idx == channal
    wire [15:0] convoled_data_valid;

    reg inv; // for stride 2
    always@(posedge i_clk)begin
        if(i_rst)
            inv <= 1;
        else
            inv <= ~inv;
    end

    genvar i;
    generate
        for(i=0;i<16;i=i+1)begin : Conv1
            conv conv(
            .i_clk(i_clk),
            .i_pixel_data(i_pixel_data),
            .i_pixel_data_valid(i_pixel_data_valid&inv),
            .i_weight(i_weight[i*72+:72]),
            .i_bias(i_bias[i*8+:8]),
            .o_convloed_data(convoled_data[i]),
            .o_convloed_valid(convoled_data_valid[i])
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
