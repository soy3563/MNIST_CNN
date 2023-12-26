module lineBuffer #(
    parameter F = 28, // feature
    parameter B = 8 // bit size
)(
    input i_clk,
    input i_rst,
    input [B-1:0] i_data,
    input i_data_valid,
    input i_rd_data,
    output [3*B-1:0] o_data
);
    reg [B-1:0] line [F-1:0];
    reg [$clog2(F)-1:0] wrPtr; // for pixel location pointing, write
    reg [$clog2(F)-1:0] rdPtr; // for pixel location pointing, read

    always@(posedge i_clk)begin
        if(i_data_valid)
            line[wrPtr] <= i_data;
    end
    
    always@(posedge i_clk)begin
        if(i_rst)
            wrPtr <= 'd0;
        else if(i_data_valid)begin
            if(wrPtr == F)
                wrPtr <= 'd0;
            else
                wrPtr <= wrPtr + 'd1;
        end
    end
    
    assign o_data = {line[rdPtr], line[rdPtr+1], line[rdPtr+2]}; // it can be made as sequential by one clk delay but like this comb logic, it can prefatching? what is prefatcing?
    // fifo prefatch, by using comb logic our latency will be zero

    always@(posedge i_clk)begin
        if(i_rst)
            rdPtr <= 'd0;
        else if(i_rd_data)begin
            if(rdPtr == F)
                rdPtr <= 'd0;
            else
                rdPtr <= rdPtr + 'd1;
        end
    end

endmodule