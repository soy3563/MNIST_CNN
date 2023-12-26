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
// 
//////////////////////////////////////////////////////////////////////////////////
module ctrlL2#(
    parameter F = 28, // feature
    parameter B = 8 // bit size
)(
    input i_clk,
    input i_rst,
    input [B-1:0] i_pixel_data,
    input i_pixel_data_valid,
    input [36863:0] i_weight,
    input [255:0] i_bias,
    output reg [3*3*B-1:0] o_pixel_data,
    output o_pixel_data_valid,
    output reg o_intr
);

    reg [$clog2(F)-1:0] pixelCounter;
    reg [1:0] currentWrLineBuffer;
    reg [3:0] lineBufferdataValid;
    reg [3:0] lineBuffRdData;
    reg [1:0] currentRdLineBuffer;
    wire [3*B-1:0] lb0data;
    wire [3*B-1:0] lb1data;
    wire [3*B-1:0] lb2data;
    wire [3*B-1:0] lb3data;
    reg [$clog2(F)-1:0] rdCounter;
    reg rd_line_buffer;
    reg [$clog2(3*F*B)-1:0] totalPixelCounter;
    reg rdState;

    localparam IDEL = 'b0;
    localparam RD_BUFFER = 'b1;

    assign o_pixel_data_valid = rd_line_buffer;

    always@(posedge i_clk)begin
        if(i_rst)
            totalPixelCounter <= 0;
        else begin
            if(i_pixel_data_valid & !rd_line_buffer)// reading from memory, but not read for conv
                totalPixelCounter <= totalPixelCounter + 1;
            else if(!i_pixel_data_valid & rd_line_buffer)
                totalPixelCounter <= totalPixelCounter - 1;
        end
    end

    always@(posedge i_clk)begin
        if(i_rst)begin
            rdState <= IDEL;
            rd_line_buffer <= 1'b0;
            o_intr <= 1'b0;
        end
        else begin
            case(rdState)
                IDEL : begin
                    if(totalPixelCounter >= 3*F*B) //wait for three line buffer filled
                        rd_line_buffer <= 1'b1;
                        rdState <= RD_BUFFER;
                        o_intr <= 1'b0;
                end
                RD_BUFFER : begin
                    if(rdCounter == $clog2(F)-1)begin // line buffer switched and so we need to wait 3 buffer filled
                        rdState <= IDEL;
                        rd_line_buffer <= 1'b0;
                        o_intr <= 1'b1;
                    end
                end
            endcase
        end
    end



    always@(posedge i_clk)begin
        if(i_rst)
            pixelCounter <= 0;
        else begin
            if(i_pixel_data_valid)
                pixelCounter <= pixelCounter;
        end
    end

    always@(*)begin
        lineBufferdataValid = 4'b0;
        lineBufferdataValid[currentWrLineBuffer] = i_pixel_data_valid; // for this, four bits of linebuffervalud gets high
    end


    always@(posedge i_clk)begin
        if(i_rst)
            currentWrLineBuffer <= 0;
        else begin
            if(pixelCounter == ($clog2(F)-1) & i_pixel_data_valid)
                currentWrLineBuffer <= currentWrLineBuffer + 1;
        end
    end

    always@(*)begin// which line buffer has nessasary data. from here, we have to know where to start read. by using i_rd_data for increasing rd_cnt
        case(currentRdLineBuffer)
            0 : begin
                o_pixel_data = {lb2data,lb1data,lb0data};
            end
            1 : begin
                o_pixel_data = {lb3data,lb2data,lb1data};
            end
            2 : begin
                o_pixel_data = {lb0data,lb3data,lb2data};
            end
            3 : begin
                o_pixel_data = {lb1data,lb0data,lb3data};
            end
        endcase
    end

    always@(*)begin
        case(currentRdLineBuffer)
            0 : begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[2] = rd_line_buffer;
                lineBuffRdData[3] = 1'b0;
            end
            1 : begin
                lineBuffRdData[0] = 1'b0;
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[2] = rd_line_buffer;
                lineBuffRdData[3] = rd_line_buffer;
            end
            2 : begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[1] = 1'b0;
                lineBuffRdData[2] = rd_line_buffer;
                lineBuffRdData[3] = rd_line_buffer;
            end
            3 : begin
                lineBuffRdData[0] = rd_line_buffer;
                lineBuffRdData[1] = rd_line_buffer;
                lineBuffRdData[2] = 1'b0;
                lineBuffRdData[3] = rd_line_buffer;
            end
        endcase
    end

    always@(posedge i_clk)begin
        if(i_rst)
            rdCounter <= 0;
        else begin
            if(rd_line_buffer)
                rdCounter <= rdCounter + 1;
        end
    end

    always@(posedge i_clk)begin
        if(i_rst)
            currentRdLineBuffer <= 0;
        else begin
            if(rdCounter == ($clog2(F)-1) & rd_line_buffer)
                currentRdLineBuffer <= currentRdLineBuffer + 1;
        end
    end

    lineBuffer lB0(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_data_valid(lineBufferdataValid[0]),
        .o_data(lb0data),
        .i_rd_data(lineBuffRdData[0])
    );

    lineBuffer lB1(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_data_valid(lineBufferdataValid[1]),
        .o_data(lb1data),
        .i_rd_data(lineBuffRdData[1])
    );

    lineBuffer lB2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_data_valid(lineBufferdataValid[2]),
        .o_data(lb2data),
        .i_rd_data(lineBuffRdData[2])
    );

    lineBuffer lB3(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_pixel_data),
        .i_data_valid(lineBufferdataValid[3]),
        .o_data(lb3data),
        .i_rd_data(lineBuffRdData[3])
    );

endmodule
