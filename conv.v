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
module conv(
    input i_clk,
    input i_rst,
    input [71:0] i_pixel_data,// 24bit(3pixel) for three line
    input i_pixel_data_valid,
    input [71:0] i_weight,
    input [7:0] i_bias,
    output reg [7:0] o_convoled_data,
    output reg o_convoled_valid
    );

    integer i;
    // reg [width] name [depth]
    // reg [7:0] kernel [8:0]; // nine pixel, each pixel represnents 8bit
    reg [15:0] maultData [8:0]; // 8bit * 8bit >> 16 bit width
    reg [15:0] sumData;
    reg [15:0] sumDataInt;
    reg        maultDataValid;
    reg        sumDataValid;
    
    // initial begin
    //     for(i=0;i<9;i=i+1)begin // this is for discript easier, if not use for loop, we have to write kernel[0] = 1; kernel[1] = 1; ....kernel[8] = 1;
    //         kernel[i] = i_weight[i*8+:8];
    //     end
    // end
    
    always@(posedge i_clk)begin
        for(i=0;i<9;i=i+1)begin
            maultData[i] <= i_weight[i*8+:8] * i_pixel_data[i*8+:8]; // kernel[0] * i_pixel_data[7:0] ...... kernel[8] * i_pixel_data[71:64]
        end
        maultDataValid <= i_pixel_data_valid;
    end

    always@(*)begin
        sumDataInt = 0;//sumDataInt <= 0; >> like this, for every next edge of i_clk  sumDataInt will be zero, its updated value appears at next clk
        for(i=0; i<9; i=i+1)begin
            sumDataInt = sumDataInt + maultData[i]; //sumDataInt = sumDataInt + maultData[i] >> like this, sumDataInt is immiedatly changed. so it doesnt be updated by clk cycle
        end
    end
    // mixed <= & = in one always block cant be synthsizeable

    always@(posedge i_clk)begin
        sumData <= sumDataInt;
        sumDataValid <= maultDataValid;
    end

    reg [15:0] addBias;
    always@(*)begin
        addBias <= sumData+{{8{1'b0}},i_bias};
    end

    always@(posedge i_clk)begin
        //o_convloed_data <= addBias[8]==0 ? addBias[7:0] : addBias[8:1];//this will discard fraction part, only takes integer part of dividied val
        o_convoled_data <= addBias[15:8];//take MSB
        o_convoled_valid <= sumDataValid;
    end

endmodule
