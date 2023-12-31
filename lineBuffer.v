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
        if(i_rst | wrPtr == F-1)
            wrPtr <= 'd0;
        else if(i_data_valid)begin
            wrPtr <= wrPtr + 'd1;
        end
    end
    
    assign o_data = rdPtr<=F-3 ? {line[rdPtr], line[rdPtr+1], line[rdPtr+2]} : 
                    rdPtr==F-2 ? {line[rdPtr], line[rdPtr+1], 8'h0} :
                    {line[rdPtr],16'h0};
                    //this is for zero padding, if we want other mathod, we should change this
     // it can be made as sequential by one clk delay but like this comb logic, it can prefatching? what is prefatcing?
    // fifo prefatch, by using comb logic our latency will be zero

    always@(posedge i_clk)begin
        if(i_rst | rdPtr == F-1)
            rdPtr <= 'd0;
        else if(i_rd_data)begin
            rdPtr <= rdPtr + 'd1;
        end
    end

endmodule